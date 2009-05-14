package heatmap.model
{
	import com.google.maps.LatLng;
	
	import flash.events.Event;
	import flash.net.FileReference;
	
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
			if (fileRef != null)
		    {
				fileRef.cancel();
				fileRef.load();
		    }
		    else
		    {
		        trace("fileRef is null!");
		    }
		}

		public function extractList(fileRef:FileReference):void
		{
			if (fileRef != null)
		    {
		        var externalXML:XML = new XML(fileRef.data);
		        var pointsList:ArrayCollection = new ArrayCollection();
		        var criteriaList:ArrayCollection = new ArrayCollection();
		        var date:String;
		        var libelle:String;
		        
		        for(var i:int = 0; i < externalXML.data.length() ; i++)
		        {
		        	date = externalXML.data.date[i].toString();
		        	libelle = externalXML.data.libelle[i].toString();
		        	
		        	//pointsList.addItem(new HeatmapPoint(data.adresse[i], externalXML.data.intensite[i]));
		        	pointsList.addItem(new HeatmapPoint("10 Avenue Foch", externalXML.data.intensite[i], new LatLng(externalXML.data.lat[i],externalXML.data.long[i]), date, libelle));
		        	//To delete new Latlng(), date and libelle and change adresse;
		        	
		        	if(!isContained(criteriaList, date))
		        		criteriaList.addItem(date);
		        	
		        	if(!isContained(criteriaList, libelle))
		        		criteriaList.addItem(libelle);
		        }
		        sendNotification(ApplicationFacade.DATA_EXTRACTED, [pointsList,criteriaList]);
		    }
		    else
		    {
		        trace("fileRef is null!");
		    }
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