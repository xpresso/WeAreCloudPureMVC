package heatmap.model
{
	import heatmap.ApplicationFacade;
	
	import hmp.HeatmapPoint;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	import flash.events.Event;	
	import flash.net.FileReference;


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
		        
		        for(var i:int = 0; i < externalXML.data.length() ; i++)
		        {
//		        	pointsList.addItem(new HeatmapPoint("249 Rue Adrien Proby, Montpellier, 34090", 1));
//		        	pointsList.addItem(new HeatmapPoint("28 Chemin des cavaliers, Bernis, 30620", 2));
//		        	pointsList.addItem(new HeatmapPoint("18 Rue des Aigrettes, Roques, 31120", 3));
		        	pointsList.addItem(new HeatmapPoint(externalXML.data.adresse[i], 
		        										externalXML.data.intensite[i]));
		        }
		        sendNotification(ApplicationFacade.DATA_EXTRACTED, pointsList);
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
					trace(count +" || "+pointsList.length+" || "+geocodedPointsList.length);
					if ( count == pointsList.length )
						sendNotification(ApplicationFacade.GEOCODING_COMPLETE, geocodedPointsList);
				});
			
			for (var i:int = 0 ; i < pointsList.length ; i++)
			{
				(pointsList[i] as HeatmapPoint).geocodeAddress(geocodedPointsList);
			} 						
		}
				
	}
}