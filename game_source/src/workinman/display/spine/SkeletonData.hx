package workinman.display.spine;

import workinman.display.spine.animation.Animation;

import workinman.display.spine.Exception;

class SkeletonData {

	/** May be null. */
	public var name:String;
	public var bones:Array<BoneData> = new Array<BoneData>(); // Ordered parents first.
	public var slots:Array<SlotData> = new Array<SlotData>(); // Setup pose draw order.
	public var skins:Array<Skin> = new Array<Skin>();
	public var defaultSkin:Skin;
	public var events:Array<EventData> = new Array<EventData>();
	public var animations:Array<Animation> = new Array<Animation>();
	public var ikConstraints:Array<IkConstraintData> = new Array<IkConstraintData>();
	public var transformConstraints:Array<TransformConstraintData> = new Array<TransformConstraintData>();
	public var width:Float;
	public var height:Float;
	public var version:String;
	public var hash:String;

	public function new() {
		
	}

	public function dispose() : Void {
		bones = null;
		slots = null;
		skins = null;
		defaultSkin = null;
		events = null;
		animations = null;
		ikConstraints = null;
	}

	// --- Bones.

	/** @return May be null. */
	public function findBone (boneName:String) : BoneData {
		if (boneName == null) throw new IllegalArgumentException("boneName cannot be null.");
		for(i in 0...bones.length) {
			var bone:BoneData = bones[i];
			if (bone.name == boneName) return bone;
		}
		return null;
	}

	/** @return -1 if the bone was not found. */
	public function findBoneIndex (boneName:String) : Int {
		if (boneName == null) throw new IllegalArgumentException("boneName cannot be null.");
		for(i in 0...bones.length)
			if (bones[i].name == boneName) return i;
		return -1;
	}

	// --- Slots.

	/** @return May be null. */
	public function findSlot (slotName:String) : SlotData {
		if (slotName == null) throw new IllegalArgumentException("slotName cannot be null.");
		for(i in 0...slots.length) {
			var slot:SlotData = slots[i];
			if (slot.name == slotName) return slot;
		}
		return null;
	}

	/** @return -1 if the bone was not found. */
	public function findSlotIndex (slotName:String) : Int {
		if (slotName == null) throw new IllegalArgumentException("slotName cannot be null.");
		for(i in 0...slots.length)
			if (slots[i].name == slotName) return i;
		return -1;
	}

	// --- Skins.

	/** @return May be null. */
	public function findSkin (skinName:String) : Skin {
		if (skinName == null) throw new IllegalArgumentException("skinName cannot be null.");
		for (skin in skins)
			if (skin.name == skinName) return skin;
		return null;
	}

	// --- Events.

	/** @return May be null. */
	public function findEvent (eventName:String) : EventData {
		if (eventName == null) throw new IllegalArgumentException("eventName cannot be null.");
		for (eventData in events)
			if (eventData.name == eventName) return eventData;
		return null;
	}

	// --- Animations.

	/** @return May be null. */
	public function findAnimation (animationName:String) : Animation {
		if (animationName == null) throw new IllegalArgumentException("animationName cannot be null.");
		for (animation in animations)
			if (animation.name == animationName) return animation;
		return null;
	}

	// --- IK constraints.

	/** @return May be null. */
	public function findIkConstraint (constraintName:String) : IkConstraintData {
		if (constraintName == null) throw new IllegalArgumentException("constraintName cannot be null.");
		for (ikConstraintData in ikConstraints)
			if (ikConstraintData.name == constraintName) return ikConstraintData;
		return null;
	}

	// --- Transform constraints.

	/** @return May be null. */
	public function findTransformConstraint (constraintName:String) : TransformConstraintData {
		if (constraintName == null) throw new IllegalArgumentException("constraintName cannot be null.");
		for (transformConstraintData in transformConstraints)
			if (transformConstraintData.name == constraintName) return transformConstraintData;
		return null;
	}

	// ---

	public function toString () : String {
		return name != null ? name : "";
	}
}
