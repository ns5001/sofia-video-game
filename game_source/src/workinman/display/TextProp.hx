package workinman.display;

import flambe.display.Font;

typedef TextProp = {
	> SpriteProp,
	text:String,
	?vars:Array<Dynamic>,
	?align:TextAlign,
	?wrapWidth:Float,
	?lineSpacing:Float,
	?letterSpacing:Float,
	?color:Int,
}
