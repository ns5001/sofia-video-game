package workinman.pooling;

interface IStrictPoolable {

	// Strict pooling - for objects that should not be requested outside of a pooling context
	// Comes through the PoolStore on WMCloud
	//
	// Must keep a reference to pReturnFunction and call it on dispose
	function instance( pKey:String, pReturnFunction:IStrictPoolable->Void ) : IStrictPoolable; // Replacement for new() constructor
	function create() : Void;		// Init objects that are to be reused between pool instances
	function dispose() : Void; 		// Must return itself to the return function, also dispose any of it's pooled objects
	function destroy() : Void; 		// Destroy object for emergency situations, null references to non-pooled objects, including the return function
	function poolActivate() : Void;	// For reuse to prevent double disposal tracking errors
	public var poolKey(get,never) : String;
}
