package workinman.utils;

/**
 * Haxe Wrapper for JSEmbed
 */
@:native( "jsembed" )
extern class JSEmbed {

	static function addAlert( pString:String ) : Void;
	static function removeAlert() : Void;
	static function exists() : Bool;
	static function params() : String;
	static function attr() : String;
	static function baseUrl() : String;
	static function isBaseCrossdomain() : Bool;
	static function scaleType() : String;
	static function canvasScale() : Float;
	static function canvasWidth() : Float;
	static function canvasHeight() : Float;
	static function scaledWidth() : Float;
	static function scaledHeight() : Float;
	static function contentOffsetX() : Float;
	static function contentOffsetY() : Float;
	static function isPaused() : Bool;
	static function embedDiv() : Dynamic; // TODO NOT DYNAMIC?
	static function embedDivId() : String;

	/**
	 * Whether or not JSEmbed is set to allow portrait scaling
	 *
	 * 		Not supported in every version of JSEmbed
	 */
	static function allowPortrait() : Bool;

	/**
	 * If JSEmbed is allowing portrait, and it is currently in portrait
	 *
	 * 		Not supported in every version of JSEmbed
	 */
	static function isPortrait() : Bool;

	static function pause() : Void;
	static function unpause() : Void;
	static function inform( pString:String ) : Void;
	static function informConstructed() : Void;
	static function informInitialized() : Void;
	static function informReady() : Void;
	// TODO SET DIMENSIONS OVERLOAD
	// "setScale("+Std.string(inWidth)+","+Std.string(inHeight)+")"
	static function setScale( pScale:String ) : Void;
	static function setCanvasScaleMax( pCanvasScaleMax:String ) : Void;
}
