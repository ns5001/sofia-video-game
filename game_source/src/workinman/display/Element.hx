package workinman.display;

import workinman.math.WMPoint;

class Element extends ImageSprite {

	public var velocity(default,null) : WMPoint;

	public function new( prop:ImageSpriteProp ) : Void {
		super(prop);
		velocity = WMPoint.request();
		_addEventListeners();
	}

	public override function dispose() : Void {
		super.dispose();
		velocity.dispose();
		velocity = null;
		_removeEventListeners();
	}

	private function _addEventListeners() : Void {
		// Override
	}

	private function _removeEventListeners() : Void {
		// Override
	}
}
