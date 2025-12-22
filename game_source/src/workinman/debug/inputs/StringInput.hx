package workinman.debug.inputs;

import js.Browser;
import js.html.Document;
import js.html.Element;
import js.html.UIEvent;

@:keep class StringInput extends Input {
	
	public function new(prop:InputProp) {
		super(prop);
	}

	private override function _buildInput(prop:Dynamic) : Void {
		_inputElement = cast DebugUtils.newElem("input", { type:"text", style:prop.style }, prop.parent);
		_root = _inputElement;
	}

	private override function _onChange(pEvent:UIEvent) : Void {
		setObjValue(_inputElement.value);
		super._onChange(pEvent);
	}

	public override function refresh() : Void {
		_inputElement.value = getObjValue();
	}
}
