package michaelvandaniker.visualization
{
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.GradientType;
    import flash.display.Shape;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.BlurFilter;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import mx.collections.ArrayCollection;
    import mx.core.UIComponent;
    import mx.events.CollectionEvent;
    import mx.styles.CSSStyleDeclaration;
    import mx.styles.StyleManager;
	
	[Style(name="backgroundColor", type="uint", format="Color", inherit="no")]
	[Style(name="backgroundAlpha", type="Number", inherit="no")]

	/**
	 * A HeatMap shows the density of a collection of points by giving each point a sphere
	 * of influence.  The spheres are drawn to a BitmapData, which subsequently gets recolored
	 * such that pixels with the most accumulated influence have the hottest colors. 
	 */
    public class HeatMap extends UIComponent
    {
		public function HeatMap()
		{
			super();
			mouseEnabled = false;
			cacheAsBitmap = true;
			gradientArray = GradientDictionary.THERMAL;
			alpha = .7;
		}
		
		/**
		 * Initialize the backgroundAlpha and backgroundColor styles
		 */
		private static function initializeStyles():void
		{
			if (!StyleManager.getStyleDeclaration("HeatMap"))
            {
                var defaultStyles:CSSStyleDeclaration = new CSSStyleDeclaration();
                defaultStyles.defaultFactory = function():void
                {
                    this.backgroundAlpha = 0;
                    this.backgroundColor = 0;
               }
                StyleManager.setStyleDeclaration("HeatMap", defaultStyles, true);
            }
		}
		initializeStyles();
		
		/**
		 * A few BitmapData operations take a Point as an argument.
		 * Save a tiny bit of memory by making that Point a constant.
		 */ 
		public static const POINT:Point = new Point();
		
		/**
		 * true if the dataProvider has changed.
		 */
		protected var collectionDirtyFlag:Boolean = true;
        
        /**
		 * true if something has happened the requires a potential change
		 * to centerValeu.
		 */
        protected var centerValueDirtyFlag:Boolean = true; 
        
        /**
         * The width the last time updateDisplayList was called
         */
        protected var oldWidth:Number;
        
        /**
         * The height the last time updateDisplayList was called
         */
        protected var oldHeight:Number;
        
        /**
         * A dictionary of strings that represent the points in the dataProvider.
         * This is used to determine the centerValue.
         */
        protected var pointDictionary:Object;
		
		/**
		 * A collection of Points extracted from the dataProvider
		 */ 
		protected var points:Array = new Array();
        
        /**
         * The BitmapData representing the heat map
         */
        protected var heatBitmapData:BitmapData;

		/**
		 * The color at the center of each circle drawn to heatBitmapData
		 */ 
		protected var centerValue:Number;
		
        /**
         * An array of 256 colors used to color the heat map. Colors towards the
         * end of the array represent hotter regions of the map.
         */ 
        public function get gradientArray():Array
        {
        	return _gradientArray;
        }
        public function set gradientArray(value:Array):void
        {
        	if(_gradientArray != value)
        	{
	        	_gradientArray = value;
	        	invalidateDisplayList();
	        }
        }
        private var _gradientArray:Array;
       
		[Bindable]
		/**
		 * The radius of each item drawn on the heat map.
		 */
		public function get itemRadius():int
		{
			return _itemRadius;
		}
        public function set itemRadius(value:int):void
        {
        	if(_itemRadius != value)
			{
				_itemRadius = value;
				invalidateDisplayList();
			}
		}
		private var _itemRadius:int = 25;
		
		[Bindable(event="transformationFunctionChange")]
		/**
		 * A function used to calculate the position on the heat map
		 * for each item in the dataProivder.
		 * 
		 * The function takes an Object (o) and a String (fieldName).
		 * Currently the only accepted value of fieldName is "point".   
		 */
		public function set transformationFunction(value:Function):void
		{
			if(value != _transformationFunction)
			{
				_transformationFunction = value;
				collectionDirtyFlag = true;
				invalidateDisplayList();
				dispatchEvent(new Event("transformationFunctionChange"));
			}
		}
		public function get transformationFunction():Function
		{
			return _transformationFunction;
		}
		private var _transformationFunction:Function = xyTransformationFunction;
		
		[Bindable(event="weightFunctionChange")]
		public function set weightFunction(value:Function):void
		{
			if(value != _weightFunction)
			{
				_weightFunction = value;
				collectionDirtyFlag = true;
				invalidateDisplayList();
				dispatchEvent(new Event("weightFunctionChange"));
			}
		}
		public function get weightFunction():Function
		{
			return _weightFunction;
		}
		private var _weightFunction:Function = uniformWeightFunction;
		
		/**
		 * The default dataFunction. Returns a new point based on o's x and y values.
		 */
		protected function xyTransformationFunction(o:Object):Point
		{
			return new Point(o["x"],o["y"]);
		}
		
		protected function uniformWeightFunction(o:Object):int
		{
			return 1;
		}
		
		[Bindable]
		/**
		 * An ArrayCollection of object to plot on the heat map.
		 */
        public function get dataProvider():ArrayCollection
        {
			return _dataProvider;
        }
		public function set dataProvider(value:ArrayCollection):void
		{
			if(_dataProvider != value)
			{
				if (_dataProvider)
					_dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, handleCollectionChange);
				_dataProvider = value;
	            _dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleCollectionChange);
	            collectionDirtyFlag = true;            
	            invalidateDisplayList();
			}
        }
        private var _dataProvider:ArrayCollection;

		/**
		 * If the dataProvider changes we have to re-evaluate the properties
		 * backing the heat map and redraw.
		 */
        protected function handleCollectionChange(event:CollectionEvent):void
        {
        	collectionDirtyFlag = true;
            invalidateDisplayList();
        }
        
        /**
         * All of the heat map calculations require knowing the size of the displayed area
         * so it doesn't make sense to do that sort of work in commitProperties. HeatMap
         * overrides invalidateProperties to make it a proxy for invalidateDisplayList.  
         */
        override public function invalidateProperties():void
        {
        	super.invalidateProperties();
        	collectionDirtyFlag = true;
        	invalidateDisplayList();
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
            super.updateDisplayList(unscaledWidth,unscaledHeight);
            
            if(collectionDirtyFlag || oldWidth != width || oldHeight != height)
            {
            	updatePoints();
            	collectionDirtyFlag = false;
            }
            
            if(centerValueDirtyFlag)
            {
            	updateCenterValue();
            	centerValueDirtyFlag = false;
            }
            
            drawHeatMap();           
			
			var bgColor:Number = getStyle("backgroundColor");
			var bgAlpha:Number = getStyle("backgroundAlpha")
			graphics.clear();
            graphics.beginFill(bgColor,bgAlpha);
            graphics.drawRect(0,0,width,height);
            graphics.endFill();
            
            if(heatBitmapData)
            {
                graphics.beginBitmapFill(heatBitmapData);
                graphics.drawRect(0,0,width,height);
                graphics.endFill();
            }
            
            oldWidth = width;
            oldHeight = height;
        }
        
        protected function updatePoints():void
        {
        	if(_dataProvider != null)
			{
				// Test if points from the dataProvider fall within the bounds
				// of the display area. To get the proper coloring around the ends we 
				// need to include points that fall just outside the bounds as well.
				var rect:Rectangle = getRect(this);
				rect.inflate(itemRadius,itemRadius);
				
				// Generate a list of unique points in the dataProvider
				pointDictionary = new Object();
				var tempPoints:Array = new Array();
	            for each(var o:Object in _dataProvider)
	            {
	            	var point:Point = transformationFunction.apply(this,[o]);
	            	if(rect.containsPoint(point))
	            	{
	            		var pointCount:Number = weightFunction.apply(this,[o]);
	            		for(var a:int = 0; a < pointCount; a++)
	            		{
	            			tempPoints.push(point);
	            		}
	            			
		                var pointKey:String = Math.round(point.x)+"_"+Math.round(point.y);
		                if(pointDictionary[pointKey] == null)
							pointDictionary[pointKey] = pointCount;
		                else
		                    pointDictionary[pointKey] += pointCount;
					} 
	            }
	            
	            if(tempPoints.toString() != points.toString())
	            {
	            	points = tempPoints;
	            	centerValueDirtyFlag = true;
	            }
			}
        }
        
        protected function updateCenterValue():void
        {
        	// Determine the centerValue by taking 255 / the maximum number of points in a single place.
			// Bound centerValue between 19  and 255 / 5 to keep the gradient diverse enough to remain attractive.
			var maxPointsInOnePlace:int = 5;
			for(var key:String in pointDictionary)
			{
				maxPointsInOnePlace = Math.max(maxPointsInOnePlace,pointDictionary[key]);
			}
			var tempCenterValue:Number = 255 / maxPointsInOnePlace;//Math.max(19, 255 / maxPointsInOnePlace);
			if(tempCenterValue != centerValue)
				centerValue = tempCenterValue;
        }
        
        /**
         * Recalcuate the contents of heatBitmapData.
         */
        protected function drawHeatMap():void
        {
        	// Just don't draw the heatMap in situations that would break BitmapData
            if(width > 2880 || width <= 0 || height > 2880 || height <= 0 || points == null)
            {
                if(heatBitmapData)
                    heatBitmapData.dispose();
                return;
            }
           
            var cellSize:int = itemRadius * 2;
            var m:Matrix = new Matrix();
            m.createGradientBox(cellSize, cellSize, 0, -itemRadius, -itemRadius);
           
            // Create the sphere of influence: A circle with a gradient that moves
            // from blue to black as you move from the inside of the circle out.
            var heatMapShape:Shape = new Shape();
            heatMapShape.graphics.clear();
            //heatMapShape.graphics.beginGradientFill(GradientType.RADIAL,[centerValue,0],[0.6,0.3],[0,255],m);
            heatMapShape.graphics.beginGradientFill(GradientType.RADIAL,//GradientType.LINEAR or GradientType.RADIAL
            										[centerValue,0],    // les couleurs prises
            										[1,1],//alphas: An array of alpha values for the corresponding colors in the colors array; valid values are 0 to 1
            										[0,255],//ratios: An array of color distribution ratios; valid values are 0 to 255. This value defines the percentage of the width where the color is sampled at 100%
            					// Attention, quand les jeux de données comprendront bcp plus de valeurs il faudra baisser le nombre 200 !!!
            										m);
            heatMapShape.graphics.drawCircle(0,0,itemRadius);
            heatMapShape.graphics.endFill();
           
            // Bitmap.draw is fastest when the first argument is a BitmapData,
            // so draw the shape to a BitmapData to save time later.
            var heatMapItem:BitmapData = new BitmapData(heatMapShape.width,heatMapShape.height,true,0x00000000);
            var translationMatrix:Matrix = new Matrix();
            translationMatrix.tx = itemRadius;
            translationMatrix.ty = itemRadius;
            heatMapItem.draw(heatMapShape,translationMatrix);
           
            // If there is an existing heatBitmapData we have to clear it.
            // Using fillRect for this is faster than creating a new BitmapData, so only use new 
            // when needed (width or height has changed or heatBitmapData does not exist)
            if(!heatBitmapData || heatBitmapData.width != width || heatBitmapData.height != height)
                heatBitmapData = new BitmapData(width,height,true,0x00000000);
            else
                heatBitmapData.fillRect(new Rectangle(0,0,heatBitmapData.width,heatBitmapData.height),0x00000000);
            
            // Draw a heatMapItem to the BitmapData for each point. Use the screen blend mode
            // to create the effect of overlapping heatMapItems influencing each other. 
            var len:int = points.length;
            for each(var point:Point in points)
            {
                translationMatrix.tx = point.x - itemRadius;
                translationMatrix.ty = point.y - itemRadius;
                heatBitmapData.draw(heatMapItem,translationMatrix,null,BlendMode.SCREEN);
            }
            heatMapItem.dispose();
			
			// paletteMap leaves some artifacts unless we get rid of the blackest colors 
			heatBitmapData.threshold(heatBitmapData, heatBitmapData.rect,POINT,"<=", 0x00000003, 0x00000000, 0x000000FF, true);
			
			// Replace the black and blue with the gradient. Blacker pixels will get their new colors from
			// the beginning of the gradientArray and bluer pixels will get their new colors from the end. 
			heatBitmapData.paletteMap(heatBitmapData,heatBitmapData.rect,POINT,null,null,gradientArray,null);
			
			// This blur filter makes the heat map looks quite smooth.
			heatBitmapData.applyFilter(heatBitmapData,heatBitmapData.rect,POINT,new BlurFilter(4,4));
        }
    }
}