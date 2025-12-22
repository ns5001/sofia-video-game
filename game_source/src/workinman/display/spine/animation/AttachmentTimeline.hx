package workinman.display.spine.animation;

class AttachmentTimeline implements Timeline {
	
	public var slotIndex:Int;
	public var frames:Array<Float>; // time, ...
	public var attachmentNames:Array<String>;

	public function new (frameCount:Int) {
		frames = ArrayUtils.allocFloat(frameCount);
		attachmentNames = ArrayUtils.allocString(frameCount);
	}

	public function dispose() : Void
	{
		frames = null;
		attachmentNames = null;
	}

	public var frameCount (get, never) : Int;
	public function get_frameCount () : Int {
		return frames.length;
	}

	/** Sets the time and value of the specified keyframe. */
	public function setFrame (frameIndex:Int, time:Float, attachmentName:String) : Void {
		frames[frameIndex] = time;
		attachmentNames[frameIndex] = attachmentName;
	}

	public function apply (skeleton:Skeleton, lastTime:Float, time:Float, firedEvents:Array<Event>, alpha:Float) : Void {
		var frames:Array<Float> = this.frames;
		if (time < frames[0]) {
			if (lastTime > time) apply(skeleton, lastTime, Math.POSITIVE_INFINITY, null, 0);
			return;
		} else if (lastTime > time) //
			lastTime = -1;

		var frameIndex:Int = time >= frames[frames.length - 1] ? frames.length - 1 : Animation.binarySearch1(frames, time) - 1;
		if (frames[frameIndex] < lastTime) return;

		var attachmentName:String = attachmentNames[frameIndex];
		skeleton.slots[slotIndex].attachment = attachmentName == null ? null : skeleton.getAttachmentForSlotIndex(slotIndex, attachmentName);
	}
}
