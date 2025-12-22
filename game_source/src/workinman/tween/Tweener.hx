package workinman.tween;

import workinman.tween.data.*;

class Tweener {

	// Class
	private var _objectTrackers : Array<ObjectTracker>;

	public function new() : Void {
		_objectTrackers = new Array<ObjectTracker>();
	}

	public function dispose() : Void {
		for ( t in _objectTrackers ) {
			t.dispose();
		}
		_objectTrackers = null;
	}

	public function update(dt:Float) : Void {
		var tI : Int = _objectTrackers.length;
		while ( tI-- > 0 ) {
			var tTracker = _objectTrackers[tI];
			tTracker.update(dt);
			if ( tTracker.isComplete ) {
				tTracker.dispose();
				_objectTrackers.splice(tI,1);
			}
		}
	}

	public function hasTween( pTarget:Dynamic ) : Bool {
		for ( t in _objectTrackers ) {
			if ( t.target == pTarget ) {
				return true;
			}
		}
		return false;
	}

	public function tween( pInfo:TweenInfo, pDest:Dynamic ) : TweenStep {
		if ( pInfo.overwrite == null ) {
			pInfo.overwrite = false;
		}
		if ( pInfo.thread == null ) {
			pInfo.thread = "def";
		}
		var tStep : TweenStep = new TweenStep( pInfo, pDest );
		for ( t in _objectTrackers ) {
			if ( t.target == pInfo.target ) {
				// We've got a pre-existing tween!
				if ( pInfo.overwrite ) {
					t.stopThread( pInfo.thread );
				}
				t.queueStep( tStep, pInfo.thread );
				return tStep;
			}
		}
		var tTracker : ObjectTracker = new ObjectTracker( pInfo.target );
		_objectTrackers.push(tTracker);
		tTracker.queueStep( tStep, pInfo.thread );
		return tStep;
	}

	public function stopThread( pTarget:Dynamic, pThread:String ) : Void {
		var tI : Int = _objectTrackers.length;
		while ( tI-- > 0 ) {
			if ( _objectTrackers[tI].target == pTarget ) {
				_objectTrackers[tI].stopThread( pThread );
				return;
			}
		}
	}

	public function stop( pTarget:Dynamic ) : Void {
		var tI : Int = _objectTrackers.length;
		while ( tI-- > 0 ) {
			if ( _objectTrackers[tI].target == pTarget ) {
				_objectTrackers[tI].dispose();
				_objectTrackers.splice(tI, 1);
				return;
			}
		}
	}

	public function stopAllTweens() : Void {
		while ( _objectTrackers.length > 0 ) {
			_objectTrackers.pop().dispose();
		}
	}
}
