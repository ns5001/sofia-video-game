package workinman.random;

class WeightTracker {

	public var objects(default,null) : Array<WeightPair>;

	public function new() : Void {
		objects = new Array<WeightPair>();
	}

	public function dispose() : Void {
		objects = null;
	}

	public function add( pObject:WeightPair ) : Void {
		objects.push( pObject );
	}

	public function remove( pObject:Dynamic ) : Void {
		var tI : Int = objects.length;
		while ( tI-- > 0 ) {
			if ( objects[tI].object == pObject ) {
				objects.splice(tI,1);
				return;
			}
		}
	}

	public function getValueForObject( pObject:Dynamic ) : Float {
		for ( o in objects ) {
			if ( o.object == pObject ) {
				return o.weight;
			}
		}
		trace("[WeightTracker](getValueForObject) Can't find object! Returning 0." );
		return 0;
	}

	public var totalWeight( get, never ) : Float;
	private function get_totalWeight() : Float {
		var tVal : Float = 0;
		for ( v in objects ) {
			tVal += v.weight;
		}
		return tVal;
	}
}
