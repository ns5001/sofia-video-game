package workinman.display.spine.animation;

import workinman.display.spine.Exception;

class Listeners {

	public var listeners (default, null) : Array<Dynamic>;

	public function new() {
		listeners = new Array<Dynamic>();
	}

	public function dispose() : Void {
		listeners = null;
	}

	public function add (listener:Dynamic) : Void {
		if (listener == null)
			throw new IllegalArgumentException("listener cannot be null.");
		listeners[listeners.length] = listener;
	}

	public function remove (listener:Dynamic) : Void {
		if (listener == null)
			throw new IllegalArgumentException("listener cannot be null.");
		listeners.splice(listeners.indexOf(listener), 1);
	}

	public function invoke (i:Int, ?arg:Dynamic=null) {
		for (listener in listeners)
			listener(i, arg);
	}
}
