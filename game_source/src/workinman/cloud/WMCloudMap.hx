package workinman.cloud;

import workinman.WMCloud;

// This abtract is used for operator overloading.
abstract WMCloudMap<V>( WMCloudMapBase<V> ) {

	public function new() { this = new WMCloudMapBase<V>(); }

	// Operator Overloading - uses same names as in base class to allow calling them directly as functions.
	@:arrayAccess public inline function get( key:String ) : V 					{ return this.get(key); }
	@:arrayAccess public inline function set( key:String, val:V ) : V 			{ return this.set(key, val); }
	
	// Have to duplicate function names to explose calls from the abstract.
	public inline function has( key:String ) : Bool 							{ return this.has(key); }
	public inline function setDefault( key:String, val:V ) : V 					{ return this.setDefault(key, val); }
	public inline function resetValue( key:String ) : Void 						{ this.resetValue(key); }
}

// This class contains the actual class logic
private class WMCloudMapBase<V> implements ArrayAccess<String> {

	public function new() : Void { }

	public function get( key:String ) {
		return WMCloud.getValue(key);
	}

	public function set( key:String, val:V ) : V {
		WMCloud.setValue(key, val);
		return val;
	}

	public function has( key:String ) : Bool {
		return WMCloud.hasValue(key);
	}

	public function setDefault( key:String, val:V ) : V {
		WMCloud.setDefault(key, val);
		return val;
	}

	public function resetValue( key:String ) : Void {
		WMCloud.resetValue(key);
	}
}
