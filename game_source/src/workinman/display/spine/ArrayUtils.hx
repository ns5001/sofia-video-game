package workinman.display.spine;

class ArrayUtils {

	public static function allocIntArray(n:Int):Array<Array<Int>> {
		var v:Array<Array<Int>> = new Array<Array<Int>>();
		for (i in 0 ... n) v[i] = new Array<Int>();
		return v;
	}

	public static function allocFloatArray(n:Int):Array<Array<Float>> {
		var v:Array<Array<Float>> = new Array<Array<Float>>();
		for (i in 0 ... n) v[i] = new Array<Float>();
		return v;
	}

	public static function allocFloat(n:Int):Array<Float> {
		var v:Array<Float> = new Array<Float>();
		for (i in 0 ... n) v[i] = 0;
		return v;
	}

	public static function allocString(n:Int):Array<String> {
		var v:Array<String> = new Array<String>();
		for (i in 0 ... n) v[i] = "";
		return v;
	}
}
