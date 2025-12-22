package workinman.display.spine.platform.flambe;

import workinman.display.spine.atlas.TextureLoader;
import workinman.display.spine.atlas.AtlasPage;
import workinman.display.spine.atlas.AtlasRegion;
import flambe.asset.AssetPack;
import flambe.display.Texture;
using flambe.util.Strings;

class FlambeTextureLoader implements TextureLoader {

	var prefix:String;
	var pack:AssetPack;

	public function new(prefix:String, pack:AssetPack) {
		this.prefix = prefix;
		this.pack = pack;
	}

	public function dispose() : Void {
		pack = null;
	}

	public function loadPage (page:AtlasPage, path:String) : Void {
		var tPath:String = prefix + path.removeFileExtension();
		var texture:Texture = pack.getTexture(tPath);
		page.rendererObject = texture;
		page.width = texture.width;
		page.height = texture.height;
	}

	public function loadRegion (region:AtlasRegion) : Void {

	}

	public function unloadPage (page:AtlasPage) : Void {

	}

	public function loadTexture(textureFile:String, format, useMipMaps):Texture {
		return null;
	}
}
