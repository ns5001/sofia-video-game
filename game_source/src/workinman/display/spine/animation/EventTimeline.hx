package workinman.display.spine.animation;

class EventTimeline implements Timeline {

	public var frames:Array<Float>; // time, ...
	public var events:Array<Event>;

	public function new (frameCount:Int) {
		frames = ArrayUtils.allocFloat(frameCount);
		events = new Array<Event>();
		for(i in 0...frameCount) {
			events.push(null);
		}
	}

	public function dispose() : Void
	{
		frames = null;
		events = null;
	}

	public var frameCount (get, never) : Int;
	public function get_frameCount () : Int {
		return frames.length;
	}

	/** Sets the time and value of the specified keyframe. */
	public function setFrame (frameIndex:Int, event:Event) : Void {
		frames[frameIndex] = event.time;
		events[frameIndex] = event;
	}

	/** Fires events for frames > lastTime and <= time. */
	public function apply (skeleton:Skeleton, lastTime:Float, time:Float, firedEvents:Array<Event>, alpha:Float) : Void {
		if (firedEvents == null) return;

		if (lastTime > time) { // Fire events after last time for looped animations.
			apply(skeleton, lastTime, Math.POSITIVE_INFINITY, firedEvents, alpha);
			lastTime = -1;
		} else if (lastTime >= frames[frameCount - 1]) // Last time is after last frame.
			return;
		if (time < frames[0]) return; // Time is before first frame.

		var frameIndex:Int;
		if (lastTime < frames[0])
			frameIndex = 0;
		else {
			frameIndex = Animation.binarySearch1(frames, lastTime);
			var frame:Float = frames[frameIndex];
			while (frameIndex > 0) { // Fire multiple events with the same frame.
				if (frames[frameIndex - 1] != frame) break;
				frameIndex--;
			}
		}
		while(frameIndex < frameCount && time >= frames[frameIndex]) {
			firedEvents[firedEvents.length] = events[frameIndex];
			frameIndex++;
		}
	}
}
