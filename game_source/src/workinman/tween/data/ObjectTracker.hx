package workinman.tween.data;

class ObjectTracker {

	public var target(default,null) : Dynamic;
	private var _threads : Array<ThreadQueue>;

	public function new( pTarget : Dynamic ) : Void {
		target = pTarget;
		_threads = new Array<ThreadQueue>();
	}

	public function dispose() : Void {
		if ( target == null ) {
			// Double dispose
			return;
		}
		target = null;
		for ( t in _threads ) {
			t.dispose();
		}
		_threads = null;
	}

	public function update( dt:Float ) : Void {
		var tI : Int = _threads.length;
		while ( tI-- > 0 ) {
			var tQueue = _threads[tI];
			tQueue.update(dt);
			if ( _threads == null ) {
				return;
			}
			if ( tQueue.isComplete ) {
				tQueue.dispose();
				_threads.splice(tI,1);
			}
		}
	}

	public var isComplete(get,never) : Bool;
	private function get_isComplete() : Bool { return _threads == null || _threads.length < 1; }

	public function stopAllThreads() : Void {
		while ( _threads.length > 0 ) {
			_threads.pop().dispose();
		}
	}

	public function stopThread( pThread:String ) : Void {
		var tI = _threads.length;
		while ( tI-- > 0 ) {
			if ( _threads[tI].id == pThread ) {
				_threads[tI].dispose();
				_threads.splice(tI,1);
				return;
			}
		}
	}

	public function queueStep( pStep:TweenStep, pThread:String ) : Void {
		var tQueue : ThreadQueue = null;
		for ( t in _threads ) {
			if ( t.id == pThread ) {
				tQueue = t;
				break;
			}
		}
		if ( tQueue == null ) {
			tQueue = new ThreadQueue( pThread );
			_threads.push(tQueue);
		}
		tQueue.queueStep(pStep);
	}
}
