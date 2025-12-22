package workinman.display.spine.attachments;

class WeightedMeshAttachment extends Attachment {
	
	public var bones:Array<Int>;
	public var weights:Array<Float>;
	public var uvs:Array<Float>;
	public var regionUVs:Array<Float>;
	public var triangles:Array<Int>;
	public var hullLength:Int;
	public var r:Float = 1;
	public var g:Float = 1;
	public var b:Float = 1;
	public var a:Float = 1;

	public var path:String;
	public var rendererObject:Dynamic;
	public var regionU:Float;
	public var regionV:Float;
	public var regionU2:Float;
	public var regionV2:Float;
	public var regionRotate:Bool;
	public var regionOffsetX:Float; // Pixels stripped from the bottom left, unrotated.
	public var regionOffsetY:Float;
	public var regionWidth:Float; // Unrotated, stripped size.
	public var regionHeight:Float;
	public var regionOriginalWidth:Float; // Unrotated, unstripped size.
	public var regionOriginalHeight:Float;

	// Nonessential.
	public var edges:Array<Int>;
	public var width:Float;
	public var height:Float;

	public function new (name:String) {
		super(name);
	}

	public override function dispose() : Void {
		super.dispose();
		bones = null;
		weights = null;
		uvs = null;
		regionUVs = null;
		triangles = null;
		rendererObject = null;
	}

	public function updateUVs () : Void {
		var width:Float = regionU2 - regionU, height:Float = regionV2 - regionV;
		var i:Int, n:Int = regionUVs.length;
		if (uvs == null || uvs.length != n) uvs = new Array<Float>();
		if (regionRotate) {
			i = 0;
			while(i < n) {
				uvs[i] = regionU + regionUVs[i + 1] * width;
				uvs[i + 1] = regionV + height - regionUVs[i] * height;
				i += 2;
			}
		} else {
			i = 0;
			while(i < n) {
				uvs[i] = regionU + regionUVs[i] * width;
				uvs[i + 1] = regionV + regionUVs[i + 1] * height;
				i += 2;
			}
		}
	}

	public function computeWorldVertices (x:Float, y:Float, slot:Slot, worldVertices:Array<Float>) : Void {
		var skeletonBones:Array<Bone> = slot.skeleton.bones;
		var weights:Array<Float> = this.weights;
		var bones:Array<Int> = this.bones;

		var w:Int = 0, v:Int = 0, b:Int = 0, f:Int = 0, n:Int = bones.length, nn:Int;
		var wx:Float, wy:Float, bone:Bone, vx:Float, vy:Float, weight:Float;
		if (slot.attachmentVertices.length == 0) {
			while(v < n) {
				wx = 0;
				wy = 0;
				nn = bones[v++] + v;
				while(v < nn) {
					bone = skeletonBones[bones[v]];
					vx = weights[b];
					vy = weights[b + 1];
					weight = weights[b + 2];
					wx += (vx * bone.a + vy * bone.b + bone.worldX) * weight;
					wy += (vx * bone.c + vy * bone.d + bone.worldY) * weight;
					v++;
					b += 3;
				}
				worldVertices[w] = wx + x;
				worldVertices[w + 1] = wy + y;
				w += 2;
			}
		} else {
			var ffd:Array<Float> = slot.attachmentVertices;
			while(v < n) {
				wx = 0;
				wy = 0;
				nn = bones[v++] + v;
				while(v < nn) {
					bone = skeletonBones[bones[v]];
					vx = weights[b] + ffd[f];
					vy = weights[b + 1] + ffd[f + 1];
					weight = weights[b + 2];
					wx += (vx * bone.a + vy * bone.b + bone.worldX) * weight;
					wy += (vx * bone.c + vy * bone.d + bone.worldY) * weight;
					v++;
					b += 3;
					f += 2;
				}
				worldVertices[w] = wx + x;
				worldVertices[w + 1] = wy + y;
				w += 2;
			}
		}
	}
}
