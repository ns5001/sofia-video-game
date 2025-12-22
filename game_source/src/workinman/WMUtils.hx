package workinman;

import workinman.utils.PropertyList;
import flambe.display.Texture;
import flambe.display.BlendMode;
import flambe.System;

class WMUtils  {

	// Trim the domain off of the supplied url
	public static function trimUrl( url:String ) : String {
		if(url==""){return "";}
		if(url.indexOf("http")<0)
		{
			if(url.charAt(0)=="/")
			{
				url = url.substr(1, url.length-1);
			}
			return url;
		}
		var tStartIndex = url.indexOf("http://");
		if(tStartIndex<0)
		{
			tStartIndex = url.indexOf("https://");
			if(tStartIndex<0)
			{
				// This should be impossible.
				tStartIndex=0;
			} else {
				tStartIndex += 8;
			}
		} else {
			tStartIndex += 7;
		}

		var tEndIndex = url.indexOf("/", tStartIndex);
		var result = url.substr(tEndIndex, url.length-tEndIndex);
		result = appendAssetsToUrl(result);

		return result;
	}

	// Append the "assets" tag to the url
	public static function appendAssetsToUrl( url:String) : String {
		if ( url.length == 0 ) {
			return url;
		}
		if(url.charAt(url.length-1)!="/")	{
			url = url + "/";
		}
		if(url.indexOf("/assets")<url.length-9)
		{
			url = url + "assets/";
		}
		return url;
	}

	static public function getCacheBreakerString() : String {
		return "?_=" + WMRandom.randomString( 5 + Math.floor(Math.random() * 15) );
	}

	static public function parsePropertyList( pText:String ) : Dynamic {
		return PropertyList.parse(pText);
	}

	static public function getExtension( pPath:String ) : String {
		if(pPath == null) { return ""; }
		var length:Int = pPath.lastIndexOf(".");
		if (length < 0) {
			return "";
		} else {
			var query:Int = pPath.lastIndexOf("?");
			if(query > length) return pPath.substring(length + 1, query);
			return pPath.substring(length + 1, pPath.length);
		}
	}

	static public function removeExtension( pPath:String ) : String {
		var length = pPath.lastIndexOf(".");
		if (length < 0) {
			return pPath;
		} else {
			return pPath.substring(0, length);
		}
	}

	static public function addStringToArrayWithoutDuplicates( pString:String, pArray:Array<String> ) : Void {
		for ( s in pArray ) {
			if ( s == pString ) {
				return;
			}
		}
		pArray.push(pString);
	}

	static public function removeDuplicatesFromStringArray( pArray:Array<String> ) : Array<String> {
		var tRes : Array<String> = [];
		for ( s in pArray ) {
			addStringToArrayWithoutDuplicates(s,tRes);
		}
		return tRes;
	}

	static public function clearTexture( pTexture:Texture ) : Void {
		pTexture.graphics.save();
		pTexture.graphics.setBlendMode(BlendMode.Mask);
		pTexture.graphics.setAlpha(0);
		pTexture.graphics.fillRect(0x000000,0,0,pTexture.width,pTexture.height);
		pTexture.graphics.restore();
	}

	// inject a script onto the page. Typical usage: WorkinUtils.addScript("analytics", ConstantsApp.BASE_URL + "embed/deltadna_proxy.js");
	static public function addScript(pId:String, pSrc:String, pComplete:Dynamic->Void) : Void {
		var element = js.Browser.document.createElement('script');
		element.setAttribute('id', pId);
		element.setAttribute('type', 'text/javascript');
		element.setAttribute('src', pSrc);
		element.onload = pComplete;
		js.Browser.document.getElementsByTagName('head')[0].appendChild(element);
	}

	static public function isDateToday(tDateString:String = "") : Bool {
		var date:Date = Date.now();
		var str:String = date.getFullYear() + (date.getMonth() < 9 ? "-0" : "-") + (date.getMonth() + 1) + (date.getDate() < 10 ? "-0" : "-") + date.getDate();
		date = Date.fromString(str);
		if(tDateString != "") {
			var tDate:Date = Date.fromString(tDateString);
			var dif:Float = (tDate.getTime() - date.getTime()) / 1000 / 60 / 60 / 24;
			if(dif == 0) { return true; }
		}
		return false;
	}

	static public function isDatePast(tDateString:String = "") : Bool {
		var date:Date = Date.now();
		if(tDateString != "") {
			var tDate:Date = Date.fromString(tDateString);
			var dif:Float = (tDate.getTime() - date.getTime()) / 1000 / 60 / 60 / 24;
			if(dif <= 0) { return true; }
		}
		return false;
	}
}
