package heatmap.controler
{
	import flash.net.FileReference;
	
	import heatmap.model.HeatmapProxy;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class ExtractDataFromXmlFileCommand  extends SimpleCommand implements ICommand
	{
		override public function execute(notification:INotification):void
		{
			var proxy:HeatmapProxy = facade.retrieveProxy(HeatmapProxy.NAME) as HeatmapProxy;
			proxy.extractList(notification.getBody() as FileReference);
		}
	}
}