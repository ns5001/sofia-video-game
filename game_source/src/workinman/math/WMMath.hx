package workinman.math;

import flambe.math.Rectangle;

class WMMath
{
	static public function sign(pNum:Float) : Int
	{
		if(pNum < 0)
			return -1;

		return 1;
	}

	static public function diffBetweenPoints( p0:WMPoint, p1:WMPoint, pResult:WMPoint ) : Void {
		pResult.toPoint(p1);
		pResult.subtractPoint(p0);
	}

	static public function distBetweenPoints( p0:WMPoint, p1:WMPoint) : Float {
		return Math.abs(Math.sqrt( ((p0.x-p1.x) * (p0.x-p1.x)) + ((p0.y-p1.y) * (p0.y-p1.y)) ));
	}

	static public function testRectangleIntersection( pR1:Rectangle, pR2:Rectangle ) : Bool {
		return ! ( 	pR2.x > pR1.x + pR1.width ||
					pR2.x + pR2.width < pR1.x ||
					pR2.y > pR1.y + pR1.height ||
					pR2.y + pR2.height < pR1.y );
	}

	static public function testWMRectangleIntersection( pR1:WMRectangle, pR2:WMRectangle ) : Bool {
		return ! ( 	pR2.x > pR1.x + pR1.width ||
					pR2.x + pR2.width < pR1.x ||
					pR2.y > pR1.y + pR1.height ||
					pR2.y + pR2.height < pR1.y );
	}

	static public function getIntersection(pR1:WMRectangle, pR2:WMRectangle, out:WMRectangle) : Void {
		out.x = Math.max(pR1.x, pR2.x);
		out.y = Math.max(pR1.y, pR2.y);
		out.width = Math.min(pR1.right, pR2.right) - out.x;
		out.height = Math.min(pR1.bottom, pR2.bottom) - out.y;
	}

	static public function clamp(pNum:Float, pMin:Float, pMax:Float, pCircular:Bool = false):Float{
		if(!pCircular){
			if(pNum > pMax){
				pNum = pMax;
			}
			else if(pNum < pMin){
				pNum = pMin;
			}
		}else{
			if(pNum > pMax){
				pNum = pMin;
			}
			else if(pNum < pMin){
				pNum = pMax;
			}
		}
		return pNum;
	}

	public static function normalizeAngle(pAngle:Float) {
		while (pAngle < -180) {
			pAngle += 360;
		}
		while (pAngle > 180) {
			pAngle -= 360;
		}
		return pAngle;
	}

	static public function vectorPointToLine( point:WMPoint, refPoint:WMPoint, lineSegment:WMPoint, pResult:WMPoint ) : Void {
		var pointToReference:WMPoint = WMPoint.request();
		var projectionToLine:WMPoint;
		var pointToLine:WMPoint = WMPoint.request();

		//a = refPoint
		//p = point
		//n = normalized lineSegment
		//pointToLine = (a-p) - ((a-p) dot n)n

		lineSegment.normalize();
		WMMath.diffBetweenPoints(point, refPoint,pointToReference);
		projectionToLine = lineSegment.multiplyCopy(pointToReference.dot(lineSegment));
		WMMath.diffBetweenPoints(projectionToLine, pointToReference,pointToLine);
		pointToLine.normalize();

		pResult.toPoint(pointToLine);

		pointToReference.dispose();
		pointToReference = null;
		pointToLine.dispose();
		pointToLine = null;
		projectionToLine.dispose();
		projectionToLine = null;
	}

	public static function testSweepCollision<T:ISweepTarget>( pStart:WMPoint, pDestX:Float, pDestY:Float, pRadius:Float, pTargets:Array<T>, pResults:Array<T> ) : Void {
		// Translate everything so that line segment start point to (0, 0)
		var a : Float = pDestX-pStart.x; // Line segment end point horizontal coordinate
		var b : Float = pDestY-pStart.y; // Line segment end point vertical coordinate
		var aa : Float = a*a;
		var bb : Float = b*b;

		var c : Float;
		var d : Float;
		var cb : Float;
		var da : Float;
		var ca : Float;
		var db : Float;
		var tRadius : Float;

		// Clear out the array coming in
		while ( pResults.length > 0 ) {
			pResults.pop();
		}

		// TODO Give this a slight tolerance because they're floats
		if ( a == 0 && b == 0 ) {
			// Not moving, didn't hit
			return;
		}

		for ( t in pTargets ) {
			c = t.pos.x-pStart.x; // Circle center horizontal coordinate
			d = t.pos.y-pStart.y; // Circle center vertical coordinate
			cb = c*b;
			da = d*a;
			tRadius = ((t.radius + pRadius) * (t.radius + pRadius));

			// Collision computation
			if ( (da-cb)*(da-cb) <= tRadius * (aa + bb)) {
				// Collision is possible
				if (c*c + d*d <= tRadius ) {
					pResults.push(t);
					continue;
				}
				if ((a-c)*(a-c) + (b-d)*(b-d) <= tRadius ) {
					pResults.push(t);
					continue;
				}
				ca = c*a;
				db = d*b;
				if ( ca + db >= 0 && ca + db <= aa + bb) {
					pResults.push(t);
					continue;
				}
			}
		}
	}

}
