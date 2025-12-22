package workinman.display;

class AnimatedElementFrames extends AnimatedElement {

	public function new ( pData:ImageSpriteProp ) : Void {
		super( pData );
	}

	public function addAnimation( pName:String, pFrames:Array<String> ) : AnimatedElement {
		removeAnimation(pName);
		_animations.push( AnimationDef.request(pName,-1,-1,pFrames) );
		return this;
	}

	private override function _setFrame( pFrame:Float ) {
		setAsset(_currentAnimDef.frameIds[Math.floor(pFrame-1)]);
	}
}
