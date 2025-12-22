package workinman.display;

import flambe.display.Texture;
import workinman.display.Graphics;

class ImageSprite extends Sprite {

	public var rect(default,default) : SpriteRect;
	public var texture(default,default) : Texture;
	public var asset(get,set) : String;
	public function get_asset() : String {
		return _asset;
	}
	
	public function set_asset(pAsset:String) : String {
		setAsset(pAsset);

		return _asset;
	}

	private var _asset : String;

	public function new( prop:ImageSpriteProp ) : Void {
		super(prop);
		rect = null;
		texture = null;
		if ( prop != null ) {
			if ( prop.asset != null ) { setAsset(prop.asset);	}
		}
	}

	public override function dispose() : Void {
		super.dispose();
		rect = null;
		texture = null;
	}

	public override function get_width() : Int {
		if ( texture == null ) {
			return 0;
		}
		if ( rect != null ) {
			return rect.origX;
		}
		return texture.width;
	}

	public override function get_height() : Int {
		if ( texture == null ) {
			return 0;
		}
		if ( rect != null ) {
			return rect.origY;
		}
		return texture.height;
	}

	public function setAsset( pAsset:String ) : ImageSprite {
		if ( pAsset == null || pAsset == "" ) {
			// Ignore changes that aren't valid
			return this;
		}
		
		_asset = pAsset;
		texture = workinman.WMAssets.getTexture(pAsset);
		rect = workinman.WMAssets.getSpriteRect(pAsset);
		return this;
	}

	public function setTexture( pTexture:Texture ) : ImageSprite {
		rect = null;
		texture = pTexture;
		return this;
	}

	private override function _draw( g:Graphics ) : Void {
		if ( texture == null ) {
			return;
		}
		if ( rect != null ) {
			if ( rect.rotate ) {
				g.ctx.save();
				g.ctx.rotate(90);
				g.ctx.drawSubTexture( texture, rect.origY - rect.sizeY - rect.offsetY, -rect.offsetX-rect.sizeX, rect.x, rect.y, rect.sizeY, rect.sizeX );
				g.ctx.restore();
			} else {
				g.ctx.drawSubTexture( texture, rect.offsetX, rect.origY - rect.sizeY - rect.offsetY, rect.x, rect.y, rect.sizeX, rect.sizeY );
			}
			return;
		}
		g.ctx.drawTexture(texture,0,0);
	}
}
