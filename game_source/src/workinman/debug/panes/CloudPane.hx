package workinman.debug.panes;

import js.Browser;
import js.html.*;
import workinman.debug.inputs.Input;
import workinman.debug.inputs.StringInput;
import workinman.debug.inputs.SwitchInput;
import workinman.debug.inputs.NumericInput;

class CloudPane extends Pane {

	// Storage
	private var _inputs			: Array<Input>;

	// Constructor
	public function new(?prop:Dynamic) {
		super(prop);
	}

	private override function _buildPane() : Void {
		_inputs = [];
		_buildCloudSection();
	}

	private function _buildCloudSection() : Void {
		var tCont = _addSection("CLOUD Values");
		var tCloudTable = DebugUtils.newElem("table", { id:"cloud-table" }, tCont);
		WMTimer.start(function(){
			var tRow, tCell, tInput;
			for(tCloud in WMCloud.listAllKeys()) {
				tRow = DebugUtils.newElem("tr", null, tCloudTable);
				DebugUtils.newElem("th", { innerHTML:"<div>"+tCloud+"</div>", title:tCloud }, tRow);
				tCell = DebugUtils.newElem("td", null, tRow);
				tInput = _createCloudInput(tCloud, tCell);
				if(tInput == null) {
					tCell.innerHTML = Std.string(WMCloud.getValue(tCloud));
				}
			}
		}, 0.5);
	}

	private function _createCloudInput(pCloud:String, pParent:Element) : Input {
		var tInput:Input = null;
		if(pCloud.indexOf("BOOL_") == 0 || Std.is(WMCloud.getValue(pCloud), Bool)) {
			tInput = new SwitchInput({ cloud:pCloud, parent:pParent });
		}
		else if(pCloud.indexOf("FLOAT_") == 0 || (Std.is(WMCloud.getValue(pCloud), Float) && pCloud.indexOf("INT_") != 0)) {
			tInput = new NumericInput({ cloud:pCloud, parent:pParent, step:0.1 });
		}
		else if(pCloud.indexOf("INT_") == 0 || Std.is(WMCloud.getValue(pCloud), Int)) {
			tInput = new NumericInput({ cloud:pCloud, parent:pParent });
		}
		else if(pCloud.indexOf("STRING_") == 0 || Std.is(WMCloud.getValue(pCloud), String)) {
			tInput = new StringInput({ cloud:pCloud, parent:pParent });
		}

		if(tInput != null) { _inputs.push(tInput); }
		return tInput;
	}

	public override function dispose() : Void {
		super.dispose();
		var i = _inputs.length;
		while (--i >= 0) {
			_inputs[i].dispose();
			_inputs[i] = null;
			_inputs.splice(i, 1);
		}
		_inputs = null;
	}

	/***************************************
	 * Events
	 ***************************************/
	public override function update() : Void {
		super.update();
		for(tInput in _inputs) {
			tInput.refreshIfUpdated();
		}
	}
}
