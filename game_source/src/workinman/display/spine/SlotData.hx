package workinman.display.spine;

import workinman.display.spine.Exception;

class SlotData {

	private var _name:String;
	private var _boneData:BoneData;
	public var r:Float = 1;
	public var g:Float = 1;
	public var b:Float = 1;
	public var a:Float = 1;
	public var attachmentName:String;
	public var blendMode:BlendMode;

	public function new (name:String, boneData:BoneData) {
		if (name == null) throw new IllegalArgumentException("name cannot be null.");
		if (boneData == null) throw new IllegalArgumentException("boneData cannot be null.");
		_name = name;
		_boneData = boneData;
	}

	public function dispose() : Void
	{
		_boneData = null;
	}

	public var name (get, never) : String;
	private function get_name () : String {
		return _name;
	}

	public var boneData (get, never) : BoneData;
	private function get_boneData () : BoneData {
		return _boneData;
	}

	public function toString () : String {
		return _name;
	}
}
