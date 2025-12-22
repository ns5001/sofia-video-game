package workinman.display.spine.attachments;

import workinman.display.spine.atlas.AtlasRegion;

class MeshAttachment extends Attachment {

	public var vertices:Array<Float>;
	public var uvs:Array<Float>;
	public var regionUVs:Array<Float>;
	public var triangles:Array<Int>;
	public var hullLength:Int;
	public var region:AtlasRegion;
	public var rendererObject:Dynamic;
	public var worldVertices:Array<Float>;

	public var r:Float = 1;
	public var g:Float = 1;
	public var b:Float = 1;
	public var a:Float = 1;

	public var path:String;

	// Nonessential.
	public var edges:Array<Int>;
	public var width:Float;
	public var height:Float;

	public function new (name:String) {
		super(name);
	}

	public override function dispose() : Void {
		super.dispose();
		vertices = null;
		uvs = null;
		regionUVs = null;
		triangles = null;
		rendererObject = null;
		worldVertices = null;
		region = null;
	}

	public function updateUVs() : Void {
		if(region == null) { region = rendererObject; }

		var i:Int, n:Int = regionUVs.length;
		if (uvs == null || uvs.length != n) uvs = new Array<Float>();
		var u:Float, v:Float, width:Float, height:Float;
		if(region == null) {
			u = v = 0;
			width = height = 1;
		} else {
			u = region.u;
			v = region.v;
			width = region.u2 - u;
			height = region.v2 - v;
		}
		var regionUVs:Array<Float> = this.regionUVs;
		if(Std.is(region, AtlasRegion) && cast(region, AtlasRegion).rotate) {
			i = 0;
			while(i < n) {
				uvs[i] = u + regionUVs[i + 1] * width;
				uvs[i + 1] = v + height - regionUVs[i] * height;
				i += 2;
			}
		} else {
			i = 0;
			while(i < n) {
				uvs[i] = u + regionUVs[i] * width;
				uvs[i + 1] = v + regionUVs[i + 1] * height;
				i += 2;
			}
		}
	}

	public function updateWorldVertices(slot:Slot, premultipliedAlpha:Bool) : Array<Float>
	{
		var skeleton:Skeleton = slot.skeleton;
		var bone:Bone = slot.bone;
		var x:Float = skeleton.x + bone.worldX, y:Float = skeleton.y + bone.worldY;
		var m00:Float = bone.a, m01 = bone.b, m10 = bone.c, m11 = bone.d;

		var vertices:Array<Float> = this.vertices;
		var verticesCount:Int = vertices.length;
		if (slot.attachmentVertices.length == verticesCount) vertices = slot.attachmentVertices;

		var worldVertices:Array<Float> = new Array<Float>();
		var v:Int = 0;
		var w:Int = 0;
		while(w < verticesCount) {

			var vx:Float = vertices[v];
			var vy:Float = vertices[v + 1];
			worldVertices[w] = vx * m00 + vy * m01 + x;
			worldVertices[w + 1] = vx * m10 + vy * m11 + y;

			v += 2;
			w += 2;
		}
		return worldVertices;
	}
}
