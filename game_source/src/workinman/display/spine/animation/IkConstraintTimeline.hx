package workinman.display.spine.animation;

class IkConstraintTimeline extends CurveTimeline {

	static private inline var PREV_FRAME_TIME:Int = -3;
	static private inline var PREV_FRAME_MIX:Int = -2;
	static private inline var PREV_FRAME_BEND_DIRECTION:Int = -1;
	static private inline var FRAME_MIX:Int = 1;

	public var ikConstraintIndex:Int;
	public var frames:Array<Float>; // time, mix, bendDirection, ...

	public function new (frameCount:Int) {
		super(frameCount);
		frames = ArrayUtils.allocFloat(frameCount);
	}

	public override function dispose() : Void
	{
		super.dispose();
		frames = null;
	}

	/** Sets the time, mix and bend direction of the specified keyframe. */
	public function setFrame (frameIndex:Int, time:Float, mix:Float, bendDirection:Int) : Void {
		frameIndex *= 3;
		frames[frameIndex] = time;
		frames[frameIndex + 1] = mix;
		frames[frameIndex + 2] = bendDirection;
	}

	override public function apply (skeleton:Skeleton, lastTime:Float, time:Float, firedEvents:Array<Event>, alpha:Float) : Void {
		if (time < frames[0]) return; // Time is before first frame.

		var ikConstraint:IkConstraint = skeleton.ikConstraints[ikConstraintIndex];

		if (time >= frames[frames.length - 3]) { // Time is after last frame.
			ikConstraint.mix += (frames[frames.length - 2] - ikConstraint.mix) * alpha;
			ikConstraint.bendDirection = Math.floor(frames[frames.length - 1]);
			return;
		}

		// Interpolate between the previous frame and the current frame.
		var frameIndex:Int = Animation.binarySearch(frames, time, 3);
		var prevFrameMix:Float = frames[frameIndex + PREV_FRAME_MIX];
		var frameTime:Float = frames[frameIndex];
		var percent:Float = 1 - (time - frameTime) / (frames[frameIndex + PREV_FRAME_TIME] - frameTime);
		percent = getCurvePercent(Math.floor(frameIndex / 3 - 1), percent < 0 ? 0 : (percent > 1 ? 1 : percent));

		var mix:Float = prevFrameMix + (frames[frameIndex + FRAME_MIX] - prevFrameMix) * percent;
		ikConstraint.mix += (mix - ikConstraint.mix) * alpha;
		ikConstraint.bendDirection = Math.floor(frames[frameIndex + PREV_FRAME_BEND_DIRECTION]);
	}
}
