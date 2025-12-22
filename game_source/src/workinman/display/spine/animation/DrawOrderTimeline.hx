package workinman.display.spine.animation;

class DrawOrderTimeline implements Timeline {

	public var frames:Array<Float>; // time, ...
	public var drawOrders:Array<Array<Int>>;

	public function new (frameCount:Int) {
		frames = ArrayUtils.allocFloat(frameCount);
		drawOrders = ArrayUtils.allocIntArray(frameCount);
	}

	public function dispose() : Void
	{
		frames = null;
		drawOrders = null;
	}

	public var frameCount (get, never) : Int;
	private function get_frameCount () : Int {
		return frames.length;
	}

	/** Sets the time and value of the specified keyframe. */
	public function setFrame (frameIndex:Int, time:Float, drawOrder:Array<Int>) : Void {
		frames[frameIndex] = time;
		drawOrders[frameIndex] = drawOrder;
	}

	public function apply (skeleton:Skeleton, lastTime:Float, time:Float, firedEvents:Array<Event>, alpha:Float) : Void {
		if (time < frames[0])
			return; // Time is before first frame.

		var frameIndex:Int;
		if (time >= frames[frames.length - 1]) // Time is after last frame.
			frameIndex = frames.length - 1;
		else
			frameIndex = Animation.binarySearch1(frames, time) - 1;

		var drawOrder:Array<Slot> = skeleton.drawOrder;
		var slots:Array<Slot> = skeleton.slots;
		var drawOrderToSetupIndex:Array<Int> = drawOrders[frameIndex];
		var i:Int = 0;
		if (drawOrderToSetupIndex == null) {
			for (slot in slots)
				drawOrder[i++] = slot;
		} else {
			for (setupIndex in drawOrderToSetupIndex)
				drawOrder[i++] = slots[setupIndex];
		}
	}
}
