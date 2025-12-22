package workinman.random;

import workinman.WMRandom;

class RandomWeight {

	private var _sessions : Map<String, WeightTracker>;

	public function new() : Void {
		_sessions = new Map<String, WeightTracker>();
	}

	public function start( pWeightSession:String ) : Void {
		end( pWeightSession );
		_sessions[pWeightSession] = new WeightTracker();
	}

	public function end( pWeightSession:String ) : Void {
		if ( _sessions.exists(pWeightSession) == false ) {
			//trace("[WMWeight](endSession) No session named " + pId + " exists!");
			return;
		}
		_sessions[pWeightSession].dispose();
		_sessions.remove(pWeightSession);
	}

	public function add( pWeightSession:String, pObjects:Array<WeightPair>, pClearSession:Bool = false ) : Void {
		if ( pObjects == null ) {
			trace("[RandomWeight](add) Can't add null list of objects.");
			return;
		}
		if ( _sessions.exists(pWeightSession) == false || pClearSession ) {
			start(pWeightSession);
		}
		var tTracker = _sessions[pWeightSession];
		for ( o in pObjects ) {
			tTracker.add(o);
		}
	}

	public function remove( pWeightSession:String, pObject:Dynamic ) : Void {
		if ( _sessions.exists(pWeightSession) == false ) {
			return;
		}
		_sessions[pWeightSession].remove( pObject );
	}

	public function size( pWeightSession:String ) : Int {
		if ( _sessions.exists(pWeightSession) == false ) {
			return 0;
		}
		return _sessions[pWeightSession].objects.length;
	}

	public function get<T>( pType:Class<T>, pWeightSession:String, pSeedSession:String = "" ) : T {
		if ( _sessions.exists(pWeightSession) == false ) {
			trace("[WMWeight](get) No session named \'${pId}\' exists! Returning null.");
			return null;
		}

		// Pick a random number from the weight
		var tTotalWeight : Float = _sessions[pWeightSession].totalWeight * WMRandom.random(pSeedSession);

		// Look through the objects to find the correct weight
		for ( o in _sessions[pWeightSession].objects ) {
			var tVal : Float = o.weight;
			// If we're on the correct weight return the object
			if ( tTotalWeight < tVal ) {
				return o.object;
			}
			// Otherwise modify the weight and move on to the next object
			tTotalWeight -= tVal;
		}

		// If we got here, there's a problem!
		trace("[WMWeight](getRandomObjectFromSession) Get object failed! We've got an error somewhere!");
		return null;
	}

	public function contains( pWeightSession:String, pObject:Dynamic ) : Bool {
		if ( _sessions.exists(pWeightSession) == false ) {
			return false;
		}
		return _sessions[pWeightSession].objects.indexOf(pObject) >= 0;
	}
}
