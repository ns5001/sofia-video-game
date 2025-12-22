package workinman.display.spine.animation;

import workinman.display.spine.attachments.Attachment;

class FfdTimeline extends CurveTimeline {

	public var slotIndex:Int;
	public var frames:Array<Float>;
	public var frameVertices:Array<Array<Float>>;
	public var attachment:Attachment;

	public function new (frameCount:Int) {
		super(frameCount);
		frames = ArrayUtils.allocFloat(frameCount);
		frameVertices = ArrayUtils.allocFloatArray(frameCount);
	}

	public override function dispose() : Void
	{
		super.dispose();
		frames = null;
		frameVertices = null;
		attachment = null;
	}

	/** Sets the time and value of the specified keyframe. */
	public function setFrame (frameIndex:Int, time:Float, vertices:Array<Float>) : Void {
		frames[frameIndex] = time;
		frameVertices[frameIndex] = vertices;
	}

	override public function apply (skeleton:Skeleton, lastTime:Float, time:Float, firedEvents:Array<Event>, alpha:Float) : Void {
		var slot:Slot = skeleton.slots[slotIndex];
		if (slot.attachment != attachment) return;

		var frames:Array<Float> = this.frames;
		if (time < frames[0]) return; // Time is before first frame.

		var frameVertices:Array<Array<Float>> = this.frameVertices;
		var vertexCount:Int = frameVertices[0].length;

		var vertices:Array<Float> = slot.attachmentVertices;
		if (vertices.length != vertexCount) alpha = 1; // Don't mix from uninitialized slot vertices.

		var i:Int;
		if (time >= frames[frames.length - 1]) { // Time is after last frame.
			var lastVertices:Array<Float> = frameVertices[frames.length - 1];
			if (alpha < 1) {
				for(i in 0...vertexCount)
					vertices[i] += (lastVertices[i] - vertices[i]) * alpha;
			} else {
				for(i in 0...vertexCount)
					vertices[i] = lastVertices[i];
			}
			return;
		}

		// Interpolate between the previous frame and the current frame.
		var frameIndex:Int = Animation.binarySearch1(frames, time);
		var frameTime:Float = frames[frameIndex];
		var percent:Float = 1 - (time - frameTime) / (frames[frameIndex - 1] - frameTime);
		percent = getCurvePercent(frameIndex - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent));

		var prevVertices:Array<Float> = frameVertices[frameIndex - 1];
		var nextVertices:Array<Float> = frameVertices[frameIndex];

		var prev:Float;
		if (alpha < 1) {
			for(i in 0...vertexCount) {
				prev = prevVertices[i];
				vertices[i] += (prev + (nextVertices[i] - prev) * percent - vertices[i]) * alpha;
			}
		} else {
			for(i in 0...vertexCount) {
				prev = prevVertices[i];
				vertices[i] = prev + (nextVertices[i] - prev) * percent;
			}
		}
	}
}
