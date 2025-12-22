package workinman.display.spine;

import workinman.display.spine.Exception;

class Event {

	public var data(default,null):EventData;
	public var time:Float;
	public var intValue:Int;
	public var floatValue:Float;
	public var stringValue:String;

	public function new (time:Float, pData:EventData) {
		if (pData == null) throw new IllegalArgumentException("data cannot be null.");
		this.time = time;
		data = pData;
	}

	public function dispose() : Void {
		data.dispose();
		data = null;
	}

	public function toString () : String {
		return data.name;
	}
}
