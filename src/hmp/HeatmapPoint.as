package hmp
{
	import com.google.maps.InfoWindowOptions;
	import com.google.maps.LatLng;
	import com.google.maps.MapMouseEvent;

	import com.google.maps.overlays.Marker; // Google Maps Marker.

	// Google Maps services.
	import com.google.maps.services.ClientGeocoder;
	import com.google.maps.services.GeocodingEvent;

	// Flash imports.
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	import heatmap.model.HeatmapProxy;

	import mx.collections.ArrayCollection;	// Flex import.

	/**
	 * HeatmapPoint.
	 *
	 * @authors Florent Odier, Philippe Miguet & Marion	Trenza.
	 */
	public class HeatmapPoint
	{
		/**
		 * The GEOCODED_DATA notification.
		 */
		public static const GEOCODED_DATA:String                  = 'geocodedData';

		/**
		 * The postal address of the point
		 */
		private var _address:String;
		
		/*
		 * The point intensity.
		 */
		private var _intensity:Number;

		/*
		 * The criteria values.
		 */
		private var _criteriaValues:Array;

		/*
		 * The Lat-Lng coordinates of the point.
		 */
		private var _latLng:LatLng;
		/*
		 * The marker associated.
		 */
		private var _marker:Marker;

		/**
		 * @constructor
		 *
		 * @param {String} address The point address.
		 * @param {Number} intensity The point intensity.
		 * @param {Array} criteriaValues The point criteria and their values. Null by default.
		 * @param {LatLng} latLng The point coordinates. Null by default.
		 * @param {Marker} marker The marker associated to the point. Null by default.
		 */
		public function HeatmapPoint(address:String, intensity:Number, criteriaValues:Array = null,
									 latLng:LatLng = null, marker:Marker = null)
		{
			_address = address;
			_intensity = intensity;
			_criteriaValues = criteriaValues;
			_latLng = latLng;
			_marker = marker;
		}

		/**
		 * Get the point address.
		 *
		 * @return {String}
		 */
		public function get address():String
		{
			return _address;
		}
		/**
		 * Set the point address.
		 *
		 * @param {String} address The point address.
		 */
		public function set address(address:String):void
		{
			_address = address;
		}

		/**
		 * Get the point intensity.
		 *
		 * @return {String}
		 */
		public function get intensity():Number
		{
			return _intensity;
		}
		/**
		 * Set the point intensity.
		 *
		 * @param {String} address The point intensity.
		 */
		public function set intensity(intensity:Number):void
		{
			intensity = intensity;
		}

		/**
		 * Get the point coordinates.
		 *
		 * @return {String}
		 */
		public function get latLng():LatLng
		{
			return _latLng;
		}
		/**
		 * Set the point coordinates.
		 *
		 * @param {LatLng} latLng The point coordinates.
		 */
		public function set latLng(latLng:LatLng):void
		{
			_latLng = latLng;
		}

		/**
		 * Get the marker associated.
		 *
		 * @return {Marker}
		 */
		public function get marker():Marker
		{
			return _marker;
		}
		/**
		 * Set the marker associated.
		 *
		 * @param {Marker} marker The marker associated.
		 */
		public function set marker(marker:Marker):void
		{
			_marker = marker;
		}

		/**
		 * Get the point criteria and their values.
		 *
		 * @return {Array}
		 */
		public function get criteriaValues():Array
		{
			return _criteriaValues;
		}
		/**
		 * Set the point criteria and their values.
		 *
		 * @param {Array} criteriaValues The point criteria and their values.
		 */
		public function set criteria(criteriaValue:Array):void
		{
			_criteriaValues = criteriaValue;
		}

		/**
		 * Return a description of the point.
		 *
		 * @param {String}
		 */
		public function toString():String
		{
			return _address.toString()+_criteriaValues.toString() +"\n";
		}

		/**
		 * Geocode one address.
		 *
		 * @param {ArrayCollection} geocodedPointsList That list will be filled in.
		 * @param {Array} criteria The criteria array is also filled in.
		 */
		public function geocodeAddress(geocodedPointsList:ArrayCollection, criteria:Array):void
		{
			var geocoder:ClientGeocoder = new ClientGeocoder();
			var heatMapPoint:Object = this;

			geocoder.addEventListener(GeocodingEvent.GEOCODING_SUCCESS, function(event:GeocodingEvent):void 
				{
					trace("Geocoding success");

					var placemarks:Array = event.response.placemarks;
					if(placemarks.length > 0)
					{
						// Fill in the attibutes.
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
						
						// Update criteria array.
						for(var j:int = 0; j < HeatmapProxy.NB_BAL_TO_CARE ; j++)
						{	
							// If this entry doesn't exist in the dictonary, we add it to the dictionary and to the criteria array.
							if ((criteria[2][j] as Dictionary)[criteriaValues[j].toString()] == null)
							{
								(criteria[1][j] as ArrayCollection).addItem(criteriaValues[j].toString());
								criteria[2][j][criteriaValues[j].toString()] = new ArrayCollection();
							}
							// Add the current point to the current entry in the points list of the criterion value.
							(criteria[2][j][criteriaValues[j].toString()] as ArrayCollection).addItem(heatMapPoint);
						} 

						// Add the point to the successfull geocoded points list.
						geocodedPointsList.addItem(heatMapPoint);
					}
					// Notify that the geocoding for this point is complete.
					geocodedPointsList.dispatchEvent(new Event(GEOCODED_DATA));
				});

			geocoder.addEventListener(GeocodingEvent.GEOCODING_FAILURE, function(event:GeocodingEvent):void 
				{
					trace("Geocoding failed");
					// Notify that the geocoding for this point is complete.
					geocodedPointsList.dispatchEvent(new Event(GEOCODED_DATA));
				});

			geocoder.geocode(address);
		}
	}
}