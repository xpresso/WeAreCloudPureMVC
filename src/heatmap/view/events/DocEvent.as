package heatmap.view.events
{
	import flash.events.Event;
	
	/**
	 * DocEvent
	 * An event which contains a body
	 * @author Florent, Philippe et Marion
	 */
	public class DocEvent extends Event
	{
		public var body:Object;
		
		/**
		 * Constructor
		 */
		public function DocEvent(type:String, body:Object = null, bubbles:Boolean=true)
		{
			super(type, bubbles);
			this.body = body;
		}
	}
}