package workinman.display.spine.platform.flambe;

import flambe.display.BlendMode;
import flambe.display.Texture;
import flambe.platform.html.CanvasGraphics;
import flambe.platform.html.CanvasTexture;
import js.html.CanvasRenderingContext2D;
import workinman.display.spine.attachments.MeshAttachment;
import workinman.display.spine.atlas.AtlasRegion;

class MeshSprite extends Sprite {

    /** The region attachment for this sprite */
    public var meshAttachment (default, null)		: MeshAttachment;
    /** The texture to use for rendering. */
    public var region(default, null) 				: AtlasRegion;
    /** The atlas to draw from. */
    public var atlas(default, null) 				: Texture;
    public var slot (default, null)					: Slot;
	public var color 								: Int;
	public var worldVertices						: Array<Float>;
	private var _flagRenderBoxes					: Bool;

    public function new (meshAttachment :MeshAttachment, slot:Slot, renderBoxes:Bool)
    {
        super({originX:0, originY:0});
        this.meshAttachment = meshAttachment;
        this.region = cast meshAttachment.rendererObject;
        this.atlas = cast region.page.rendererObject;
		this.slot = slot;
		_flagRenderBoxes = renderBoxes;

        var regionWidth:Float = region.rotate ? region.height : region.width;
        var regionHeight:Float = region.rotate ? region.width : region.height;
        _w = regionWidth;
        _h = regionHeight;
    }

    override public function dispose ()
    {
        super.dispose();
        meshAttachment = null;
        region = null;
        atlas = null;
		slot = null;
    }

    private override function _draw (g :Graphics) {
		var uvs:Array<Float> = meshAttachment.uvs;
		var triangles:Array<Int> = meshAttachment.triangles;
		var vertices:Array<Float> = worldVertices;

		// if(!Std.is(g, CanvasGraphics)) {
		// 	//TODO webgl
		// 	return;
		// }

		var i:Int = 0;
		while(i < triangles.length)
		{
			var triangle:Int = triangles[i] * 2;
			var x0:Float = vertices[triangle];
			var y0:Float = vertices[triangle + 1];
			var u0:Float = uvs[triangle] * region.page.width;
			var v0:Float = uvs[triangle + 1] * region.page.height;

			triangle = triangles[i + 1] * 2;
			var x1:Float = vertices[triangle];
			var y1:Float = vertices[triangle + 1];
			var u1:Float = uvs[triangle] * region.page.width;
			var v1:Float = uvs[triangle + 1] * region.page.height;

			triangle = triangles[i + 2] * 2;
			var x2:Float = vertices[triangle];
			var y2:Float = vertices[triangle + 1];
			var u2:Float = uvs[triangle] * region.page.width;
			var v2:Float = uvs[triangle + 1] * region.page.height;

			g.canvasCtx.save();
			g.canvasCtx.beginPath();
			g.canvasCtx.moveTo(x0, y0);
			g.canvasCtx.lineTo(x1, y1);
			g.canvasCtx.lineTo(x2, y2);
			g.canvasCtx.closePath();
			if(_flagRenderBoxes) {
				g.canvasCtx.strokeStyle="#00FF00";
				g.canvasCtx.stroke();
			}
			g.canvasCtx.clip();

			var delta =  (u0 * v1)      + (v0 * u2)      + (u1 * v2)      - (v1 * u2)      - (v0 * u1)      - (u0 * v2);
		    var deltaA = (x0 * v1)      + (v0 * x2)      + (x1 * v2)      - (v1 * x2)      - (v0 * x1)      - (x0 * v2);
		    var deltaB = (u0 * x1)      + (x0 * u2)      + (u1 * x2)      - (x1 * u2)      - (x0 * u1)      - (u0 * x2);
		    var deltaC = (u0 * v1 * x2) + (v0 * x1 * u2) + (x0 * u1 * v2) - (x0 * v1 * u2) - (v0 * u1 * x2) - (u0 * x1 * v2);
		    var deltaD = (y0 * v1)      + (v0 * y2)      + (y1 * v2)      - (v1 * y2)      - (v0 * y1)      - (y0 * v2);
		    var deltaE = (u0 * y1)      + (y0 * u2)      + (u1 * y2)      - (y1 * u2)      - (y0 * u1)      - (u0 * y2);
		    var deltaF = (u0 * v1 * y2) + (v0 * y1 * u2) + (y0 * u1 * v2) - (y0 * v1 * u2) - (v0 * u1 * y2) - (u0 * y1 * v2);

		    g.canvasCtx.transform(deltaA / delta, deltaD / delta, deltaB / delta, deltaE / delta, deltaC / delta, deltaF / delta);
	        var texture :CanvasTexture = cast atlas;
	        var root = texture.root;
	        root.assertNotDisposed();
			g.canvasCtx.drawImage(root.image, 0, 0);
			texture = null;
			root = null;

			g.canvasCtx.restore();

			i += 3;
		}
    }

    private override function get_width() :Float {
        return region.width;
    }

    private override function get_height() :Float {
        return region.height;
    }

    /** The real width of this region */
    private var _w :Float = 0;
    /** The real height of this region */
    private var _h :Float = 0;

}
