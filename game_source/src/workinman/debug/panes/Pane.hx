package workinman.debug.panes;

import js.html.*;

class Pane {
	
	// Storage
	private var _root			: Element;	// The root HTML element
	private var _contentDiv		: Element;

	// Properties
	public var root(get, never) : Element;
	private function get_root() : Element { return _root; }

	// Constructor
	public function new(?prop:Dynamic) {
		_root = DebugUtils.newElem("div", { className:"debug-pane" });
		_contentDiv = DebugUtils.newElem("div", { className:"" }, _root);

		_buildPane();
		_addEventHandlers();
	}

	private function _buildPane() : Void {
		// Override
	}

	public function dispose() : Void {
		_removeEventHandlers();
		_contentDiv = null;
		DebugUtils.removeElem(_root);
		_root = null;
	}

	/***************************************
	* Events
	****************************************/
	private function _addEventHandlers() : Void {
		// Override
	}

	private function _removeEventHandlers() : Void {
		// Override
	}

	/***************************************
	* Methods
	****************************************/
	public function update() : Void {
		// Override
	}

	// Returns the section's content div
	private function _addSection(pTitle:String) : Element {
		var tCont = DebugUtils.newElem("div", { className:"pane-section" }, _contentDiv);
		DebugUtils.newElem("strong", { className:"title", innerHTML:pTitle }, tCont);
		return DebugUtils.newElem("div", { className:"pane-section-content" }, tCont);
	}
}
