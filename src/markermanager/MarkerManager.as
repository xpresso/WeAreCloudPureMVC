/*
 * MarkerManager, v1.0
 * Copyright (c) 2007 Google Inc.
 * Author: Doug Ricket and others. Ported to AS3 by Pamela Fox.
 *
 * Extended by Marcus Schiesser.
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0.
 */
package markermanager
{
	import com.google.maps.LatLngBounds;
	import com.google.maps.MapMoveEvent;
	import com.google.maps.LatLng;
	
	import com.google.maps.interfaces.IMap;
	import com.google.maps.interfaces.IProjection;
	
	import com.google.maps.overlays.Marker;

	import flash.geom.Point;

	public class MarkerManager
	{

	// Static constants:
	public static const DEFAULT_TILE_SIZE:Number = 1024;
	public static const DEFAULT_MAX_ZOOM:Number = 17;
	public static const DEFAULT_BORDER_PADDING:Number = 100;
	public static const MERCATOR_ZOOM_LEVEL_ZERO_RANGE:Number = 256;

	private var _map:IMap;
	private var _mapZoom:Number;
	private var _maxZoom:Number;
	private var _projection:IProjection;
	private var _trackMarkers:Boolean;
	private var _swPadding:Point;
	private var _nePadding:Point;
	private var _borderPadding:Number;
	private var _gridWidth:Array;
	private var _grid:Array;
	private var _numMarkers:Array;
	private var _shownBounds:GridBounds;
	private var _shownMarkers:Number;
	private var _tileSize:Number;

	/**
	 * Creates a new MarkerManager that will show/hide markers on a map.
	 *
	 * @constructor
	 * @param {Map} map  The map to manage.
	 * @param {Object} opt_opts  A container for optional arguments:
	 *        {Number} maxZoom  The maximum zoom level for which to create tiles.
	 *        {Number} borderPadding  The width in pixels beyond the map border,
	 *                                where markers should be displayed.
	 *        {Boolean} trackMarkers  Whether or not this manager should track marker movements.
	 */
	public function MarkerManager(map:IMap, opt_opts:Object)
	{
		this._map = map;
		this._mapZoom = map.getZoom();
		this._projection = map.getCurrentMapType().getProjection();

		opt_opts = opt_opts || {};
		this._tileSize = DEFAULT_TILE_SIZE;

		var maxZoom:Number = DEFAULT_MAX_ZOOM;
		if(opt_opts.maxZoom != undefined)
		{
			maxZoom = opt_opts.maxZoom;
		}
		this._maxZoom = maxZoom;

		this._trackMarkers = opt_opts.trackMarkers;

		var padding:Number;
		if (opt_opts.borderPadding)
		{
			padding = opt_opts.borderPadding;
		}
		else
		{
			padding = DEFAULT_BORDER_PADDING;
		}
		// The padding in pixels beyond the viewport, where we will pre-load markers.
		this._swPadding = new Point(-padding, padding);
		this._nePadding = new Point(padding, -padding);
		this._borderPadding = padding;

		this._gridWidth = new Array();

		this._grid = new Array();
		this._grid[maxZoom] = new Array();
		this._numMarkers = new Array();
		this._numMarkers[maxZoom] = 0;

		this._map.addEventListener(MapMoveEvent.MOVE_END, this._onMapMoveEnd);

		this._resetManager();
		this._shownMarkers = 0;

		this._shownBounds = this._getMapGridBounds();
	}

	// NOTE: These two closures provide easy access to the map. They are used as callbacks, not as methods.
	private function _removeOverlay(marker:Marker):void
	{
		this._map.removeOverlay(marker);
		this._shownMarkers--;
	}

	private function _addOverlay(marker:Marker):void
	{
		this.map_.addOverlay(marker);
		this._shownMarkers++;
	}

	/**
	 * Initializes MarkerManager arrays for all zoom levels. Called by constructor and by clearAllMarkers.
	 */
	private function _resetManager():void
	{
		var mapWidth:Number = MERCATOR_ZOOM_LEVEL_ZERO_RANGE;
		for (var zoom:Number = 0; zoom <= this._maxZoom; ++zoom)
		{
			this._grid[zoom] = new Array();
			this._numMarkers[zoom] = 0;
			this._gridWidth[zoom] = Math.ceil(mapWidth/this._tileSize);
			mapWidth <<= 1;
		}
	}

	/**
	 * Removes all currently displayed markers and calls resetManager to clear arrays.
	 */
	public function clearMarkers():void
	{
		this._processAll(this._shownBounds, this._removeOverlay);
		this._resetManager();
	}

	/**
	 * Gets the tile coordinate for a given latlng point.
	 *
	 * @param {LatLng} latlng  The geographical point.
	 * @param {Number} zoom  The zoom level.
	 * @param {GSize} padding  The padding used to shift the pixel coordinate.
	 *
	 * Used for expanding a bounds to include an extra padding of pixels surrounding the bounds.
	 *
	 * @return {GPoint}  The point in tile coordinates.
	 */
	private function _getTilePoint(latlng:LatLng, zoom:Number, padding:Point):Point
	{
		var pixelPoint:Point = this.projection_.fromLatLngToPixel(latlng, zoom);
		return new Point(Math.floor((pixelPoint.x + padding.x) / this._tileSize),
		                 Math.floor((pixelPoint.y + padding.y) / this._tileSize));
	}

	/**
	 * Finds the appropriate place to add the marker to the grid.
	 *
	 * Designed for batch-processing thousands of markers, does not actually add the marker to the map.
	 *
	 * @param {Marker} marker  The marker to add.
	 * @param {Number} minZoom  The minimum zoom for displaying the marker.
	 * @param {Number} maxZoom  The maximum zoom for displaying the marker.
	 */
	private function _addMarkerBatch(marker:Marker, minZoom:Number, maxZoom:Number):void
	{
		var mPoint:LatLng = marker.getLatLng();
		// Tracking markers is expensive.
		// So we do this only if the user explicitly requested it when creating marker manager.
		if (this._trackMarkers)
		{
			marker.addEventListener("changed", this._onMarkerMoved);
		}

		var gridPoint:Point = this._getTilePoint(mPoint, maxZoom, new Point(0, 0));

		for (var zoom:Number = maxZoom; zoom >= minZoom; zoom--)
		{
			var cell:Array = this._getGridCellCreate(gridPoint.x, gridPoint.y, zoom);
			cell.push(marker);

			gridPoint.x = gridPoint.x >> 1;
			gridPoint.y = gridPoint.y >> 1;
		}
	}

	// The next two functions have been added by Marcus Schiesser.

	/**
	 * Calculates the minimum zoom level for marker to be displayed.
	 *
	 * @param {Marker} marker
	 * @return {Number}  The minimum zoom level.
	 */
	private function _calcMinZoomLevel(marker:Marker):Number
	{
		var mPoint:LatLng = marker.getLatLng();

		for (var zoom:Number = 1; zoom<_maxZoom; zoom++)
		{
			var gridPoint:Point = this._getTilePoint(mPoint, zoom, new Point(0, 0));
			var cell:Array = this._getGridCellNoCreate(gridPoint.x, gridPoint.y, zoom);
			if (cell == null)
			{
				return zoom;
			}	
		}
		return _maxZoom;
	}

	/**
	 * Automaticly add a marker at a zoom level so that markers don't overlap.
	 *
	 * @param {Marker} marker
	 * @param {int} zoomLevelAdjust  = 4 by default.
	 */
	public function addMarkerAuto(marker:Marker, zoomLevelAdjust:int = 4):void
	{
		var minZoom:Number = calcMinZoomLevel(marker) - zoomLevelAdjust;
		if (minZoom < 1)
		{
			minZoom = 1;
		}
		addMarker(marker, minZoom, DEFAULT_MAX_ZOOM);
	}

	/**
	 * Returns whether or not the given point is visible in the shown bounds.
	 *
	 * @param {Point} point  A point on a grid.
	 * @return {Boolean}  Whether or not the given point is visible in the currently shown bounds.
	 */
	private function _isGridPointVisible(point:Point):Boolean
	{
		var vertical:Boolean = this._shownBounds.minY <= point.y &&
		                       point.y <= this._shownBounds.maxY;
		var minX:Number = this._shownBounds.minX;
		var horizontal:Boolean = minX <= point.x && point.x <= this.shownBounds_.maxX;
		if (!horizontal && minX < 0)
		{
			// Shifts the negative part of the rectangle.
			// As point.x is always less than grid width, only test shifted minX .. 0 part of the shown bounds.
			var width:Number = this.gridWidth_[this.shownBounds_.z];
			horizontal = minX + width <= point.x && point.x <= width - 1;
		}
		return vertical && horizontal;
	}

	/**
	 * Reacts to a notification from a marker that it has moved to a new location.
	 *
	 * It scans the grid all all zoom levels and moves the marker from the old grid location to a new grid location.
	 *
	 * @param {Marker} marker  The marker that moved.
	 * @param {LatLng} oldLatLng  The old position of the marker.
	 * @param {LatLng} newLatLng  The new position of the marker.
	 */
	private function _onMarkerMoved(marker:Marker, oldLatLng:LatLng, newLatLng:LatLng):void
	{
		// NOTE: We do not know the minimum or maximum zoom the marker was added at.
		// So we start at the absolute maximum.
		// Whenever we successfully remove a marker at a given zoom, we add it at the new grid coordinates.
		var zoom:Number = this._maxZoom;
		var changed:Boolean = false;
		var oldGrid:Point = this._getTilePoint(oldLatLng, zoom, new Point(0, 0));
		var newGrid:Point = this._getTilePoint(newLatLng, zoom, new Point(0, 0));
	
		while (zoom >= 0 && (oldGrid.x != newGrid.x || oldGrid.y != newGrid.y))
		{
	 		var cell:Array = this._getGridCellNoCreate(oldGrid.x, oldGrid.y, zoom);
			if (cell) {
				if (this.removeFromArray(cell, marker))
				{
					this._getGridCellCreate(newGrid.x, newGrid.y, zoom).push(marker);
				}
			}
			// For the current zoom we also need to update the map.
			// Markers that no longer are visible are removed from the map. Those that moved into are added.
	
			// This also lets us keep the count of visible markers up to date.
			if (zoom == this._mapZoom)
			{
				if (this._isGridPointVisible(oldGrid))
				{
					if (!this._isGridPointVisible(newGrid))
					{
						this._removeOverlay(marker);
						changed = true;
					}
				}
				else
				{
					if (this._isGridPointVisible(newGrid))
					{
						this._addOverlay(marker);
						changed = true;
					}
				}
			}
			oldGrid.x = oldGrid.x >> 1;
			oldGrid.y = oldGrid.y >> 1;
			newGrid.x = newGrid.x >> 1;
			newGrid.y = newGrid.y >> 1;
			--zoom;
			}
		if (changed)
		{
			this.notifyListeners_();
		}
	}

	/**
	 * Searches at every zoom level to find grid cell that marker would be in, removes from that array if found.
	 * Also removes marker with removeOverlay if visible.
	 *
	 * @param {GMarker} marker  The marker to delete.
	 */
	public function removeMarker(marker:Marker):void
	{
		var zoom:Number = this._maxZoom;
		var changed:Boolean = false;
		var point:LatLng = marker.getLatLng();
		var grid:Point = this._getTilePoint(point, zoom, new Point(0, 0));
		while (zoom >= 0)
		{
			var cell:Array = this._getGridCellNoCreate(grid.x, grid.y, zoom);

			if (cell)
			{
				this.removeFromArray(cell, marker);
			}
			// Markers that no longer are visible are removed from the map.
			// This lets us keep the count of visible markers up to date.
			if (zoom == this._mapZoom)
			{
				if (this._isGridPointVisible(grid))
				{
					this._removeOverlay(marker);
					changed = true;
				}
			}
			grid.x = grid.x >> 1;
			grid.y = grid.y >> 1;
			--zoom;
		}
		if (changed)
		{
			this._notifyListeners();
		}
	}

	/**
	 * Add many markers at once. Does not actually update the map, just the internal grid.
	 *
	 * @param {Array of Marker} markers  The markers to add.
	 * @param {Number} minZoom  The minimum zoom level to display the markers.
	 * @param {Number} opt_maxZoom  The maximum zoom level to display the markers.
	 */
	public function addMarkers(markers:Array, minZoom:Number, opt_maxZoom:Number = Infinity):void
	{
		var maxZoom:Number = this._getOptMaxZoom(opt_maxZoom);
		for (var i:Number = markers.length - 1; i >= 0; i--)
		{
			this._addMarkerBatch(markers[i], minZoom, maxZoom);
		}

		this._numMarkers[minZoom] += markers.length;
	}

	/**
	 * Returns the value of the optional maximum zoom.
	 * This method is defined so that we have just one place where optional maximum zoom is calculated.
	 *
	 * @param {Number} opt_maxZoom  The optinal maximum zoom.
	 * @return {Number}  The maximum zoom.
	 */
	private function _getOptMaxZoom(opt_maxZoom:Number):Number
	{
		return opt_maxZoom != Infinity ? opt_maxZoom : this._maxZoom;
	}

	/**
	 * Calculates the total number of markers potentially visible at a given zoom level.
	 *
	 * @param {Number} zoom The zoom level to check.
	 * @return {Number}
	 */
	public function getMarkerCount(zoom:Number):Number
	{
		var total:Number = 0;
		for (var z:Number = 0; z <= zoom; z++)
		{
			total += this._numMarkers[z];
		}
		return total;
	}

	/**
	 * Add a single marker to the map.
	 *
	 * @param {Marker} marker  The marker to add.
	 * @param {Number} minZoom  The minimum zoom level to display the marker.
	 * @param {Number} opt_maxZoom  The maximum zoom level to display the marker.
	 */
	public function addMarker(marker:Marker, minZoom:Number, opt_maxZoom:Number):void
	{
		var maxZoom:Number = this._getOptMaxZoom(opt_maxZoom);
		this._addMarkerBatch(marker, minZoom, maxZoom);
		var gridPoint:Point = this._getTilePoint(marker.getLatLng(), this._mapZoom, new Point(0, 0));
		if (this._isGridPointVisible(gridPoint) &&
		    minZoom <= this.shownBounds_.z &&
		    this._shownBounds.z <= maxZoom)
		{
			this._addOverlay(marker);
			this._notifyListeners();
		}
		this._numMarkers[minZoom]++;
	}

	/**
	 * Get a cell in the grid, creating it first if necessary.
	 *
	 * @param {Number} x  The x coordinate of the cell.
	 * @param {Number} y  The y coordinate of the cell.
	 * @param {Number} z  The z coordinate of the cell.
	 * @return {Array}  The cell in the array.
	 */
	private function _getGridCellCreate(x:Number, y:Number, z:Number):Array
	{
		var grid:Array = this._grid[z];
		if (x < 0)
		{
			x += this._gridWidth[z];
		}
		var gridCol:Array = grid[x];
		if (!gridCol)
		{
			gridCol = grid[x] = [];
			return gridCol[y] = [];
		}
		var gridCell:Array = gridCol[y];
		if (!gridCell)
		{
			return gridCol[y] = [];
		}
		return gridCell;
	}

	/**
	 * Get a cell in the grid, returning undefined if it does not exist.
	 *
	 * NOTE: Optimized for speed -- otherwise could combine with _getGridCellCreate.
	 *
	 * @param {Number} x  The x coordinate of the cell.
	 * @param {Number} y  The y coordinate of the cell.
	 * @param {Number} z  The z coordinate of the cell.
	 * @return {Array}  The cell in the array.
	 */
	private function _getGridCellNoCreate(x:Number, y:Number, z:Number):Array
	{
		var grid:Array = this._grid[z];
		if (x < 0)
		{
			x += this._gridWidth[z];
		}
		var gridCol:Array = grid[x];
		return gridCol ? gridCol[y] : undefined;
	}

	/**
	 * Turns at geographical bounds into a grid-space bounds.
	 *
	 * @param {LatLngBounds} bounds  The geographical bounds.
	 * @param {Number} zoom  The zoom level of the bounds.
	 * @param {GSize} swPadding  The padding in pixels to extend beyond the given bounds.
	 * @param {GSize} nePadding  The padding in pixels to extend beyond the given bounds.
	 * @return {GBounds}  The bounds in grid space.
	 */
	private function _getGridBounds(bounds:LatLngBounds, zoom:Number, swPadding:Point, nePadding:Point):GridBounds
	{
		zoom = Math.min(zoom, this._maxZoom);

		var bl:LatLng = bounds.getSouthWest();
		var tr:LatLng = bounds.getNorthEast();
		var sw:Point = this._getTilePoint(bl, zoom, swPadding);
		var ne:Point = this._getTilePoint(tr, zoom, nePadding);
		var gw:Number = this._gridWidth[zoom];

		// Crossing the prime meridian requires correction of bounds.
		if (tr.lng() < bl.lng() || ne.x < sw.x)
		{
			sw.x -= gw;
		}
		if (ne.x - sw.x  + 1 >= gw)
		{
	  		// Computed grid bounds are larger than the world; truncate.
			sw.x = 0;
			ne.x = gw - 1;
		}
		var gridBounds:GridBounds = new GridBounds([sw, ne]);
		gridBounds.z = zoom;
		return gridBounds;
	}

	/**
	 * Gets the grid-space bounds for the current map viewport.
	 *
	 * @return {Bounds}  The bounds in grid space.
	 */
	private function _getMapGridBounds():GridBounds
	{
		return this._getGridBounds(this._map.getLatLngBounds(), this._mapZoom,
		                           this._swPadding, this._nePadding);
	}

	/**
	 * Event listener for map:movend.
	 *
	 * NOTE: Use a timeout so that the user is not blocked from moving the map.
	 */
	private function _onMapMoveEnd(event:MapMoveEvent):void
	{
		this._updateMarkers();
		//this._objectSetTimeout(this, this._updateMarkers, 0);
	}
	
	/**
	 * Refresh forces the marker-manager into a good state.
	 * If never before initialized, shows all the markers.
	 * If previously initialized, removes and re-adds all markers.
	 */
	public function refresh():void
	{
		if (this._shownMarkers > 0)
		{
			this._processAll(this._shownBounds, this._removeOverlay);
		}
		this._processAll(this._shownBounds, this._addOverlay);
		this._notifyListeners();
	}

	/**
	 * After the viewport may have changed, add or remove markers as needed.
	 */
	private function _updateMarkers():void
	{
		this._mapZoom = this._map.getZoom();
		var newBounds:GridBounds = this._getMapGridBounds();

		// If the move does not include new grid sections, we have no work to do:
		if (newBounds.equals(this._shownBounds) && newBounds.z == this._shownBounds.z) {
			return;
		}

		if (newBounds.z != this.shownBounds.z)
		{
			this._processAll(this._shownBounds, this._removeOverlay);
			this._processAll(newBounds, this._addOverlay);
		}
		else
		{
			// Remove markers:
			this._rectangleDiff(this._shownBounds, newBounds, this._removeCellMarkers);
	
			// Add markers:
			this._rectangleDiff(newBounds, this._shownBounds, this._addCellMarkers);
		}
		this._shownBounds = newBounds;
	}

	/**
	 * Process all markers in the bounds provided, using a callback.
	 *
	 * @param {Bounds} bounds  The bounds in grid space.
	 * @param {Function} callback  The function to call for each marker.
	 */
	private function _processAll(bounds:GridBounds, callback:Function):void
	{
		for (var x:int = bounds.minX; x <= bounds.maxX; x++)
		{
			for (var y:int = bounds.minY; y <= bounds.maxY; y++)
			{
				this._processCellMarkers(x, y,  bounds.z, callback);
			}
		}
	}

	/**
	 * Process all markers in the grid cell, using a callback.
	 *
	 * @param {Number} x  The x coordinate of the cell.
	 * @param {Number} y  The y coordinate of the cell.
	 * @param {Number} z  The z coordinate of the cell.
	 * @param {Function} callback  The function to call for each marker.
	 */
	private function _processCellMarkers(x:Number, y:Number, z:Number, callback:Function):void
	{
		var cell:Array = this._getGridCellNoCreate(x, y, z);
		if (cell)
		{
			for (var i:int = cell.length - 1; i >= 0; i--)
			{
				callback(cell[i]);
			}
		}
	}

	/**
	 * Remove all markers in a grid cell.
	 *
	 * @param {Number} x  The x coordinate of the cell.
	 * @param {Number} y  The y coordinate of the cell.
	 * @param {Number} z  The z coordinate of the cell.
	 */
	private function _removeCellMarkers(x:Number, y:Number, z:Number):void
	{
		this._processCellMarkers(x, y, z, this._removeOverlay);
	}

	/**
	 * Add all markers in a grid cell.
	 *
	 * @param {Number} x  The x coordinate of the cell.
	 * @param {Number} y  The y coordinate of the cell.
	 * @param {Number} z  The z coordinate of the cell.
	 */
	private function _addCellMarkers(x:Number, y:Number, z:Number):void
	{
		this._processCellMarkers(x, y, z, this._addOverlay);
	}

	/**
	 * Uses the rectangleDiffCoords function to process all grid cells that are in bounds1 but not bounds2,.
	 * It uses a callback, and the current MarkerManager object as the instance.
	 *
	 * Pass the z parameter to the callback in addition to x and y.
	 *
	 * @param {Bounds} bounds1  The bounds of all points we may process.
	 * @param {Bounds} bounds2  The bounds of points to exclude.
	 * @param {Function} callback  The callback function to call for each grid coordinate (x, y, z).
	 */
	private function _rectangleDiff(bounds1:GridBounds, bounds2:GridBounds, callback:Function):void
	{
		var me:MarkerManager = this;
		this.rectangleDiffCoords(bounds1, bounds2, function(x:Number, y:Number):void
			{
				callback.apply(me, [x, y, bounds1.z]);
			});
	}

	/**
	 * Calls the function for all points in bounds1, not in bounds2.
	 *
	 * @param {Bounds} bounds1  The bounds of all points we may process.
	 * @param {Bounds} bounds2  The bounds of points to exclude.
	 * @param {Function} callback  The callback function to call for each grid coordinate.
	 */
	private function rectangleDiffCoords(bounds1:GridBounds, bounds2:GridBounds, callback:Function):void
	{
		var minX1:Number = bounds1.minX;
		var minY1:Number = bounds1.minY;
		var maxX1:Number = bounds1.maxX;
		var maxY1:Number = bounds1.maxY;
		var minX2:Number = bounds2.minX;
		var minY2:Number = bounds2.minY;
		var maxX2:Number = bounds2.maxX;
		var maxY2:Number = bounds2.maxY;

		var x:int;
		var y:int;

		for (x = minX1; x <= maxX1; x++) // All x in R1
		{
			// All above:
			for (y = minY1; y <= maxY1 && y < minY2; y++) // y in R1 above R2
			{
				callback(x, y);
			}
			// All below:
			for (y = Math.max(maxY2 + 1, minY1); y <= maxY1; y++) // y in R1 below R2
			{
				callback(x, y);
			}
		}

		for (y = Math.max(minY1, minY2); y <= Math.min(maxY1, maxY2); y++) // All y in R2 and in R1
		{
			// Strictly left:
			for (x = Math.min(maxX1 + 1, minX2) - 1; x >= minX1; x--) // x in R1 left of R2
			{
				callback(x, y);
			}
			// Strictly right:
			for (x = Math.max(minX1, maxX2 + 1); <= maxX1; x++) // x in R1 right of R2
			{
				callback(x, y);
			}
		}
	}

	/**
	 * Removes value from array. O(N).
	 *
	 * @param {Array} array  The array to modify.
	 * @param {any} value  The value to remove.
	 * @param {Boolean} opt_notype  Flag to disable type checking in equality.
	 * @return {Number}  The number of instances of value that were removed.
	 */
	private function removeFromArray(array:Array, value:Object, opt_notype:Boolean = false):Number
	{
		var shift:int = 0;
		for (var i:int = 0; i < array.length; ++i)
		{
	 		if (array[i] === value || (opt_notype && array[i] == value))
	 		{
				array.splice(i--, 1);
				shift++;
			}
		}
		return shift;
	}

	}
}