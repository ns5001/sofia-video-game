package workinman.debug.inputs;

import js.Browser;
import js.html.Document;
import js.html.Element;

import js.html.UIEvent;

typedef NumericInputProp = {
	> InputProp,
	?min:Float,
	?max:Float,
	?step:Float,
}

@:keep class NumericInput extends Input
{
	public function new(prop:NumericInputProp) {
		super(prop);
	}

	private override function _buildInput(prop:Dynamic) : Void {
		_inputElement = cast DebugUtils.newElem("input", {
			type:"number",
			min:Std.string(prop.min != null ? prop.min : -100000),
			max:Std.string(prop.max != null ? prop.max : 100000),
			step:Std.string(prop.step != null ? prop.step : "any"),
			style:prop.style
		}, prop.parent);
		_root = _inputElement;
	}

	private override function _onChange(pEvent:UIEvent) : Void {
		var tFloat:Float = cast parseInput();
		if(Math.isNaN(tFloat) == false) {
			setObjValue(parseInput());
			super._onChange(pEvent);
		}
	}

	public override function parseInput() : Dynamic {
		return _inputElement.value == "" ? Math.NaN : Std.parseFloat(_inputElement.value);
	}

	public override function refresh() : Void {
		if(parseInput() == getObjValue()) { return; }
		_inputElement.value = Std.string(DebugUtils.cleanNum(getObjValue(), 3));
	}
}
