package workinman.display.spine.animation;

interface Timeline {
	
	/** Sets the value(s) for the specified time. */
	function apply (skeleton:Skeleton, lastTime:Float, time:Float, firedEvents:Array<Event>, alpha:Float) : Void;
	function dispose() : Void;
}
