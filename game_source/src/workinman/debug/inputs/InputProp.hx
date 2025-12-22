package workinman.debug.inputs;

import js.html.Element;

typedef InputProp = {
	?keyObj:{ key:String, obj:Dynamic },
	?cloud:String,
	?parent:Element,
	?onChange:Void->Void,
	?style:String,
}
