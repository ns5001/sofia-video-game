package workinman.tween.data;

class TweenStep {

	private var _target : Dynamic;
	private var _properties : Array<PropertyReference>;
	private var _easeFunction : Float->Float->Float->Float->Float;
	private var _completionHandler : Void->Void;
	private var _started : Bool;
	private var _duration : Float;
	private var _delay : Float;
	private var _postDelay : Float;
	private var _progress : Float;

	public function new( pInfo : TweenInfo, pProp : Dynamic ) : Void {
		_properties = new Array<PropertyReference>();
		for ( f in Reflect.fields( pProp ) ) {
			_properties.push( new PropertyReference( f, Reflect.field( pProp, f ) ) );
		}
		_target = pInfo.target;
		_easeFunction = pInfo.ease;
		_duration = pInfo.duration;
		_delay = 0;
		_postDelay = 0;
		_completionHandler = null;
		_progress = 0;
		_started = false;
		if ( pInfo.delay != null ) {
			_delay = pInfo.delay;
		}
		if ( pInfo.postDelay != null ) {
			_postDelay = pInfo.postDelay;
		}
		if ( pInfo.complete != null ) {
			_completionHandler = pInfo.complete;
		}
	}

	public function dispose() : Void {
		if ( _target == null ) {
			// Double dispose
			return;
		}
		_target = null;
		for ( p in _properties ) {
			p.dispose();
		}
		_properties = null;
		_easeFunction = null;
		_completionHandler = null;
	}

	// Return remainder of dt
	public function update( dt:Float ) : Float {
		if ( _delay > 0 ) {
			_delay -= dt;
			if ( _delay > 0 ) {
				// DT is consumed
				return 0;
			}
			// Calc dt remainder
			dt = _delay * -1;
		}

		if ( _started == false ) {
			_started = true;
			for ( f in _properties ) {
				if ( Reflect.hasField( _target,f.name ) ) {
					f.origin = Reflect.field( _target,f.name );
				} else if ( Reflect.getProperty( _target,f.name ) != null ) {
					f.origin = Reflect.getProperty( _target,f.name );
				}
			}
		}

		if ( _progress < _duration ) {
			_progress += dt;
			if ( _progress >= _duration ) {
				dt = _duration - _progress;
				_progress = _duration;
				for ( f in _properties ) {
					Reflect.setProperty( _target, f.name, f.dest );
				}
			} else {
				for ( f in _properties ) {
					Reflect.setProperty( _target, f.name, _easeFunction( _progress, f.origin, f.dest - f.origin, _duration ) );
				}
				return 0;
			}
		}

		_postDelay -= dt;
		if ( _postDelay <= 0 ) {
			if ( _completionHandler != null ) {
				var tComplete = _completionHandler;
				_completionHandler = null;
				tComplete();
			}
		} else {
			return 0;
		}
		// Returns the remainder of dt
		return _postDelay * -1;
	}

	public var isComplete(get,never) : Bool;
	private function get_isComplete() : Bool { return _progress >= _duration && _postDelay < 0 && _completionHandler == null; }

	public function delay( pDelay : Float ) : TweenStep { _delay = pDelay; return this; }
	public function postDelay( pPostDelay : Float ) : TweenStep { _postDelay = pPostDelay; return this; }
	public function ease( pEase : Float->Float->Float->Float->Float ) : TweenStep { _easeFunction = pEase; return this; }
	public function onComplete( pComplete : Void->Void ) : TweenStep { _completionHandler = pComplete; return this; }
}
