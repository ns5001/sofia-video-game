package workinman.saving;

import haxe.Serializer;

class WMSharedObject {

	public var id( default,null ) : String;
	public var data( default,default ) : SharedObjectSaveDef;

	public function new( pId:String ) : Void {
		data = {version:"-1"};
		id = pId;
	}

	public function dispose() : Void {
		data = null;
		id = null;
	}

	public function clear() : Void {
		data = null;
		data = {version:"-1"};
		js.Browser.window.localStorage.removeItem( id );
	}

	public function flush() : Void {
		js.Browser.window.localStorage.setItem( id, Serializer.run(data) );
	}
}
