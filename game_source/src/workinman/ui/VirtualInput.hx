package workinman.ui;

import workinman.display.ImageSprite;
import workinman.display.FillSprite;
import workinman.tween.*;
import app.INPUT_VIRTUAL;
import flambe.math.Point;

class VirtualInput extends ImageSprite {

	private var _id : INPUT_VIRTUAL;
	private var _tween : Tweener;
	private var _hitBox : FillSprite;
	private var _scratchPoint : Point;

	private var _active : Bool;
	private var _hasTouch : Bool;

	private static inline var _DEBUG_SHOW_HITBOX : Bool = false;

	public function new( pData:VirtualInputProp ) {
		super( pData );
		_tween = pData.tween;
		_id = pData.id;
		_active = false;
		_hasTouch = false;
		_scratchPoint = new Point();
		setHitboxSize( width, height );
		_defaultInit();
	}

	public override function dispose() : Void {
		_tween = null;
		_id = null;
		_hitBox.dispose();
		_hitBox = null;
		super.dispose();
	}

	public function setHitboxSize( pW:Float, pH:Float ) : VirtualInput {
		if ( _hitBox == null ) {
			_hitBox = addChild( new FillSprite({color:0xFF0000,sizeX:pW,sizeY:pH,alpha:_DEBUG_SHOW_HITBOX?.5:0}) );
		}
		_hitBox.sizeX = pW;
		_hitBox.sizeY = pH;
		return this;
	}

	public override function update( dt:Float ) : Void {
		super.update(dt);

		_hasTouch = false;
		for ( p in WMInput.multiTouch ) {
			if ( p.down && _hitBox.inverseTransform( p.currentPos.x, p.currentPos.y, _scratchPoint )  ) {
				_hasTouch = true;
				break;
			}
		}

		if ( _hasTouch && _active == false ) {
			WMInput.onVirtualDown(_id);
		} else if ( _hasTouch == false && _active ) {
			WMInput.onVirtualUp(_id);
		}

		_defaultBehavior(dt);
		_active = _hasTouch;
	}

	private function _defaultInit() : Void {
		// OVERRIDE IF DEFAULT BEHAVIOR IS UNDESIRED
		alpha = .5;
	}

	private function _defaultBehavior( dt:Float ) : Void {
		// OVERRIDE IF DEFAULT BEHAVIOR IS UNDESIRED
		if ( _hasTouch && _active == false ) {
			_tween.tween( { target: this, duration: .1, overwrite: true, thread: "ralpha", ease:Ease.linear }, { alpha:.9 } );
		} else if ( _hasTouch == false && _active ) {
			_tween.tween( { target:this, duration: .1, overwrite: true, thread: "ralpha", ease:Ease.linear }, { alpha:.1 } );
		}
	}
}
