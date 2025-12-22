package workinman.tween.data;

class PropertyReferenceCurve {

	public var target(default,null) : Dynamic;
	public var name(default,null) : String;
	private var _curve : Float->Float;

	private var _val : Float;
	private var _origin : Float;
	private var _amp : Float;
	private var _rate : Float;

	public function new() { }

	public function init( pTarget:Dynamic, pName:String, pCurve:Float->Float, pBaseValue:Float, pAmp:Float, pRate:Float ) : Bool {
		target = pTarget;
		name = pName;
		if ( Reflect.hasField( target, name ) == false && Reflect.getProperty( target, name ) == null ) {
			trace("[PropertyReferenceCurve](init) Can't find property \"" + pName + "\" on \"" + pTarget + "\"" );
			return false;
		}
		_curve = pCurve;
		_origin = pBaseValue;
		_val = 0;
		_amp = pAmp;
		_rate = pRate;
		return true;
	}

	public function dispose() {
		target = null;
		name = null;
		_curve = null;
	}

	public function update( dt:Float ) : Void {
		_val = ( _val + dt * ( Math.PI * _rate ) ) % ( Math.PI * 2 );
		Reflect.setProperty( target, name, _origin + _curve(_val) * _amp );
	}
}
