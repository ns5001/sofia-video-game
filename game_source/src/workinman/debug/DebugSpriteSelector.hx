package workinman.debug;

import app.INPUT_TYPE;
import workinman.display.Camera;
import workinman.display.Sprite;
import workinman.display.FillSprite;
import workinman.display.ElementManagerSprite;
import workinman.math.WMPoint;
import js.Browser;
import js.html.*;
import flambe.math.Point;
import flambe.System;

@:keep class DebugSpriteSelector {

	private var _ALLOW_DEBUG:Bool = false;

	// Storage
	// private var _elementManagers : Array<ElementManager>;
	private var _camera : Camera;
	private var _scratchPoint : Point;
	private var _inputPos : WMPoint = WMPoint.request();
	private var _selectedItem : Sprite;
	private var _selectedItemOffsetX : Float;
	private var _selectedItemOffsetY : Float;
	private var _lastMouseX : Float;
	private var _lastMouseY : Float;
	private var _root : Sprite;

	public var screenX(get, never) : Float;
	private function get_screenX() : Float { return _inputPos.x; }
	public var screenY(get, never) : Float;
	private function get_screenY() : Float { return _inputPos.y; }

	// Constructor
	public function new() {
		// _elementManagers = [];
		_scratchPoint = new Point();
		_addEventHandlers();
		// Wait for rest of app to init to get root.
		WMTimer.start(function(){
			_root = Reflect.getProperty(Reflect.getProperty(WMInput, "_root"), "_root");
			_camera = new Camera(_root, 0, 0);
		}, 1);
	}

	public function dispose() : Void {
		_removeEventHandlers();
		_scratchPoint = null;
		_selectedItem = null;
	}

	/***************************************
	* Events
	****************************************/
	private function _addEventHandlers() : Void {
		WMInput.eventInput.add( _onInput );
	}

	private function _removeEventHandlers() : Void {
		WMInput.eventInput.remove( _onInput );
	}

	private function _onInput( pType:INPUT_TYPE, pDown:Bool ) : Void {
		_lastMouseX = System.pointer.x;
		_lastMouseY = System.pointer.y;

		// Stores the actual world input position in _inputPos
		_camera.getWorldPositionOfScreenPoint( System.pointer.x, System.pointer.y, 0, _inputPos );

		switch ( pType ) {
			case INPUT_TYPE.POINTER:
				if ( pDown ) {
					// trace("DOWN");
					if ( _ALLOW_DEBUG && System.keyboard.isDown( flambe.input.Key.Shift ) ) {
						// var tDepthResult : WMSprite = hitTest(pX,pY);
						var tDepthResult : Sprite = hitTest( System.pointer.x, System.pointer.y );
						if(tDepthResult != null) {
							// trace(tDepthResult);
							// trace(Type.getClassName(Type.getClass(tDepthResult)));
							// tDepthResult.doDelete = true;
							Debug.debug(tDepthResult);
							// _selectItem(tDepthResult);
						} else {
							trace("[DebugSpriteSelector](_onInput) No sprite clicked.");
						}
					}
					_selectedItem = null;
				}
			case INPUT_TYPE.POINTER_MOVE:
				_moveItem( System.pointer.x, System.pointer.y );
			default:
		}
	}

	public function startItemDrag(pSprite:Sprite) : Void {
		_selectedItem = pSprite;
		_selectedItemOffsetX = 0;//_lastMouseX - _selectedItem.x;
		_selectedItemOffsetY = 0;//_lastMouseY - _selectedItem.y;
		_setOffsetOfChild(pSprite);
		trace(_selectedItemOffsetX, _selectedItemOffsetY);
	}

	private function _setOffsetOfChild(pSprite:Sprite) : Void {
		// pSprite.parent.parent check is because we don't want the x/y of root sprite.
		if(pSprite.parent != null && pSprite.parent.parent != null) {
			trace(pSprite.parent.x, pSprite.parent.y);
			_selectedItemOffsetX = pSprite.parent.x + _selectedItemOffsetX;
			_selectedItemOffsetY = pSprite.parent.y + _selectedItemOffsetY;
			_setOffsetOfChild(pSprite.parent);
		}
	}

	private function _moveItem(pX:Float, pY:Float) : Void {
		if(_selectedItem != null) {
			// _selectedItem.pos.to(pX - _selectedItemOffsetX, pY - _selectedItemOffsetY);
			_selectedItem.pos.to(_inputPos.x - _selectedItemOffsetX, _inputPos.y - _selectedItemOffsetY);
		}
	}

	/***************************************
	* Methods
	****************************************/
	// public function addElementManager(pManager:ElementManager) : Void {
	// 	_elementManagers.push(pManager);
	// }

	public function hitTest( x:Float, y:Float ) : Sprite {
		// return WMInput.hitTest(x,y);
		var tResult = _root.hitTest(x, y, _scratchPoint);//hitTestSprite(_root ,x,y,_scratchPoint);
		if(tResult != null && tResult.alpha == 0 && Std.is(tResult, FillSprite)) {
			if(Std.is(tResult.parent, ElementManagerSprite)) {
				tResult.inputEnabled = false;
				var tResult2 = hitTest(x, y);//hitTestSprite(tResult.parent ,x,y,_scratchPoint);
				tResult.inputEnabled = true;
				tResult = tResult2;
			} else {
				tResult = tResult.parent;
			}
		}
		return tResult;
	}

	// /**
	// * small rewrite of WMRootSprite.hitTest. functionally the same except for checking each element manager (to avoid screen clickwalls)
	// */
	// public function hitTestSprite( pSprite:WMSprite, x:Float, y:Float, point:Point ) : WMSprite {
	// 	// Skip invisible
	// 	if ( pSprite.visible == false || pSprite.inputEnabled == false ) {
	// 		return null;
	// 	}
	// 	if(Std.is(pSprite, WMElementManagerSprite)) {
	// 		var tReturnSprite = pSprite.hitTest(x, y, point);
	// 		if(tReturnSprite != null) {
	// 			if(tReturnSprite.alpha != 0 && !Std.is(tReturnSprite, WMFillSprite)) {
	// 				return tReturnSprite;
	// 			} else {
	// 				tReturnSprite.inputEnabled = false;
	// 				var tReturnSprite2 = pSprite.hitTest(x, y, point);
	// 				tReturnSprite.inputEnabled = true;
	// 				return tReturnSprite2;
	// 			}
	// 		} else {
	// 			return tReturnSprite;
	// 		}
	// 	}
	// 	// Check all children
	// 	var tI : Int = pSprite.children.length;
	// 	var tRes : WMSprite = null;
	// 	while ( tI-- > 0 ) {
	// 		tRes = hitTestSprite(pSprite.children[tI], x,y,point);
	// 		if ( tRes != null ) {
	// 			return tRes;
	// 		}
	// 	}
	// 	// Check this
	// 	if ( pSprite.inverseTransform(x,y,point) && (pSprite.alpha != 0 && !Std.is(pSprite, WMFillSprite)) ) {
	// 		return pSprite;
	// 	}
	// 	// Nothing in this one
	// 	return null;
	// }
}
