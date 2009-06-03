package heatmap
{
	import heatmap.controller.LoadXMLDataCommand; // Controller command.
//	import heatmap.controller.ExtractDataFromXMLFileCommand;
//	import heatmap.controller.GeocodeAddressesCommand;
	import heatmap.controller.startup.ApplicationStartupCommand;

	// PureMVC imports.
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;

	/**
	 * Application Facade. The facade for PureMVC.
	 *
	 * @extends Facade
	 * @implements IFacade
	 * @author Florent Odier, Philippe Miguet & Marion Trenza.
	 */
	public class ApplicationFacade extends Facade implements IFacade
	{
		/**
		 * Facade name.
		 */
		public static const NAME:String                               = 'heatmap';

		/**
		 * STARTUP notification. Sent to launch the application.
		 */
		public static const STARTUP:String 							  = 'startup';
		/**
		 * LOAD_XML_DATA notification. Sent to load datas.
		 */
		public static const LOAD_XML_DATA:String                      = 'loadXMLData';
		/**
		 * EXTRACT_DATA_FROM_XML_FILE notification. Sent to extract datas.
		 */
		public static const EXTRACT_DATA_FROM_XML_FILE:String         = 'extractDataFromXMLFile';
		/**
		 * DATA_EXTRACTED notification. Sent to notify that datas are extracted.
		 */
		public static const DATA_EXTRACTED:String                     = 'dataExtracted';
		/**
		 * GEOCODE_ADDRESSES notification. Sent to geocode addresses.
		 */
		public static const GEOCODE_ADDRESSES:String                  = 'geocodeAdresses';
		/**
		 * GEOCODING_COMPLETE notification. Sent to notifiy that the geocoding is finished.
		 */
		public static const GEOCODING_COMPLETE:String                 = 'geocodingComplete';
		/**
		 * APPLY_CRITERION notification. Sent to filter the heatmap with new critiria.
		 */
		public static const APPLY_CRITERION:String                     = 'applyCriterion';
		/**
		 * CRITERION_APPLICATION_COMPLETE notification. Sent to notify that the criterion is applied.
		 */
		public static const CRITERION_APPLICATION_COMPLETE:String      = 'criteriaApplicationComplete';

		/**
		 * @constructor
		 *
		 * @param {String} key
		 */
		public function ApplicationFacade(key:String)
		{
			super(key);
		}

		/**
		 * Our application.
		 */
		public var application:Heatmap;
 
		/**
		 * Get the singleton ApplicationFacade.
		 *
		 * @param {String} key
		 * @return {ApplicationFacade}
		 */
		public static function getInstance(key:String):ApplicationFacade
		{
			if(instanceMap[key] == null)
			{
				instanceMap[key] = new ApplicationFacade(key);
			}
			return instanceMap[key] as ApplicationFacade;
		}

		/*
		 * Register commands to the Controller.
		 */
		override protected function initializeController():void
		{
			super.initializeController();
			registerCommand(STARTUP, heatmap.controller.startup.ApplicationStartupCommand);
			registerCommand(LOAD_XML_DATA, heatmap.controller.LoadXMLDataCommand);
			registerCommand(EXTRACT_DATA_FROM_XML_FILE, heatmap.controller.ExtractDataFromXMLFileCommand);
			registerCommand(GEOCODE_ADDRESSES, heatmap.controller.GeocodeAddressesCommand);
		}

		/**
		 * Start the application.
		 *
		 * @param {Heatmap} app Refer to the application component.
		 */
		public function startup(app:Heatmap):void
		{
			sendNotification(STARTUP, app);
		}
	}
}