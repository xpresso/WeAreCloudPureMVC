package heatmap.controller
{
	import mx.collections.ArrayCollection; // Flex import.

	import heatmap.model.HeatmapProxy; // Our proxy.

	// PureMVC imports.
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	/**
	 * GeocodeAddressesCommand.
	 *
	 * @extends SimpleCommand
	 * @implements ICommand
	 * @author Florent Odier, Philippe Miguet & Marion Trenza.
	 */
	public class GeocodeAddressesCommand extends SimpleCommand implements ICommand
	{
		/**
		 * Redirect the notification to the proxy.
		 *
		 * @param {INotification} The notification.
		 */
		override public function execute(notification:INotification):void
		{
			var proxy:HeatmapProxy = facade.retrieveProxy(HeatmapProxy.NAME) as HeatmapProxy;
			proxy.geocodeAddresses(notification.getBody()[0] as ArrayCollection,notification.getBody()[1] as Array);
		}
	}
}