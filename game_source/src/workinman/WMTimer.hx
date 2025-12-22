package workinman;

class WMTimer {

	private static var _timers : Array<WMTimerData> = new Array<WMTimerData>();

	private static var _uniqueInc : Int = 0;
	private static var _paused : Bool = false;

	public static function update( dt:Float ) : Void {
		if ( _paused ) {
			return;
		}
		var tI : Int = _timers.length;
		while ( tI-- > 0 ) {
			_timers[tI].update(dt);
			if ( _timers[tI].isComplete ) {
				_timers[tI].dispose( true );
				_timers.splice( tI,1 );
			}
		}
	}

	public static function start( pCallback:Void->Void, pTime:Float, pId:String = "" ) : Void {
		if ( pCallback == null ) {
			trace("[WMTimer](start) Can't start a timer with no callback function." );
			return;
		}
		_timers.push( new WMTimerData( pCallback, pTime, pId==""?"def"+_uniqueInc++:pId ) );
	}

	public static function pause( pId:String ) : Void {
		for ( t in _timers ) {
			if ( t.id == pId ) {
				t.paused = true;
				return;
			}
		}
	}

	public static function unPause( pId:String ) : Void {
		for ( t in _timers ) {
			if ( t.id == pId ) {
				t.paused = false;
				return;
			}
		}
	}

	public static function stop( pId:String, pDoCallback:Bool = false ) : Void {
		var tI : Int = _timers.length;
		while ( tI-- > 0 ) {
			if ( _timers[tI].id == pId ) {
				_timers[tI].dispose( pDoCallback );
				_timers.splice(tI,1);
				return;
			}
		}
	}

	public static function pauseAll() : Void {
		_paused = true;
	}

	public static function unPauseAll() : Void {
		_paused = false;
	}

	public static function stopAll( pDoCallback:Bool = false ) : Void {
		while ( _timers.length > 0 ) {
			_timers.pop().dispose( pDoCallback );
		}
	}
}

class WMTimerData {

	public var id(default,null) : String;
	private var _callback : Void->Void;

	private var _timer : Float;
	public var paused : Bool;

	public function new( pCallback:Void->Void, pTime:Float, pId:String ) : Void {
		id = pId;
		_callback = pCallback;
		_timer = pTime;
		paused = false;
	}

	public function dispose( pDoCallback:Bool ) : Void {
		if ( pDoCallback ) {
			_fireCallback();
		}
		id = null;
		_callback = null;
	}

	public var isComplete(get,never) : Bool;
	private function get_isComplete() : Bool { return _timer <= 0; }

	public function update( dt:Float ) : Void {
		if ( paused ) {
			return;
		}
		_timer -= dt;
		if ( _timer < 0 ) {
			_fireCallback();
		}
	}

	private function _fireCallback() : Void {
		if ( _callback == null ) {
			return;
		}
		var tCallback = _callback;
		_callback = null;
		tCallback();
	}
}
