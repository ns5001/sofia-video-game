package workinman.display.spine.animation;

class TranslateTimeline extends CurveTimeline {
	
	public var PREV_FRAME_TIME:Int = -3;
	public var FRAME_X:Int = 1;
	public var FRAME_Y:Int = 2;

	public var boneIndex:Int;
	public var frames:Array<Float>; // time, value, value, ...

	public function new (frameCount:Int) {
		super(frameCount);
		frames = ArrayUtils.allocFloat(frameCount);
	}

	public override function dispose() : Void
	{
		super.dispose();
		frames = null;
	}

	/** Sets the time and value of the specified keyframe. */
	public function setFrame (frameIndex:Int, time:Float, x:Float, y:Float) : Void {
		frameIndex *= 3;
		frames[frameIndex] = time;
		frames[frameIndex + 1] = x;
		frames[frameIndex + 2] = y;
	}

	override public function apply (skeleton:Skeleton, lastTime:Float, time:Float, firedEvents:Array<Event>, alpha:Float) : Void {
		if (time < frames[0])
			return; // Time is before first frame.

		var bone:Bone = skeleton.bones[boneIndex];

		if (time >= frames[frames.length - 3]) { // Time is after last frame.
			bone.x += (bone.data.x + frames[frames.length - 2] - bone.x) * alpha;
			bone.y += (bone.data.y + frames[frames.length - 1] - bone.y) * alpha;
			return;
		}

		// Interpolate between the previous frame and the current frame.
		var frameIndex:Int = Animation.binarySearch(frames, time, 3);
		var prevFrameX:Float = frames[frameIndex - 2];
		var prevFrameY:Float = frames[frameIndex - 1];
		var frameTime:Float = frames[frameIndex];
		var percent:Float = 1 - (time - frameTime) / (frames[frameIndex + PREV_FRAME_TIME] - frameTime);
		percent = getCurvePercent(Math.floor(frameIndex / 3 - 1), percent < 0 ? 0 : (percent > 1 ? 1 : percent));

		bone.x += (bone.data.x + prevFrameX + (frames[frameIndex + FRAME_X] - prevFrameX) * percent - bone.x) * alpha;
		bone.y += (bone.data.y + prevFrameY + (frames[frameIndex + FRAME_Y] - prevFrameY) * percent - bone.y) * alpha;
	}
}
