package workinman.random;

class SeededRandom {

    public var seed(default,set) : Int;

    public function new ( pSeed : Int = 1 ) : Void {
        seed = pSeed;
    }

    private function set_seed( pSeed : Int ) : Int {
		if ( pSeed == 0 ) {
			pSeed = 1;
		}
        seed = pSeed;
        return pSeed;
    }

    private function _randomInt() : Int {
        return (seed = (seed * 16807) % 0x7FFFFFFF) & 0x3FFFFFFF;
    }

    public function random() : Float {
        return _randomInt() / 1073741823.0; // divided by 2^30-1
    }
}
