package workinman.display.spine.animation;

class ColorTimeline extends CurveTimeline {

	static private inline var PREV_FRAME_TIME:Int = -5;
	static private inline var FRAME_R:Int = 1;
	static private inline var FRAME_G:Int = 2;
	static private inline var FRAME_B:Int = 3;
	static private inline var FRAME_A:Int = 4;

	public var slotIndex:Int;
	public var frames:Array<Float>; // time, r, g, b, a, ...

	public function new (frameCount:Int) {
		super(frameCount);
		frames = ArrayUtils.allocFloat(frameCount);
	}

	public override function dispose() : Void
	{
		super.dispose();
	}

	/** Sets the time and value of the specified keyframe. */
	public function setFrame (frameIndex:Int, time:Float, r:Float, g:Float, b:Float, a:Float) : Void {
		frameIndex *= 5;
		frames[frameIndex] = time;
		frames[frameIndex + 1] = r;
		frames[frameIndex + 2] = g;
		frames[frameIndex + 3] = b;
		frames[frameIndex + 4] = a;
	}

	override public function apply (skeleton:Skeleton, lastTime:Float, time:Float, firedEvents:Array<Event>, alpha:Float) : Void {
		if (time < frames[0])
			return; // Time is before first frame.

		var r:Float, g:Float, b:Float, a:Float;
		if (time >= frames[frames.length - 5]) {
			// Time is after last frame.
			var i:Int = frames.length - 1;
			r = frames[i - 3];
			g = frames[i - 2];
			b = frames[i - 1];
			a = frames[i];
		} else {
			// Interpolate between the previous frame and the current frame.
			var frameIndex:Int = Animation.binarySearch(frames, time, 5);
			var prevFrameR:Float = frames[frameIndex - 4];
			var prevFrameG:Float = frames[frameIndex - 3];
			var prevFrameB:Float = frames[frameIndex - 2];
			var prevFrameA:Float = frames[frameIndex - 1];
			var frameTime:Float = frames[frameIndex];
			var percent:Float = 1 - (time - frameTime) / (frames[frameIndex + PREV_FRAME_TIME] - frameTime);
			percent = getCurvePercent(Math.floor(frameIndex / 5 - 1), percent < 0 ? 0 : (percent > 1 ? 1 : percent));

			r = prevFrameR + (frames[frameIndex + FRAME_R] - prevFrameR) * percent;
			g = prevFrameG + (frames[frameIndex + FRAME_G] - prevFrameG) * percent;
			b = prevFrameB + (frames[frameIndex + FRAME_B] - prevFrameB) * percent;
			a = prevFrameA + (frames[frameIndex + FRAME_A] - prevFrameA) * percent;
		}
		var slot:Slot = skeleton.slots[slotIndex];
		if (alpha < 1) {
			slot.r += (r - slot.r) * alpha;
			slot.g += (g - slot.g) * alpha;
			slot.b += (b - slot.b) * alpha;
			slot.a += (a - slot.a) * alpha;
		} else {
			slot.r = r;
			slot.g = g;
			slot.b = b;
			slot.a = a;
		}
	}
}
