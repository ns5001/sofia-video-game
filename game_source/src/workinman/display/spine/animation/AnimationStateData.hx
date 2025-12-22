package workinman.display.spine.animation;

import workinman.display.spine.Exception;

class AnimationStateData {

	private var _skeletonData:SkeletonData;
	private var animationToMixTime:Map<String, Float>;
	public var defaultMix:Float = 0;

	public function new (skeletonData:SkeletonData) {
		_skeletonData = skeletonData;
		animationToMixTime = new Map<String, Float>();
	}

	public function dispose():Void {
		animationToMixTime = null;
		_skeletonData = null;
	}

	public var skeletonData (get, never) : SkeletonData;
	public function get_skeletonData () : SkeletonData {
		return _skeletonData;
	}

	public function setMixByName (fromName:String, toName:String, duration:Float) : Void {
		var from:Animation = _skeletonData.findAnimation(fromName);
		if (from == null) throw new IllegalArgumentException("Animation not found: " + fromName);
		var to:Animation = _skeletonData.findAnimation(toName);
		if (to == null) throw new IllegalArgumentException("Animation not found: " + toName);
		setMix(from, to, duration);
	}

	public function setMix (from:Animation, to:Animation, duration:Float) : Void {
		if (from == null) throw new IllegalArgumentException("from cannot be null.");
		if (to == null) throw new IllegalArgumentException("to cannot be null.");
		animationToMixTime[from.name + ":" + to.name] = duration;
	}

	public function getMix (from:Animation, to:Animation) : Float {
		var time:Dynamic = animationToMixTime[from.name + ":" + to.name];
		if (time == null) return defaultMix;
		return time;
	}
}
