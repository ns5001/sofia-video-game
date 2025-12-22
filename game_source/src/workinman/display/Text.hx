package workinman.display;

import flambe.display.Font;
import flambe.math.FMath;
import workinman.localization.LocalizationData;

class Text extends Sprite {

	private var _layout 					: TextLayout;
	private var _font 						: Font;
	private var _fontName					: String;
	private var _data						: LocalizationData;
	private var _text						: String;
	private var _color						: Int;
	private var align(default,set)			: TextAlign;

	public var wrapWidth(default,set) 		: Float;
	public var letterSpacing(default,set) 	: Float;
	public var lineSpacing(default,set) 	: Float;

	// NOTE: force line breaks by adding "\r\n" or <br> in translation xml

	public function new( pData:TextProp ) {
		super(pData);
		_fontName = "";
		wrapWidth = letterSpacing = lineSpacing = 0;
		align = TextAlign.Center;
		if ( pData != null ) {
			if ( pData.color != null)			{ _color = pData.color; }
			setText( pData.text );
			setVariables( pData.vars );
			if ( pData.align != null ) 			{ align = pData.align; }
			if ( pData.wrapWidth != null ) 		{ wrapWidth = pData.wrapWidth; }
			if ( pData.lineSpacing != null )	{ lineSpacing = pData.lineSpacing; }
			if ( pData.letterSpacing != null )	{ letterSpacing = pData.letterSpacing; }
		}
		inputEnabled = false;
	}

	public override function dispose(): Void {
		_layout = null;
		_font = null;
		_fontName = null;
		_data = null;
		_text = null;
		align = null;
		super.dispose();
	}

	private override function get_width() : Float {
		if ( _layout == null || _data == null ) {
			return 0;
		}
		// return _layout.bounds.width * _data.scale;
		return ((wrapWidth>0)?wrapWidth:_layout.bounds.width) * _data.scale;
	}

	private override function get_height() : Float {
		if ( _layout == null || _data == null ) {
			return 0;
		}
	    var paddedHeight = _layout.lines * (_font.lineHeight+lineSpacing);
	    var boundsHeight = _layout.bounds.height;
	    return FMath.max(paddedHeight, boundsHeight) * _data.scale;
	}

	private function set_align(val:TextAlign) : TextAlign {
		if ( val == null ) {
			align = null;
			return null;
		}
		align = val;
		_updateLayout();
		return val;
	}

	private override function set_originX(val:Float) : Float {
		originX = 0;
		return 0;
	}

	private function set_wrapWidth(val:Float) : Float {
		wrapWidth = val;
		_updateLayout();
		return val;
	}

	private function set_letterSpacing(val:Float) : Float {
		letterSpacing = val;
		_updateLayout();
		return val;
	}

	private function set_lineSpacing(val:Float) : Float {
		lineSpacing = val;
		_updateLayout();
		return val;
	}

	public function setText( id:String, variables:Array<Dynamic> = null ) : Void {
		_data = workinman.WMLocalize.getLocalizeData(id);
		if ( _data == null ) {
			return;
		}
		offsetX = _data.offsetX;
		offsetY = _data.offsetY;
		_setFont(_data.fontName);
		_text = _replaceVars(variables);
		_updateLayout();
	}

	public function setColor( pColor : Int ) : Void {
		_color = pColor;
	}

	public function setVariables( variables:Array<Dynamic> ) : Void {
		if ( _data == null ) {
			return;
		}
		_text = _replaceVars(variables);
		_updateLayout();
	}

	public function _updateLayout() : Void {
		if ( _data == null || _font == null ) {
			return;
		}
		_layout = _font.layoutText(_text,align,wrapWidth/_data.scale,letterSpacing,lineSpacing);
	}

	private override function _draw(g:Graphics) : Void {
		if ( _layout == null ) {
			return;
		}
		g.ctx.save();
		if ( wrapWidth > 0 ) {
			var tAmt : Float = wrapWidth * _data.scale;
			switch ( align ) {
				case TextAlign.Left:
					//g.translate(-tAmt*.5,0);
				case TextAlign.Center:
					g.ctx.translate(-wrapWidth*0.5,0);
				case TextAlign.Right:
					g.ctx.translate(-tAmt*2,0);
			}
		}
		g.ctx.scale(_data.scale,_data.scale);
		_layout.draw(g.ctx);
		g.ctx.restore();
	}

	private function _setFont( pFont:String ) : Void {
		if ( pFont == _fontName ) {
			return;
		}
		if (_color != null) {
			_font = workinman.WMAssets.getFont(pFont, true, _color);
		} else {
			_font = workinman.WMAssets.getFont(pFont);
		}
	}

	private function _replaceVars( pVars:Array<Dynamic> ) : String {
		var tRes : String = "";
		var tSplit : Array<String> = _data.string.split("}");
		for ( s in tSplit ) {
			var tNum : Array<String> = s.split("{");
			tRes += tNum[0];
			if ( tNum.length > 1 ) {
				var tIndex : Int = Std.parseInt(tNum[1]);
				if ( pVars != null && pVars.length > tIndex ) {
					tRes += pVars[tIndex];
				} else {
					tRes += "[Missing {" + tIndex + "}]";
				}
				tNum = null;
			}
		}
		tSplit = null;
		return tRes;
	}
}
