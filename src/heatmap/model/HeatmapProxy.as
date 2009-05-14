package heatmap.model
{
	import com.google.maps.LatLng;
	
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.utils.Dictionary;
	
	import heatmap.ApplicationFacade;
	
	import hmp.HeatmapPoint;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class HeatmapProxy extends Proxy implements IProxy
	{
		public static const NAME:String = 'heatmapProxy';
		
		public function HeatmapProxy(data:Object=null)
		{
			super(NAME, data);
		}
		
		public function loadXmlFile(fileRef:FileReference):void
		{
			fileRef.cancel();
			fileRef.load();
		}

		public function extractList(fileRef:FileReference):void
		{			
	        var XMLFile:XML = new XML(fileRef.data);
	        var pointsList:ArrayCollection = new ArrayCollection();
			
			/* Contruction de la liste des critères */				
			const NB_BAL_TO_IGNORE:int = 3; /* Long - Lat - intensite */
			const NB_BAL_TO_CARE:int = (XMLFile.children()[0] as XML).children().length()-NB_BAL_TO_IGNORE;
			
			var criteriaName:Array = new Array(NB_BAL_TO_CARE);
	    	var criteriaContent:Array = new Array(NB_BAL_TO_CARE);
	    	var criteriaDictionary:Array = new Array(NB_BAL_TO_CARE);
	    	
	    	//TODO Recupérer les bons noms de balises
	    	var str:String = new String((XMLFile.children()[0] as XML).children().toString());
	    	var names:Array = str.match(/<[a-zA-Z]*>/g);
    		
	    	for(var k:int = 0 ; k < NB_BAL_TO_CARE ; k++)
	    	{
	    		criteriaName[k] = (names[k+NB_BAL_TO_IGNORE] as String).substring(1,(names[k+NB_BAL_TO_IGNORE] as String).length-1);
	    		criteriaContent[k] = new ArrayCollection();
	    		criteriaDictionary[k] = new Dictionary();
	    	}
	    	
			var data:XML = new XML();
			var indice:String = new String();
			
	    	for(var i:int = 0; i < XMLFile.data.length() ; i++)
	        {
	        	data = XMLFile.data[i];
	        	
	    		pointsList.addItem(new HeatmapPoint("10 Avenue Foch", data.intensite, new LatLng(data.lat,data.long)));
	        	//TODO delete new Latlng(), date and libelle and change adresse;
	    		for(var j:int=0 ; j < NB_BAL_TO_CARE ; j++)
	    		{
	    			//La valeur de la balise j qui nous interesse
	    			indice = data.children()[j+NB_BAL_TO_IGNORE];
	    			
	    			//Si cette entrée n'existe pas dans le dictionnaire, alors on l'a créée, et on l'ajoute à la liste des valeurs pour cette balise j.
	    			if (criteriaDictionary[j][indice] == null)
	    			{
	    				(criteriaContent[j] as ArrayCollection).addItem(indice);
	    				criteriaDictionary[j][indice] = new ArrayCollection();
	    			}					
					//A cette entrée, on ajoute l'objet que l'on vient de créer.
	    			(criteriaDictionary[j][indice] as ArrayCollection).addItem(pointsList[pointsList.length -1]);
	    		}
	        }
	       sendNotification(ApplicationFacade.DATA_EXTRACTED, [pointsList,[criteriaName, criteriaContent, criteriaDictionary]]);
		}
		
		public function geocodeAddresses(pointsList:ArrayCollection):void
		{
			var geocodedPointsList:ArrayCollection = new ArrayCollection();
			var count:int = 0;
			
			geocodedPointsList.addEventListener(HeatmapPoint.GEOCODEDDATA, 
				function(event:Event):void 
				{
					count++;
					//trace(count +" || "+pointsList.length+" || "+geocodedPointsList.length);
					if ( count == pointsList.length )
						sendNotification(ApplicationFacade.GEOCODING_COMPLETE, geocodedPointsList);
				});
			
			for (var i:int = 0 ; i < pointsList.length ; i++)
			{
				(pointsList[i] as HeatmapPoint).geocodeAddress(geocodedPointsList);
			} 						
		}
		
		public function applyCriteria(array:Array):void
		{
			var pointsSubList:ArrayCollection = new ArrayCollection();
			var pointsList:ArrayCollection = array[0] as ArrayCollection;
			var criteriaList:Array = array[1] as Array;
			
			var found:Boolean = false;
			var i:int = 0, j:int = 0;
			
			for (i ; i < pointsList.length ; i++)
			{
				while(j < criteriaList.length && !found)
				{
					found = (pointsList[i] as HeatmapPoint).date == criteriaList[j].toString()
							|| (pointsList[i] as HeatmapPoint).libelle == criteriaList[j].toString();
					j++;
				}
				if(found)
					pointsSubList.addItem(pointsList[i] as HeatmapPoint);
					
				found = false;
				j=0;
			}
			
			sendNotification(ApplicationFacade.CRITERIA_APPLICATION_COMPLETE, pointsSubList);
		}
		
		private function isContained(array:ArrayCollection, data:String):Boolean
		{
			var found:Boolean = false;
			var i:int = 0;

			while(i < array.length && !found)
			{
				found = array[i].toString() == data;
				i++;
			}
			return found;
		}
	}
}