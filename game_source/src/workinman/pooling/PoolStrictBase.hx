package workinman.pooling;

import haxe.CallStack;

@:keepSub class PoolStrictBase implements IStrictPoolable {

	private var _returnFunction : IStrictPoolable->Void;

	private var _key : String;
	private var _disposed : Bool;

	public function instance( pKey:String, pReturnFunction:IStrictPoolable->Void ) : IStrictPoolable {
		_returnFunction = pReturnFunction;
		_key = pKey;
		poolActivate();
		create();
		return this;
	}

	public var poolKey(get,never) : String;
	public function get_poolKey() : String { return _key; }

	public function create() : Void {
		// Override
	}

	public function poolActivate() : Void {
		_disposed = false;
	}

	public function dispose() : Void {
		if ( _disposed ) { return; }
		_disposed = true;
		_returnFunction(this);
	}

	public function destroy() : Void {
		_returnFunction = null;
	}
}
