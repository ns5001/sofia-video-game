package workinman.display.spine.atlas;

class AtlasRegion {

	public var page:AtlasPage;
	public var name:String;
	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;
	public var u:Float;
	public var v:Float;
	public var u2:Float;
	public var v2:Float;
	public var offsetX:Float;
	public var offsetY:Float;
	public var originalWidth:Int;
	public var originalHeight:Int;
	public var index:Int;
	public var rotate:Bool;
	public var splits:Array<Int>;
	public var pads:Array<Int>;
	public var rendererObject:Dynamic;

	public function new() {}

	public function dispose() : Void {
		page = null;
		splits = null;
		pads = null;
		rendererObject = null;
	}
}
