package workinman.display.spine;

import workinman.display.spine.Exception;

class TransformConstraint implements Updatable {

	private var _data:TransformConstraintData;
	public var bone:Bone;
	public var target:Bone;
	public var translateMix:Float;
	public var rotateMix:Float;
	public var scaleMix:Float;
	public var shearMix:Float;
	public var offsetRotation:Float;
	public var offsetX:Float;
	public var offsetY:Float;
	public var offsetScaleX:Float;
	public var offsetScaleY:Float;
	public var offsetShearY:Float;

	public function new (data:TransformConstraintData, skeleton:Skeleton) {
		if (data == null) throw new IllegalArgumentException("data cannot be null.");
		if (skeleton == null) throw new IllegalArgumentException("skeleton cannot be null.");
		_data = data;
		translateMix = data.translateMix;
		rotateMix = data.rotateMix;
		scaleMix = data.scaleMix;
		shearMix = data.shearMix;
		offsetRotation = data.offsetRotation;
		offsetX = data.offsetX;
		offsetY = data.offsetY;
		offsetScaleX = data.offsetScaleX;
		offsetScaleY = data.offsetScaleY;
		offsetShearY = data.offsetShearY;

		bone = skeleton.findBone(data.bone.name);
		target = skeleton.findBone(data.target.name);
	}

	public function dispose() : Void
	{
		_data.dispose();
		_data = null;
		bone = null;
		target = null;
	}

	public function apply () : Void {
		update();
	}

	public function update () : Void {
		if (rotateMix > 0) {
			var a:Float = bone.a, b:Float = bone.b, c:Float = bone.c, d:Float = bone.d;
			var r:Float = Math.atan2(target.c, target.a) - Math.atan2(c, a) + offsetRotation * MathUtils.degRad;
			if (r > Math.PI)
				r -= (Math.PI * 2);
			else if (r < -Math.PI) r += (Math.PI * 2);
			r *= rotateMix;
			var cos:Float = Math.cos(r), sin:Float = Math.sin(r);
			bone.a = cos * a - sin * c;
			bone.b = cos * b - sin * d;
			bone.c = sin * a + cos * c;
			bone.d = sin * b + cos * d;
		}

		if (scaleMix > 0) {
			var bs:Float = Math.sqrt(bone.a * bone.a + bone.c * bone.c);
			var ts:Float = Math.sqrt(target.a * target.a + target.c * target.c);
			var s:Float = bs > 0 ? (bs + (ts - bs + offsetScaleX) * scaleMix) / bs : 0;
			bone.a *= s;
			bone.c *= s;
			bs = Math.sqrt(bone.b * bone.b + bone.d * bone.d);
			ts = Math.sqrt(target.b * target.b + target.d * target.d);
			s = bs > 0 ? (bs + (ts - bs + offsetScaleY) * scaleMix) / bs : 0;
			bone.b *= s;
			bone.d *= s;
		}

		if (shearMix > 0) {
			var b:Float = bone.b, d:Float = bone.d;
			var by:Float = Math.atan2(d, b);
			var r:Float = Math.atan2(target.d, target.b) - Math.atan2(target.c, target.a) - (by - Math.atan2(bone.c, bone.a));
			if (r > Math.PI)
				r -= (Math.PI * 2);
			else if (r < -Math.PI) r += (Math.PI * 2);
			r = by + (r + offsetShearY * MathUtils.degRad) * shearMix;
			var s:Float = Math.sqrt(b * b + d * d);
			bone.b = Math.cos(r) * s;
			bone.d = Math.sin(r) * s;
		}

		var translateMix:Float = translateMix;
		if (translateMix > 0) {
			var local:Array<Float> = ArrayUtils.allocFloat(2);
			local[0] = offsetX;
			local[1] = offsetY;
			target.localToWorld(local);
			bone.worldX += (local[0] - bone.worldX) * translateMix;
			bone.worldY += (local[1] - bone.worldY) * translateMix;
		}
	}

	public var data (get, never) : TransformConstraintData;
	private function get_data () : TransformConstraintData {
		return _data;
	}

	public function toString () : String {
		return _data.name;
	}
}
