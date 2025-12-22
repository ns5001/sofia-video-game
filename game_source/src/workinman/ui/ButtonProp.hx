package workinman.ui;

import workinman.tween.Tweener;
import workinman.display.ImageSpriteProp;

typedef ButtonProp = {
	> ImageSpriteProp,
	tween : Tweener,
	clear : Void->Bool,
	?assetUp : String,
	?assetOver : String,
	?assetDown : String,
	?assetDisabled : String,
}
