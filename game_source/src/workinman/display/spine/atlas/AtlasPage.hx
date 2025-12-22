package workinman.display.spine.atlas;

class AtlasPage {

	public var name:String;
	public var format:Format;
	public var minFilter:TextureFilter;
	public var magFilter:TextureFilter;
	public var uWrap:TextureWrap;
	public var vWrap:TextureWrap;
	public var rendererObject:Dynamic;
	public var width:Int;
	public var height:Int;

	public function new() {}

	public function dispose() : Void {
		rendererObject = null;
	}
}
