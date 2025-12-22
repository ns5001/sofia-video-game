package workinman.display.spine.animation;

import workinman.math.WMMath;

class ShearTimeline extends TranslateTimeline {

	public function new (frameCount:Int) {
		super(frameCount);
	}

	public override  function dispose() : Void
	{
		super.dispose();
	}

	override public function apply (skeleton:Skeleton, lastTime:Float, time:Float, firedEvents:Array<Event>, alpha:Float) : Void {
		if (time < frames[0])
			return; // Time is before first frame.

		var bone:Bone = skeleton.bones[boneIndex];
		if (time >= frames[frames.length - 3]) { // Time is after last frame.
			bone.shearX += (bone.data.shearX + frames[frames.length - 2] - bone.shearX) * alpha;
			bone.shearY += (bone.data.shearY + frames[frames.length - 1] - bone.shearY) * alpha;
			return;
		}

		// Interpolate between the previous frame and the current frame.
		var frameIndex:Int = Animation.binarySearch(frames, time, 3);
		var prevFrameX:Float = frames[frameIndex - 2];
		var prevFrameY:Float = frames[frameIndex - 1];
		var frameTime:Float = frames[frameIndex];
		var percent:Float = WMMath.clamp(1 - (time - frameTime) / (frames[frameIndex + PREV_FRAME_TIME] - frameTime), 0, 1);
		percent = getCurvePercent(Math.floor(frameIndex / 3 - 1), percent);

		bone.shearX += (bone.data.shearX + (prevFrameX + (frames[frameIndex + FRAME_X] - prevFrameX) * percent) - bone.shearX) * alpha;
		bone.shearY += (bone.data.shearY + (prevFrameY + (frames[frameIndex + FRAME_Y] - prevFrameY) * percent) - bone.shearY) * alpha;
	}
}
