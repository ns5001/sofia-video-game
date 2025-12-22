package workinman;

import haxe.xml.Fast;
import com.workinman.cloud.*;
import flambe.pooling.*;
import haxe.Json;
import workinman.localization.LocalizationData;

enum LOCALIZATION_FORMAT {
	TRADITIONAL_XML;
	STRINGS_JS;
	STRINGS_JSON;
}

class WMLocalize {

	private static var _localizedData : Map<String,LocalizationData> = new Map<String,LocalizationData>();
	private static var _emptyLocalization : LocalizationData = new LocalizationData("","","",1,0,0,-1);
	public static var region(default,default) : String = "";
	public static var rtl(default,null) : Bool;
	public static var defaultFont(default,null) : String;
	public static var subtitlesEnabled(default,null) : Bool;

	public static function parseLocalization( pPath:String = "" ) : Void {
		// Find path if we haven't specified it
		if ( pPath == null || pPath == "" ) {
			// TODO Manifest
			pPath = "translation.xml";
		}
		// Load up the XML
		var tFast : Fast = workinman.WMAssets.getXML( pPath );

		// Check the XML format
		var tFormat : LOCALIZATION_FORMAT = TRADITIONAL_XML;
		if ( tFast.has.format ) {
			tFormat = Type.createEnum(LOCALIZATION_FORMAT,tFast.att.format);
		}

		// Check the XML default font
		defaultFont = tFast.att.defaultFont;

		// Check the XML rtl status
		rtl = false;
		if ( tFast.has.rtl ) {
			rtl = tFast.att.rtl == "true";
		}

		subtitlesEnabled = false;
		if ( tFast.has.sub ) {
			subtitlesEnabled = tFast.att.sub == "true";
		}

		// Now handle the format correctly
		switch ( tFormat ) {
			case TRADITIONAL_XML:
				// Parse the string nodes in the xml
				var tId : String = "";
				for ( stringNode in tFast.nodes.string ) {
					tId = stringNode.att.id;
					if ( _localizedData.exists(tId) ) {
						trace( "[WMLocalize](parseLocalization) Duplicate localization entry found for id \'" + tId + "\'" );
						continue;
					}
					_addLocalizationData( tId, stringNode.innerData,
						stringNode.has.fontName?stringNode.att.fontName:defaultFont,
						stringNode.has.fontScale?stringNode.att.fontScale:"1",
						stringNode.has.offsetX?stringNode.att.offsetX:"0",
						stringNode.has.offsetY?stringNode.att.offsetY:"0",
						stringNode.has.subTime?stringNode.att.subTime:"-1"
					);
				}
				tId = null;
			case STRINGS_JS:
				// Parse whatever JS we load, the path is contained in the informational xml
				// TODO UNHANDLED AS OF NOW SINCE JSON FORMAT WAS SPECIFIED instead
			case STRINGS_JSON:
				var tId : String = "";
				for ( json in tFast.nodes.json ) {
					var tJson : Dynamic = Json.parse(workinman.WMAssets.getFile(json.innerData).toString());
					for ( s in Reflect.fields(tJson.strings) ) {
						var tVal : Dynamic = Reflect.field(tJson.strings,s);
						// See if we have more data than just the name:
						if ( tVal.value != null ) {
							_addLocalizationData( s, tVal.value,
								tVal.fontName==null?"":tVal.fontName,
								tVal.fontScale==null?"1":tVal.fontScale,
								tVal.offsetX==null?"0":tVal.offsetX,
								tVal.offsetY==null?"0":tVal.offsetY,
								tVal.subTime==null?"-1":tVal.subTime
							);
						} else {
							_addLocalizationData( s, tVal, "", "1", "0", "0", "-1" );
						}
					}
					tJson = null;
				}
		}
		tFast = null;
	}

	private static function _addLocalizationData( pId:String, pValue:String, pFontName:String, pFontScale:String, pOffsetX:String, pOffsetY:String, pSubtitleTime:String ) : Void {
		if ( _localizedData.exists(pId) ) {
			trace("[WMLocalize](_addLocalizationData) Duplucate definition of id \"" + pId + "\" disposing old definition." );
			_localizedData[pId].dispose();
		}
		_localizedData[pId] = new LocalizationData( pId, pValue, pFontName, Std.parseFloat(pFontScale), Std.parseFloat(pOffsetX), Std.parseFloat(pOffsetY), Std.parseFloat(pSubtitleTime) );
	}

	public static function getLocalizeData( pId:String ) : LocalizationData {
		if ( _localizedData.exists(pId) == false ) {
			trace("[WMLocalize] ERROR: No localization data for : \'" + pId + "\'" );
			return null;
		}
		return _localizedData[pId];
	}
}
