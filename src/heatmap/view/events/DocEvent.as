package heatmap.view.events
{
	import flash.events.Event;
	
	public class DocEvent extends Event
	{
		public var body:Object;
		
		public function DocEvent(type:String, body:Object = null, bubbles:Boolean=true)
		{
			super(type, bubbles);
			this.body = body;
		}
	}
}