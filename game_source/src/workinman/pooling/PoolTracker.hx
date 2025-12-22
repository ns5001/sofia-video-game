package workinman.pooling;

import flambe.math.FMath;

class PoolTracker {

	private var _pool : Array<IStrictPoolable>;
	private var _class : Class<IStrictPoolable>;
	private var _log : LOG_LEVEL;
	private var _max : Int;
	private var _created : Int;
	private var _cap : Int;
	private var _loose : Int;

	public function new( pClass:Class<IStrictPoolable>, pLog:LOG_LEVEL, pCap:Int ) : Void {
		_pool = new Array<IStrictPoolable>();
		_class = pClass;
		_log = pLog;
		_max = 0;
		_created = 0;
		_cap = pCap;
		_loose = 0;
	}

	public function dispose() : Void {
		_pool = null;
		_class = null;
		_log = null;
	}

	public var className( get, never ) : Class<IStrictPoolable>;
	private function get_className() : Class<IStrictPoolable> { return _class; }

	public var log( get, never ) : LOG_LEVEL;
	private function get_log() : LOG_LEVEL { return _log; }

	public var numPooled( get, never ) : Int;
	private function get_numPooled() : Int { return _pool.length; }

	public var max( get, never ) : Int;
	private function get_max() : Int { return _max; }

	public var created( get, never ) : Int;
	private function get_created() : Int { return _created; }

	public var cap( get, never ) : Int;
	private function get_cap() : Int { return _cap; }

	public var loose( get, set ) : Int;
	private function get_loose() : Int { return _loose; }
	private function set_loose( pLoose:Int ) : Int { _loose = pLoose; return get_loose(); }

	public function incrementCreated() : Void {
		_created++;
	}

	public function poolObject( pObject:IStrictPoolable ) : Void {
		_pool.push(pObject);
		_max = FMath.max(_max,_pool.length);
	}

	public function givePool() : IStrictPoolable {
		return _pool.pop();
	}

	public function flush() : Void {
		while ( _pool.length > 0 ) {
			_pool.pop().destroy();
		}
	}
}
