package heatmap.model
{
	import flash.net.FileReference;
	
	import heatmap.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	public class HeatmapProxy extends Proxy implements IProxy
	{
		public static const NAME:String = 'heatmapProxy';
		
		public function selectHandler(fileRef:FileReference):void
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

		/**
		 * Handle complete event.
		 */
		public function completeHandler(fileRef:FileReference):void
		{
			if (fileRef != null)
		    {
		        var externalXML:XML = new XML(fileRef.data);
		        sendNotification(ApplicationFacade.XML_DATA_LOADED, externalXML);
		        //startApp();
		        trace(externalXML.toXMLString());
		    }
		    else
		    {
		        trace("fileRef is null!");
		    }
		}
	}
}