package workinman.assets;

import flambe.asset.AssetPack;

class WMAssetPack {

	public var assets(default,null) : Array<String>;
	public var spritesheets(default,null) : Array<String>;
	public var pack(default,null) : AssetPack;
	public var flump(default,null) : Array<String>;

	public function new( pPack:AssetPack ) : Void {
		pack = pPack;
		assets = [];
		spritesheets = [];
		flump = [];
	}

	public function dispose() : Void {
		pack.dispose();
		pack = null;
		assets = null;
		pack = null;
		flump = null;
	}
}
