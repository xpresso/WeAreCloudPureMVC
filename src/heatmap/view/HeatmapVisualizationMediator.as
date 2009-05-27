package heatmap.view
{
	import com.google.maps.overlays.Marker;
	
	import heatmap.ApplicationFacade;
	import heatmap.view.components.HeatmapVisualization;
	import heatmap.view.events.DocEvent;
	
	import mx.collections.ArrayCollection;
	import mx.managers.PopUpManager;
	
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
			heatmapVisualization.addEventListener(HeatmapVisualization.APPLY_CRITERIA, onApplyCriteria);
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
					(this.viewComponent as HeatmapVisualization)._window.progressBar.label = "Geocoding addresses";
					sendNotification(ApplicationFacade.GEOCODE_ADDRESSES, notification.getBody() as Array);
				break;
				
				case ApplicationFacade.GEOCODING_COMPLETE:
					var pointsList:ArrayCollection = notification.getBody()[0] as ArrayCollection;
					var criteria:Array = notification.getBody()[1] as Array;									
					
					(this.viewComponent as HeatmapVisualization).criteria = criteria;
					(this.viewComponent as HeatmapVisualization).criteriaListComponent.dataProvider = criteria[0];
					
					(this.viewComponent as HeatmapVisualization).pointsList = pointsList;
					(this.viewComponent as HeatmapVisualization).Heatmap.dataProvider = pointsList;

					// Add a marker for each point.
					for(var i:int = 0; i < pointsList.length; i++)
					{
						var marker:Marker = new Marker(
							(this.viewComponent as HeatmapVisualization).Heatmap.dataProvider[i].latLng);

						// Add each marker to the pointsList.
						(this.viewComponent as HeatmapVisualization).pointsList[i].marker = marker;
						// And to the map.
						(this.viewComponent as HeatmapVisualization).markerManager.addMarkerAuto(pointsList[i].marker);
					}
					this.viewComponent.activeButtons();
					PopUpManager.removePopUp((this.viewComponent as HeatmapVisualization)._window);
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
		
		private function onApplyCriteria(event:DocEvent):void
		{
			sendNotification(ApplicationFacade.APPLY_CRITERIA, event.body);
		}
	}
}