package workinman.display.spine;

import workinman.display.spine.Exception;

class IkConstraintData {

	public var name(default,null):String;
	public var bones:Array<BoneData> = new Array<BoneData>();
	public var target:BoneData;
	public var bendDirection:Int = 1;
	public var mix:Float = 1;

	public function new (pName:String) {
		if (pName == null) throw new IllegalArgumentException("name cannot be null.");
		name = pName;
	}

	public function dispose() : Void {
		bones = null;
		target = null;
	}

	public function toString () : String {
		return name;
	}
}
