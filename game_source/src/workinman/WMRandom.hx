package workinman;

import workinman.random.*;

class WMRandom {

	private static var _seeds : Map<String,SeededRandom> = new Map<String,SeededRandom>();
	public static var weight : RandomWeight = new RandomWeight();

	public static function setSeed( pSession:String, pSeed:Int ) : Void {
		if ( pSession == "" ) {
			trace("[WMRandom](setSeed) Cannot set seed for default session.");
			return;
		}
		if ( _seeds[pSession] == null ) {
			_seeds[pSession] = new SeededRandom();
		}
		_seeds[pSession].seed = pSeed;
	}

	public static function random( pSession:String = "" ) : Float {
		if ( pSession == null || pSession == "" ) {
			return Math.random();
		} else if ( _seeds[pSession] == null ) {
			trace("[WMRandom](random) No seed set for session " + pSession );
			return Math.random();
		}
		return _seeds[pSession].random();
	}

	public static function randomFloat( pMin:Float, pMax:Float, pSession:String = "" ) : Float {
		return pMin + (random(pSession)*(pMax-pMin));
	}

	public static function randomInt( pMin:Int, pMax:Int, pSession:String = "" ) : Int {
		return Math.floor(randomFloat(pMin,pMax+1,pSession));
	}

	public static function randomObject<T>( pList:Array<T>, pSession:String = "" ) : T {
		return pList[randomInt(0,pList.length-1,pSession)];
	}

	public static function randomString( pLen:Int, pChars:String = "", pSession:String = "" ) : String {
		if ( pChars == "" ) {
			pChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
		}
		var tString = "";
		var tI : Int = 0;
		while ( tI < pLen ) {
			tString += pChars.charAt(randomInt(0, pChars.length-1,pSession));
			tI++;
		}
		return tString;
	}

	/**
	* This function doesn't create a copy of the array, but rather modified the original array.
	*/
	public static function shuffleArray<T>(pArray:Array<T>, pSession:String = "") : Array<T> {
		var tmp:T, current:Int, top:Int = pArray.length;
		// Fisher-Yates shuffle - http://stackoverflow.com/a/962890/1411473
		while(--top >= 0) {
			current = Math.floor(random(pSession) * (top + 1));
			tmp = pArray[current];
			pArray[current] = pArray[top];
			pArray[top] = tmp;
		}
		tmp = null;
		return pArray;
	}
}
