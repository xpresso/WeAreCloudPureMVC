/*
 * Typo changed from original MarkerManager to fit our project.
 */
package markermanager
{
	import flash.geom.Point;

	/**
	 * GridBounds.
	 *
	 * @author Pamela Fox & Florent Odier.
	 */
	public class GridBounds
	{
		private var _z:Number;
		private var _minX:Number;
		private var _minY:Number;
		private var _maxX:Number;
		private var _maxY:Number;


		/**
		 * A Bounds is defined by minimum and maximum X and Y coordinates on a plane.
		 *
		 * @constructor
		 *
		 * @param {Array.<Point>} opt_points Points which this Bound must contain.
		 */
		// TODO: Mettre les autres Array ainsi.
		public function GridBounds(opt_points:Array):void
		{
			_minX = Infinity;
			_minY = Infinity;
			_maxX = -Infinity;
			_maxY = -Infinity;
			if(opt_points && opt_points.length)
			{
				for(var i:Number = 0; i < opt_points.length; i++)
				{
					extend(opt_points[i]);
				}
			}
		}
	
		/**
		 * Get z.
		 *
		 * @return {Number}
		 */
		public function get z():Number
		{
			return _z;
		}
		/**
		 * Set z.
		 *
		 * @param {Number}
		 */
		public function set z(z:Number):void
		{
			_z = z;
		}

		/**
		 * Get minX.
		 *
		 * @return {Number}
		 */
		public function get minX():Number
		{
			return _minX;
		}

		/**
		 * Get minY.
		 *
		 * @return {Number}
		 */
		public function get minY():Number
		{
			return _minY;
		}

		/**
		 * Get maxX.
		 *
		 * @return {Number}
		 */
		public function get maxX():Number
		{
			return _maxX;
		}

		/**
		 * Get maxY.
		 *
		 * @return {Number}
		 */
		public function get maxY():Number
		{
			return _maxY;
		}

		/**
		 * Get the minimum x and y in this bound.
		 *
		 * @return {Point}
		 */
		public function min():Point
		{
			return new Point(_minX, _minY);
		}

		/**
		 * Get the maximum x and y in this bound.
		 *
		 * @return {Point}
		 */
		public function max():Point
		{
			return new Point(_maxX, _maxY);
		}

		/**
		 * Get the size of this bounds.
		 *
		 * @return {Point}
		 */
		public function getSize():Point
		{
			return new Point(_maxX - _minX, _maxY - _minY);
		}

		/**
		 * Get the midpoint x and y in this bound.
		 *
		 * @return {Point}
		 */
		public function mid():Point
		{
			return new Point((_minX + _maxX) / 2, (_minY + _maxY) / 2);
		}

		/**
		 * Returns a description of the bound.
		 *
		 * @returns {string}
		 */
		public function toString():String
		{
		  return "(" + min() + ", " + max() + ")";
		}

		/**
		 * Test for empty bounds.
		 *
		 * @return {Boolean}
		 */
		public function isEmpty():Boolean
		{
			return _minX > _maxX || _minY > _maxY;
		}

		/**
		 * Returns true if this bounds (inclusively) contains the given bounds.
		 *
		 * @param {Bounds} inner Inner Bounds.
		 *
		 * @return {boolean}
		 */
		public function containsBounds(inner:GridBounds):Boolean
		{
			var outer:GridBounds = this;
			return outer._minX <= inner._minX &&
			       outer._maxX >= inner._maxX &&
			       outer._minY <= inner._minY &&
			       outer._maxY >= inner._maxY;
		}

		/**
		 * Returns true if this bounds (inclusively) contains the given point.
		 *
		 * @param {Point} point The point to test.
		 *
		 * @return {boolean}
		 */
		public function containsPoint(point:Point):Boolean
		{
			var outer:GridBounds = this;
			return outer._minX <= point.x &&
			       outer._maxX >= point.x &&
			       outer._minY <= point.y &&
			       outer._maxY >= point.y;
		}

		/**
		 * Extends this bounds to contain the given point.
		 *
		 * @param {Point} point Additional point.
		 */
		public function extend(point:Point):void
		{
			if(isEmpty())
			{
				_minX = _maxX = point.x;
				_minY = _maxY = point.y;
			}
			else
			{
				_minX = Math.min(_minX, point.x);
				_maxX = Math.max(_maxX, point.x);
				_minY = Math.min(_minY, point.y);
				_maxY = Math.max(_maxY, point.y);
			}
		}

		/**
		 * Compare this bounds to another.
		 *
		 * @param {Bounds} bounds The bounds to test against.
		 * @return {boolean}
		 */
		public function equals(bounds:GridBounds):Boolean
		{
			return _minX == bounds._minX &&
			       _minY == bounds._minY &&
			       _maxX == bounds._maxX &&
			       _maxY == bounds._maxY;
		}

	}
}