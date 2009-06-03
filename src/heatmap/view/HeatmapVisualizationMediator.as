package heatmap.view
{
	import heatmap.ApplicationFacade;
	import heatmap.view.components.HeatmapVisualization;
	import heatmap.view.events.DocEvent;

	import com.google.maps.overlays.Marker;

	// Flex imports.
	import mx.collections.ArrayCollection;
	import mx.managers.PopUpManager;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	/**
	 * The mediator.
	 *
	 * @extends Mediator
	 * @implements IMediator
	 * @author Florent Odier, Philippe Miguet & Marion Trenza.
	 */
	public class HeatmapVisualizationMediator extends Mediator implements IMediator
	{
		/**
		 * Mediator name
		 */
		public static const NAME:String = 'heatmapVisualizationMediator';

		/**
		 * @constructor
		 *
		 * @param {Object} viewComponent
		 */
		public function HeatmapVisualizationMediator(viewComponent:Object)
		{
			super(NAME, viewComponent);
			heatmapVisualization.addEventListener(HeatmapVisualization.LOAD_XML_DATA, _onLoadXMLData);
			heatmapVisualization.addEventListener(HeatmapVisualization.EXTRACT_DATA_FROM_XML_FILE, _onExtractDataFromXMLFile);
			heatmapVisualization.addEventListener(HeatmapVisualization.APPLY_CRITERION, _onApplyCriterion);
		}

		/**
		 * Get the viewComponant as a HeatmapVisualization.
		 *
		 * return {HeatmapVisualization}
		 */
		public function get heatmapVisualization():HeatmapVisualization
		{
			return viewComponent as HeatmapVisualization;
		}

		/**
		 * Return an array which contains the notifications that interest it.
		 *
		 * @return {Array}
		 */
		override public function listNotificationInterests():Array
		{
			return [ApplicationFacade.DATA_EXTRACTED, ApplicationFacade.GEOCODING_COMPLETE];
		}

		/**
		 * Handle the notification.
		 *
		 * @param {INotification} notification
		 */
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case ApplicationFacade.DATA_EXTRACTED:
					(this.viewComponent as HeatmapVisualization).window.progressBar.label = "Geocoding addresses";
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
						var marker:Marker = (this.viewComponent as HeatmapVisualization).pointsList[i].marker;

						// Add each marker to the map.
						(this.viewComponent as HeatmapVisualization).markerManager.addMarkerAuto(pointsList[i].marker);
					}
					this.viewComponent.enableButtons();
					PopUpManager.removePopUp((this.viewComponent as HeatmapVisualization).window);
					break;
			}
		}

		/*
		 * Send LOAD_XML_DATA notification.
		 */
		private function _onLoadXMLData(event:DocEvent):void
		{
			sendNotification(ApplicationFacade.LOAD_XML_DATA, event.body);
		}

		/*
		 * Send EXTRACT_DATA_FROM_XML_FILE notification.
		 */
		private function _onExtractDataFromXMLFile(event:DocEvent):void
		{
			sendNotification(ApplicationFacade.EXTRACT_DATA_FROM_XML_FILE, event.body);
		}

		/*
		 * Send APPLY_CRITERIA notification.
		 */
		private function _onApplyCriterion(event:DocEvent):void
		{
			sendNotification(ApplicationFacade.APPLY_CRITERION, event.body);
		}
	}
}