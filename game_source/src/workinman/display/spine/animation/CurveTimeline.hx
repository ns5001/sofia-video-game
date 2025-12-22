package workinman.display.spine.animation;

/** Base class for frames that use an Interpolation bezier curve. */
class CurveTimeline implements Timeline {
	
	static private inline var LINEAR:Float = 0;
	static private inline var STEPPED:Float = 1;
	static private inline var BEZIER:Float = 2;
	static private inline var BEZIER_SEGMENTS:Int = 10;
	static private inline var BEZIER_SIZE:Int = BEZIER_SEGMENTS * 2 - 1;

	private var curves:Array<Float>; // type, x, y, ...

	public function new (frameCount:Int) {
		curves = ArrayUtils.allocFloat((frameCount - 1) * BEZIER_SIZE);
	}

	public function dispose() : Void
	{
		curves = null;
	}

	public function apply (skeleton:Skeleton, lastTime:Float, time:Float, firedEvents:Array<Event>, alpha:Float) : Void {
	}

	public var frameCount (get, never) : Int;
	private function get_frameCount () : Int {
		return Math.floor(curves.length / BEZIER_SIZE + 1);
	}

	public function setLinear (frameIndex:Int) : Void {
		curves[Math.floor(frameIndex * BEZIER_SIZE)] = LINEAR;
	}

	public function setStepped (frameIndex:Int) : Void {
		curves[Math.floor(frameIndex * BEZIER_SIZE)] = STEPPED;
	}

	/** Sets the control handle positions for an Interpolation bezier curve used to transition from this keyframe to the next.
	 * cx1 and cx2 are from 0 to 1, representing the percent of time between the two keyframes. cy1 and cy2 are the percent of
	 * the difference between the keyframe's values. */
	public function setCurve (frameIndex:Int, cx1:Float, cy1:Float, cx2:Float, cy2:Float) : Void {
		var subdiv1:Float = 1 / BEZIER_SEGMENTS, subdiv2:Float = subdiv1 * subdiv1, subdiv3:Float = subdiv2 * subdiv1;
		var pre1:Float = 3 * subdiv1, pre2:Float = 3 * subdiv2, pre4:Float = 6 * subdiv2, pre5:Float = 6 * subdiv3;
		var tmp1x:Float = -cx1 * 2 + cx2, tmp1y:Float = -cy1 * 2 + cy2, tmp2x:Float = (cx1 - cx2) * 3 + 1, tmp2y:Float = (cy1 - cy2) * 3 + 1;
		var dfx:Float = cx1 * pre1 + tmp1x * pre2 + tmp2x * subdiv3, dfy:Float = cy1 * pre1 + tmp1y * pre2 + tmp2y * subdiv3;
		var ddfx:Float = tmp1x * pre4 + tmp2x * pre5, ddfy:Float = tmp1y * pre4 + tmp2y * pre5;
		var dddfx:Float = tmp2x * pre5, dddfy:Float = tmp2y * pre5;

		var i:Int = frameIndex * BEZIER_SIZE;
		var curves:Array<Float> = this.curves;
		curves[i++] = BEZIER;

		var x:Float = dfx, y:Float = dfy;
		var n:Int = i + BEZIER_SIZE - 1;
		while(i < n) {
			curves[i] = x;
			curves[i + 1] = y;
			dfx += ddfx;
			dfy += ddfy;
			ddfx += dddfx;
			ddfy += dddfy;
			x += dfx;
			y += dfy;
			i += 2;
		}
	}

	public function getCurvePercent (frameIndex:Int, percent:Float) : Float {
		var curves:Array<Float> = this.curves;
		var i:Int = frameIndex * BEZIER_SIZE;
		var type:Float = curves[i];
		if (type == LINEAR) return percent;
		if (type == STEPPED) return 0;
		i++;
		var x:Float = 0;
		var start:Int = i;
		var n:Int = i + BEZIER_SIZE - 1;
		while(i < n) {
			x = curves[i];
			if (x >= percent) {
				var prevX:Float, prevY:Float;
				if (i == start) {
					prevX = 0;
					prevY = 0;
				} else {
					prevX = curves[i - 2];
					prevY = curves[i - 1];
				}
				return prevY + (curves[i + 1] - prevY) * (percent - prevX) / (x - prevX);
			}
			i += 2;
		}
		var y:Float = curves[i - 1];
		return y + (1 - y) * (percent - x) / (1 - x); // Last point is 1,1.
	}
}
