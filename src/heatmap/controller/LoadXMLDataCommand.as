package heatmap.controller
{
	import flash.net.FileReference; // Flash import.

	import heatmap.model.HeatmapProxy; // Our proxy.

	// PureMVC imports.
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	/**
	 * LoadXMLDataCommand.
	 *
	 * @extends SimpleCommand
	 * @implements ICommand
	 * @author Florent Odier, Philippe Miguet & Marion Trenza.
	 */	
	public class LoadXMLDataCommand extends SimpleCommand implements ICommand
	{
		/**
		 * Redirect the notification to the proxy.
		 *
		 * @param {INotification} The notification.
		 */
		override public function execute(notification:INotification):void
		{
			var proxy:HeatmapProxy = facade.retrieveProxy(HeatmapProxy.NAME) as HeatmapProxy;
			proxy.loadXmlFile(notification.getBody() as FileReference);
		}
	}
}