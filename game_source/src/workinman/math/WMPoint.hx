package workinman.math;

import workinman.cloud.*;
import workinman.pooling.*;

@:keep class WMPoint extends PoolStrictBase {

	public static function request( pX:Float = 0, pY:Float = 0, pZ:Float = 0 ) : WMPoint {
		return WMPool.requestObject(WMPoint).init(pX,pY,pZ);
	}

	public var x : Float;
	public var y : Float;
	public var z : Float;
	private var _length:Float;
	private var _workFloat : Float;

	public function init( pX:Float, pY:Float, pZ:Float ) : WMPoint {
		return to(pX,pY,pZ);
	}

	public var angle(get_angle,never) : Float;
	private function get_angle() : Float { return (Math.atan2(y, x)*180)/Math.PI; }

	/**********************************************************
	@description
	Rounds the point to two decimals.
	**********************************************************/
	public function clean() : WMPoint {
		x = Math.round(x*1000)/1000;
		y = Math.round(y*1000)/1000;
		z = Math.round(z*1000)/1000;
		return this;
	}

	/**********************************************************
	@description
	**********************************************************/
	public function to( pX:Float, pY:Float, pZ:Float = 0 ) : WMPoint {
		x = pX;
		y = pY;
		z = pZ;
		calculateLength();
		return this;
	}

	/**********************************************************
	@description
	**********************************************************/
	public function toPoint ( pPoint:WMPoint ) : WMPoint
	{
		x = pPoint.x;
		y = pPoint.y;
		z = pPoint.z;
		calculateLength();
		return this;
	}
	/**********************************************************
	@description
	**********************************************************/
	public function add( pX: Float, pY:Float, pZ:Float = 0 ) : WMPoint
	{
		x += pX;
		y += pY;
		z += pZ;
		//clean();
		calculateLength();
		return this;
	}
	/**********************************************************
	@description
	**********************************************************/
	public function addPoint( pPoint:WMPoint ) : WMPoint
	{
		x += pPoint.x;
		y += pPoint.y;
		z += pPoint.z;
		//clean();
		calculateLength();
		return this;
	}
	/**********************************************************
	@description
	**********************************************************/
	public function addCopy( pX:Float, pY:Float, pZ:Float = 0) : WMPoint {
		return WMPoint.request( x+pX, y + pY, z +pZ );
	}
	/**********************************************************
	@description
	**********************************************************/
	public function addPointCopy( pPoint:WMPoint ) : WMPoint
	{
		return WMPoint.request( x+pPoint.x, y + pPoint.y, z +pPoint.z );
	}
	/**********************************************************
	@description
	**********************************************************/
	public function subtract( pX: Float, pY:Float, pZ:Float = 0) : WMPoint
	{
		x -= pX;
		y -= pY;
		z -= pZ;
		//clean();
		calculateLength();
		return this;
	}
	/**********************************************************
	@description
	**********************************************************/
	public function subtractScalar( pValue:Float, pZeroStop:Bool = false ) : WMPoint
	{
		var newLength = _length - pValue;
		if(WMMath.sign(_length) != WMMath.sign(newLength))
			newLength = 0;
		length = newLength;

		return this;
	}
	/**********************************************************
	@description
	**********************************************************/
	public function subtractPoint( pPoint:WMPoint ) : WMPoint
	{
		x -= pPoint.x;
		y -= pPoint.y;
		z -= pPoint.z;
		//clean();
		calculateLength();
		return this;
	}
	/**********************************************************
	@description
	**********************************************************/
	public function subtractCopy( pX:Float, pY:Float, pZ:Float = 0) : WMPoint
	{
		return WMPoint.request( x - pX, y - pY, z - pZ );
	}
	/**********************************************************
	@description
	**********************************************************/
	public function subtractPointCopy( pPoint:WMPoint ) : WMPoint
	{
		return WMPoint.request( x - pPoint.x, y - pPoint.y, z - pPoint.z );
	}
	/**********************************************************
	@description
	**********************************************************/
	public function multiply( pScalar:Float ) : WMPoint
	{
		x *= pScalar;
		y *= pScalar;
		z *= pScalar;
		clean();
		calculateLength();
		return this;
	}
	/**********************************************************
	@description
	**********************************************************/
	public function multiplyCopy( pScalar:Float ) : WMPoint
	{
		return WMPoint.request( x*pScalar, y*pScalar, z*pScalar );
	}
	/**********************************************************
	@description
	**********************************************************/
	public function divide( pScalar:Float ) : WMPoint
	{
		x /= pScalar;
		y /= pScalar;
		z /= pScalar;
		clean();
		calculateLength();
		return this;
	}
	/**********************************************************
	@description
	**********************************************************/
	public function divideCopy( pScalar:Float ) : WMPoint
	{
		return WMPoint.request( x/pScalar, y/pScalar, z/pScalar );
	}
	/**********************************************************
	@description
	**********************************************************/
	public function reverse() : WMPoint
	{
		x 	= -x;
		y	= -y;
		z	= -z;
		return this;
	}
	/**********************************************************
	@description
	**********************************************************/
	public function copy() : WMPoint
	{
		return WMPoint.request( x, y, z );
	}
	/**********************************************************
	@description
	**********************************************************/
	public function copyAndResize( pLen:Float ) : WMPoint {
		if ( pLen==0 ) {
			return WMPoint.request(0,0);
		}
		return multiplyCopy( pLen/_length);
	}
	/**********************************************************
	@description
	**********************************************************/
	public function equals( pPoint:WMPoint ) : Bool
	{
		return (x==pPoint.x)&&(y==pPoint.y)&&(z==pPoint.z);
	}
	/**********************************************************
	@description
	**********************************************************/
	public var length(get_length,set_length) : Float;
	private function get_length() : Float { return _length; }
	private function set_length( pLen:Float ) : Float
	{
		if(_length==0 || pLen<=0)
		{
			to(0,0);
			return _length;
		}
		multiply( pLen/_length);
		return _length;
	}
	/**********************************************************
	@description
	**********************************************************/
	public function reverseCopy() : WMPoint
	{
		return WMPoint.request( x*-1, y*-1, z*-1);
	}
	/**********************************************************
	@description	Normalize to a 1 length line.
	**********************************************************/
	public function normalize() : WMPoint
	{
		if(_length==0){ return this; }
		x /= _length;
		y /= _length;
		z /= _length;
		calculateLength();
		return this;
	}
	/**********************************************************
	@description	Normalize to a line of length pLen. This is identical to just setting the length.
	**********************************************************/
	public function normalizeTo( pLen:Float ) : WMPoint
	{
		length = pLen;
		return this;
	}
	/**********************************************************
	@description
	**********************************************************/
	public function normalizeCopy() : WMPoint
	{
		if(_length==0){ return WMPoint.request ( 0, 0, 0 ); }
		return WMPoint.request ( x/_length, y/_length, z/_length );
	}
	/**********************************************************
	@description
	**********************************************************/
	public function normalizeCopyTo( pLen:Float ) : WMPoint
	{
		if(_length==0){ return WMPoint.request ( 0, 0, 0 ); }
		_workFloat = pLen / _length;
		return WMPoint.request( x*_workFloat, y*_workFloat, z*_workFloat );
	}
	/**********************************************************
	@description 		Gets a vector perpendicular to this vector. 2D only.
	**********************************************************/
	public function pseudoCross( pResult:WMPoint ) : WMPoint {
		pResult.to( y, -x, z );
		return this;
	}
	/**********************************************************
	@description
	**********************************************************/
	public function calculateLength() : WMPoint
	{
		_length = Math.sqrt(x * x + y * y + z * z);
		return this;
	}

	/**********************************************************
	@description  Rotate BY pAngle degrees. Clockwise.
	**********************************************************/
	public function rotate( pAngle:Float ) : WMPoint
	{
		// Convert the angle to radians
		pAngle = pAngle*(Math.PI/180);
		_workFloat = (x * Math.cos(pAngle)) - (y * Math.sin(pAngle));
		y = (y * Math.cos(pAngle)) + (x * Math.sin(pAngle));
		x = _workFloat;
		return this;
	}
	/**********************************************************
	@description  Rotate to pAngle degrees. Clockwise.
	**********************************************************/
	public function rotateTo( pAngle:Float ) : WMPoint
	{
		rotate(pAngle - angle);
		return this;
	}
	/**********************************************************
	@description
	Returns the angle between this vector and vector pPoint.
	Uses the Equation: A . B = |A||B|cos(angle)       where |A| is the magnitude of A and . stands for Dot.
	That solves for:  angle = acos( ((ax * bx) + (ay * by)) / (sqrt(ax*ax + ay*ay) * sqrt(bx*bx + by*by))
	If the lines are perpendicular then the result in 90. If the lines are parallel then it should be 0.
	**********************************************************/
	public function getAngleBetween(pPoint:WMPoint) : Float
	{
		if(pPoint.length == 0 || length == 0){return 0;}
		return ((180/Math.PI) * Math.acos( ((pPoint.x * x) + (pPoint.y * y)) / (pPoint.length * length)));
	}
	/**********************************************************
	@description  Rotate by pAngle degrees and return new copy. Clockwise.
	**********************************************************/
	public function rotateCopy( pAngle:Float ) : WMPoint {
		var tCa:Float = Math.cos( pAngle * Math.PI/180);
		var tSa:Float = Math.sin( pAngle * Math.PI/180);
		return WMPoint.request(x*tCa-y*tSa,  x*tSa-y*tCa);
	}

	/**********************************************************
	@description
	**********************************************************/
	public var normalizedMagnitude(get_normalizedMagnitude,never) : Float;
	private function get_normalizedMagnitude() : Float {
		var tNormalizedVector:WMPoint = normalizeCopy();
		var tMag : Float = Math.sqrt((tNormalizedVector.x*tNormalizedVector.x) + (tNormalizedVector.y*tNormalizedVector.y));
		tNormalizedVector.dispose();
		tNormalizedVector = null;
		return tMag;
	}

	/**********************************************************
	@description
	**********************************************************/
	public function toString() : String {
		return "{ WMPoint : " + x + " , " + y + " , " + z + " , len: " + _length + "  }";
	}

	public function dot(pVector:WMPoint) : Float {
		return x * pVector.x + y * pVector.y;
	}
}
