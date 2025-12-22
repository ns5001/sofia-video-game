package workinman.input;

import workinman.input.INPUT_SWIPE;
import workinman.math.WMLine;
import workinman.math.WMPoint;

enum PHASE {
	DOWN;
	MOVED;
	STOPPED;
	UP;
}

class Pointer {

	public var swipe( default,null ) : INPUT_SWIPE;
	public var line( default,null ) : WMLine;
	public var lastPos( default,null ) : WMPoint;
	public var phase(default, null) : PHASE;

	public var consumed( default,default ) : Bool;
	public var id( default,null ) : Int;
	public var down( default,null ) : Bool;
	public var disposed( default,null ) : Bool;
	public var fresh( default,default ) : Bool;

	private static inline var _DELTA_ALLOWANCE : Float = 30;

	public function new( pId:Int ) : Void {
		lastPos = WMPoint.request();
		line = WMLine.request();
		swipe = INPUT_SWIPE.NONE;
		down = false;
		fresh = true;
		id = pId;
		consumed = false;
		disposed = false;
	}

	public function dispose() : Void {
		disposed = true;
		lastPos.dispose();
		lastPos = null;
		line.dispose();
		line = null;
		swipe = null;
	}

	public var originPos( get,never ) : WMPoint;
	private function get_originPos() : WMPoint { return line.p0; }

	public var currentPos( get,never ) : WMPoint;
	private function get_currentPos() : WMPoint { return line.p1; }

	public function begin( pX:Float, pY:Float ) : Void {
		line.toFloats( pX, pY, pX, pY );
		lastPos.to( pX, pY );
		phase = DOWN;
		down = true;
		fresh = true;
		consumed = false;
		swipe = INPUT_SWIPE.NONE;
	}

	public function move( pX:Float, pY:Float ) : Void {
		_updateInfo( pX, pY );
		if (phase != UP && !fresh) {
			fresh = true;
			phase = MOVED;
		}
	}

	public function stop() : Void {
		phase = STOPPED;
	}

	public function end( pX:Float, pY:Float ) : Void {
		_updateInfo( pX, pY );
		fresh = true;
		phase = UP;
		down = false;
	}

	private function _updateInfo( pX:Float, pY:Float ) : Void {
		lastPos.toPoint( line.p1 );
		line.endTo( pX, pY, 0 );

		var tDifX : Float = line.p0.x - line.p1.x;
		var tDifY : Float = line.p0.y - line.p1.y;
		if ( Math.abs( tDifX ) >= _DELTA_ALLOWANCE && Math.abs( tDifY ) < _DELTA_ALLOWANCE ) {
			if ( tDifX > 0 ) {
				swipe = INPUT_SWIPE.LEFT;
			} else {
				swipe = INPUT_SWIPE.RIGHT;
			}
		} else if ( Math.abs( tDifY ) >= _DELTA_ALLOWANCE && Math.abs( tDifX ) < _DELTA_ALLOWANCE ) {
			if ( tDifY > 0 ) {
				swipe = INPUT_SWIPE.UP;
			} else {
				swipe = INPUT_SWIPE.DOWN;
			}
		} else {
			swipe = INPUT_SWIPE.NONE;
		}
	}
}
