package workinman.display.spine.animation;

class RotateTimeline extends CurveTimeline {

	static private inline var PREV_FRAME_TIME:Int = -2;
	static private inline var FRAME_VALUE:Int = 1;

	public var boneIndex:Int;
	public var frames:Array<Float>; // time, value, ...

	public function new (frameCount:Int) {
		super(frameCount);
		frames = ArrayUtils.allocFloat(frameCount * 2);
	}

	public override function dispose() : Void
	{
		super.dispose();
		frames = null;
	}

	/** Sets the time and angle of the specified keyframe. */
	public function setFrame (frameIndex:Int, time:Float, angle:Float) : Void {
		frameIndex *= 2;
		frames[frameIndex] = time;
		frames[frameIndex + 1] = angle;
	}

	override public function apply (skeleton:Skeleton, lastTime:Float, time:Float, firedEvents:Array<Event>, alpha:Float) : Void {
		if (time < frames[0])
			return; // Time is before first frame.

		var bone:Bone = skeleton.bones[boneIndex];

		var amount:Float;
		if (time >= frames[frames.length - 2]) { // Time is after last frame.
			amount = bone.data.rotation + frames[frames.length - 1] - bone.rotation;
			while (amount > 180)
				amount -= 360;
			while (amount < -180)
				amount += 360;
			bone.rotation += amount * alpha;
			return;
		}

		// Interpolate between the previous frame and the current frame.
		var frameIndex:Int = Animation.binarySearch(frames, time, 2);
		var prevFrameValue:Float = frames[frameIndex - 1];
		var frameTime:Float = frames[frameIndex];
		var percent:Float = 1 - (time - frameTime) / (frames[frameIndex + PREV_FRAME_TIME] - frameTime);
		percent = getCurvePercent(Math.floor(frameIndex / 2 - 1), percent < 0 ? 0 : (percent > 1 ? 1 : percent));

		amount = frames[frameIndex + FRAME_VALUE] - prevFrameValue;
		while (amount > 180)
			amount -= 360;
		while (amount < -180)
			amount += 360;
		amount = bone.data.rotation + (prevFrameValue + amount * percent) - bone.rotation;
		while (amount > 180)
			amount -= 360;
		while (amount < -180)
			amount += 360;
		bone.rotation += amount * alpha;
	}
}
