package workinman.display.spine.attachments;

class BoundingBoxAttachment extends Attachment {

	public var vertices:Array<Float>;

	public function new(name:String) {
		super(name);
		vertices = new Array<Float>();
	}

	public override function dispose() : Void {
		super.dispose();
		vertices = null;
	}

	public function computeWorldVertices (x:Float, y:Float, bone:Bone, worldVertices:Array<Float>) : Void {
		while(worldVertices.length > 0) worldVertices.pop();
		x += bone.worldX;
		y += bone.worldY;
		var m00:Float = bone.a;
		var m01:Float = bone.b;
		var m10:Float = bone.c;
		var m11:Float = bone.d;
		var vertices:Array<Float> = this.vertices;
		var i:Int = 0;
		var n:Int = vertices.length;
		while(i < n) {
			var ii:Int = i + 1;
			var px:Float = vertices[i];
			var py:Float = vertices[ii];
			worldVertices[i] = px * m00 + py * m01 + x;
			worldVertices[ii] = px * m10 + py * m11 + y;
			i += 2;
		}
	}
}
