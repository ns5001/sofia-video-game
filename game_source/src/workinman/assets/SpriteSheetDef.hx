package workinman.assets;

import workinman.display.SpriteRect;

/**
 * A parsed TexturePacker sprite definition
 */
class SpriteSheetDef {

	/**
	 * String ID of the Texture Atlas Asset
	 */
	public var atlas(default,null) : String;

	/**
	 * Rectangle coordinates for Sprite within the Sprite Sheet
	 */
	public var rect(default,null) : SpriteRect;

	/**
	 * Constructor for WMSpriteSheetDef
	 */
	public function new ( pAtlas:String, pRect:SpriteRect ) : Void {
		rect = pRect;
		atlas = pAtlas;
	}

	/**
	 * Dispose the WMSpriteSheetDef
	 */
	public function dispose() : Void {
		rect = null;
		atlas = null;
	}
}
