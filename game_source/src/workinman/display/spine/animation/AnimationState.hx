package workinman.display.spine.animation;

import workinman.display.spine.Exception;

class AnimationState {

	private var _data:AnimationStateData;
	private var _tracks:Array<TrackEntry>;
	private var _events:Array<Event>;
	public var onStart:Listeners;
	public var onEnd:Listeners;
	public var onComplete:Listeners;
	public var onEvent:Listeners;
	public var timeScale:Float = 1;

	public function new (data:AnimationStateData) {
		if (data == null) throw new IllegalArgumentException("data cannot be null.");

		_data = data;
		_tracks = new Array<TrackEntry>();
		_events= new Array<Event>();
		onStart = new Listeners();
		onEnd = new Listeners();
		onComplete = new Listeners();
		onEvent = new Listeners();
	}

	public function dispose():Void {
		_data.dispose();
		_data = null;
		for(t in _tracks) {
			if (t != null) {
				t.dispose();
			}
		}
		_tracks = null;
		for(e in _events) {
			e.dispose();
		}
		_events = null;
		onStart.dispose();
		onStart = null;
		onEnd.dispose();
		onEnd = null;
		onComplete.dispose();
		onComplete = null;
		onEvent.dispose();
		onEvent = null;
	}

	public var data(get, never) : AnimationStateData;
	private function get_data() : AnimationStateData { return _data; }

	public function update (delta:Float) : Void {
		delta *= timeScale;
		for(i in 0..._tracks.length) {
			var current:TrackEntry = _tracks[i];
			if (current == null) continue;

			current.time += delta * current.timeScale;
			if (current.previous != null) {
				var previousDelta:Float = delta * current.previous.timeScale;
				current.previous.time += previousDelta;
				current.mixTime += previousDelta;
			}

			var next:TrackEntry = current.next;
			var lastTime:Float = current.lastTime;
			if(current.timeScale < 0) {
				lastTime = Math.abs(lastTime);
			}
			if (next != null) {
				next.time = lastTime - next.delay;
				if (next.time >= 0) setCurrent(i, next);
			} else {
				// End non-looping animation when it reaches its end time and there is no next entry.
				if (!current.loop && lastTime >= current.endTime) clearTrack(i);
			}
		}
	}

	public function apply (skeleton:Skeleton) : Void {
		for(i in 0..._tracks.length) {
			var current:TrackEntry = _tracks[i];
			if (current == null) continue;

			_events = new Array<Event>();

			var time:Float = current.time;
			var lastTime:Float = current.lastTime;
			var endTime:Float = current.endTime;
			var loop:Bool = current.loop;
			if (!loop && time > endTime) time = endTime;

			if(current.timeScale < 0) {
				while(time < 0) {
					time += current.animation.duration;
				}
				while(lastTime < 0) {
					lastTime += current.animation.duration;
				}
			}

			var previous:TrackEntry = current.previous;
			if (previous == null) {
				if (current.mix == 1)
					current.animation.apply(skeleton, current.lastTime, time, loop, _events);
				else
					current.animation.mix(skeleton, current.lastTime, time, loop, _events, current.mix);
			} else {
				var previousTime:Float = previous.time;
				if (!previous.loop && previousTime > previous.endTime) previousTime = previous.endTime;
				previous.animation.apply(skeleton, previousTime, previousTime, previous.loop, null);

				var alpha:Float = current.mixTime / current.mixDuration * current.mix;
				if (alpha >= 1) {
					alpha = 1;
					current.previous = null;
				}
				current.animation.mix(skeleton, current.lastTime, time, loop, _events, alpha);
			}

			for (event in _events) {
				if (current.onEvent != null) current.onEvent(i, event);
				onEvent.invoke(i, event);
			}

			// Check if completed the animation or a loop iteration.
			if (loop ? (lastTime % endTime > time % endTime) : (lastTime < endTime && time >= endTime)) {
				var count:Int = Math.floor(time / endTime);
				if (current.onComplete != null) current.onComplete(i, count);
				onComplete.invoke(i, count);
			}

			current.lastTime = current.time;
		}
	}

	public function clearTracks () : Void {
		for(i in 0..._tracks.length)
			clearTrack(i);
		_tracks = new Array<TrackEntry>();
	}

	public function clearTrack (trackIndex:Int) : Void {
		if (trackIndex >= _tracks.length) return;
		var current:TrackEntry = _tracks[trackIndex];
		if (current == null) return;

		if (current.onEnd != null) current.onEnd(trackIndex);
		onEnd.invoke(trackIndex);

		_tracks[trackIndex] = null;
	}

	private function expandToIndex (index:Int) : TrackEntry {
		if (index < _tracks.length) return _tracks[index];
		while (index >= _tracks.length)
			_tracks[_tracks.length] = null;
		return null;
	}

	private function setCurrent (index:Int, entry:TrackEntry) : Void {
		var current:TrackEntry = expandToIndex(index);
		if (current != null) {
			var previous:TrackEntry = current.previous;
			current.previous = null;

			if (current.onEnd != null) current.onEnd(index);
			onEnd.invoke(index);

			entry.mixDuration = _data.getMix(current.animation, entry.animation);
			if (entry.mixDuration > 0) {
				entry.mixTime = 0;
				// If a mix is in progress, mix from the closest animation.
				if (previous != null && current.mixTime / current.mixDuration < 0.5) {
					entry.previous = previous;
					previous = current;
				} else
					entry.previous = current;
			}
		}

		_tracks[index] = entry;

		if (entry.onStart != null) entry.onStart(index);
		onStart.invoke(index);
	}

	public function setAnimationByName (trackIndex:Int, animationName:String, loop:Bool) : TrackEntry {
		var animation:Animation = _data.skeletonData.findAnimation(animationName);
		if (animation == null) throw new IllegalArgumentException("Animation not found: " + animationName);
		return setAnimation(trackIndex, animation, loop);
	}

	/** Set the current animation. Any queued animations are cleared. */
	public function setAnimation (trackIndex:Int, animation:Animation, loop:Bool) : TrackEntry {
		var entry:TrackEntry = new TrackEntry();
		entry.animation = animation;
		entry.loop = loop;
		entry.endTime = animation.duration;

		setCurrent(trackIndex, entry);
		return entry;
	}

	public function addAnimationByName (trackIndex:Int, animationName:String, loop:Bool, delay:Float) : TrackEntry {
		var animation:Animation = _data.skeletonData.findAnimation(animationName);
		if (animation == null) throw new IllegalArgumentException("Animation not found: " + animationName);
		return addAnimation(trackIndex, animation, loop, delay);
	}

	/** Adds an animation to be played delay seconds after the current or last queued animation.
	 * @param delay May be <= 0 to use duration of previous animation minus any mix duration plus the negative delay. */
	public function addAnimation (trackIndex:Int, animation:Animation, loop:Bool, delay:Float) : TrackEntry {
		var entry:TrackEntry = new TrackEntry();
		entry.animation = animation;
		entry.loop = loop;
		entry.endTime = animation.duration;

		var last:TrackEntry = expandToIndex(trackIndex);
		if (last != null) {
			while (last.next != null)
				last = last.next;
			last.next = entry;
		} else
			_tracks[trackIndex] = entry;

		if (delay <= 0) {
			if (last != null)
				delay += last.endTime - _data.getMix(last.animation, animation);
			else
				delay = 0;
		}
		entry.delay = delay;

		return entry;
	}

	/** May be null. */
	public function getCurrent (trackIndex:Int) : TrackEntry {
		if (trackIndex >= _tracks.length) return null;
		return _tracks[trackIndex];
	}

	public function toString () : String {
		var buffer:String = "";
		for (entry in _tracks) {
			if (entry == null) continue;
			if (buffer.length > 0) buffer += ", ";
			buffer += entry.toString();
		}
		if (buffer.length == 0) return "<none>";
		return buffer;
	}
}
