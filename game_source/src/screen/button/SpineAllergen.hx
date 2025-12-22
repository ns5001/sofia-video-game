package screen.button;

import workinman.display.spine.SpineElement;
import workinman.display.Element;
import workinman.tween.Tweener;
import workinman.ui.Button;
import workinman.WMSound;
import app.ConstantsEvent;
import app.ALLERGEN_TYPE;

enum PICKUP_TYPE {
	ANIMATE_THEN_IMMEDIATE_AND_HIDE;
	ANIMATE_THEN_TRANSITION_AND_HIDE;
	ANIMATE_THEN_TRANSITION;
	BIRD;
}

class SpineAllergen extends Element {
	private var _tween:Tweener;
	private var _allergen:SpineElement;
	private var _button:Button;

	private var _idleAnim:String;
	private var _reactionAnim:String;
	private var _reentryAnim:String;
	private var _sfxPath:String;
	private var _collected:Int = 0;
	private var _reserved:Int = 0;
	private var _pickupType:PICKUP_TYPE;

	public var type:ALLERGEN_TYPE;
	public var collected:Bool = false;
	public var reserved:Bool = false;
	public var index:Int;

	private var _callback: Void -> Void = null;

	public function new(pData:Dynamic, pX:Float, pY:Float, pW:Float, pH:Float, asset:String, pType:ALLERGEN_TYPE, pIndex:Int, pSFX:String, pTween:Tweener,
			pClear:Void->Bool):Void {
		super(pData);

		type = pType;
		index = pIndex;

		_sfxPath = pSFX;

		_allergen = this.addElement(new SpineElement({
			library: asset,
			x: 0,
			y: 0,
			scale: 1
		}));

		_button = _allergen.addElement(new Button({
			x: pX,
			y: pY,
			tween: pTween,
			clear: pClear
		}));
		_button.setCustomHitBox(pW, pH);
		_button.eventDown.add(_select);
		
		app.ConstantsEvent.setCollectedCount.add(_eventSetCollectCount);
		app.ConstantsEvent.setReservedCount.add(_eventSetReservedCount);
	}

	public function setAnimations(pIdleAnim:String, pReactionAnim:String, pReentryAnim:String, pPickupType:PICKUP_TYPE, ?pSofiaCallback:Void->Void = null):Void {
		_idleAnim = pIdleAnim;
		_reactionAnim = pReactionAnim;
		_reentryAnim = pReentryAnim;
		_pickupType = pPickupType;

		_allergen.animate(_idleAnim);

		if (pSofiaCallback != null)
			_callback = pSofiaCallback;
	}

	private function _select():Void {
		if (collected || (_collected + _reserved) >= 5)
			return;

		if (_callback != null)
			_callback();

		collected = true;

		ConstantsEvent.reserveSlot.dispatch(type, index);

		if (_sfxPath != "")
			WMSound.playSound(_sfxPath);
		
		switch(_pickupType) {
			case ANIMATE_THEN_IMMEDIATE_AND_HIDE:
				_allergen.animate(_reactionAnim, 1).eventAnimationComplete.add(_immediatelyCollectAllergen);
			case ANIMATE_THEN_TRANSITION_AND_HIDE:
				_allergen.animate(_reactionAnim, 1).eventAnimationComplete.add(_transitionHideAllergen);
			case ANIMATE_THEN_TRANSITION:
				if (_reactionAnim != "")
					_allergen.animate(_reactionAnim, 1).eventAnimationComplete.add(_transitionAllergen);
				else
					_transitionAllergen();

				_allergen.queueAnimation(_idleAnim);
			case BIRD:
				_allergen.animate(_reactionAnim, 1).eventAnimationComplete.add(_transitionAllergen);
				_allergen.queueAnimation("scene_tree_idle2");
		}
	}

	private function _immediatelyCollectAllergen():Void {
		_allergen.eventAnimationComplete.remove(_immediatelyCollectAllergen);
		
		alpha = 0;
		ConstantsEvent.collectAllergen.dispatch(type, index);
	}

	private function _transitionHideAllergen():Void {
		_allergen.eventAnimationComplete.remove(_transitionHideAllergen);
		
		alpha = 0;
		ConstantsEvent.selectAllergen.dispatch(type, index);
	}

	private function _transitionAllergen():Void {
		_allergen.eventAnimationComplete.remove(_transitionAllergen);
		
		ConstantsEvent.selectAllergen.dispatch(type, index);
	}

	private function _eventSetCollectCount(pCount:Int):Void {
		_collected = pCount;
	}

	private function _eventSetReservedCount(pCount:Int):Void {
		_reserved = pCount;
	}

	public function release() {

		if (_pickupType == PICKUP_TYPE.ANIMATE_THEN_IMMEDIATE_AND_HIDE) {
			if (_reentryAnim != "") {
				_allergen.animate(_reentryAnim);
				_allergen.queueAnimation(_idleAnim);
			} else {
				if (type == ALLERGEN_TYPE.COLD) {
					_allergen.setSkin("default", false);
				}
				_allergen.animate(_idleAnim);
			}
			alpha = 1;
		} else if (_pickupType == PICKUP_TYPE.ANIMATE_THEN_TRANSITION_AND_HIDE) {
			_allergen.animate(_idleAnim);
			alpha = 1;
		} else if (_pickupType == PICKUP_TYPE.BIRD) {
			_allergen.animate("scene_tree_bird_in", 1);
			_allergen.queueAnimation(_idleAnim);
		}

		collected = false;
	}

	public function animate(pAnimation : String) : Void {
		_allergen.animate(pAnimation);
	}
}
