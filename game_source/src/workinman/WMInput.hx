package workinman;

import workinman.display.RootSprite;
import workinman.display.Sprite;
import workinman.event.Event1;
import workinman.event.Event2;
import workinman.math.WMPoint;
import workinman.input.Pointer;
import workinman.input.InputTracker;
import workinman.input.INPUT_CONTROLLER;
import workinman.input.GamepadBase;
import workinman.input.GamepadXbox360;
import app.INPUT_VIRTUAL;
import app.INPUT_TYPE;
import flambe.input.Key;
import flambe.input.KeyboardEvent;
import flambe.input.PointerEvent;
import flambe.input.TouchPoint;
import flambe.System;
import js.Browser;

class WMInput {

  	//events
	public static var eventInput : Event2<INPUT_TYPE,Bool> = new Event2<INPUT_TYPE,Bool>();
	public static var eventMouseWheel : Event1<Float> = new Event1<Float>();
	public static var eventKey : Event2<Key,Bool> = new Event2<Key,Bool>();

	//members
	public static var leftStick : WMPoint = WMPoint.request();
	public static var rightStick : WMPoint = WMPoint.request();
	public static var pointer( default,null ) : Pointer = new Pointer(-1);
	public static var multiTouch( default,null ) : Array<Pointer> = new Array<Pointer>();
	public static var enabled(default,default) : Bool = false;

	private static var _root : RootSprite = null;
	private static var _delegateUnlockWebAudio : Void->Void = null;
	private static var _inputTrackers : Array<InputTracker> = new Array<InputTracker>();
	private static var _virtualDown	: Array<INPUT_VIRTUAL> = new Array<INPUT_VIRTUAL>();
	private static var _controllerDown : Array<INPUT_CONTROLLER> = new Array<INPUT_CONTROLLER>();
	private static var _gamepad : GamepadBase = null;

	private static inline var _XBOX_CONTROLLER_ID : String = "Xbox 360 Controller";

  	public static function setDelegateUnlockWebAudio( pFunc:Void->Void ) : Void {
		_delegateUnlockWebAudio = pFunc;
	}

	private static function _delegateDispatch( pType:INPUT_TYPE, pDown:Bool ) : Void {
		// These are the different event.type cases in flambe.
		// switch (event.type) {
		// 	case "touchstart", "MSPointerDown", "pointerdown":
		// 	case "touchmove", "MSPointerMove", "pointermove":
		// 	case "touchend", "touchcancel", "MSPointerUp", "pointerup":
		// }

		// Since enabling the audio on touchstart doesn't work on iOS 9 pointerdown or touchend is recommended.

		// pointerdown is in the same case as touchstart so use touchend (INPUT_PHASE.UP)
		if ( _delegateUnlockWebAudio != null && pDown == false ) {
			_delegateUnlockWebAudio();
			_delegateUnlockWebAudio = null;
		}

		if ( enabled == false ) {
			return;
		}
		eventInput.dispatch( pType, pDown );
	}

	public static function update( dt:Float ) : Void {
		if ( enabled == false ) {
			return;
		}

		// Check gamepad status
		_findGamepad();

		if ( _gamepad != null ) {
			_gamepad.update();
			leftStick.to(_gamepad.leftX,_gamepad.leftY);
			rightStick.to(_gamepad.rightX,_gamepad.rightY);
		}

		for ( t in _inputTrackers ) {
			t.updateStatus();
		}

		// Pointer updating
		pointer.fresh = false;
		var tI : Int = multiTouch.length;
		var tPointer : Pointer;
		while ( tI-- > 0 ) {
			tPointer = multiTouch[tI];
			if (tPointer.fresh == false) {
				if (tPointer.down == false) {
					tPointer.dispose();
					multiTouch.splice(tI,1);
				} else {
					tPointer.stop();
				}
			}
			tPointer.fresh = false;
			tPointer = null;
		}
	}

	private static function _findGamepad() : Void {
		// TODO HANDLE SWITCHING / MULTIPLE GAME PADS?
		if (!Reflect.isFunction(Browser.navigator.getGamepads)) {
			return; //gamepads not supported
		}
		for ( g in Browser.navigator.getGamepads() ) {
			if ( g != null ) {
				if ( g.id.indexOf(_XBOX_CONTROLLER_ID) > -1 ) {
					if ( _gamepad == null ) {
						_gamepad = new GamepadXbox360(g);
					} else {
						_gamepad.setGamepad(g);
					}
					break;
				}
			}
		}
	}

	public static function prime( pRootSprite:RootSprite ) : Void {
		_root = pRootSprite;
		System.keyboard.down.connect(_onKeyDown);
		System.keyboard.up.connect(_onKeyUp);

		if ( System.touch.supported ) {
			trace("[WMInput](prime) Multi Touch Enabled");
			System.touch.down.connect(_onTouchDown);
			System.touch.move.connect(_onTouchMove);
			System.touch.up.connect(_onTouchUp);
		}

		System.pointer.down.connect(_onPointerDown);
		System.pointer.move.connect(_onPointerMove);
		System.pointer.up.connect(_onPointerUp);

		System.mouse.scroll.connect(_onScrollWheel);
	}

	public static function hitTest( pRawX:Float, pRawY:Float ) : Sprite {
		return _root.hitTest(pRawX,pRawY);
	}

	private static function _onScrollWheel( pEvent:Float ) : Void {
    // A velocity emitted when the mouse wheel or trackpad is scrolled. A positive value is an upward scroll, negative is a downward scroll. Typically, each scroll wheel "click" equates to 1 velocity.
		//trace("[WMInput](_onScrollWheel) scrollwheel " + pEvent);
    	eventMouseWheel.dispatch( pEvent );
	}

	public static function registerInput( pId:INPUT_TYPE, pKeys:Array<Key> = null, pVirtual:Array<INPUT_VIRTUAL> = null, pController:Array<INPUT_CONTROLLER> = null ) : Void {
		var tTracker : InputTracker = _createOrGetInputTracker( pId );
		tTracker.setKeys( pKeys, pVirtual, pController );
		tTracker = null;
	}

	private static function _createOrGetInputTracker( pId:INPUT_TYPE ) : InputTracker {
		for ( p in _inputTrackers ) {
			if ( p.type == pId ) {
				return p;
			}
		}
		var tTracker : InputTracker = new InputTracker( pId, _fireKeyEvent, _isVirtualDown, _isControllerDown );
		_inputTrackers.push( tTracker );
		return tTracker;
	}

	private static function _fireKeyEvent( pType:INPUT_TYPE, pDown:Bool ) : Void {
		_delegateDispatch( pType, pDown );
	}

	public static function getAnyInput() : Bool {
		for ( b in _inputTrackers ) {
			if ( b.down ) {
				return true;
			}
		}
		return false;
	}

	public static function getInputDown( pId:INPUT_TYPE ) : Bool {
		if ( pId == INPUT_TYPE.POINTER ) {
			return pointer.down;
		}
		for ( b in _inputTrackers ) {
			if ( b.type == pId ) {
				return b.down;
			}
		}
		return false;
	}

	public static function getInputFresh( pId:INPUT_TYPE ) : Bool {
		if ( pId == INPUT_TYPE.POINTER ) {
			return pointer.fresh;
		}
		for ( b in _inputTrackers ) {
			if ( b.type == pId ) {
				return b.fresh;
			}
		}
		return false;
	}

	private static function _onKeyDown( pEvent:KeyboardEvent ):Void {
    	eventKey.dispatch( pEvent.key, true );
	}

	private static function _onKeyUp( pEvent:KeyboardEvent ):Void {
    	eventKey.dispatch( pEvent.key, false );
	}

 	public static function onVirtualDown( pId:INPUT_VIRTUAL ) : Void {
		for ( v in _virtualDown ) {
			if ( v == pId ) {
				return;
			}
		}
		_virtualDown.push(pId);
  }

  public static function onVirtualUp( pId:INPUT_VIRTUAL ) : Void {
		var tI : Int = _virtualDown.length;
		while ( tI-- > 0 ) {
			if ( _virtualDown[tI] == pId ) {
				_virtualDown.splice(tI,1);
				return;
			}
		}
  }

	private static function _isVirtualDown( pId:INPUT_VIRTUAL ) : Bool {
		for ( v in _virtualDown ) {
			if ( v == pId ) {
				return true;
			}
		}
		return false;
	}

	public static function onControllerDown( pId:INPUT_CONTROLLER ) : Void {
		for ( c in _controllerDown ) {
			if ( c == pId ) {
				return;
			}
		}
		_controllerDown.push(pId);
  }

  public static function onControllerUp( pId:INPUT_CONTROLLER ) : Void {
		var tI : Int = _controllerDown.length;
		while ( tI-- > 0 ) {
			if ( _controllerDown[tI] == pId ) {
				_controllerDown.splice(tI,1);
				return;
			}
		}
  }

	private static function _isControllerDown( pId:INPUT_CONTROLLER ) : Bool {
		for ( c in _controllerDown ) {
			if ( c == pId ) {
				return true;
			}
		}
		return false;
	}

	private static function _onTouchDown( pEvent:TouchPoint ) : Void {
		_doTouchDown( pEvent.id, pEvent.viewX, pEvent.viewY );
	}

	private static function _onTouchMove( pEvent:TouchPoint ) : Void {
		_doTouchMove( pEvent.id, pEvent.viewX, pEvent.viewY );
	}

	private static function _onTouchUp( pEvent:TouchPoint ) : Void {
		_doTouchUp( pEvent.id, pEvent.viewX, pEvent.viewY );
	}

	private static function _doTouchDown( pIndex:Int, pX:Float, pY:Float ) : Void {
		var tPointer : Pointer = _findTouch( pIndex );
		if ( tPointer == null ) {
			tPointer = new Pointer( pIndex );
			multiTouch.push( tPointer );
		}
		tPointer.begin( pX, pY );
		tPointer = null;
	}

	private static function _doTouchMove( pIndex:Int, pX:Float, pY:Float ) : Void {
		var tPointer : Pointer = _findTouch( pIndex );
		if ( tPointer == null ) {
			return;
		}
		tPointer.move( pX, pY );
		tPointer = null;
	}

	private static function _doTouchUp( pIndex:Int, pX:Float, pY:Float ) : Void {
		var tPointer : Pointer = _findTouch( pIndex );
		if ( tPointer == null ) {
			return;
		}
		tPointer.end( pX,pY );
		tPointer = null;
	}

	private static function _findTouch( pId:Int ) : Pointer {
		for ( p in multiTouch ) {
			if ( p.id == pId ) {
				return p;
			}
		}
		return null;
	}

	private static function _onPointerDown( pEvent:PointerEvent ) : Void {
		pointer.begin( pEvent.viewX, pEvent.viewY );
		// Fake touches for non-touch devices
		if ( System.touch.supported == false ) {
			_doTouchDown( 0, pEvent.viewX, pEvent.viewY );
		}
		_delegateDispatch( INPUT_TYPE.POINTER, true );
	}

	private static function _onPointerMove( pEvent:PointerEvent ) : Void {
		pointer.move( pEvent.viewX, pEvent.viewY );
		// Fake touches for non-touch devices
		if ( System.touch.supported == false ) {
			_doTouchMove( 0, pEvent.viewX, pEvent.viewY );
		}
		_delegateDispatch( INPUT_TYPE.POINTER_MOVE, true );
		// TODO MOVE EVENT
		// _delegateDispatch( INPUT_PHASE.MOVE, INPUT_TYPE.CLICK, pointer.currentPos.x, pointer.currentPos.y, pointer.swipe );
	}

	private static function _onPointerUp( pEvent:PointerEvent ) : Void {
		pointer.end( pEvent.viewX, pEvent.viewY );
		// Fake touches for non-touch devices
		if ( System.touch.supported == false ) {
			_doTouchUp( 0, pEvent.viewX, pEvent.viewY );
		}
		_delegateDispatch( INPUT_TYPE.POINTER, false );
	}
}
