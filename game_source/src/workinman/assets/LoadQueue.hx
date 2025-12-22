package workinman.assets;

class LoadQueue {

	public var complete(default,null) : Void->Void;
	public var packs(default,null) : Array<String>;
	public var delay : Float;

	public function new( pComplete:Void->Void, pPacks:Array<String>, pDelay:Float ) : Void {
		packs = pPacks;
		complete = pComplete;
		delay = pDelay;
	}

	public function dispose() : Void {
		packs = null;
		complete = null;
	}
}
