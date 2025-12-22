package workinman.display.spine.attachments;

import workinman.display.spine.Exception;

class Attachment {

	public var name(default,null):String;

	public function new (pName:String) {
		if ( pName == null ) {
			throw new IllegalArgumentException("name cannot be null.");
		}
		name = pName;
	}

	public function dispose() {

	}

	public function toString () : String {
		return name;
	}
}
