package workinman.display.spine.animation;

typedef Function = Dynamic;

class TrackEntry {

	public var next:TrackEntry;
	public var previous:TrackEntry;
	public var animation:Animation;
	public var loop:Bool;
	public var delay:Float;
	public var time:Float = 0;
	public var lastTime:Float = -1;
	public var endTime:Float;
	public var timeScale:Float = 1;
	public var mixTime:Float;
	public var mixDuration:Float;
	public var mix:Float = 1;
	public var onStart:Function;
	public var onEnd:Function;
	public var onComplete:Function;
	public var onEvent:Function;

	public function new() {
		
	}

	public function dispose():Void {
		next = null;
		previous = null;
		animation = null;
		onStart = null;
		onEnd = null;
		onComplete = null;
		onEvent = null;
	}

	public function toString () : String {
		return animation == null ? "<none>" : animation.name;
	}
}
