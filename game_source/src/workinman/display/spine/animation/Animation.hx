package workinman.display.spine.animation;

import workinman.display.spine.Exception;

class Animation {

	private var _name:String;
	private var _timelines:Array<Timeline>;
	public var duration:Float;
	public var currentTime:Float;

	public function new (name:String, timelines:Array<Timeline>, duration:Float) {
		if (name == null) throw new IllegalArgumentException("name cannot be null.");
		if (timelines == null) throw new IllegalArgumentException("timelines cannot be null.");
		_name = name;
		_timelines = timelines;
		this.duration = duration;
	}

	public function dispose() : Void
	{
		for(t in _timelines) {
			t.dispose();
		}
		_timelines = null;
	}

	public var timelines(get, never): Array<Timeline>;
	private function get_timelines () : Array<Timeline> {
		return _timelines;
	}

	/** Poses the skeleton at the specified time for this animation. */
	public function apply (skeleton:Skeleton, lastTime:Float, time:Float, loop:Bool, events:Array<Event>) : Void {
		if (skeleton == null) throw new IllegalArgumentException("skeleton cannot be null.");

		if (loop && duration != 0) {
			time %= duration;
			if (lastTime > 0) lastTime %= duration;
		}

		for (i in 0...timelines.length) {
			timelines[i].apply(skeleton, lastTime, time, events, 1);
		}
		currentTime = time;
	}

	/** Poses the skeleton at the specified time for this animation mixed with the current pose.
	 * @param alpha The amount of this animation that affects the current pose. */
	public function mix (skeleton:Skeleton, lastTime:Float, time:Float, loop:Bool, events:Array<Event>, alpha:Float) : Void {
		if (skeleton == null) throw new IllegalArgumentException("skeleton cannot be null.");

		if (loop && duration != 0) {
			time %= duration;
			if (lastTime > 0) lastTime %= duration;
		}

		for (i in 0...timelines.length) {
			timelines[i].apply(skeleton, lastTime, time, events, alpha);
		}
	}

	public var name (get, never) : String;
	private function get_name () : String {
		return _name;
	}

	public function toString () : String {
		return _name;
	}

	/** @param target After the first and before the last entry. */
	static public function binarySearch (values:Array<Float>, target:Float, step:Int) : Int {
		var low:Int = 0;
		var high:Int = Math.floor(values.length / step - 2);
		if (high == 0)
			return step;
		var current:Int = high >>> 1;
		while (true) {
			if (values[(current + 1) * step] <= target)
				low = current + 1;
			else
				high = current;
			if (low == high)
				return (low + 1) * step;
			current = (low + high) >>> 1;
		}
		return 0; // Can't happen.
	}

	/** @param target After the first and before the last entry. */
	static public function binarySearch1 (values:Array<Float>, target:Float) : Int {
		var low:Int = 0;
		var high:Int = values.length - 2;
		if (high == 0)
			return 1;
		var current:Int = high >>> 1;
		while (true) {
			if (values[current + 1] <= target)
				low = current + 1;
			else
				high = current;
			if (low == high)
				return low + 1;
			current = (low + high) >>> 1;
		}
		return 0; // Can't happen.
	}

	static public function linearSearch (values:Array<Float>, target:Float, step:Int) : Int {
		for(i in 0...values.length - step) {
			if (values[i] > target)
				return i;
		}
		return -1;
	}
}
