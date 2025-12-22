package workinman.display.spine;

import workinman.display.spine.attachments.Attachment;
import workinman.display.spine.Exception;

class Slot {

	private var _data:SlotData;
	private var _bone:Bone;
	public var r:Float;
	public var g:Float;
	public var b:Float;
	public var a:Float;
	private var _attachment:Attachment;
	private var _attachmentTime:Float;
	public var attachmentVertices:Array<Float> = new Array<Float>();

	public function new (data:SlotData, bone:Bone) {
		if (data == null) throw new IllegalArgumentException("data cannot be null.");
		if (bone == null) throw new IllegalArgumentException("bone cannot be null.");
		_data = data;
		_bone = bone;
		setToSetupPose();
	}

	public function dispose() : Void
	{
		_data.dispose();
		_data = null;
		_bone = null;
		_attachment = null;
		attachmentVertices = null;
	}

	public var data (get, never) : SlotData;
	private function get_data () : SlotData {
		return _data;
	}

	public var bone (get, never) : Bone;
	private function get_bone () : Bone {
		return _bone;
	}

	public var skeleton (get, never) : Skeleton;
	private function get_skeleton () : Skeleton {
		return _bone.skeleton;
	}

	/** @return May be null. */
	public var attachment (get, set) : Attachment;
	private function get_attachment () : Attachment {
		return _attachment;
	}

	/** Sets the attachment and resets {@link #getAttachmentTime()}.
	 * @param attachment May be null. */
	private function set_attachment (attachment:Attachment) : Attachment {
		if (_attachment == attachment) return _attachment;
		_attachment = attachment;
		_attachmentTime = _bone.skeleton.time;
		attachmentVertices = new Array<Float>();
		return _attachment;
	}

	public var attachmentTime (get, set) : Float;
	private function set_attachmentTime (time:Float) : Float {
		_attachmentTime = _bone.skeleton.time - time;
		return _attachmentTime;
	}

	/** Returns the time since the attachment was set. */
	private function get_attachmentTime () : Float {
		return _bone.skeleton.time - _attachmentTime;
	}

	public function setToSetupPose () : Void {
		var slotIndex:Int = _bone.skeleton.data.slots.indexOf(data);
		r = _data.r;
		g = _data.g;
		b = _data.b;
		a = _data.a;
		if (_data.attachmentName == null)
			attachment = null;
		else {
			_attachment = null;
			attachment = _bone.skeleton.getAttachmentForSlotIndex(slotIndex, data.attachmentName);
		}
	}

	public function toString () : String {
		return _data.name;
	}
}
