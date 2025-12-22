package workinman.debug;

import js.Browser;
import js.html.*;

class DebugUtils {
	
	public static function getElem(pQuery:String, ?pParent:Element) : Element {
		if(pParent != null) {
			return pParent.querySelector(pQuery);
		} else {
			return Browser.document.querySelector(pQuery);
		}
	};

	public static function newElem(pTag:String, ?pAttributes:Dynamic, ?pParent:Node) : Element {
		var tElement:Element = Browser.document.createElement(pTag);
		if(pAttributes != null) {
			for (n in Reflect.fields(pAttributes)) {
				if(Reflect.field(pAttributes, n) != null) {
					switch(n) {
						case "style": Reflect.setField(Reflect.field(tElement, "style"), "cssText", Reflect.field(pAttributes, n));
						default:
							Reflect.setField(tElement, n, Reflect.field(pAttributes, n));
					}
				}
			}
		}
		if(pParent != null) pParent.appendChild(tElement);
		return tElement;
	}

	public static function removeElem(pElem:Element) : Element {
		return cast pElem.parentNode.removeChild(pElem);
	}

	public static function cleanNum(pNum:Float, pDec:Int) : Float {
		var tCleaner = Math.pow(10, pDec);
		return Math.floor(pNum * tCleaner) / tCleaner;
	}

	public static function getClassName(pObj:Dynamic) : String {
		var tClassNameArray:Array<String> = Type.getClassName(Type.getClass(pObj)).split(".");
		return tClassNameArray[tClassNameArray.length-1];
	}

	public static var _UNIQ : Int = 0;
	public static function uniqID() : String { return Std.string(_UNIQ++); }

	public static function drawLine(pContext:CanvasRenderingContext2D, p1X:Float, p1Y:Float, p2X:Float, p2Y:Float, pColour:String="#000")
	{
		pContext.beginPath();
		pContext.moveTo(p1X, p1Y);
		pContext.lineTo(p2X, p2Y);
		pContext.closePath();

		/*pContext.lineWidth = 1;*/
		pContext.strokeStyle = pColour;
		pContext.stroke();
	}
}
