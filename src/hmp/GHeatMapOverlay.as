package hmp
{
	import com.google.maps.Map;
	import com.google.maps.MapEvent;
	import com.google.maps.PaneId;

	// Google Maps interfaces.
	import com.google.maps.interfaces.IMap;
	import com.google.maps.interfaces.IPane;

	import com.google.maps.overlays.OverlayBase; // Google Maps base overlay.

	// Michael Vandanicker HeatMap component.
	import michaelvandaniker.visualization.HeatMap;

	import flash.events.Event; // Flash import.
	
	/**
	 * GHeatMapOverlay. A new Google Maps overlay created to display a heatmap on Google Maps.
	 *
	 * @extends OverlayBase
	 * @authors Florent Odier, Philippe Miguet & Marion Trenza.
	 */
	public class GHeatMapOverlay extends OverlayBase
	{
		/**
		 * The Heatmap
		 */
		public var heatMap:HeatMap;

		/**
		 * @onstructor
		 *
		 * @param {HeatMap} heatMap
		 */
		public function GHeatMapOverlay(heatMap:HeatMap)
		{
			super();
			this.heatMap = heatMap;
			// Add the listeners.
			addEventListener(MapEvent.OVERLAY_ADDED, handleOverlayAdded,false,0,true);
			addEventListener(MapEvent.OVERLAY_REMOVED, handleOverlayRemoved,false,0,true);
		}

		/**
		 * Figure out which "pane" to put the overlay on.
		 *
		 * @param {IMap} map
		 * @return {IPane}
		 */
		override public function getDefaultPane(map:IMap):IPane
		{
			return map.getPaneManager().getPaneById(PaneId.PANE_OVERLAYS);
		}

		/**
		 * This method positions the overlay on the map. It is called when the map is zoomed/moved...
		 *
		 * @param {Boolean} zoom
		 */
		override public function positionOverlay(zoom:Boolean):void
		{
			if (zoom)
			{
				heatMap.itemRadius = Math.max(10,Math.pow(pane.map.getZoom(),1.5));
			}

			// Positioned at (0,0) by default.
			heatMap.width = (pane.map as Map).width;
			heatMap.height = (pane.map as Map).height;

			heatMap.invalidateProperties();
		}

		/*
		 * Called when the overlay is added.
		 *
		 * @param {Event} event
		 */
		private function handleOverlayAdded(event:Event):void
		{
			addChild(heatMap);
		}

		/*
		 * Called when the orverlay is removed.
		 *
		 * @param {Event} event
		 */
		private function handleOverlayRemoved(event:Event):void
		{
			removeChild(heatMap);
		}
	}
}