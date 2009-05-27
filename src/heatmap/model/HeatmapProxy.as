package heatmap.model
{
		
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.FileReference;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import heatmap.ApplicationFacade;
	import hmp.HeatmapPoint;
	import mx.collections.ArrayCollection;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	/**
	 * The Proxy
	 */
	public class HeatmapProxy extends Proxy implements IProxy
	{
		/**
		 * The name of the proxy
		 */
		public static const NAME:String = 'heatmapProxy';
		public static const NB_BAL_TO_IGNORE:int = 2; /* Adresse & intensite */
		public static var NB_BAL_TO_CARE:int;
		
		/**
		 * Constructor
		 */
		public function HeatmapProxy(data:Object=null)
		{
			super(NAME, data);
		}
		
		/**
		 * Load the XML file
		 * @param fileRef  The reference of the file
		 */
		public function loadXmlFile(fileRef:FileReference):void
		{
			fileRef.cancel();
			fileRef.load();
		}

		public function extractList(fileRef:FileReference):void
		{			
	        var XMLFile:XML = new XML(fileRef.data);
	        var pointsList:ArrayCollection = new ArrayCollection();

			/* Contruction of the criteria list */			
			NB_BAL_TO_CARE = (XMLFile.children()[0] as XML).children().length()-NB_BAL_TO_IGNORE;
			
			var criteriaName:Array = new Array(NB_BAL_TO_CARE);
	    	var criteriaContent:Array = new Array(NB_BAL_TO_CARE);
	    	var criteriaDictionary:Array = new Array(NB_BAL_TO_CARE);
	    	
	    	//Retrieve all tags' name
	    	var str:String = new String((XMLFile.children()[0] as XML).children().toString());
	    	var names:Array = str.match(/<[a-zA-Z]*>/g);
    		
	    	for(var k:int = 0 ; k < NB_BAL_TO_CARE ; k++)
	    	{
	    		//Retrieve criteria tags' name
	    		criteriaName[k] = (names[k+NB_BAL_TO_IGNORE] as String).substring(1,(names[k+NB_BAL_TO_IGNORE] as String).length-1);
	    		
	    		/* Initialization of the lists */
	    		criteriaContent[k] = new ArrayCollection();
	    		criteriaDictionary[k] = new Dictionary();
	    	}
	    	
			var currentData:XML = new XML();
						
			/* Construction of the points list */
	    	for(var i:int = 0; i < XMLFile.data.length() ; i++)
	        {
	        	currentData = XMLFile.data[i];

				var criteriaValue:Array = new Array(NB_BAL_TO_CARE);
				
				for(var j:int=0 ; j < NB_BAL_TO_CARE ; j++)
	    			//Retrieve criteria value for this point
	    			criteriaValue[j] = currentData.children()[j+NB_BAL_TO_IGNORE];
	    		
	    		pointsList.addItem(new HeatmapPoint(currentData.adresse, currentData.intensite, criteriaValue));
	        }
	        
	        sendNotification(ApplicationFacade.DATA_EXTRACTED, [pointsList,[criteriaName, criteriaContent, criteriaDictionary]]);
		}
		
		/**
		 * Geocode all the addresses of the list
		 * @param pointsList The list of the points
		 * @param criteria   The set of criteria
		 */
		public function geocodeAddresses(pointsList:ArrayCollection, criteria:Array):void
		{
			var geocodedPointsList:ArrayCollection = new ArrayCollection();
			var count:int = 0;
			var timer:Timer = new Timer(170);
			var i:int = 0;
			
			timer.addEventListener(TimerEvent.TIMER, 
				function():void
				{
					if ( i == pointsList.length ) 
					{timer.stop();}
					else 
					{ 	(pointsList[i] as HeatmapPoint).geocodeAddress(geocodedPointsList, criteria);
						i++;
					}
				});
				
			geocodedPointsList.addEventListener(HeatmapPoint.GEOCODED_DATA, 
				function(event:Event):void 
				{
					count++;
					
					if ( count == pointsList.length )
						sendNotification(ApplicationFacade.GEOCODING_COMPLETE, [geocodedPointsList , criteria]);
					
				});	
			
			timer.start();					
		}
	}
}