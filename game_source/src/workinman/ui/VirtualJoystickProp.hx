package workinman.ui;

import workinman.display.ImageSpriteProp;
import workinman.tween.Tweener;

typedef VirtualJoystickProp = {
	>ImageSpriteProp,
	mode : VIRTUAL_JOYSTICK_MODE,
	tweener:Tweener,
	assetKnob : String,
	assetBase : String,
	inputThreshold : Float,
	maxKnobDist : Float,
	slideToMaxDist : Bool 
}
