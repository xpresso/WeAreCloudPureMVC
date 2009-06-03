package heatmap.view.events
{
	import flash.events.Event;

	/**
	 * DocEvent. An event which contains a body.
	 *
	 * @extends Event
	 * @author Florent Odier, Philippe Miguet & Marion Trenza.
	 */
	public class DocEvent extends Event
	{
		public var body:Object;

		/**
		 * @constructor
		 *
		 * @param {String} type The event name.
		 * @param {Object} body The optional event body.
		 * @param {Boolean} bubbles True by default.
		 */
		public function DocEvent(type:String, body:Object = null, bubbles:Boolean = true)
		{
			super(type, bubbles);
			this.body = body;
		}
	}
}