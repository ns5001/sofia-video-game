package workinman.display.spine;

import workinman.display.spine.attachments.Attachment;
import workinman.display.spine.Exception;

/** Stores attachments by slot index and attachment name. */
class Skin {

	private var _name:String;
	private var _attachments:Array<Map<String, Attachment>> = new Array<Map<String, Attachment>>();

	public function new (name:String) {
		if (name == null) throw new IllegalArgumentException("name cannot be null.");
		_name = name;
	}

	public function dispose() : Void
	{
		_attachments = null;
	}

	public function addAttachment (slotIndex:Int, name:String, attachment:Attachment) : Void {
		if (attachment == null) throw new IllegalArgumentException("attachment cannot be null.");
		if (attachments[slotIndex] == null) attachments[slotIndex] = new Map<String, Attachment>();
		attachments[slotIndex][name] = attachment;
	}

	/** @return May be null. */
	public function getAttachment (slotIndex:Int, name:String) : Attachment {
		if (slotIndex >= attachments.length) return null;
		var dictionary:Map<String, Attachment> = attachments[slotIndex];
		return dictionary != null ? dictionary[name] : null;
	}

	public var attachments (get, never) : Array<Map<String, Attachment>>;
	private function get_attachments () : Array<Map<String, Attachment>> {
		return _attachments;
	}

	public var name (get, never) : String;
	private function get_name () : String {
		return _name;
	}

	public function toString () : String {
		return _name;
	}

	/** Attach each attachment in this skin if the corresponding attachment in the old skin is currently attached. */
	public function attachAll (skeleton:Skeleton, oldSkin:Skin) : Void {
		var slotIndex:Int = 0;
		for (slot in skeleton.slots) {
			var slotAttachment:Attachment = slot.attachment;
			if (slotAttachment != null && slotIndex < oldSkin.attachments.length) {
				var dictionary:Map<String, Attachment> = oldSkin.attachments[slotIndex];
				if (dictionary != null) {
					for (name in dictionary.keys()) {
						var skinAttachment:Attachment = dictionary[name];
						if (slotAttachment == skinAttachment) {
							var attachment:Attachment = getAttachment(slotIndex, name);
							if (attachment != null) slot.attachment = attachment;
							break;
						}
					}
				}
			}
			slotIndex++;
		}
	}
}
