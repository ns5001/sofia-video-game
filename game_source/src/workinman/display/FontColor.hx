package workinman.display;

import flambe.asset.AssetPack;
import flambe.asset.File;
import flambe.math.FMath;
import flambe.display.Font;
import flambe.display.BlendMode;
import flambe.display.Texture;
import flambe.System;

using StringTools;
using flambe.util.Strings;

/**
 * A bitmap font, created in any tool that exports the BMFont format, such as the original BMFont
 * editor, Hiero, or Glyph Designer.
 */
class FontColor extends Font
{
	private var _color : Int;
	private var _texture : Texture;

    public function new (pack :AssetPack, name :String, color : Int)
    {
		_color = color;
		super(pack, name);
    }

	private static var NEWLINE = new Glyph('\n'.code);

    private override function reload ()
    {
        _glyphs = new Map();
        _glyphs.set(NEWLINE.charCode, NEWLINE);

        var parser = new ConfigParser(_file.toString());
        var pages = new Map<Int,Texture>();

        // The basename of the font's path, where we'll find the textures
        var idx = name.lastIndexOf("/");
        var basePath = (idx >= 0) ? name.substr(0, idx+1) : "";

        // BMFont spec: http://www.angelcode.com/products/bmfont/doc/file_format.html
        for (keyword in parser.keywords()) {
            switch (keyword) {
            case "info":
                for (pair in parser.pairs()) {
                    switch (pair.key) {
                    case "size":
                        size = pair.getInt();
                    }
                }

            case "common":
                for (pair in parser.pairs()) {
                    switch (pair.key) {
                    case "lineHeight":
                        lineHeight = pair.getInt();
                    }
                }

            case "page":
                var pageId :Int = 0;
                var file :String = null;
                for (pair in parser.pairs()) {
                    switch (pair.key) {
                    case "id":
                        pageId = pair.getInt();
                    case "file":
                        file = pair.getString();
                    }
                }
				if (pages.get(pageId) == null) {
					var tTexture = _pack.getTexture(basePath + file.removeFileExtension());
					_texture = System.renderer.createTexture(Std.int(tTexture.width), Std.int(tTexture.height));
					_texture.graphics.fillRect(_color, 0, 0, _texture.width, _texture.height);
					//mask
					_texture.graphics.setBlendMode(BlendMode.Mask);
					_texture.graphics.drawTexture(tTexture, 0, 0);
					_texture.graphics.setBlendMode(BlendMode.Normal);
					tTexture = null;
					pages.set(pageId, _texture);
				}


            case "char":
                var glyph = null;
                for (pair in parser.pairs()) {
                    switch (pair.key) {
                    case "id":
                        glyph = new Glyph(pair.getInt());
                    case "x":
                        glyph.x = pair.getInt();
                    case "y":
                        glyph.y = pair.getInt();
                    case "width":
                        glyph.width = pair.getInt();
                    case "height":
                        glyph.height = pair.getInt();
                    case "page":
                        glyph.page = pages.get(pair.getInt());
                    case "xoffset":
                        glyph.xOffset = pair.getInt();
                    case "yoffset":
                        glyph.yOffset = pair.getInt();
                    case "xadvance":
                        glyph.xAdvance = pair.getInt();
                    }
                }
                _glyphs.set(glyph.charCode, glyph);

            case "kerning":
                var first :Glyph = null;
                var second = 0, amount = 0;
                for (pair in parser.pairs()) {
                    switch (pair.key) {
                    case "first":
                        first = _glyphs.get(pair.getInt());
                    case "second":
                        second = pair.getInt();
                    case "amount":
                        amount = pair.getInt();
                    }
                }
                if (first != null && amount != 0) {
                    first.setKerning(second, amount);
                }
            }
        }
    }
}

private class ConfigParser
{
    public function new (config :String)
    {
        _configText = config;
        _keywordPattern = ~/([A-Za-z]+)(.*)/;
        _pairPattern = ~/([A-Za-z]+)=("[^"]*"|[^\s]+)/;
    }

    public function keywords () :Iterator<String>
    {
        var text = _configText;
        return {
            next: function () {
                text = advance(text, _keywordPattern);
                _pairText = _keywordPattern.matched(2);
                return _keywordPattern.matched(1);
            },
            hasNext: function () {
                return _keywordPattern.match(text);
            }
        };
    }

    public function pairs () :Iterator<ConfigPair>
    {
        var text = _pairText;
        return {
            next: function () {
                text = advance(text, _pairPattern);
                return new ConfigPair(_pairPattern.matched(1), _pairPattern.matched(2));
            },
            hasNext: function () {
                return _pairPattern.match(text);
            }
        };
    }

    private static function advance (text :String, expr :EReg)
    {
        var m = expr.matchedPos();
        return text.substr(m.pos + m.len, text.length);
    }

    // The entire config file contents
    private var _configText :String;

    // The line currently being processed
    private var _pairText :String;

    private var _keywordPattern :EReg;
    private var _pairPattern :EReg;
}

private class ConfigPair
{
    public var key (default, null) :String;

    public function new (key :String, value :String)
    {
        this.key = key;
        _value = value;
    }

    public function getInt () :Int
    {
        return Std.parseInt(_value);
    }

    public function getString () :String
    {
        if (_value.fastCodeAt(0) != "\"".code) {
            return null;
        }
        return _value.substr(1, _value.length-2);
    }

    private var _value :String;
}
