package workinman.debug.inputs;

import js.Browser;
import js.html.Document;
import js.html.Element;
import js.html.InputElement;
import js.html.UIEvent;

@:keep class SwitchInput extends Input {

	private var _label	: Element;

	public function new(prop:InputProp) {
		super(prop);
	}

	private override function _buildInput(prop:Dynamic) : Void {
		_root = DebugUtils.newElem("div", {className:"onoffswitch"}, prop.parent);
		_label = DebugUtils.newElem("label", {className:"onoffswitch-label"}, _root);

		_inputElement = cast DebugUtils.newElem("input", {type:"checkbox", className:"onoffswitch-checkbox"}, _label);
		DebugUtils.newElem("span", {className:"onoffswitch-inner"}, _label);
		DebugUtils.newElem("span", {className:"onoffswitch-switch"}, _label);
	}

	private override function _addEventHandlers() {
		_label.addEventListener("click", _onChange);
	}

	private override function _removeEventHandlers() {
		_label.removeEventListener("click", _onChange);
	}

	private override function _onChange(pEvent:UIEvent) : Void {
		if(Std.is(pEvent.target, InputElement)) {
			setObjValue( cast(pEvent.target, InputElement).checked );
			super._onChange(pEvent);
		}
	}

	public override function parseInput() : Dynamic {
		return _inputElement.checked;
	}

	public override function refresh() : Void {
		_inputElement.checked = getObjValue();
	}
}
