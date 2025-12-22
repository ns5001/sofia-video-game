package workinman.tween.data;

class PropertyReference {

	public var name(default,null) : String;
	public var origin(default,default) : Float;
	public var dest(default,null) : Float;

	public function new( pName:String, pDest:Float ) : Void {
		name = pName;
		origin = 0; // This is set later
		dest = pDest;
	}

	public function dispose() {
		name = null;
	}
}
