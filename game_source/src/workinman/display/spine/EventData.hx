package workinman.display.spine;

import workinman.display.spine.Exception;

class EventData {

	public var name(default,null):String;
	public var intValue:Int;
	public var floatValue:Float;
	public var stringValue:String;

	public function new (pName:String) {
		if (pName == null) throw new IllegalArgumentException("name cannot be null.");
		name = pName;
	}

	public function dispose() : Void {

	}

	public function toString () : String {
		return name;
	}
}
