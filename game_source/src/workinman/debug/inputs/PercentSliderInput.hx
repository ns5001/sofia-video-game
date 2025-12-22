package workinman.debug.inputs;

import js.Browser;
import js.html.Document;
import js.html.Element;
import js.html.UIEvent;

@:keep class PercentSliderInput extends Input {

	private var _numDisplay	: Element;

	public function new(prop:InputProp) {
		super(prop);
	}

	private override function _buildInput(prop:Dynamic) : Void {
		var tCont = DebugUtils.newElem("span", {}, prop.parent);
		_inputElement = cast DebugUtils.newElem("input", {type:"range", min:"0", max:"100"}, tCont);
		_numDisplay = DebugUtils.newElem("output", {className:"detail"}, tCont);
		_root = tCont;
	}

	public override function dispose() : Void {
		super.dispose();
		_numDisplay = null;
	}

	private override function _onChange(pEvent:UIEvent) : Void {
		var tFloat:Float = parseInput()/100;
		setObjValue(tFloat);
		_numDisplay.innerHTML = Math.floor(tFloat * 100)+"%";//Std.string(DebugUtils.cleanNum(tFloat, 2));
		super._onChange(pEvent);
	}

	public override function parseInput() : Dynamic {
		return Std.parseFloat(_inputElement.value);
	}

	public override function refresh() : Void {
		_inputElement.value = Std.string(Std.parseFloat(getObjValue()) * 100);
		_numDisplay.innerHTML = Math.floor(getObjValue() * 100)+"%";//Std.string(DebugUtils.cleanNum(getObjValue(), 2));
	}
}
