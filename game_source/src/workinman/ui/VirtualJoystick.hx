package workinman.ui;

import workinman.display.ImageSprite;
import workinman.math.WMPoint;
import flambe.math.Point;
import workinman.tween.*;
import workinman.input.Pointer;
import app.INPUT_VIRTUAL;

class VirtualJoystick extends ImageSprite {

	private var _base : ImageSprite;
	private var _knob : ImageSprite;
	private var _mode : VIRTUAL_JOYSTICK_MODE;
	private var _scratchPoint : Point;
	private var _workPoint : WMPoint;
	private var _inputDirection : WMPoint;
	private var _inputThreshold:Float; 
	private var _maxKnobDist : Float; 
	private var _slideToMaxDist:Bool;
	private var _tweener:Tweener;

	private var _inputActive:Bool;
	private var _inputId:Int;

	private var _inputUp:Bool;
	private var _inputDown:Bool;
	private var _inputleft:Bool;
	private var _inputRight:Bool;

	private var _outOfRange:Bool;
	
	public function new( pData:VirtualJoystickProp )  {
		super( pData );
		pos.to(0,0);

		_scratchPoint = new Point(); 
		_base = addElement( new ImageSprite({asset:pData.assetBase, alpha:0}) );
		_knob = addElement( new ImageSprite({asset:pData.assetKnob, alpha:0}) );
		
		_inputActive = false;
		_outOfRange = false; 
		_inputId = -1; 

		_mode = pData.mode;
		_tweener = pData.tweener;
		_slideToMaxDist = pData.slideToMaxDist; 
		_maxKnobDist = pData.maxKnobDist; 
		_inputThreshold = pData.inputThreshold; 
		_workPoint = WMPoint.request();
		_inputDirection = WMPoint.request();

		_inputUp = _inputDown = _inputleft = _inputRight = false;
	}

	public override function dispose() : Void {
		super.dispose();
		_workPoint.dispose(); 
		_workPoint = null; 
		_inputDirection.dispose();
		_inputDirection = null; 
		_tweener = null; 
	}

	public override function update(dt:Float) : Void {
		_updateTouches(dt); 
		_updateInput();
		super.update(dt);
	}

	private function _updateTouches( dt:Float ){
		// reset to 0, just to be safe. 
		// using inverse transform to test left / right of screen quickly. 
		pos.to(0,0);

		if( !_inputActive ){
			//not active, find a suitable touch. 
			for ( p in WMInput.multiTouch ) {
				if( p.down && !_inputActive ){
					_onNewTouch(p);
				}
			}
		}else{
			//input active, update or see if its over. 
			var tTouchStillActive = false; 

			for ( p in WMInput.multiTouch ) {
				//see if input still there. 
				if( p.id== _inputId && p.down ){
					tTouchStillActive = true; 
					_updateActiveTouch(p); 
				}
			}

			//touch ended or isnt there anymore, stop input & hide joystick
			if( _inputActive && !tTouchStillActive ){
				_onTouchEnd();
			}
		}

		//slide the base towards the ideal spot
		if( _outOfRange && _slideToMaxDist ){
			//TODO: tween base towards edge. 
		}
	}

	private function _onNewTouch( p:Pointer ){
		//convert screenspace touch to local coords
		inverseTransform( p.currentPos.x, p.currentPos.y, _scratchPoint );
		switch( _mode ){
			case VIRTUAL_JOYSTICK_MODE.LEFT_SIDE:
				if( _scratchPoint.x > 0 ){return;}
			case VIRTUAL_JOYSTICK_MODE.RIGHT_SIDE:
				if( _scratchPoint.x < 0 ){return;}
			case VIRTUAL_JOYSTICK_MODE.FULL_SCREEN:
				//everything works! 
		}
		_inputActive = true; 
		_inputId = p.id;
		_base.pos.to( _scratchPoint.x, _scratchPoint.y ); 
		_knob.pos.toPoint( _base.pos );

		_showControls();
	}

	private function _onTouchEnd(){
		_inputActive = false; 
		_knob.pos.toPoint( _base.pos );
		_inputDirection.to(0,0); 
		_hideControls();
	}

	private function _updateActiveTouch( p:Pointer ){
		//convert screenspace touch to local coords
		inverseTransform( p.currentPos.x, p.currentPos.y, _scratchPoint );
		_workPoint.to(_scratchPoint.x, _scratchPoint.y );
		_workPoint.subtractPoint(_base.pos);

		if( _workPoint.length > _maxKnobDist ){
			_outOfRange = true; 
			_workPoint.normalizeTo( _maxKnobDist );
		}else{
			_outOfRange = false; 
		}
		_inputDirection.to( _workPoint.x / _maxKnobDist, _workPoint.y / _maxKnobDist ); 
		_knob.pos.to(_workPoint.x + _base.x, _workPoint.y + _base.y);
	}

	private function _updateInput(){
		//there has to be a better way!

		if( _inputDirection.x > _inputThreshold && !_inputRight ){ _inputRight = true; WMInput.onVirtualDown(INPUT_VIRTUAL.RIGHT); } 
		if( _inputDirection.x <= _inputThreshold && _inputRight ){ _inputRight = false; WMInput.onVirtualUp(INPUT_VIRTUAL.RIGHT); }
		if( _inputDirection.x < -_inputThreshold && !_inputleft ){ _inputleft = true; WMInput.onVirtualDown(INPUT_VIRTUAL.LEFT); } 
		if( _inputDirection.x >= -_inputThreshold && _inputleft ){ _inputleft = false; WMInput.onVirtualUp(INPUT_VIRTUAL.LEFT); }

		if( _inputDirection.y > _inputThreshold && !_inputDown ){ _inputDown = true; WMInput.onVirtualDown(INPUT_VIRTUAL.DOWN);  } 
		if( _inputDirection.y <= _inputThreshold && _inputDown ){ _inputDown = false; WMInput.onVirtualUp(INPUT_VIRTUAL.DOWN); }
		if( _inputDirection.y < -_inputThreshold && !_inputUp ){ _inputUp = true; WMInput.onVirtualDown(INPUT_VIRTUAL.UP); } 
		if( _inputDirection.y >= -_inputThreshold && _inputUp ){ _inputUp = false; WMInput.onVirtualUp(INPUT_VIRTUAL.UP); }
	}

	//-----------------------------------
	// override - animation 
	//-----------------------------------

	private function _showControls(){
		//animate In
		_base.alpha = 0; 
		_knob.alpha = 0; 
		_knob.scale = 0.5; 
		_tweener.tween( { target: _base, duration: 0.25, overwrite: true, ease: Ease.outQuad, thread:"inOut" }, { alpha:1 } );
		_tweener.tween( { target: _knob, duration: 0.5, overwrite: true, ease: Ease.outBack, thread:"inOut" }, { alpha:1, scale:1 } );
	}

	private function _hideControls(){
		//animate Out
		_tweener.tween( { target: _base, duration: 0.4, overwrite: true, ease: Ease.inQuad, thread:"inOut" }, { alpha:0 } );
		_tweener.tween( { target: _knob, duration: 0.25, overwrite: true, ease: Ease.inQuad, thread:"inOut" }, { alpha:0, scale:0.5 } );
	}

}
