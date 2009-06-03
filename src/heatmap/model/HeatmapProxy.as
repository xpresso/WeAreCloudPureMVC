package heatmap.model
{
	// Flash imports.
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.Dictionary;
	import flash.net.FileReference;

	import heatmap.ApplicationFacade; // The Facade.
	import hmp.HeatmapPoint; // Our data class.

	import mx.collections.ArrayCollection; // Flex import.

	// PureMVC imports.
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	/**
	 * HeatmapProxy. The proxy for PureMVC.
	 *
	 * @extends Proxy
	 * @implements IProxy
	 * @author Florent Odier, Philippe Miguet & Marion Trenza.
	 */
	public class HeatmapProxy extends Proxy implements IProxy
	{
		/**
		 * The proxy name.
		 */
		public static const NAME:String = 'heatmapProxy';
		/**
		 * The number of first tags to ignore in the XML file.
		 */
		public static const NB_BAL_TO_IGNORE:int = 2; // Address & intensity.
		/**
		 * The number of following tags to care in the XML file.
		 */
		public static var NB_BAL_TO_CARE:int;

		/**
		 * @constructor
		 *
		 * @param {Object} data Null by default.
		 */
		public function HeatmapProxy(data:Object=null)
		{
			super(NAME, data);
		}

		/**
		 * Load a XML file.
		 *
		 * @param {FileReference} fileRef The file reference.
		 */
		public function loadXmlFile(fileRef:FileReference):void
		{
			fileRef.cancel();
			fileRef.load();
		}
		/**
		 * Extract datas from a loaded XML file.
		 *
		 * @param {FileReference} fileRef The file reference.
		 */
		public function extractList(fileRef:FileReference):void
		{
			var XMLFile:XML = new XML(fileRef.data);
			var pointsList:ArrayCollection = new ArrayCollection();

			// Contruction of the criteria list.
			NB_BAL_TO_CARE = (XMLFile.children()[0] as XML).children().length()
				- NB_BAL_TO_IGNORE;

			var criteriaNames:Array = new Array(NB_BAL_TO_CARE);
			var criteriaContents:Array = new Array(NB_BAL_TO_CARE);
			var criteriaDictionary:Array = new Array(NB_BAL_TO_CARE);

			// Retrieve all tag names.
			var str:String = new String((XMLFile.children()[0] as XML).children().toString());
			var names:Array = str.match(/<[a-zA-Z]*>/g);

	    	for(var k:int = 0 ; k < NB_BAL_TO_CARE ; k++)
	    	{
				// Retrieve criteria tag names.
	    		criteriaNames[k] = (names[k+NB_BAL_TO_IGNORE] as String).substring(
	    			1,
	    			(names[k+NB_BAL_TO_IGNORE] as String).length - 1);

				// Initialization of lists.
				criteriaContents[k] = new ArrayCollection();
				criteriaDictionary[k] = new Dictionary();
			}

			var currentData:XML = new XML();

			// Construction of the points list.
			for(var i:int = 0; i < XMLFile.data.length(); i++)
			{
				currentData = XMLFile.data[i];

				var criteriaValues:Array = new Array(NB_BAL_TO_CARE);
				
				for(var j:int=0 ; j < NB_BAL_TO_CARE; j++)
				{
					// Retrieve the criterion value for this point.
					criteriaValues[j] = currentData.children()[j + NB_BAL_TO_IGNORE];
				}

				pointsList.addItem(new HeatmapPoint(currentData.adresse, currentData.intensite, criteriaValues));
			}

			sendNotification(ApplicationFacade.DATA_EXTRACTED, [pointsList,
			                                                   [criteriaNames, criteriaContents, criteriaDictionary]]);
		}

		/**
		 * Geocode all addresses from the points list.
		 *
		 * @param {ArrayCollection} pointsList The list of the points.
		 * @param {Array} criteria The set of criteria.
		 */
		public function geocodeAddresses(pointsList:ArrayCollection, criteria:Array):void
		{
			var geocodedPointsList:ArrayCollection = new ArrayCollection();
			var count:int = 0;
			var timer:Timer = new Timer(170);
			var i:int = 0;

			timer.addEventListener(TimerEvent.TIMER, function():void
				{
					if (i == pointsList.length)
					{
						timer.stop();
					}
					else 
					{
						(pointsList[i] as HeatmapPoint).geocodeAddress(geocodedPointsList, criteria);
						i++;
					}
				});

			geocodedPointsList.addEventListener(HeatmapPoint.GEOCODED_DATA, function(event:Event):void 
				{
					count++;

					if (count == pointsList.length)
					{
						sendNotification(ApplicationFacade.GEOCODING_COMPLETE, [geocodedPointsList , criteria]);
					}
				});
			timer.start();
		}
	}
}