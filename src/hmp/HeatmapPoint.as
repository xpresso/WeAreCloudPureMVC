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
	 * @authors Florent, Philippe, Marion	
	 **/
	public class HeatmapPoint
	{
		/**
		 * The postal address of the point
		 */
		private var _address:String;
		/**
		 * The intensity of the point
		 */
		private var _intensity:Number;
		/**
		 * The Lat-Long coordinates of the point
		 */
		private var _latLng:LatLng;
		/**
		 * The marker associated
		 */
		private var _marker:Marker;
		/**
		 * The geocodded data notification
		 */
		public static const GEOCODEDDATA:String                  = 'geocodedData';
		/**
		 * Constructor of the HeatmapPoint
		 **/
		public function HeatmapPoint(address:String, intensity:Number, latLng:LatLng = null, 
									 marker:Marker = null)
		{
			this._address = address;
			this._intensity = intensity;
			this._latLng = latLng;
			this._marker = marker;
		}


		public function get address():String
		{
			return this._address;
		}

		public function set address(address:String):void
		{
			this._address = address;
		}
		
		public function get intensity():Number
		{
			return this._intensity;
		}
		
		public function set intensity(intensity:Number):void
		{
			this._intensity = intensity;
		}
		
		public function get latLng():LatLng
		{
			return this._latLng;	
		}
		
		public function set latLng(latLng:LatLng):void
		{
			this._latLng = latLng;	
		}
		public function get marker():Marker
		{
			return this._marker;
		}
		
		public function set marker(marker:Marker):void
		{
			this._marker = marker;
		}
		
		public function toString():String
		{
			return this._address.toString();
		}
		
		/**
		 * Geocode one address
		 * @param geocodedPointsList The list of the points already geocoded
		 */
		public function geocodeAddress(geocodedPointsList:ArrayCollection):void
		{
			var geocoder:ClientGeocoder = new ClientGeocoder();
            var heatMapPoint:Object = this;
            
			geocoder.addEventListener(GeocodingEvent.GEOCODING_SUCCESS,
				function(event:GeocodingEvent):void {
					trace("Geocoding success");
					//geocodedPointsList.addItem(heatMapPoint); //TO delete
					var placemarks:Array = event.response.placemarks;
					if (placemarks.length > 0) 
					{
						marker = new Marker(placemarks[0].point);
						latLng = marker.getLatLng(); //To uncomment
						
						geocodedPointsList.addItem(heatMapPoint); //To uncomment
						geocodedPointsList.dispatchEvent(new Event(GEOCODEDDATA));
					}
					else
						geocodedPointsList.dispatchEvent(new Event(GEOCODEDDATA));
				});
				
			geocoder.addEventListener(GeocodingEvent.GEOCODING_FAILURE,
				function(event:GeocodingEvent):void {
					trace("Geocoding failed");
					//geocodedPointsList.addItem(heatMapPoint); //TO delete
					geocodedPointsList.dispatchEvent(new Event(GEOCODEDDATA));
				});
				
			geocoder.geocode(this.address);
		}
	}
}