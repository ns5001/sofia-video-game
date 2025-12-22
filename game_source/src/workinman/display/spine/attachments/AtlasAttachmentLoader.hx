package workinman.display.spine.attachments;

import workinman.display.spine.atlas.Atlas;
import workinman.display.spine.atlas.AtlasRegion;
import workinman.display.spine.Exception;

class AtlasAttachmentLoader implements AttachmentLoader {

	private var atlas:Atlas;

	public function new (atlas:Atlas) {
		//if (atlas == null)
			//throw new IllegalArgumentException("atlas cannot be null.");
		this.atlas = atlas;
	}

	public function dispose() : Void
	{
		atlas.dispose();
		atlas = null;
	}

	public function newRegionAttachment (skin:Skin, name:String, path:String) : RegionAttachment {
		if(atlas == null) {return null;}

		var region:AtlasRegion = atlas.findRegion(path);
		if (region == null)
			throw new Exception("Region not found in atlas: " + path + " (region attachment: " + name + ")");
		var attachment:RegionAttachment = new RegionAttachment(name);
		attachment.rendererObject = region;
		var scaleX:Float = region.page.width / nextPOT(region.page.width);
		var scaleY:Float = region.page.height / nextPOT(region.page.height);
		attachment.setUVs(region.u * scaleX, region.v * scaleY, region.u2 * scaleX, region.v2 * scaleY, region.rotate);
		attachment.regionOffsetX = region.offsetX;
		attachment.regionOffsetY = region.offsetY;
		attachment.regionWidth = region.width;
		attachment.regionHeight = region.height;
		attachment.regionOriginalWidth = region.originalWidth;
		attachment.regionOriginalHeight = region.originalHeight;
		return attachment;
	}

	public function newMeshAttachment (skin:Skin, name:String, path:String) : MeshAttachment {
		if(atlas == null) {return null;}

		var region:AtlasRegion = atlas.findRegion(path);
		if (region == null)
			throw new Exception("Region not found in atlas: " + path + " (mesh attachment: " + name + ")");
		var attachment:MeshAttachment = new MeshAttachment(name);
		attachment.rendererObject = region;
		return attachment;
	}

	public function newWeightedMeshAttachment (skin:Skin, name:String, path:String) : WeightedMeshAttachment {
		if(atlas == null) {return null;}

		var region:AtlasRegion = atlas.findRegion(path);
		if (region == null)
			throw new Exception("Region not found in atlas: " + path + " (weighted mesh attachment: " + name + ")");
		var attachment:WeightedMeshAttachment = new WeightedMeshAttachment(name);
		attachment.rendererObject = region;
		var scaleX:Float = region.page.width / nextPOT(region.page.width);
		var scaleY:Float = region.page.height / nextPOT(region.page.height);
		attachment.regionU = region.u * scaleX;
		attachment.regionV = region.v * scaleY;
		attachment.regionU2 = region.u2 * scaleX;
		attachment.regionV2 = region.v2 * scaleY;
		attachment.regionRotate = region.rotate;
		attachment.regionOffsetX = region.offsetX;
		attachment.regionOffsetY = region.offsetY;
		attachment.regionWidth = region.width;
		attachment.regionHeight = region.height;
		attachment.regionOriginalWidth = region.originalWidth;
		attachment.regionOriginalHeight = region.originalHeight;
		return attachment;
	}

	public function newBoundingBoxAttachment (skin:Skin, name:String) : BoundingBoxAttachment {
		return new BoundingBoxAttachment(name);
	}

	static public function nextPOT (value:Int) : Int {
		value--;
		value |= value >> 1;
		value |= value >> 2;
		value |= value >> 4;
		value |= value >> 8;
		value |= value >> 16;
		return value + 1;
	}
}
