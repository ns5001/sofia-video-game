package workinman.display.spine;

import workinman.display.spine.attachments.Attachment;
import workinman.display.spine.Exception;

class Skeleton {
	private var _data:SkeletonData;
	public var bones:Array<Bone>;
	public var slots:Array<Slot>;
	public var drawOrder:Array<Slot>;
	public var ikConstraints:Array<IkConstraint>;
	public var transformConstraints:Array<TransformConstraint>;
	private var _updateCache:Array<Updatable> = new Array<Updatable>();
	private var _skin:Skin;
	public var r:Float = 1;
	public var g:Float = 1;
	public var b:Float = 1;
	public var a:Float = 1;
	public var time:Float = 0;
	public var flipX:Bool = false;
	public var flipY:Bool = false;
	public var x:Float = 0;
	public var y:Float = 0;

	public function new (data:SkeletonData) {
		if (data == null)
			throw new IllegalArgumentException("data cannot be null.");
		_data = data;

		bones = new Array<Bone>();
		for (boneData in data.bones) {
			var parent:Bone = boneData.parent == null ? null : bones[data.bones.indexOf(boneData.parent)];
			bones[bones.length] = new Bone(boneData, this, parent);
		}

		slots = new Array<Slot>();
		drawOrder = new Array<Slot>();
		for (slotData in data.slots) {
			var bone:Bone = bones[data.bones.indexOf(slotData.boneData)];
			var slot:Slot = new Slot(slotData, bone);
			slots[slots.length] = slot;
			drawOrder[drawOrder.length] = slot;
		}

		ikConstraints = new Array<IkConstraint>();
		for (ikConstraintData in data.ikConstraints)
			ikConstraints[ikConstraints.length] = new IkConstraint(ikConstraintData, this);

		transformConstraints = new Array<TransformConstraint>();
		for (transformConstraintData in data.transformConstraints)
			transformConstraints[transformConstraints.length] = new TransformConstraint(transformConstraintData, this);

		updateCache();
	}

	public function dispose() : Void
	{
		_data.dispose();
		_data = null;
		for (b in bones) {
			b.dispose();
		}
		bones = null;
		for(s in slots) {
			s.dispose();
		}
		slots = null;
		drawOrder = null;
		for(ik in ikConstraints) {
			ik.dispose();
		}
		ikConstraints = null;
		for(tk in transformConstraints) {
			tk.dispose();
		}
		transformConstraints = null;
		_updateCache = null;
		if(skin != null) { skin.dispose(); }
		skin = null;
	}

	/** Caches information about bones and constraints. Must be called if bones or constraints are added or removed. */
	public function updateCache () : Void {
		var updateCache:Array<Updatable> = _updateCache;
		var ikConstraints:Array<IkConstraint> = this.ikConstraints;
		var transformConstraints:Array<TransformConstraint> = this.transformConstraints;
		var i:Int = 0;
		var length:Int = bones.length + ikConstraints.length;
		for(i in 0...length) {
			updateCache.push(null);
		}
		for (bone in bones) {
			updateCache[i++] = bone;
			for (ikConstraint in ikConstraints) {
				if (bone == ikConstraint.bones[ikConstraint.bones.length - 1]) {
					updateCache[i++] = ikConstraint;
					break;
				}
			}
		}
		for (transformConstraint in transformConstraints) {
			var ii:Int = updateCache.length - 1;
			while(ii >= 0) {
				var updateable:Updatable = updateCache[ii];
				if (updateable == transformConstraint.bone || updateable == transformConstraint.target) {
					updateCache.insert(ii + 1, transformConstraint);
					break;
				}
				updateable = null;
				ii--;
			}
		}
	}

	/** Updates the world transform for each bone and applies constraints. */
	public function updateWorldTransform () : Void {
		for (updatable in _updateCache)
			updatable.update();
	}

	/** Sets the bones, constraints, and slots to their setup pose values. */
	public function setToSetupPose () : Void {
		setBonesToSetupPose();
		setSlotsToSetupPose();
	}

	/** Sets the bones and constraints to their setup pose values. */
	public function setBonesToSetupPose () : Void {
		for (bone in bones)
			bone.setToSetupPose();

		for (ikConstraint in ikConstraints) {
			ikConstraint.bendDirection = ikConstraint.data.bendDirection;
			ikConstraint.mix = ikConstraint.data.mix;
		}

		for (transformConstraint in transformConstraints) {
			transformConstraint.translateMix = transformConstraint.data.translateMix;
			transformConstraint.rotateMix = transformConstraint.data.rotateMix;
			transformConstraint.scaleMix = transformConstraint.data.scaleMix;
			transformConstraint.shearMix = transformConstraint.data.shearMix;
		}
	}

	public function setSlotsToSetupPose () : Void {
		var i:Int = 0;
		for (slot in slots) {
			drawOrder[i++] = slot;
			slot.setToSetupPose();
		}
	}

	public var data(get, never) : SkeletonData;
	private function get_data () : SkeletonData {
		return _data;
	}

	public var rootBone (get, never) : Bone;
	private function get_rootBone () : Bone {
		if (bones.length == 0) return null;
		return bones[0];
	}

	/** @return May be null. */
	public function findBone (boneName:String) : Bone {
		if (boneName == null)
			throw new IllegalArgumentException("boneName cannot be null.");
		for (bone in bones)
			if (bone.data.name == boneName) return bone;
		return null;
	}

	/** @return -1 if the bone was not found. */
	public function findBoneIndex (boneName:String) : Int {
		if (boneName == null)
			throw new IllegalArgumentException("boneName cannot be null.");
		var i:Int = 0;
		for (bone in bones) {
			if (bone.data.name == boneName) return i;
			i++;
		}
		return -1;
	}

	/** @return May be null. */
	public function findSlot (slotName:String) : Slot {
		if (slotName == null)
			throw new IllegalArgumentException("slotName cannot be null.");
		for (slot in slots)
			if (slot.data.name == slotName) return slot;
		return null;
	}

	/** @return -1 if the bone was not found. */
	public function findSlotIndex (slotName:String) : Int {
		if (slotName == null)
			throw new IllegalArgumentException("slotName cannot be null.");
		var i:Int = 0;
		for (slot in slots) {
			if (slot.data.name == slotName) return i;
			i++;
		}
		return -1;
	}

	public function findSlotWithBone(boneName:String) : Slot {
		if (boneName == null)
			throw new IllegalArgumentException("boneName cannot be null.");
		for (slot in slots)
			if (slot.data.boneData.name == boneName) return slot;
		return null;

	}

	public var skin(get, set) : Skin;
	private function get_skin () : Skin {
		return _skin;
	}

	public function set_skinName (skinName:String) : String {
		var skin:Skin = data.findSkin(skinName);
		if (skin == null) throw new IllegalArgumentException("Skin not found: " + skinName);
		if (_skin != null && skinName == _skin.name) return _skin.name;
		this.skin = skin;
		return _skin == null ? null : _skin.name;
	}

	/** @return May be null. */
	public var skinName(get, set) : String;
	private function get_skinName () : String {
		return _skin == null ? null : _skin.name;
	}

	/** Sets the skin used to look up attachments before looking in the {@link SkeletonData#getDefaultSkin() default skin}.
	 * Attachments from the new skin are attached if the corresponding attachment from the old skin was attached. If there was
	 * no old skin, each slot's setup mode attachment is attached from the new skin.
	 * @param newSkin May be null. */
	public function set_skin (newSkin:Skin) : Skin {
		if (newSkin != null) {
			if (skin != null)
				newSkin.attachAll(this, skin);
			else {
				var i:Int = 0;
				for (slot in slots) {
					var name:String = slot.data.attachmentName;
					if (name != "") {
						var attachment:Attachment = newSkin.getAttachment(i, name);
						if (attachment != null) slot.attachment = attachment;
					}
					i++;
				}
			}
		}
		_skin = newSkin;
		return _skin;
	}

	/** @return May be null. */
	public function getAttachmentForSlotName (slotName:String, attachmentName:String) : Attachment {
		return getAttachmentForSlotIndex(data.findSlotIndex(slotName), attachmentName);
	}

	/** @return May be null. */
	public function getAttachmentForSlotIndex (slotIndex:Int, attachmentName:String) : Attachment {
		if (attachmentName == null) throw new IllegalArgumentException("attachmentName cannot be null.");
		if (skin != null) {
			var attachment:Attachment = skin.getAttachment(slotIndex, attachmentName);
			if (attachment != null) return attachment;
		}
		if (data.defaultSkin != null) return data.defaultSkin.getAttachment(slotIndex, attachmentName);
		return null;
	}

	public function getSlot(slotName : String) {
		for (slot in slots) {
			if (slot.data.name == slotName) {
				return slot;
			}
		}
		throw new IllegalArgumentException("Slot not found: " + slotName);
	}

	/** @param attachmentName May be null. */
	public function setAttachment (slotName:String, attachmentName:String) : Void {
		if (slotName == null) throw new IllegalArgumentException("slotName cannot be null.");
		var i:Int = 0;
		for (slot in slots) {
			if (slot.data.name == slotName) {
				var attachment:Attachment = null;
				if (attachmentName != null) {
					attachment = getAttachmentForSlotIndex(i, attachmentName);
					if (attachment == null)
						throw new IllegalArgumentException("Attachment not found: " + attachmentName + ", for slot: " + slotName);
				}
				slot.attachment = attachment;
				return;
			}
			i++;
		}
		throw new IllegalArgumentException("Slot not found: " + slotName);
	}

	/** @return May be null. */
	public function findIkConstraint (constraintName:String) : IkConstraint {
		if (constraintName == null) throw new IllegalArgumentException("constraintName cannot be null.");
		for (ikConstraint in ikConstraints)
			if (ikConstraint.data.name == constraintName) return ikConstraint;
		return null;
	}

	/** @return May be null. */
	public function findTransformConstraint (constraintName:String) : TransformConstraint {
		if (constraintName == null) throw new IllegalArgumentException("constraintName cannot be null.");
		for (transformConstraint in transformConstraints)
			if (transformConstraint.data.name == constraintName) return transformConstraint;
		return null;
	}

	public function update (delta:Float) : Void {
		time += delta;
	}

	public function toString () : String {
		return _data.name != null ? _data.name : "";
	}
}
