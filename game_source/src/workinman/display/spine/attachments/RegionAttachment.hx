package workinman.display.spine.attachments;

class RegionAttachment extends Attachment {

	public static inline var X1:Int = 0;
	public static inline var Y1:Int = 1;
	public static inline var X2:Int = 2;
	public static inline var Y2:Int = 3;
	public static inline var X3:Int = 4;
	public static inline var Y3:Int = 5;
	public static inline var X4:Int = 6;
	public static inline var Y4:Int = 7;

	public var x:Float;
	public var y:Float;
	public var scaleX:Float = 1;
	public var scaleY:Float = 1;
	public var rotation:Float;
	public var width:Float;
	public var height:Float;
	public var r:Float = 1;
	public var g:Float = 1;
	public var b:Float = 1;
	public var a:Float = 1;

	public var path:String;
	public var rendererObject:Dynamic;
	public var regionOffsetX:Float; // Pixels stripped from the bottom left, unrotated.
	public var regionOffsetY:Float;
	public var regionWidth:Float; // Unrotated, stripped size.
	public var regionHeight:Float;
	public var regionOriginalWidth:Float; // Unrotated, unstripped size.
	public var regionOriginalHeight:Float;

	public var offset:Array<Float> = new Array<Float>();
	public var uvs:Array<Float> = new Array<Float>();

	public function new (name:String) {
		super(name);
		offset = ArrayUtils.allocFloat(8);
		uvs = ArrayUtils.allocFloat(8);
	}

	public override function dispose() : Void
	{
		super.dispose();
		rendererObject = null;
	}

	public function setUVs (u:Float, v:Float, u2:Float, v2:Float, rotate:Bool) : Void {
		if (rotate) {
			uvs[X2] = u;
			uvs[Y2] = v2;
			uvs[X3] = u;
			uvs[Y3] = v;
			uvs[X4] = u2;
			uvs[Y4] = v;
			uvs[X1] = u2;
			uvs[Y1] = v2;
		} else {
			uvs[X1] = u;
			uvs[Y1] = v2;
			uvs[X2] = u;
			uvs[Y2] = v;
			uvs[X3] = u2;
			uvs[Y3] = v;
			uvs[X4] = u2;
			uvs[Y4] = v2;
		}
	}

	public function updateOffset () : Void {
		var regionScaleX:Float = width / regionOriginalWidth * scaleX;
		var regionScaleY:Float = height / regionOriginalHeight * scaleY;
		var localX:Float = -width / 2 * scaleX + regionOffsetX * regionScaleX;
		var localY:Float = -height / 2 * scaleY + regionOffsetY * regionScaleY;
		var localX2:Float = localX + regionWidth * regionScaleX;
		var localY2:Float = localY + regionHeight * regionScaleY;
		var radians:Float = rotation * Math.PI / 180;
		var cos:Float = Math.cos(radians);
		var sin:Float = Math.sin(radians);
		var localXCos:Float = localX * cos + x;
		var localXSin:Float = localX * sin;
		var localYCos:Float = localY * cos + y;
		var localYSin:Float = localY * sin;
		var localX2Cos:Float = localX2 * cos + x;
		var localX2Sin:Float = localX2 * sin;
		var localY2Cos:Float = localY2 * cos + y;
		var localY2Sin:Float = localY2 * sin;
		offset[X1] = localXCos - localYSin;
		offset[Y1] = localYCos + localXSin;
		offset[X2] = localXCos - localY2Sin;
		offset[Y2] = localY2Cos + localXSin;
		offset[X3] = localX2Cos - localY2Sin;
		offset[Y3] = localY2Cos + localX2Sin;
		offset[X4] = localX2Cos - localYSin;
		offset[Y4] = localYCos + localX2Sin;
	}

	public function computeWorldVertices (x:Float, y:Float, bone:Bone, worldVertices:Array<Float>) : Void {
		x += bone.worldX;
		y += bone.worldY;
		var m00:Float = bone.a;
		var m01:Float = bone.b;
		var m10:Float = bone.c;
		var m11:Float = bone.d;
		var x1:Float = offset[X1];
		var y1:Float = offset[Y1];
		var x2:Float = offset[X2];
		var y2:Float = offset[Y2];
		var x3:Float = offset[X3];
		var y3:Float = offset[Y3];
		var x4:Float = offset[X4];
		var y4:Float = offset[Y4];
		worldVertices[X1] = x1 * m00 + y1 * m01 + x;
		worldVertices[Y1] = x1 * m10 + y1 * m11 + y;
		worldVertices[X2] = x2 * m00 + y2 * m01 + x;
		worldVertices[Y2] = x2 * m10 + y2 * m11 + y;
		worldVertices[X3] = x3 * m00 + y3 * m01 + x;
		worldVertices[Y3] = x3 * m10 + y3 * m11 + y;
		worldVertices[X4] = x4 * m00 + y4 * m01 + x;
		worldVertices[Y4] = x4 * m10 + y4 * m11 + y;
	}
}
