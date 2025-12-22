package workinman.sound;

class VOQueue {

	public var id(default,null) : String;
	public var gain(default,null) : Float;
	public var call(default,null) : Void->Void;
	public var delay(default,default) : Float;
	public var localization(default,null) : String;

	public function new( pId:String, pGain:Float, pCallback:Void->Void, pDelay:Float, pLocalization : String ) : Void {
		id = pId;
		call = pCallback;
		delay = pDelay;
		gain = pGain;
		localization = pLocalization;
	}

	public function copy(pObject:VOQueue) : Void {
		id = pObject.id;
		call = pObject.call;
		delay = pObject.delay;
		gain = pObject.gain;
		localization = pObject.localization;
	}

	public function dispose() : Void {
		call = null;
		id = null;
		localization = null;
	}
}
