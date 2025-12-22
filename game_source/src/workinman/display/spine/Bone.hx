package workinman.display.spine;

import workinman.display.spine.Exception;

class Bone implements Updatable {

	static public var yDown:Bool;

	private var _data:BoneData;
	private var _skeleton:Skeleton;
	private var _parent:Bone;
	public var x:Float = 0;
	public var y:Float = 0;
	public var rotation:Float = 0;
	public var scaleX:Float = 0;
	public var scaleY:Float = 0;
	public var appliedRotation:Float = 0;
	public var appliedScaleX:Float = 0;
	public var appliedScaleY:Float = 0;
	public var shearX:Float = 0;
	public var shearY:Float = 0;

	private var _a:Float = 0;
	private var _b:Float = 0;
	private var _c:Float = 0;
	private var _d:Float = 0;
	private var _worldX:Float = 0;
	private var _worldY:Float = 0;
	private var _worldSignX:Float = 0;
	private var _worldSignY:Float = 0;
	private var _worldRotationX:Float = 0;

	public function dispose() : Void
	{
		_parent = null;
		_data.dispose();
		_data = null;
		_skeleton = null;
	}

	/** @param parent May be null. */
	public function new (data:BoneData, skeleton:Skeleton, parent:Bone) {
		if (data == null) throw new IllegalArgumentException("data cannot be null.");
		if (skeleton == null) throw new IllegalArgumentException("skeleton cannot be null.");
		_data = data;
		_skeleton = skeleton;
		_parent = parent;
		setToSetupPose();
	}

	/** Computes the world SRT using the parent bone and this bone's local SRT. */
	public function updateWorldTransform () : Void {
		updateWorldTransformWith(x, y, rotation, scaleX, scaleY, shearX, shearY);
	}

	/** Same as updateWorldTransform(). This method exists for Bone to implement Updatable. */
	public function update () : Void {
		updateWorldTransformWith(x, y, rotation, scaleX, scaleY, shearX, shearY);
	}

	/** Computes the world SRT using the parent bone and the specified local SRT. */
	public function updateWorldTransformWith (x:Float, y:Float, rotation:Float, scaleX:Float, scaleY:Float, shearX:Float, shearY:Float) : Void {
		appliedRotation = rotation;
		appliedScaleX = scaleX;
		appliedScaleY = scaleY;

		var cos:Float = 0;
		var sin:Float = 0;
		var radians:Float = 0;

		var rotationY:Float = rotation + 90 + shearY;
		var radians1:Float = (rotation + shearX) * MathUtils.degRad;
		var radians2:Float = rotationY * MathUtils.degRad;
		var la:Float = Math.cos(radians1) * scaleX;
		var lb:Float = Math.cos(radians2) * scaleY;
		var lc:Float = Math.sin(radians1) * scaleX;
		var ld:Float = Math.sin(radians2) * scaleY;

		var parent:Bone = _parent;
		if (parent == null) { // Root bone.
			var skeleton:Skeleton = _skeleton;
			if (skeleton.flipX) {
				x = -x;
				la = -la;
				lb = -lb;
			}
			if (skeleton.flipY != yDown) {
				y = -y;
				lc = -lc;
				ld = -ld;
			}
			_a = la;
			_b = lb;
			_c = lc;
			_d = ld;
			_worldX = x;
			_worldY = y;
			_worldSignX = scaleX < 0 ? -1 : 1;
			_worldSignY = scaleY < 0 ? -1 : 1;
			_worldRotationX = Math.atan2(_c, _a) * MathUtils.radDeg;
			return;
		}

		var pa:Float = parent.a;
		var pb:Float = parent.b;
		var pc:Float = parent.c;
		var pd:Float = parent.d;
		_worldX = pa * x + pb * y + parent.worldX;
		_worldY = pc * x + pd * y + parent.worldY;
		_worldSignX = parent.worldSignX * (scaleX < 0 ? -1 : 1);
		_worldSignY = parent.worldSignY * (scaleY < 0 ? -1 : 1);

		if (data.inheritRotation && data.inheritScale) {
			_a = pa * la + pb * lc;
			_b = pa * lb + pb * ld;
			_c = pc * la + pd * lc;
			_d = pc * lb + pd * ld;
		} else {
			if (data.inheritRotation) { // No scale inheritance.
				pa = 1;
				pb = 0;
				pc = 0;
				pd = 1;
				do {
					radians = parent.appliedRotation * MathUtils.degRad;
					cos = Math.cos(radians);
					sin = Math.sin(radians);
					var temp1:Float = pa * cos + pb * sin;
					pb = pb * cos - pa * sin;
					pa = temp1;
					temp1 = pc * cos + pd * sin;
					pd = pd * cos - pc * sin;
					pc = temp1;

					if (!parent.data.inheritRotation) break;
					parent = parent.parent;
				} while (parent != null);
				_a = pa * la + pb * lc;
				_b = pa * lb + pb * ld;
				_c = pc * la + pd * lc;
				_d = pc * lb + pd * ld;
			} else if (data.inheritScale) { // No rotation inheritance.
				pa = 1;
				pb = 0;
				pc = 0;
				pd = 1;
				do {
					radians = parent.appliedRotation * MathUtils.degRad;
					cos = Math.cos(radians);
					sin = Math.sin(radians);
					var psx:Float = parent.appliedScaleX, psy:Float = parent.appliedScaleY;
					var za:Float = cos * psx, zb:Float = sin * psy, zc:Float = sin * psx, zd:Float = cos * psy;
					var temp2:Float = pa * za + pb * zc;
					pb = pb * zd - pa * zb;
					pa = temp2;
					temp2 = pc * za + pd * zc;
					pd = pd * zd - pc * zb;
					pc = temp2;

					if (psx < 0) sin = -sin;
					temp2 = pa * cos + pb * sin;
					pb = pb * cos - pa * sin;
					pa = temp2;
					temp2 = pc * cos + pd * sin;
					pd = pd * cos - pc * sin;
					pc = temp2;

					if (!parent.data.inheritScale) break;
					parent = parent.parent;
				} while (parent != null);
				_a = pa * la + pb * lc;
				_b = pa * lb + pb * ld;
				_c = pc * la + pd * lc;
				_d = pc * lb + pd * ld;
			} else {
				_a = la;
				_b = lb;
				_c = lc;
				_d = ld;
			}

			if (_skeleton.flipX) {
				_a = -_a;
				_b = -_b;
			}
			if (_skeleton.flipY != yDown) {
				_c = -_c;
				_d = -_d;
			}
		}

		_worldRotationX = Math.atan2(_c, _a) * MathUtils.radDeg;
	}

	public function setToSetupPose () : Void {
		x = _data.x;
		y = _data.y;
		rotation = _data.rotation;
		scaleX = _data.scaleX;
		scaleY = _data.scaleY;
		shearX = _data.shearX;
		shearY = _data.shearY;
	}

	public var data (get, never) : BoneData;
	private function get_data () : BoneData {
		return _data;
	}

	public var parent (get, never) : Bone;
	private function get_parent () : Bone {
		return _parent;
	}

	public var skeleton (get, never) : Skeleton;
	private function get_skeleton () : Skeleton {
		return _skeleton;
	}

	public var a (get, set) : Float;
	private function get_a () : Float {
		return _a;
	}
	public function set_a (pValue:Float) : Float {
		_a = pValue;
		return _a;
	}

	public var b (get, set) : Float;
	private function get_b () : Float {
		return _b;
	}
	public function set_b (pValue:Float) : Float {
		_b = pValue;
		return _b;
	}

	public var c (get, set) : Float;
	public function get_c () : Float {
		return _c;
	}
	public function set_c (pValue:Float) : Float {
		_c = pValue;
		return _c;
	}

	public var d (get, set) : Float;
	public function get_d () : Float {
		return _d;
	}
	public function set_d (pValue:Float) : Float {
		_d = pValue;
		return _d;
	}

	public var worldX (get, set) : Float;
	public function get_worldX () : Float {
		return _worldX;
	}
	public function set_worldX (pValue:Float) : Float {
		_worldX = pValue;
		return _worldX;
	}

	public var worldY (get, set) : Float;
	public function get_worldY () : Float {
		return _worldY;
	}
	public function set_worldY (pValue:Float) : Float {
		_worldY = pValue;
		return _worldY;
	}

	public var worldSignX (get, never) : Float;
	public function get_worldSignX () : Float {
		return _worldSignX;
	}

	public var worldSignY (get, never) : Float;
	public function get_worldSignY () : Float {
		return _worldSignY;
	}

	public var worldRotationX (get, set) : Float;
	public function get_worldRotationX () : Float {
		return _worldRotationX;
	}
	public function set_worldRotationX (pVal:Float) : Float {
		_worldRotationX = pVal;
		return _worldRotationX;
	}

	public var worldRotationY (get, never) : Float;
	public function get_worldRotationY () : Float {
		return Math.atan2(_d, _b) * MathUtils.radDeg;
	}

	public var worldScaleX (get, never) : Float;
	public function get_worldScaleX () : Float {
		return Math.sqrt(_a * _a + _b * _b) * _worldSignX;
	}

	public var worldScaleY (get, never) : Float;
	public function get_worldScaleY () : Float {
		return Math.sqrt(_c * _c + _d * _d) * _worldSignY;
	}

	public function worldToLocal (world:Array<Float>) : Void {
		var x:Float = world[0] - _worldX, y:Float = world[1] - _worldY;
		var a:Float = _a, b:Float = _b, c:Float = _c, d:Float = _d;
		var invDet:Float = 1 / (a * d - b * c);
		world[0] = (x * a * invDet - y * b * invDet);
		world[1] = (y * d * invDet - x * c * invDet);
	}

	public function localToWorld (local:Array<Float>) : Void {
		var localX:Float = local[0], localY:Float = local[1];
		local[0] = localX * _a + localY * _b + _worldX;
		local[1] = localX * _c + localY * _d + _worldY;
	}

	public function toString () : String {
		return _data.name;
	}
}
