package workinman.debug.inputs;

import js.Browser;
import js.html.Node;
import js.html.Document;
import js.html.Element;
import js.html.InputElement;
import js.html.UIEvent;
import js.html.MouseEvent;

@:keep class Input {

	// Storage
	private var _root				: Element;
	private var _inputElement		: InputElement;
	private var _obj				: Dynamic;
	private var _field				: String;
	private var _cloud				: String;
	private var _onChangeCallback	: Void->Void;
	private var _lastObjectValue	: Dynamic;

	// Properties
	public var root(get, never) : Element;
	private function get_root() : Element { return _root; }

	public var input(get, never) : InputElement;
	private function get_input() : InputElement { return _inputElement; }

	// Constructor
	public function new(prop:InputProp) {
		if(prop.keyObj != null) {
			_obj = prop.keyObj.obj;
			_field = prop.keyObj.key;
		}
		_cloud = prop.cloud;
		_onChangeCallback = prop.onChange;
		_buildInput(prop);

		_addEventHandlers();
		refresh();
	}

	private function _buildInput(prop:Dynamic) : Void {
		// Override
		// _inputElement = cast DebugUtils.newElem("input", { type:"number" }, prop.parent);
	}

	public function dispose() {
		_removeEventHandlers();

		_field = null;
		_obj = null;
		DebugUtils.removeElem(_inputElement);
		_inputElement = null;
	}

	private function _addEventHandlers() {
		_inputElement.addEventListener("input", _onChange);
	}

	private function _removeEventHandlers() {
		_inputElement.removeEventListener("input", _onChange);
	}

	private function _onChange(pEvent:UIEvent) : Void {
		if(_onChangeCallback != null) _onChangeCallback();
	}

	public function parseInput() : Dynamic {
		return _inputElement.value; // Override if needed.
	}

	/**
	 * Refreshes the control's value to reflect the object's value.
	 * May be overwritten
	 **/
	public function refresh() : Void {
		if(_obj != null) {
			_inputElement.value = Std.string(getObjValue());
		}
	}

	public function refreshIfUpdated() : Void {
		if(_lastObjectValue != getObjValue()) {
			refresh();
		}
		_lastObjectValue = getObjValue();
	}

	public function getObjValue() : Dynamic {
		if(_obj != null) {
			return Reflect.getProperty(_obj, _field);
		} else if(_cloud != null) {
			return WMCloud.getValue(_cloud);
		}
		return null;
	}

	public function setObjValue(pVal:Dynamic) : Void {
		if(_obj != null) {
			Reflect.setProperty(_obj, _field, pVal);
		} else if(_cloud != null) {
			WMCloud.setValue(_cloud, pVal);
		}
		refresh();
		_lastObjectValue = pVal; // Needed encase the value is changed again after this on same update.
	}
}
