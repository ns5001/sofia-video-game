package workinman.ui;

import app.INPUT_VIRTUAL;
import workinman.tween.Tweener;
import workinman.display.ImageSpriteProp;

typedef VirtualInputProp = {
	> ImageSpriteProp,
	id:INPUT_VIRTUAL,
	tween:Tweener,
}
