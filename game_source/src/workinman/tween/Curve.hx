package workinman.tween;

import workinman.tween.data.PropertyReferenceCurve;

class Curve {

	private var _targets : Array<PropertyReferenceCurve>;

	public function new() {
		_targets = new Array<PropertyReferenceCurve>();
	}

	public function dispose() : Void {
		stopAll();
		_targets = null;
	}

	public function start( pTarget:Dynamic, pProperty:String, pCurve:Float->Float, pBaseValue:Float, pRate:Float, pAmp:Float ) : Void {
		// Try to create our pProperty
		var tRef : PropertyReferenceCurve = new PropertyReferenceCurve();
		if ( tRef.init( pTarget, pProperty, pCurve, pBaseValue, pAmp, pRate ) == false ) {
			// Failed to create it
			tRef.dispose();
			tRef = null;
			return;
		}
		// See if we have to overwrite another of the same properties
		stopProperty( pTarget, pProperty );
		_targets.push(tRef);
	}

	public function stopAll() : Void {
		if ( _targets == null ) {
			return;
		}
		while ( _targets.length > 0 ) {
			_targets.pop().dispose();
		}
	}

	public function stop( pTarget:Dynamic ) : Void {
		var tI : Int = _targets.length;
		while ( tI-- > 0 ) {
			if ( _targets[tI].target == pTarget ) {
				_targets[tI].dispose();
				_targets.splice(tI,1);
			}
		}
	}

	public function stopProperty( pTarget:Dynamic, pThread:String ) : Void {
		var tI : Int = _targets.length;
		while ( tI-- > 0 ) {
			if ( _targets[tI].target == pTarget && _targets[tI].name == pThread ) {
				_targets[tI].dispose();
				_targets.splice(tI,1);
				return;
			}
		}
	}

	public function update( dt:Float ) : Void {
		for ( t in _targets ) {
			t.update(dt);
		}
	}
}
