package workinman.display.spine.platform.flambe;

import workinman.display.spine.attachments.RegionAttachment;
import workinman.display.spine.atlas.AtlasRegion;
import flambe.display.Texture;

/**
 * An instanced Flump atlased texture.
 */
class RegionSprite extends Sprite {

    /** The region attachment for this sprite */
    public var regionAttachment (default, null) : RegionAttachment;
    /** The texture to use for rendering. */
    public var region(default, null) : AtlasRegion;
    /** The atlas to draw from. */
    public var atlas(default, null) : Texture;
    public var slot (default, null) : Slot;
	public var color : Int;

    public function new (regionAttachment :RegionAttachment, slot:Slot)  {
        super({originX:0, originY:0});
        this.regionAttachment = regionAttachment;
        this.region = cast regionAttachment.rendererObject;
        this.atlas = cast region.page.rendererObject;
		this.slot = slot;

        var regionWidth:Float = region.rotate ? region.height : region.width;
        var regionHeight:Float = region.rotate ? region.width : region.height;
        _w = regionWidth;
        _h = regionHeight;

        // Rotate and scale using default registration point (top left corner, y-down, CW) instead of image center.
        rotation = -regionAttachment.rotation;
        scaleX = regionAttachment.scaleX * (regionAttachment.width / region.originalWidth);
        scaleY = regionAttachment.scaleY * (regionAttachment.height / region.originalHeight);
        if (region.rotate) {
		    scaleY = regionAttachment.scaleX * (regionAttachment.width / region.originalWidth);
	        scaleX = regionAttachment.scaleY * (regionAttachment.height / region.originalHeight);
		}

        // Position using attachment translation, shifted as if scale and rotation were at image center.
        var radians:Float = -regionAttachment.rotation * Math.PI / 180;
        var cos:Float = Math.cos(radians);
        var sin:Float = Math.sin(radians);
        var shiftX:Float = -regionAttachment.width / 2 * Math.abs(regionAttachment.scaleX);
        var shiftY:Float = -regionAttachment.height / 2 * Math.abs(regionAttachment.scaleY);
        var shiftXOffset:Float = region.offsetX * scaleX;
        var shiftYOffset:Float = ((region.originalHeight - region.height) - region.offsetY) * scaleY;

		if(regionAttachment.scaleX < 0) {
			 if (region.rotate) {
				shiftX -= regionHeight * (regionAttachment.width / region.originalWidth);
			 } else {
        	 	shiftX = regionAttachment.width / 2 * Math.abs(regionAttachment.scaleX);
			 }
		}

		if(regionAttachment.scaleY < 0) {
			 if (region.rotate) {
				shiftY += regionWidth * (regionAttachment.height / region.originalHeight);
			 } else {
        	 	shiftY = regionAttachment.height / 2 * Math.abs(regionAttachment.scaleY);
			 }
		}

        if (region.rotate) {
            rotation += 90;
            shiftX += regionHeight * ((regionAttachment.width * Math.abs(regionAttachment.scaleX)) / region.originalWidth);
        }

        x = regionAttachment.x + shiftX * cos - shiftY * sin + shiftXOffset * cos - shiftYOffset * sin;
        y = -regionAttachment.y + shiftX * sin + shiftY * cos + shiftXOffset * sin + shiftYOffset * cos;
    }

    override public function dispose ()
    {
        super.dispose();
        regionAttachment = null;
        region = null;
        atlas = null;
		slot = null;
    }

    private override function _draw (g :Graphics)
    {
		g.ctx.drawSubTexture(atlas, 0, 0, region.x, region.y, _w, _h);
		//g.drawTexture(ColorTransform.instance.colorMask(atlas, region.x, region.y, _w, _h, color), 0, 0);
    }

	private override function get_width() : Float {
		return region.originalWidth;
	}

	private override function get_height() : Float {
		return region.originalHeight;
	}

    /** The real width of this region */
    private var _w :Float = 0;
    /** The real height of this region */
    private var _h :Float = 0;

}
