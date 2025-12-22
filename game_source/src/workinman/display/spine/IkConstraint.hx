package workinman.display.spine;

import workinman.display.spine.Exception;

class IkConstraint implements Updatable {

	private var _data:IkConstraintData;
	public var bones:Array<Bone>;
	public var target:Bone;
	public var bendDirection:Int;
	public var mix:Float;

	public function new (data:IkConstraintData, skeleton:Skeleton) {
		if (data == null) throw new IllegalArgumentException("data cannot be null.");
		if (skeleton == null) throw new IllegalArgumentException("skeleton cannot be null.");
		_data = data;
		mix = data.mix;
		bendDirection = data.bendDirection;

		bones = new Array<Bone>();
		for (boneData in data.bones)
			bones[bones.length] = skeleton.findBone(boneData.name);
		target = skeleton.findBone(data.target.name);
	}

	public function dispose() : Void
	{
		_data.dispose();
		_data = null;
		bones = null;
		target = null;
	}

	public function apply () : Void {
		update();
	}

	public function update () : Void {
		switch (bones.length) {
			case 1:
				apply1(bones[0], target.worldX, target.worldY, mix);
			case 2:
				apply2(bones[0], bones[1], target.worldX, target.worldY, bendDirection, mix);
		}
	}

	public var data (get, never) : IkConstraintData;
	private function get_data () : IkConstraintData {
		return _data;
	}

	public function toString () : String {
		return _data.name;
	}

	/** Adjusts the bone rotation so the tip is as close to the target position as possible. The target is specified in the world
	 * coordinate system. */
	static public function apply1 (bone:Bone, targetX:Float, targetY:Float, alpha:Float) : Void {
		var pp:Bone = bone.parent;
		var id:Float = 1 / (pp.a * pp.d - pp.b * pp.c);
		var x:Float = targetX - pp.worldX, y:Float = targetY - pp.worldY;
		var tx:Float = (x * pp.d - y * pp.b) * id - bone.x, ty:Float = (y * pp.a - x * pp.c) * id - bone.y;
		var rotationIK:Float = Math.atan2(ty, tx) * MathUtils.radDeg - bone.shearX - bone.rotation;
		if (bone.scaleX < 0) rotationIK += 180;
		if (rotationIK > 180)
			rotationIK -= 360;
		else if (rotationIK < -180) rotationIK += 360;
		bone.updateWorldTransformWith(bone.x, bone.y, bone.rotation + rotationIK * alpha, bone.scaleX, bone.scaleY, bone.shearX,bone.shearY);
	}

	/** Adjusts the parent and child bone rotations so the tip of the child is as close to the target position as possible. The
	 * target is specified in the world coordinate system.
	 * @param child Any descendant bone of the parent. */
	static public function apply2 (parent:Bone, child:Bone, targetX:Float, targetY:Float, bendDir:Int, alpha:Float) : Void {
		if (alpha == 0) {
			child.updateWorldTransform();
			return;
		}
		var px:Float = parent.x, py:Float = parent.y, psx:Float = parent.scaleX, psy:Float = parent.scaleY, csx:Float = child.scaleX;
		var os1:Int, os2:Int, s2:Int;
		if (psx < 0) {
			psx = -psx;
			os1 = 180;
			s2 = -1;
		} else {
			os1 = 0;
			s2 = 1;
		}
		if (psy < 0) {
			psy = -psy;
			s2 = -s2;
		}
		if (csx < 0) {
			csx = -csx;
			os2 = 180;
		} else
			os2 = 0;
		var cx:Float = child.x, cy:Float, cwx:Float, cwy:Float, a:Float = parent.a, b:Float = parent.b, c:Float = parent.c, d:Float = parent.d;
		var u:Bool = Math.abs(psx - psy) <= 0.0001;
		if (!u) {
			cy = 0;
			cwx = a * cx + parent.worldX;
			cwy = c * cx + parent.worldY;
		} else {
			cy = child.y;
			cwx = a * cx + b * cy + parent.worldX;
			cwy = c * cx + d * cy + parent.worldY;
		}
		var pp:Bone = parent.parent;
		a = pp.a;
		b = pp.b;
		c = pp.c;
		d = pp.d;
		var id:Float = 1 / (a * d - b * c), x:Float = targetX - pp.worldX, y:Float = targetY - pp.worldY;
		var tx:Float = (x * d - y * b) * id - px, ty:Float = (y * a - x * c) * id - py;
		x = cwx - pp.worldX;
		y = cwy - pp.worldY;
		var dx:Float = (x * d - y * b) * id - px, dy:Float = (y * a - x * c) * id - py;
		var l1:Float = Math.sqrt(dx * dx + dy * dy), l2:Float = child.data.length * csx, a1:Float = 0, a2:Float = 0;
			var done:Bool = false;
		if (u) {
			l2 *= psx;
			var cos:Float = (tx * tx + ty * ty - l1 * l1 - l2 * l2) / (2 * l1 * l2);
			if (cos < -1)
				cos = -1;
			else if (cos > 1) cos = 1;
			a2 = Math.acos(cos) * bendDir;
			a = l1 + l2 * cos;
			b = l2 * Math.sin(a2);
			a1 = Math.atan2(ty * a - tx * b, tx * a + ty * b);
		} else {
			a = psx * l2;
			b = psy * l2;
			var aa:Float = a * a, bb:Float = b * b, dd:Float = tx * tx + ty * ty, ta:Float = Math.atan2(ty, tx);
			c = bb * l1 * l1 + aa * dd - aa * bb;
			var c1:Float = -2 * bb * l1, c2:Float = bb - aa;
			d = c1 * c1 - 4 * c2 * c;
			if (d >= 0) {
				var q:Float = Math.sqrt(d);
				if (c1 < 0) q = -q;
				q = -(c1 + q) / 2;
				var r0:Float = q / c2, r1:Float = c / q;
				var r:Float = Math.abs(r0) < Math.abs(r1) ? r0 : r1;
				if (r * r <= dd) {
					y = Math.sqrt(dd - r * r) * bendDir;
					a1 = ta - Math.atan2(y, r);
					a2 = Math.atan2(y / psy, (r - l1) / psx);
					done = true;
				}
			}
			if(!done) {
				var minAngle:Float = 0, minDist:Float = Math.POSITIVE_INFINITY, minX:Float = 0, minY:Float = 0;
				var maxAngle:Float = 0, maxDist:Float = 0, maxX:Float = 0, maxY:Float = 0;
				x = l1 + a;
				d = x * x;
				if (d > maxDist) {
					maxAngle = 0;
					maxDist = d;
					maxX = x;
				}
				x = l1 - a;
				d = x * x;
				if (d < minDist) {
					minAngle = Math.PI;
					minDist = d;
					minX = x;
				}
				var angle:Float = Math.acos(-a * l1 / (aa - bb));
				x = a * Math.cos(angle) + l1;
				y = b * Math.sin(angle);
				d = x * x + y * y;
				if (d < minDist) {
					minAngle = angle;
					minDist = d;
					minX = x;
					minY = y;
				}
				if (d > maxDist) {
					maxAngle = angle;
					maxDist = d;
					maxX = x;
					maxY = y;
				}
				if (dd <= (minDist + maxDist) / 2) {
					a1 = ta - Math.atan2(minY * bendDir, minX);
					a2 = minAngle * bendDir;
				} else {
					a1 = ta - Math.atan2(maxY * bendDir, maxX);
					a2 = maxAngle * bendDir;
				}
			}
		}
		var os:Float = Math.atan2(cy, cx) * s2;
		var rotation:Float = parent.rotation;
		a1 = (a1 - os) * MathUtils.radDeg + os1 - rotation;
		if (a1 > 180)
			a1 -= 360;
		else if (a1 < -180) a1 += 360;
		parent.updateWorldTransformWith(px, py, rotation + a1 * alpha, parent.scaleX, parent.scaleY, 0, 0);
		rotation = child.rotation;
		a2 = ((a2 + os) * MathUtils.radDeg - child.shearX) * s2 + os2 - rotation;
		if (a2 > 180)
			a2 -= 360;
		else if (a2 < -180) a2 += 360;
		child.updateWorldTransformWith(cx, cy, rotation + a2 * alpha, child.scaleX, child.scaleY, child.shearX, child.shearY);
	}
}
