package hmp
{
	import com.google.maps.InfoWindowOptions;
	import com.google.maps.LatLng;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.overlays.Marker;
	import com.google.maps.services.ClientGeocoder;
	import com.google.maps.services.GeocodingEvent;
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import heatmap.model.HeatmapProxy;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * An object HeatmapPoint is a localisation (the Point heatPoint, initialized by the coordinates x and y)
	 * and an intensity (the number intensity).	
	 * @authors Florent, Philippe, Marion	
	 **/
	public class HeatmapPoint
	{
		/**
		 * The geocodded data notification
		 */
		public static const GEOCODED_DATA:String                  = 'geocodedData';
		
		/**
		 * The postal address of the point
		 */
		private var _address:String;
		
		/**
		 * The intensity of the point
		 */
		private var _intensity:Number;

		/**
		 * The criteria value
		 */
		private var _criteriaValue:Array;

		/**
		 * The Lat-Long coordinates of the point
		 */

		private var _latLng:LatLng;
		/**
		 * The marker associated
		 */
		private var _marker:Marker;

		/**
		 * Constructor of the HeatmapPoint
		 **/
		public function HeatmapPoint(address:String, intensity:Number, criteriaValue:Array = null,
									 latLng:LatLng = null, marker:Marker = null)
		{
			this._address = address;
			this._intensity = intensity;
			this._criteriaValue = criteriaValue;
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
		
		public function get criteriaValue():Array
		{
			return this._criteriaValue;
		}
		
		public function set criteria(criteriaValue:Array):void
		{
			this._criteriaValue = criteriaValue;
		}

		public function toString():String
		{
			return this._address.toString()+this._criteriaValue.toString() +"\n";
		}
			    			
		/**
		 * Geocode one address
		 * @param geocodedPointsList The list of the points already geocoded
		 */
		public function geocodeAddress(geocodedPointsList:ArrayCollection, criteria:Array):void
		{
			var geocoder:ClientGeocoder = new ClientGeocoder();
            var heatMapPoint:Object = this;
            
			geocoder.addEventListener(GeocodingEvent.GEOCODING_SUCCESS,
				function(event:GeocodingEvent):void 
				{
					trace("Geocoding success");

					var placemarks:Array = event.response.placemarks;
					if (placemarks.length > 0) 
					{
						/* Fill in the attibutes */
						marker = new Marker(placemarks[0].point);
						var html:String = "<b>" + intensity + "</b> <br/>" + address;
						marker.addEventListener(MapMouseEvent.CLICK, function(event:MapMouseEvent):void
						{
							var infoWindowOptions:InfoWindowOptions = new InfoWindowOptions();
							infoWindowOptions.contentHTML = html;
							infoWindowOptions.pointOffset = new Point(0, 0);

						    marker.openInfoWindow(infoWindowOptions);
						});

						latLng = marker.getLatLng();
						
						/* Update criteria list */
						for( var j:int = 0; j < HeatmapProxy.NB_BAL_TO_CARE ; j++)
						{	
							//If this entry doesn't exist in the dictonary, then we add it to the dictionary and to the criteria value list
							if ((criteria[2][j] as Dictionary)
										 [criteriaValue[j].toString()] == null)
							{
			    				(criteria[1][j] as ArrayCollection).addItem(criteriaValue[j].toString());
			    				criteria[2][j][criteriaValue[j].toString()] = new ArrayCollection();
		    				}
		    				//Add the current point to the current entry in the points list of the crierion value
		    				(criteria[2][j][criteriaValue[j].toString()] as ArrayCollection).addItem(heatMapPoint);
						} 
						
						//Add the point to the successfull geocoded point list
						geocodedPointsList.addItem(heatMapPoint);
						
						//Notify that the geocoding for this point is complete
						geocodedPointsList.dispatchEvent(new Event(GEOCODED_DATA));
					}
					else
						//Notify that the geocoding for this point is complete
						geocodedPointsList.dispatchEvent(new Event(GEOCODED_DATA));
				});
				
			geocoder.addEventListener(GeocodingEvent.GEOCODING_FAILURE,
				function(event:GeocodingEvent):void 
				{
					trace("Geocoding failed");
					//Notify that the geocoding for this point is complete
					geocodedPointsList.dispatchEvent(new Event(GEOCODED_DATA));
				});
				
			geocoder.geocode(this.address);
		}
	}
}