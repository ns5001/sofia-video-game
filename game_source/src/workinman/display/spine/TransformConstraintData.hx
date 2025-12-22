package workinman.display.spine;

import workinman.display.spine.Exception;

class TransformConstraintData {

	private var _name:String;
	public var bone:BoneData;
	public var target:BoneData;
	public var translateMix:Float;
	public var rotateMix:Float;
	public var scaleMix:Float;
	public var shearMix:Float;
	public var offsetRotation:Float;
	public var offsetX:Float;
	public var offsetY:Float;
	public var offsetScaleX:Float;
	public var offsetScaleY:Float;
	public var offsetShearY:Float;

	public function new (name:String) {
		if (name == null) throw new IllegalArgumentException("name cannot be null.");
		_name = name;
	}

	public function dispose() : Void
	{
		bone = null;
		target = null;
	}

	public var name (get, never) : String;
	private function get_name () : String {
		return _name;
	}

	public function toString () : String {
		return _name;
	}
}
