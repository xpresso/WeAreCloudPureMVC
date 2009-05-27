package hmp
{
	import com.google.maps.Map;
	import com.google.maps.MapEvent;
	import com.google.maps.PaneId;
	import com.google.maps.interfaces.IMap;
	import com.google.maps.interfaces.IPane;
	import com.google.maps.overlays.OverlayBase;
	import michaelvandaniker.visualization.HeatMap;
	import flash.events.Event;
	
	/**
	 * Allow the superposition of the map created by Google and the Heatmap
	 * @authors Florent, philippe, marion
	 * */
	public class GHeatMapOverlay extends OverlayBase
	{
		/**
		 * The Heatmap
		 */
		public var heatMap:HeatMap;
		
		/**
		 * Constructor
		 * @param heatMap the heatmap
		 */
		public function GHeatMapOverlay(heatMap:HeatMap)
		{
			super();
			this.heatMap = heatMap;
			//add the listeners
			addEventListener(MapEvent.OVERLAY_ADDED, handleOverlayAdded,false,0,true);
			addEventListener(MapEvent.OVERLAY_REMOVED, handleOverlayRemoved,false,0,true);
		}
		
		
		/**
		 * 
		 * Overrides
		 * 
		 */
		
		/**
		 * figure out which "pane" to put the overlay on
		 */ 
		override public function getDefaultPane(map:IMap):IPane
		{
			return map.getPaneManager().getPaneById(PaneId.PANE_OVERLAYS);
		}
		
		/**
		 * This method positions the overlay on the map. It is called when the map is zoomed/moved...
		 */
		override public function positionOverlay(zoom:Boolean):void
		{
			if (zoom)
			{
				//heatMap.itemRadius = Math.max(6, Math.pow( pane.map.getZoom(),1.5));
				heatMap.itemRadius = Math.max(10,Math.pow(pane.map.getZoom(),1.5));
			}
			
			// positioned at (0,0) by default
			heatMap.width = (pane.map as Map).width;
			heatMap.height = (pane.map as Map).height;
			
			heatMap.invalidateProperties();
		}
		
		
		
		
		/**
		 * 
		 * Event handlers
		 * 
		 */
		
		
		/**
		 * Called when the overlay is added
		 */
		private function handleOverlayAdded(event:Event):void
		{
			addChild(heatMap);
		}
		
		/**
		 * Called when the orverlay is removed
		 */
		private function handleOverlayRemoved(event:Event):void
		{
			removeChild(heatMap);
		}
	}
}