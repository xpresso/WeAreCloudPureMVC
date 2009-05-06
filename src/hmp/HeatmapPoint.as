package hmp
{
	import com.google.maps.LatLng;
	import com.google.maps.overlays.Marker;
	import com.google.maps.services.ClientGeocoder;
	import com.google.maps.services.GeocodingEvent;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * An object HeatmapPoint is a localisation (the Point heatPoint, initialized by the coordinates x and y)
	 * and an intensity (the number intensity).		
	 **/
	public class HeatmapPoint
	{
		private var _address:String;
		private var _latLng:LatLng;
		private var _intensity:Number;
		private var _marker:Marker;
		
		public static const GEOCODEDDATA:String                  = 'geocodedData';
		/**
		 * Constructor of the HeatmapPoint
		 **/
		public function HeatmapPoint(address:String, intensity:Number, latLng:LatLng = null, marker:Marker = null)
		{
			this._address = address;
			this._intensity = intensity;
			this._latLng = latLng;
			this._marker = marker;
		}
			
		
		public function get latLng():LatLng
		{
			return this._latLng;	
		}
		
		public function set latLng(latLng:LatLng):void
		{
			this._latLng = latLng;	
		}		
		
		/**
		 * Accessor on the Number itensity
		 **/
		public function get intensity():Number
		{
			return this._intensity;
		}
		
		public function set intensity(intensity:Number):void
		{
			this._intensity = intensity;
		}
		
		public function get address():String
		{
			return this._address;
		}
		
		public function set address(address:String):void
		{
			this._address = address;
		}
		
		public function get marker():Marker
		{
			return this._marker;
		}
		
		public function set marker(marker:Marker):void
		{
			this._marker = marker;
		}
		
		public function geocodeAddress(geocodedPointsList:ArrayCollection):void
		{
			var geocoder:ClientGeocoder = new ClientGeocoder();
            var heatMapPoint:Object = this;
            
			geocoder.addEventListener(GeocodingEvent.GEOCODING_SUCCESS,
				function(event:GeocodingEvent):void {
					var placemarks:Array = event.response.placemarks;
					if (placemarks.length > 0) 
					{
						marker = new Marker(placemarks[0].point);
						latLng = marker.getLatLng();
						
						geocodedPointsList.addItem(heatMapPoint);
						geocodedPointsList.dispatchEvent(new Event(GEOCODEDDATA));
					}
					else
						geocodedPointsList.dispatchEvent(new Event(GEOCODEDDATA));
				});
				
			geocoder.addEventListener(GeocodingEvent.GEOCODING_FAILURE,
				function(event:GeocodingEvent):void {
					trace("Geocoding failed");
					geocodedPointsList.dispatchEvent(new Event(GEOCODEDDATA));
				});
				
			geocoder.geocode(this.address);
		}
	}
}