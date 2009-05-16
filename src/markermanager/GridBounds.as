package markermanager
{
	import flash.geom.Point;

	public class GridBounds
	{
		private var _z:Number;
		private var _minX:Number;
		private var _minY:Number;
		private var _maxX:Number;
		private var _maxY:Number;


	/**
	 * A Bounds is defined by minimum and maximum X and Y coordinates on a plane.
	 * @param {Array.<Point>} opt_points  Points which this Bound must contain.
	 *
	 * @constructor
	 */
	public function GridBounds(opt_points:Array):void
	{
		this._minX = Infinity;
		this._minY = Infinity;
		this._maxX = -Infinity;
		this._maxY = -Infinity;
		if (opt_points && opt_points.length)
		{
			for (var i:Number = 0; i < opt_points.length; i++)
			{
				this.extend(opt_points[i]);
			}
		}
	}

	/**
	 * Gets z.
	 *
	 * @return {Number} z.
	 */
	public function get z():Number
	{
		return this._z;
	}

	/**
	 * Gets the minimum x and y in this bound.
	 *
	 * @return {Point}
	 */
	public function min():Point
	{
		return new Point(this._minX, this._minY);
	}

	/**
	 * Gets the maximum x and y in this bound.
	 *
	 * @return {Point}
	 */
	public function max():Point
	{
		return new Point(this._maxX, this._maxY);
	}

	/**
	 * @return {Size}  The size of this bounds.
	 */
	public function getSize():Point
	{
		return new Point(this._maxX - this._minX, this._maxY - this._minY);
	}

	/**
	 * Gets the midpoint x and y in this bound.
	 *
	 * @return {Point}  The midpoint.
	 */
	public function mid():Point
	{
		return new Point((this._minX + this._maxX) / 2, (this._minY + this._maxY) / 2);
	}

	/**
	 * Returns a string representation of this bound.
	 *
	 * @returns {string}
	 */
	public function toString():String
	{
	  return "(" + this._min() + ", " + this._max() + ")";
	}

	/**
	 * Test for empty bounds.
	 *
	 * @return {boolean}  This Bounds is empty.
	 */
	public function isEmpty():Boolean
	{
		return (this._minX > this._maxX || this._minY > this._maxY);
	}

	/**
	 * Returns true if this bounds (inclusively) contains the given bounds.
	 *
	 * @param {Bounds} inner  Inner Bounds.
	 * @return {boolean}  This Bounds contains the given Bounds.
	 */
	public function containsBounds(inner:GridBounds):Boolean
	{
		var outer:GridBounds = this;
		return (outer._minX <= inner._minX &&
		        outer._maxX >= inner._maxX &&
		        outer._minY <= inner._minY &&
		        outer._maxY >= inner._maxY);
	}

	/**
	 * Returns true if this bounds (inclusively) contains the given point.
	 *
	 * @param {Point} point  The point to test.
	 * @return {boolean}  This Bounds contains the given Point.
	 */
	public function containsPoint(point:Point):Boolean
	{
		var outer:GridBounds = this;
		return (outer._minX <= point.x &&
		        outer._maxX >= point.x &&
		        outer._minY <= point.y &&
		        outer._maxY >= point.y);
	}

	/**
	 * Extends this bounds to contain the given point.
	 *
	 * @param {Point} point  Additional point.
	 */
	public function extend(point:Point):void
	{
		if (this.isEmpty())
		{
			this._minX = this._maxX = point.x;
			this._minY = this._maxY = point.y;
		}
		else
		{
			this._minX = Math.min(this._minX, point.x);
			this._maxX = Math.max(this._maxX, point.x);
			this._minY = Math.min(this._minY, point.y);
			this._maxY = Math.max(this._maxY, point.y);
		}
	}

	/**
	 * Compare this bounds to another.
	 *
	 * @param {Bounds} bounds  The bounds to test against.
	 * @return {boolean}  True when the bounds are equal.
	 */
	public function equals(bounds:GridBounds):Boolean
	{
		return this._minX == bounds._minX &&
		       this._minY == bounds._minY &&
		       this._maxX == bounds._maxX &&
		       this._maxY == bounds._maxY;
	}

	}
}