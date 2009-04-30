package heatmap.model
{
	import flash.net.FileReference;
	
	import heatmap.ApplicationFacade;
	
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
		        
		        for(var i:int = 0; i < this.externalXML.data.length() ; i++)
		        {
		        	
		        }
		    }
		    else
		    {
		        trace("fileRef is null!");
		    }
		}
	}
}