package workinman.debug.windows;

import workinman.debug.inputs.*;
import js.Browser;
import js.html.Node;
import js.html.Document;
import js.html.Element;
import js.html.InputElement;
import js.html.UIEvent;
import js.html.MouseEvent;

@:keep class ControlWindow extends Window {

	private var _object			: Dynamic;	// (optional) The object the whole container is based off of.
	private var _inputs			: Array<Input>;

	public var object(get, never) : Dynamic;
	private function get_object() : Dynamic { return _object; }

	/**
	 * pData can expect the following values:
	 * * title	: String - [default : "Container"] - The title of this container
	 * * col	: Int - [default : 1] - number of controls can fit into this
	 **/
	public function new(pData:ControlWindowProp) {
		_object = pData.object;
		_inputs = [];
		super(pData);
	}

	public override function dispose() {
		super.dispose();
		var i = _inputs.length;
		while (--i >= 0) {
			_inputs[i].dispose();
			_inputs[i] = null;
			_inputs.splice(i, 1);
		}
		_inputs = null;
		_object = null;
	}

	public function addDetail(pElem:Element, pTitle:String, pFull:Bool=true) : Element {
		if(pElem != null) {
			var tControlElem:Element = DebugUtils.newElem("div", { className:"control"+(pFull ? " full" : "") }, _contentDiv);
			DebugUtils.newElem("div", {className:"title", innerHTML:(pTitle == null ? "Detail" : pTitle)}, tControlElem);
			var tDetailContainer:Element = DebugUtils.newElem("div", { className:"inputContainer" }, tControlElem);
			tDetailContainer.appendChild(pElem);
			return tControlElem;
		}
		return null;
	}

	public function addInputDetail(pInput:Input, pTitle:String) : Element {
		_inputs.push(pInput);
		return addDetail(pInput.root, pTitle, false);
	}

	public override function refresh() : Window {
		for(tInput in _inputs) {
			tInput.refresh();
		}
		return this;
	}
}
