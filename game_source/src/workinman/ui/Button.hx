package workinman.ui;

import workinman.display.ImageSprite;
import workinman.display.Sprite;
import workinman.display.FillSprite;
import workinman.display.SliceSprite;
import workinman.tween.*;
import workinman.math.WMPoint;
import workinman.event.Event0;
import app.INPUT_TYPE;
import flambe.math.Point;
import flambe.System;

private enum ButtonState {
	_STATE_UP;
	_STATE_DOWN;
	_STATE_OVER;
	_STATE_CLICK;
}

class Button extends ImageSprite {

	private static var _scratchPoint : Point = new Point();

	private var _assetUp			: String;
	private var _assetOver			: String;
	private var _assetDown			: String;
	private var _assetDisabled		: String;
	private var _hitBox				: FillSprite;
	private var _tween				: Tweener;
	private var _buttonScaleBase	: WMPoint;
	private var _state				: ButtonState;
	private var _clearFunction		: Void->Bool;
	public var eventClick			: Event0;
	public var eventDown			: Event0;
	public var eventUp				: Event0;
	public var eventOver			: Event0;
	public var eventOut				: Event0;

	private var _flagEnabled		: Bool;
	private var _containsInput		: Bool;

	private var _selectedOutline : SliceSprite;

	private static inline var _DEBUG_SHOW_HITBOX	: Bool = false;

	/**********************************************************
	@constructor
	 **********************************************************/
	public function new( pData:ButtonProp ) : Void {
		if ( _scratchPoint == null ) {
			_scratchPoint = new Point();
		}

		super(pData);

		eventClick = new Event0();
		eventDown = new Event0();
		eventUp = new Event0();
		eventOver = new Event0();
		eventOut = new Event0();

		_tween = pData.tween;
		_containsInput = false;
		_clearFunction = pData.clear;

		_assetUp = pData.assetUp;
		_assetOver = pData.assetOver;
		_assetDown = pData.assetDown;
		_assetDisabled = pData.assetDisabled;

		_state = ButtonState._STATE_UP;

		enable();
		// render();
		

		_selectedOutline = addChild( new SliceSprite({asset: manifest.Texture.outline, innerW: width, innerH:height, bufferW: width+10, bufferH : height+10, alpha:0, originX:originX, originY:originY}) );

		setCustomHitBox( width,height );
		WMInput.eventInput.add( _onInput );

		_buttonScaleBase = WMPoint.request(scaleX, scaleY);
	}

	/**********************************************************
	@description
	 **********************************************************/
	public override function dispose() : Void {
		WMInput.eventInput.remove( _onInput );
		eventClick.dispose();
		eventClick = null;
		eventDown.dispose();
		eventDown = null;
		eventUp.dispose();
		eventUp = null;
		eventOver.dispose();
		eventOver = null;
		eventOut.dispose();
		eventOut = null;
		_flagEnabled = false;
		_assetUp = null;
		_assetOver = null;
		_assetDown = null;
		_assetDisabled = null;
		_hitBox.dispose();
		_hitBox = null;
		_tween = null;
		_buttonScaleBase.dispose();
		_buttonScaleBase = null;
		_state = null;
		_clearFunction = null;
		super.dispose();
	}

	/*********************************************************************************************
						PUBLIC  METHODS
	*********************************************************************************************/
	/**********************************************************
	@description
	**********************************************************/
	public function enable() : Button {
		_flagEnabled 		= true;
		_renderUp();
		return this;
	}

	/**********************************************************
	@description
	 **********************************************************/
	public function disable() : Button {
		_flagEnabled 		= false;
		_renderDisabled();
		return this;
	}

	public var hitbox(get, never) : FillSprite;
	private function get_hitbox() : FillSprite { return _hitBox; }


	public function setCustomHitBox( pW:Float, pH:Float ) : Button {
		if ( _hitBox == null ) {
			_hitBox = addChild( new FillSprite({color:0xFF0000,sizeX:pW,sizeY:pH,alpha:_DEBUG_SHOW_HITBOX?.5:0, originX:originX, originY:originY}) );
		}
		_hitBox.sizeX = pW;
		_hitBox.sizeY = pH;
		_selectedOutline.setInnerSize(Math.floor(pW), Math.floor(pH));
		return this;
	}

	private function _onInput( pType:INPUT_TYPE, pDown:Bool ) : Void {
		var pX : Float = System.pointer.x;
		var pY : Float = System.pointer.y;
		switch ( pType ) {
			case INPUT_TYPE.POINTER:
				_containsInput = _hitBox.inverseTransform( pX, pY, _scratchPoint );
				if ( pDown ) {
					switch ( _state ) {
						case _STATE_UP | _STATE_OVER | _STATE_CLICK:
							if ( _containsInput && _depthTest( pX, pY ) ) {
								_state = ButtonState._STATE_DOWN;
								_onDown(pX,pY);
							}
						default:
					}
				} else {
					switch ( _state ) {
						case _STATE_DOWN:
							if ( _containsInput ) {
								_state = ButtonState._STATE_CLICK;
								_onUp(pX, pY);
							} else {
								_state = ButtonState._STATE_UP;
								_renderReturnUp();
							}
						default:
					}
				}
			case INPUT_TYPE.POINTER_MOVE:
				switch ( _state ) {
					case _STATE_UP:
						if ( _containsInput && _depthTest( pX, pY ) ) {
							_state = ButtonState._STATE_OVER;
							_onOver();
						}
					case _STATE_OVER:
						if ( _containsInput == false ) {
							_state = ButtonState._STATE_UP;
							_onOut();
						}
					default:
				}
			default:
		}
	}

	private function _depthTest( pX:Float, pY:Float ) : Bool {
		if ( _flagEnabled == false ) {
			return false;
		}
		var tDepthResult : Sprite = WMInput.hitTest(pX,pY);
		if (  _hitBox != null && tDepthResult == _hitBox ) {
			tDepthResult = null;
			return true;
		}
		tDepthResult = null;
		return false;
	}

	public function forceClick() {
		// used for accessibility to click buttons via overlap
		_dispatch( eventDown );
		_click();
	}


	public function isSelectable() : Bool {
		return _flagEnabled && accessibleInHierarchy();
	}

	/*********************************************************************************************
						PRIVATE  METHODS
	*********************************************************************************************/
	/**********************************************************
	@description
	 **********************************************************/
	private function _dispatch( pEvent:Event0 ) : Void {
		if ( _clearFunction() == false ) {
			return;
        }
        
		pEvent.dispatch();
	}

	/**********************************************************
	@description
	 **********************************************************/
	private function _click() : Void {
		_tween.tween( { target: this, duration: .1, overwrite: true, ease: Ease.inQuad }, { scaleX:_buttonScaleBase.x*1.1, scaleY:_buttonScaleBase.y*1.1 } );
		_tween.tween( { target: this, duration: .4, overwrite: false, ease: Ease.outElastic }, { scaleX:_buttonScaleBase.x*1, scaleY:_buttonScaleBase.y*1 } ).onComplete( _onClickComplete );
		_playSoundClick();
		_doClick();
	}

	private function _onClickComplete() : Void {
		if ( _containsInput && _flagEnabled ) {
			_state = ButtonState._STATE_OVER;
			_renderOver();
		} else {
			_state = ButtonState._STATE_UP;
		}
	}

	private function _doClick() : Void {
		_dispatch( eventClick );
	}

	/**********************************************************
	@description
	 **********************************************************/
	private function _onDown(pX:Float,pY:Float) : Void {
		if ( !_flagEnabled ) {
			return;
		}
		_renderDown();
		_dispatch( eventDown );
	}

	/**********************************************************
	@description
	 **********************************************************/
	private function _onUp(pX:Float,pY:Float) : Void {
		if ( !_flagEnabled ) {
			return;
		}
		_renderReturnUp();
		_click();
		_dispatch( eventUp );
	}

	private function _onOver() : Void {
		_renderOver();
		_playSoundOver();
		_dispatch( eventOver );
	}

	/**********************************************************
	@description
	 **********************************************************/
	private function _onOut() : Void {
		if ( !_flagEnabled ) {
			return;
		}
		_renderOut();
		_dispatch( eventOut );
	}

	/**********************************************************
	@description
	 **********************************************************/
	private function _playSoundClick() : Void {
		WMSound.playSound( app.ConstantsApp.DEFAULT_BUTTON_CLICK, app.ConstantsApp.DEFAULT_BUTTON_CLICK_VOLUME );
	}

	/**********************************************************
	@description
	 **********************************************************/
	private function _playSoundOver() : Void {
		WMSound.playSound( app.ConstantsApp.DEFAULT_BUTTON_OVER, app.ConstantsApp.DEFAULT_BUTTON_OVER_VOLUME );
	}

	/**********************************************************
	@Set Button Scale Base
	 **********************************************************/
	public function setScale(x:Float, y:Float) : Button {
		_buttonScaleBase.x = x;
		_buttonScaleBase.y = y;
		scaleX = _buttonScaleBase.x*1;
		scaleY = _buttonScaleBase.y*1;
		return this;
	}

	public function setBaseAsset( pAsset : String ) : Button {
		_assetUp = pAsset;
		_assetOver = pAsset;
		_assetDown = pAsset;
		_assetDisabled = pAsset;
		setAsset(_assetUp);
		return this;
	}

	public function setHighlight(pVisible : Bool) {
		_selectedOutline.alpha = pVisible ? 1 : 0;
	}

	/**********************************************************
	@description
	 **********************************************************/
	private function _renderUp() : Void {
		setAsset(_assetUp);
	}

	private function _renderOver() : Void {
		_tween.tween( { target: this, duration: .15, overwrite: true, ease: Ease.inQuad }, { scaleX:_buttonScaleBase.x*1.1, scaleY:_buttonScaleBase.y*1.1 } );
	}

	private function _renderOut() : Void {
		_tween.tween( { target: this, duration: .5, overwrite: true, ease: Ease.outElastic }, { scaleX:_buttonScaleBase.x*1, scaleY:_buttonScaleBase.y*1 } );
	}

	/**********************************************************
	@description
	 **********************************************************/
	private function _renderDown() : Void {
		_tween.tween( { target: this, duration: .15, overwrite: true, ease: Ease.outQuad }, { scaleX:_buttonScaleBase.x*.9, scaleY:_buttonScaleBase.y*.9 } );
		setAsset(_assetDown);
	}

	/**********************************************************
	@description
	 **********************************************************/
	private function _renderReturnUp() : Void {
		_tween.tween( { target: this, duration: .15, overwrite: true, ease: Ease.outQuad }, { scaleX:_buttonScaleBase.x*1, scaleY:_buttonScaleBase.y*1 } );
		_renderUp();
	}

	/**********************************************************
	@description
	 **********************************************************/
	private function _renderDisabled() : Void {
		setAsset(_assetDisabled);
	}
}
