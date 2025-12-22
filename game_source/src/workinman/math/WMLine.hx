package workinman.math;

import workinman.pooling.PoolStrictBase;
import workinman.pooling.IStrictPoolable;

@:keep class WMLine extends PoolStrictBase implements IStrictPoolable {

	public static function request( pX0:Float = 0, pY0:Float = 0, pX1:Float = 0, pY1:Float = 0 ) : WMLine {
		return WMPool.requestObject(WMLine).init(pX0,pY0,pX1,pY1);
	}

	private var _p0			: WMPoint;
	private var _p1			: WMPoint;
	private var _normal		: WMPoint;
	private var _vector		: WMPoint;
	private var _parametricDenom : WMPoint;

	private var _slope		: Float;
	private var _yIntercept : Float;
	private var _length		: Float;
	private var _inverseDeterminate:Float;
	private var _xSegmentResult	: Float;
	private var _ySegmentResult	: Float;

	/**********************************************************
	@constructor
	**********************************************************/

	public function init( pX0:Float, pY0:Float, pX1:Float, pY1:Float ) : WMLine {
		_p0 = WMPoint.request();
		_p1 = WMPoint.request();
		_normal = WMPoint.request();
		_vector = WMPoint.request();
		_parametricDenom = WMPoint.request();
		toFloats(pX0,pY0,pX1,pY1);
		_calcProperties();
		return this;
	}

	public override function dispose() : Void {
		_p0.dispose();
		_p0 = null;
		_p1.dispose();
		_p1 = null;
		_normal.dispose();
		_normal = null;
		_vector.dispose();
		_vector = null;
		_parametricDenom.dispose();
		_parametricDenom = null;
		super.dispose();
	}

	public var p0(get_p0,never) : WMPoint;
	private function get_p0() : WMPoint { return _p0; }

	public var p1(get_p1,never) : WMPoint;
	private function get_p1() : WMPoint { return _p1; }

	public var slope(get_slope,never) : Float;
	private function get_slope() : Float { return _slope; }

	public var yIntercept(get_yIntercept,never) : Float;
	private function get_yIntercept() : Float { return _yIntercept; }

	public var normal(get_normal,never) : WMPoint;
	private function get_normal() : WMPoint { return _normal; }

	public var vector(get_vector,never) : WMPoint;
	private function get_vector() : WMPoint { return _vector; }

	public var center(get_center,never) : WMPoint;
	private function get_center() : WMPoint { return WMPoint.request(_p0.x + (_vector.x/2), _p0.y + (_vector.y/2)); }

	public var centerX(get_centerX,never) : Float;
	private function get_centerX() : Float { return _p0.x + (_vector.x/2); }

	public var centerY(get_centerY,never) : Float;
	private function get_centerY() : Float { return _p0.y + (_vector.y/2); }

	public var parametricDenom(get_parametricDenom,never) : WMPoint;
	private function get_parametricDenom() : WMPoint { return _parametricDenom; }

	public var length(get_length,set_length) : Float;
	private function get_length() : Float { return _length; }
	private function set_length( pLen:Float ) : Float {
		if(length==0){ return _length; } // Once a line length has been set to zero it's effectively broken for easy resizing because it no longer has a direction. You will have to manual set the end point location to resolve.
		_p1.to( _p0.x + (_vector.x*(pLen/length)), _p0.y + (_vector.y*(pLen/length)));
		_calcProperties();
		return _length;
	}

	/**********************************************************
	@description
	**********************************************************/
	public function recalculate() : Void
	{
		_calcProperties();
	}
	/**********************************************************
	@description	Gets a point on this line at time t (really a ratio, 0-1). t=0 will return p0, t=1 will return p1.
	**********************************************************/
	public function getNewPoint( t:Float, pOutPoint:WMPoint = null ) : WMPoint {
		// return  p0.addPointCopy( _vector.multiplyCopy(t));
		// The above is clean looking, but totally inefficent performance-wise.
		// return WMPoint.request( p0.x+(_vector.x*t), p0.y+(_vector.y*t), p0.z+(_vector.z*t) )
		// [3D] Except we never use Z, so lets leave that out for now. Can always go back if we start doing more 3D stuff.

		if ( pOutPoint == null ) {
			pOutPoint = WMPoint.request();
		}
		pOutPoint.to( p0.x+(_vector.x*t), p0.y+(_vector.y*t) );
		return pOutPoint;
	}
	/**********************************************************
	@description
	**********************************************************/
	public function equals( pLine:WMLine ) : Bool
	{
		return pLine.p0.equals(p0) && pLine.p1.equals(p1);
	}
	/**********************************************************
	@description
	**********************************************************/
	public function flip() : Void
	{
		var tP0:WMPoint = _p0.copy();
		_p0.toPoint(_p1);
		_p1.toPoint(tP0);
		tP0.dispose();
		tP0 = null;
		_calcProperties();
	}
	/**********************************************************
	@description
	Rounds the line's points to two decimals.
	**********************************************************/
	public function clean() : Void
	{
		_p0.clean();
		_p1.clean();
		_calcProperties();
	}
	/**********************************************************
	@description
	**********************************************************/
	public function copy() : WMLine
	{
		return request().to(_p0,_p1);
	}
	/**********************************************************
	@description
	**********************************************************/
	public function to( tp0:WMPoint, tp1:WMPoint ) : WMLine
	{
		_p0.toPoint( tp0 );
		//_p0.clean();
		_p1.toPoint( tp1 );
		//_p1.clean();
		_calcProperties();
		return this;
	}
	/**********************************************************
	@description
	**********************************************************/
	public function toLine( pLine:WMLine ) : WMLine
	{
		_p0.toPoint( pLine.p0 );
		_p1.toPoint( pLine.p1 );
		_calcProperties();
		return this;
	}
	/**********************************************************
	@description
	**********************************************************/
	public function toFloats( p0x:Float, p0y:Float, p1x:Float, p1y:Float ) : WMLine
	{
		_p0.to( p0x, p0y );
		//_p0.clean();
		_p1.to( p1x, p1y );
		//_p1.clean();
		_calcProperties();
		return this;
	}
	/**********************************************************
	@description
	**********************************************************/
	public function originTo( pX:Float, pY:Float, pZ:Float = 0 ) : WMLine
	{
		_p0.to(pX, pY, pZ);
		//_p0.clean();
		_calcProperties();
		return this;
	}
	/**********************************************************
	@description
	**********************************************************/
	public function originToPoint( pPoint:WMPoint ) : Void
	{
		_p0.toPoint(pPoint);
		_calcProperties();
	}
	/**********************************************************
	@description
	**********************************************************/
	public function endTo( pX:Float, pY:Float, pZ:Float = 0) : Void
	{
		_p1.to(pX, pY, pZ);
		//_p1.clean();
		_calcProperties();
	}
	/**********************************************************
	@description
	**********************************************************/
	public function endToPoint( pPoint:WMPoint ) : Void
	{
		_p1.toPoint(pPoint);
		_calcProperties();
	}
	/**********************************************************
	@description   Rotate by pAngle. Clockwise.
	**********************************************************/
	public function rotate( pAngle:Float ) : Void
	{
		//_vector.rotate( pAngle );
		//_p1.toPoint( _p0.addPointCopy(_vector));
		//2/29/16 BMayzak - Fixed memory leak
		_vector.rotateTo(pAngle);
		_p1.to(_p0.x + _vector.x, _p0.y + _vector.y);

		_calcProperties();

		_calcProperties();
	}
	/**********************************************************
	@description   Rotate to an pAngle.
	**********************************************************/
	public function rotateTo( pAngle:Float ) : Void
	{
		//_vector.rotate( pAngle );
		//_p1.toPoint( _p0.addPointCopy(_vector));
		//2/29/16 BMayzak - Fixed memory leak
		_vector.rotateTo(pAngle);
		_p1.to(_p0.x + _vector.x, _p0.y + _vector.y);

		_calcProperties();
	}
	/**********************************************************
	@description 	Adjust the Origin pDist pixels backwards along the line vector.
	**********************************************************/
	public function shiftOrigin( pDist:Float ) : Void
	{
		var tShiftVector:WMPoint = _vector.reverseCopy();
		tShiftVector.length = pDist;
		_p0.addPoint(tShiftVector);
		tShiftVector.dispose();
		tShiftVector = null;
		_calcProperties();
	}
	/**********************************************************
	@description 	Adjust the Origin pDist pixels backwards along the line vector.
	**********************************************************/
	public function shiftEnd( pDist:Float ) : Void
	{
		length += pDist;
	}
	/**********************************************************
	@description
	**********************************************************/
	private function _calcProperties() : Void
	{
		// [3D] This is a 2D length equation. If you are using the Z axis you'd better go look up a 3D equation and stick it in here.
		_length = Math.round(Math.sqrt((_p0.x - _p1.x)*(_p0.x-_p1.x) + (_p0.y -_p1.y)*(_p0.y-_p1.y))*1000)/1000;
		// [3D] We're leaving out the Z on the vector here to.
		_vector.to(p1.x - p0.x, p1.y-p0.y);

		_slope = _vector.y/_vector.x;
		if(vector.x==0){_slope=100000;}
		_yIntercept = p0.y - _slope * p0.x;

		//_hyperplane 	= {a:p0.y - p1.y, b:p0.x - p1.x, d: (p0.y - p1.y) * p0.x + (p0.x - p1.x) * p0.y};

		_parametricDenom.to( p1.x-p0.x, p1.y-p0.y);

		_vector.pseudoCross(_normal);
		_normal.normalize();
	}
	/**********************************************************
	@description
	Runs a dot product calc on this line versus pLine's normal. Basically, asks if this line is moving toward the request line's surface, or away from it
	The Dot product returns a positive number if the vectors are facing each other, a negative if they're facing away, and 0 if they're perpendicular.
	**********************************************************/
	public function testLineDot( pLine:WMLine ) : Float
	{
		return _vector.dot( pLine.normal );
	}

	/**********************************************************
	@description
	Takes the line pLine and returns the line that results from projecting it onto this line. Does not account for segments.
	NOTE: This only seems to work for lines where p0 already rests on this line. It's more like completing the triangle than actual projection.
	NOTE: This formula pretty much sucks. I don't recommend using this unless for very broad applications until it's replaced.
	**********************************************************/
	public function projectOntoLine( pLine:WMLine ) : WMLine
	{

		// Get the distance from pLine.p0 to the projected point.
		//var tDist:Float = pLine.vector.dot( vector.normalizeCopy());
		// Now that we have the above information we can use the pythagorean theorum to finish the triangle:
		//var tLength:Float = Math.sqrt((pLine.length*pLine.length) - (tDist*tDist)) ;
		// Now we have the lengths of all lines. Find the coordinates of the point by drawing a vector of tLength length from the end-point of pLine to the line.
		//var tDiffLine:WMPoint = _normal.copy();
		//tDiffLine.length = tLength;
		//var tFinalPoint:WMPoint = pLine.p1.addPointCopy(tDiffLine);
		//return WMLine.request( pLine.p0.copy(), tFinalPoint );

		// The below is the same as the above, just compressed.
		var tDist:Float = pLine.vector.dot( vector.normalizeCopy());
		return WMLine.request().to( pLine.p0, pLine.p1.addPointCopy( _normal.copyAndResize( Math.sqrt((pLine.length*pLine.length) - (tDist*tDist)) )) );
	}

	/**********************************************************
	@description
	Uses the hyperplane form of the line for fast interception detection.
	**********************************************************/
	public function testLineIntercept( pLine:WMLine, pResult:InterceptResult=null ) : InterceptResult
	{
		// Slope/Intercept math works like this:
		// Find both Y-Ints (already done by line classes).
		// Compute the inverse determinate of the line slopes (1/(slopeA*-1 - slopeB*-1))
		// Use cramers rule to compute the xi and yi (intercept coordinate).
		// xi=((-1*yintB - -1*yintA)*det_inv);
		// yi=((slopeB*yintA - slopeA*yintB)*det_inv);
		// And we're done.

		//var yint:Float = (p0.y - _slope * p0.x);
		//var byint:Float = pLine.p0.y - pLine.slope*pLine.p0.x;
		//var detInv:Float = 1/(_slope*-1 - pLine.slope*-1);
		//var result:WMPoint = WMPoint.request( ((-1*byint - -1*yint)*detInv) , ((pLine.slope*yint - slope*byint)*detInv), 0 );

		if ( pResult == null ) {
			pResult = new InterceptResult(false);
		}

		_inverseDeterminate = 1/(_slope*-1 - pLine.slope*-1);
		pResult.success = true;
		var tRes = WMPoint.request( ((-1*pLine.yIntercept - -1*_yIntercept)*_inverseDeterminate) , ((pLine.slope*_yIntercept - slope*pLine.yIntercept)*_inverseDeterminate), 0 );
		pResult.result = tRes;
		tRes.dispose();
		tRes = null;
		return pResult;
	}

	/**********************************************************
	@description
	Use the slope/intercept form to determine if this line Segment intersects with pLine Segment.
	**********************************************************/
	public function testLineSegmentIntercept( pLine:WMLine , pDebug:Bool = false, pResult:InterceptResult=null ) : InterceptResult
	{

		//USING SLOPE/INTERCEPT FORM
		//_inverseDeterminate = 1/(_slope*-1 - pLine.slope*-1);
		//var tResult:WMPoint = WMPoint.request( ((-1*pLine.yIntercept - -1*_yIntercept)*_inverseDeterminate) , ((pLine.slope*_yIntercept - slope*pLine.yIntercept)*_inverseDeterminate), 0 );
		//if(pDebug) { trace("intercept point : "  +tResult); }
		//if( testPointSegmentIntercept( tResult, pDebug) && pLine.testPointSegmentIntercept( tResult, pDebug ) )
		//{
		//	return new InterceptResult( true, tResult);
		//}
		//return new InterceptResult( false , WMPoint.request(0,0,0));


		//	USING PARAMETRIC FORM:
		// S1 = <line1.x2, line1.y2> - <line1.x1, line1.y1>
		// S2 = <line2.x2, line2.y2> - <line2.x1, line2.y1>
		// split in x and y parts:
		// S1x = line1.x2 - line1.x1
		// S1y = line1.y2 - line1.y1
		// S2x = line2.x2 - line2.x1
		// S2y = line2.y2 - line2.y1
		//
		// U = <line1.x1, line1.y1> + t * S1, where 0 >= t <= 1
		// split in x and y parts:
		// Ux = line1.x1 + t * (line1.x2 - line1.x1)
		// Uy = line1.y1 + t * (line1.y2 - line1.y1)
		//
		// V = (line2.x1, line2.y1) + s * S2, where 0 >= s <= 1
		// Vx = line2.x1 + s * (line2.x2 - line2.x1)
		// Vy = line2.y1 + s * (line2.y2 - line2.y1)
		//
		// s = (-S1y * (line1.x1 - line2.x1) + S1x * (line1.y1 - line2.y1)) / (-S2x * S1y + S1x * S2y)
		// t = ( S2x * (line1.y1 - line2.y1) + S2y * (line1.x1 - line2.x1)) / (-S2x * S1y + S1x * S2y)

		// BECOMES THIS:

		//var S1x, S1y, S2x, S2y;
		//var div, s, t, dx, dy;
		//var ix, iy;

		//S1x = p1.x - p0.x;
		//S1y = p1.y - p0.y;
		//S2x = pLine.p1.x - pLine.p0.x;
		//S2y = pLine.p1.y - pLine.p0.y;

		//div = -S2x * S1y + S1x * S2y;
		//dx = p0.x - pLine.p0.x;
		//dy = p0.y - pLine.p0.y;
		//s = (-S1y * dx + S1x * dy) / div;
		//t = ( S2x * dy - S2y * dx) / div;

		//if (s >= 0.0 && s <= 1.0 && t >= 0.0 && t <= 1.0){ // intersection
		//	ix = p0.x + t * S1x;
		//	iy = p0.y + t * S1y;
		//	return new InterceptResult( true, WMPoint.request(ix,iy));
		//}


		// Simplifies to this:
		var tDiv:Float = -pLine.vector.x*_vector.y + _vector.x * pLine.vector.y;
		var tDx:Float = p0.x - pLine.p0.x;
		var tDy:Float = p0.y - pLine.p0.y;
		var tS:Float = (-_vector.y*tDx + _vector.x*tDy) / tDiv;
		var tT:Float = (pLine.vector.x * tDy - pLine.vector.y * tDx) / tDiv;

		if ( pResult == null ) {
			pResult = new InterceptResult(false);
		}

		pResult.success = false;
		if ( tS >= 0 && tS <= 1 && tT >= 0 && tT <= 1 ) {
			//trace("SUCCESS!");
			pResult.success = true;
			var tRes : WMPoint = WMPoint.request( p0.x + tT * _vector.x , p0.y + tT * _vector.y );
			pResult.result = tRes;
			tRes.dispose();
			tRes = null;
		}

		return pResult;
	}

	/**********************************************************
	@description
	Test if the point falls  on the line by using the parametric form of the line equation

		if 0<= t <= 1 then we're on!
		t = (x-x1)  =  (y-y1)
 			------     ------
    		(x2-x1)    (y2-y1)

	**********************************************************/
	public function testPointSegmentIntercept( pPoint:WMPoint, pDebug:Bool = false ) : Bool
	{
	    // calculate the xsegment overlap
		if(_parametricDenom.x == 0){ _xSegmentResult=0; }
		else { _xSegmentResult = (pPoint.x-p0.x) / _parametricDenom.x;}
		// calculate the y segment overlap
    	if(_parametricDenom.y == 0){ _ySegmentResult=0; }
    	else { _ySegmentResult	= (pPoint.y-p0.y) / _parametricDenom.y;}
    	// if both segments are within acceptable range, it's an intercept.
    	if(pDebug){ trace("Seg : " + _xSegmentResult + " , " + _ySegmentResult); }
	    if(_xSegmentResult>=0 && _xSegmentResult<=1 && _ySegmentResult>=0 && _ySegmentResult<=1)
	    {
			return true;
		}
		return false;
	}
	/**********************************************************
	@description
	**********************************************************/
	public function toString() : String {
		return "[WMLine] " + "("+_p0.x+", "+_p0.y+", "+_p0.z + ") ~> (" + _p1.x+", "+_p1.y+", "+_p1.z +") / Len: " + _length;
	}
}
