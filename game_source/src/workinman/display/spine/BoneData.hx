package workinman.display.spine;

import workinman.display.spine.Exception;

class BoneData {

	public var name(default,null):String;
	public var parent(default,null):BoneData;
	public var length:Float;
	public var x:Float;
	public var y:Float;
	public var rotation:Float;
	public var scaleX:Float = 1;
	public var scaleY:Float = 1;
	public var inheritScale:Bool = true;
	public var inheritRotation:Bool = true;
	public var shearX:Float;
	public var shearY:Float;

	/** @param parent May be null. */
	public function new (pName:String, pParent:BoneData) {
		if (pName == null) throw new IllegalArgumentException("name cannot be null.");
		name = pName;
		parent = pParent;
	}

	public function dispose() : Void {
		parent = null;
	}

	public function toString () : String {
		return name;
	}
}
