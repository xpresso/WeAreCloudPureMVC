package heatmap.view
{
	import heatmap.ApplicationFacade;
	import heatmap.view.components.HeatmapVisualization;
	import heatmap.view.events.DocEvent;
	
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
		}
		
		public function get heatmapVisualization():HeatmapVisualization
		{
			return viewComponent as HeatmapVisualization;
		}
						
		override public function listNotificationInterests():Array
		{
			return [ApplicationFacade.XML_DATA_LOADED];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case ApplicationFacade.XML_DATA_LOADED:
				
				
				break;
			}
		}
		
		private function onLoadXmlData(event:DocEvent):void
		{
			sendNotification(ApplicationFacade.LOAD_XML_DATA, event.body);
		}
	}
}