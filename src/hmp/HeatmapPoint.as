package hmp
{
	import com.google.maps.LatLng;
	
	/**
	 * An object HeatmapPoint is a localisation (the Point heatPoint, initialized by the coordinates x and y)
	 * and an intensity (the number intensity).		
	 **/
	public class HeatmapPoint
	{
		private var address:String;
		private var heatPoint:LatLng;
		private var intensity:Number;
		
		/**
		 * Constructor of the HeatmapPoint
		 **/
		public function HeatmapPoint(address:String, intensity:Number, heatPoint:LatLng = null)
		{
			this.address = address;
			this.heatPoint = heatPoint;
			this.intensity = intensity;
		}
			
		
		public function getHeatPoint():LatLng
		{
			return this.heatPoint;	
		}
		
		public function setHeatPoint(heatPoint:LatLng):void
		{
			this.heatPoint = heatPoint;	
		}		
		
		/**
		 * Accessor on the Number itensity
		 **/
		public function getIntensity():Number
		{
			return this.intensity;
		}
		
		public function setIntensity(intensity:Number):void
		{
			this.intensity = intensity;
		}
		
		public function getAddress():String
		{
			return this.address;
		}
		
		public function setAddress(address:String):void
		{
			this.address = address;
		}	
	}
}