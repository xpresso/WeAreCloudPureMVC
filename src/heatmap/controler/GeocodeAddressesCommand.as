package heatmap.controler
{	
	import mx.collections.ArrayCollection;
		
	import heatmap.model.HeatmapProxy;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class GeocodeAddressesCommand extends SimpleCommand implements ICommand
	{
		override public function execute(notification:INotification):void
		{
			var proxy:HeatmapProxy = facade.retrieveProxy(HeatmapProxy.NAME) as HeatmapProxy;
			proxy.geocodeAddresses(notification.getBody()[0] as ArrayCollection,notification.getBody()[1] as Array);
		}

	}
}