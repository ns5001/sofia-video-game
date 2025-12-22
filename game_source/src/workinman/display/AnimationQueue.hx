package workinman.display;

import workinman.pooling.PoolStrictBase;
import workinman.pooling.IStrictPoolable;

class AnimationQueue extends PoolStrictBase implements IStrictPoolable {

	public static function request( pName:String, pLoops:Int, pForceRestart:Bool ) : AnimationQueue {
		return WMPool.requestObject(AnimationQueue).init(pName,pLoops,pForceRestart);
	}

	private var _name : String;
	private var _loops : Int;
	private var _force : Bool;

	public function init( pName:String, pLoops:Int, pForceRestart:Bool ) : AnimationQueue {
		 _name = pName;
		 _loops = pLoops;
		 _force = pForceRestart;
		 return this;
	}

	public var name(get_name,never) : String;
	private function get_name() : String { return _name; }

	public var loops(get_loops,never) : Int;
	private function get_loops() : Int { return _loops; }

	public var force(get_force,never) : Bool;
	private function get_force() : Bool { return _force; }
}
