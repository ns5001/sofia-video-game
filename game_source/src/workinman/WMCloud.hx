package workinman;

import workinman.cloud.WMCloudMap;

class WMCloud {

	private static var _values 					: Map<String, Dynamic> = new Map<String, Dynamic>();
	private static var _defaults 				: Map<String, Dynamic> = new Map<String, Dynamic>();

	public static function listAllKeys() : Array<String> {
		var tRes : Array<String> = [];
		for ( k in _values.keys() ) {
			tRes.push(k);
		}
		return tRes;
	}

	// These allow acces to CLOUD variables via map-based access. ex: WMCloud.instance.int[CLOUD.INT_SCORE] += 5;
	public static var int(default, null)		: WMCloudMap<Int> = new WMCloudMap<Int>();
	public static var float(default, null)		: WMCloudMap<Float> = new WMCloudMap<Float>();
	public static var bool(default, null)		: WMCloudMap<Bool> = new WMCloudMap<Bool>();
	public static var string(default, null)		: WMCloudMap<String> = new WMCloudMap<String>();
	public static var value(default, null)		: WMCloudMap<Dynamic> = new WMCloudMap<Dynamic>();

	public static function setBool( inValueID:String, inValue:Bool ):Void 			{ setValue(inValueID,inValue); }
	public static function getBool( inValueID:String ):Bool 						{ return _values.get(inValueID); }

	public static function setFloat(inValueID:String, inValue:Float):Void			{ setValue(inValueID,inValue); }
	public static function modifyFloat(pValueId:String, pValueMod:Float):Float		{ return modifyValue(pValueId, pValueMod); }
	public static function getFloat(inValueID:String):Float 						{ return _values.get(inValueID); }

	public static function setInt(inValueID:String, inValue:Int):Void				{ setValue(inValueID,inValue); }
	public static function modifyInt(pValueId:String, pValueMod:Int):Int			{ return Math.floor(modifyValue(pValueId, pValueMod)); }
	public static function getInt(inValueID:String):Int 							{ return _values.get(inValueID); }

	public static function setString(inValueID:String, inValue:String):Void			{ setValue(inValueID,inValue); }
	public static function getString(inValueID:String):String						{ return _values.get(inValueID); }

	public static function setDefault( inValueID:String, inValue:Dynamic ) : Void {
		_defaults.set(inValueID, inValue);
		resetValue(inValueID);
	}

	public static function hasValue(inValueID:String):Bool 							{ return _values.exists(inValueID); }
	public static function getValue(inValueID:String):Dynamic						{ return _values.get(inValueID); }
	public static function setValue(inValueID:String, inValue:Dynamic):Void {
		_values.set(inValueID, inValue);
		if ( _defaults.exists(inValueID) == false ) {
			setDefault( inValueID, inValue );
		}
		_updateDisplays(inValueID);
	}

	public static function modifyValue(inValueID:String, inValue:Float = 1) : Float {
		_values.set(inValueID, getFloat(inValueID) + inValue);
		_updateDisplays(inValueID);
		return getFloat(inValueID);
	}

	public static function resetValue( inValueID:String ) : Void {
		_values.set(inValueID, _defaults.get(inValueID));
		_updateDisplays(inValueID);
	}

	private static function _updateDisplays(inValueID:String):Void {
		app.ConstantsEvent.updateDisplay.dispatch( inValueID );
	}
}
