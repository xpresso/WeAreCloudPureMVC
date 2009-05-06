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
		private var address:String;
		private var latLng:LatLng;
		private var intensity:Number;
		private var marker:Marker;
		
		public static const GEOCODEDDATA:String                  = 'geocodedData';
		/**
		 * Constructor of the HeatmapPoint
		 **/
		public function HeatmapPoint(address:String, intensity:Number, latLng:LatLng = null, marker:Marker = null)
		{
			this.address = address;
			this.intensity = intensity;
			this.latLng = latLng;
			this.marker = marker;
		}
			
		
		public function getLatLng():LatLng
		{
			return this.latLng;	
		}
		
		public function setLatLng(latLng:LatLng):void
		{
			this.latLng = latLng;	
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
		
		public function getMarker():Marker
		{
			return this.marker;
		}
		
		public function setMarker(marker:Marker):void
		{
			this.marker = marker;
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