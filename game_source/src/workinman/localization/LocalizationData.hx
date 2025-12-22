package workinman.localization;

class LocalizationData {

	public var id(default,null) : String;
	public var string(default,null) : String;
	public var fontName(default,null) : String;
	public var scale(default,null) : Float;
	public var offsetX(default,null) : Float;
	public var offsetY(default,null) : Float;
	public var subtitleTime(default,null) : Float;

	public function new( inId:String, inString:String, inFont:String, inScale:Float, inOffsetX:Float, inOffsetY:Float, pSubtitleTime:Float ) : Void {
		id = inId;
		string = _sanitizeString(inString);
		fontName = inFont;
		scale = inScale;
		offsetX = inOffsetX;
		offsetY = inOffsetY;
		subtitleTime = pSubtitleTime;
	}

	public function dispose() : Void {
		id = null;
		string = null;
		fontName = null;
	}

	private function _sanitizeString( pString:String ) : String {
		pString = StringTools.replace(pString,"<br>","\n");
		pString = StringTools.replace(pString,"\\n","\n");
		return pString;
	}
}
