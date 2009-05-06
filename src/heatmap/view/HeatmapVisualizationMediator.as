package heatmap.view
{
	import com.google.maps.overlays.Marker;
	
	import heatmap.ApplicationFacade;
	import heatmap.view.components.HeatmapVisualization;
	import heatmap.view.events.DocEvent;
	
	import hmp.HeatmapPoint;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class HeatmapVisualizationMediator extends Mediator implements IMediator
	{
		public static const NAME:String = 'heatmapVisualizationMediator';
		
		public function HeatmapVisualizationMediator(viewComponent:Object)
		{
			super(NAME, viewComponent);
			heatmapVisualization.addEventListener(HeatmapVisualization.LOAD_XML_DATA, onLoadXmlData);
			heatmapVisualization.addEventListener(HeatmapVisualization.EXTRACT_DATA_FROM_XML_FILE, onExtractDataFromXmlFile);
		}
		
		public function get heatmapVisualization():HeatmapVisualization
		{
			return viewComponent as HeatmapVisualization;
		}
						
		override public function listNotificationInterests():Array
		{
			return [ApplicationFacade.DATA_EXTRACTED, ApplicationFacade.GEOCODING_COMPLETE];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case ApplicationFacade.DATA_EXTRACTED:
					var pointsListToGeocode:ArrayCollection = notification.getBody() as ArrayCollection;					
					sendNotification(ApplicationFacade.GEOCODE_ADDRESSES, pointsListToGeocode);
				break;
				
				case ApplicationFacade.GEOCODING_COMPLETE:
					var pointsList:ArrayCollection = notification.getBody() as ArrayCollection;
					trace("Geocoding notification handled: "+pointsList.length);
					(this.viewComponent as HeatmapVisualization).Heatmap.dataProvider = pointsList;

					/* Add a marker for each point.. */
					for(var i:int = 0; i < pointsList.length; i++)
					{
						var marker:Marker = new Marker((this.viewComponent as HeatmapVisualization).Heatmap.dataProvider[i].latLng);
						marker.visible = false;
						/* ..to the points list, */
						(this.viewComponent as HeatmapVisualization).Heatmap.dataProvider[i].setMarker(marker);
						/* and to the map. */
						(this.viewComponent as HeatmapVisualization).map.addOverlay(marker);
					}
				break;
			}
		}
		
		private function onLoadXmlData(event:DocEvent):void
		{
			sendNotification(ApplicationFacade.LOAD_XML_DATA, event.body);
		}
		

		private function onExtractDataFromXmlFile(event:DocEvent):void
		{
			sendNotification(ApplicationFacade.EXTRACT_DATA_FROM_XML_FILE, event.body);
		}
	}
}