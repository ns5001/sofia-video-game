package workinman.debug.panes;

import flambe.input.Key;
import flambe.System;
import js.Browser;
import js.html.*;

class PaneManager {

	private var _root		: Element;
	private var _tabCont	: Element;
	private var _panes		: Array<Pane>;
	private var _tabs		: Array<Element>;
	private var _curPane	: Int;
	public var visible(default, null) : Bool;

	public function new() {
		_root = DebugUtils.newElem("div", { id:"debug-panes-sidebar-cont", className:"wm-debug", style:"display:none;" }, Browser.document.body);
		_tabCont = DebugUtils.newElem("div", { id:"debug-pane-tab-cont" }, _root);
		DebugUtils.newElem("span", { className:"close-button" }, _root).addEventListener("click", function(pEvent:MouseEvent) { hide(); });
		visible = false;
		_panes = [];
		_tabs = [];
		_curPane = 0;
		_addEventHandlers();
		trace("PANE STARTED");
	}

	public function dispose() : Void {
		_removeEventHandlers();
		_tabCont = null;
		DebugUtils.removeElem(_root);
		_root = null;
	}

	/***************************************
	* Events
	****************************************/
	private function _addEventHandlers() : Void {
		WMInput.eventKey.add( _onInput );
	}

	private function _removeEventHandlers() : Void {
		WMInput.eventKey.remove( _onInput );
	}

	public function update() : Void {
		var i = _panes.length;
		while(i > 0) { i--;
			_panes[i].update();
		}
	}

	private function _onInput( pType:Key, pDown:Bool ) : Void {
		switch ( pType ) {
			case Key.Shift, Key.Backquote:
				if ( pDown && System.keyboard.isDown( Key.Shift ) && System.keyboard.isDown( Key.Backquote ) ) {
					visible ? hide() : show();
				}
			default:
		}
	}

	/***************************************
	* Methods
	****************************************/
	public function show() : Void {
		if(visible) { return; }
		visible = true;
		_root.style.display = "block";
	}

	public function hide() : Void {
		if(!visible) { return; }
		visible = false;
		_root.style.display = "none";
		Debug.canvas.focus();
	}

	public function showPane(pPane:Pane) : Void {
		for(tPane in _panes) {
			tPane.root.style.display = "none";
		}
		pPane.root.style.display = "block";
	}

	private function _selectTab(pTab:Element) {
		for(tTab in _tabs) {
			tTab.classList.remove("active");
		}
		pTab.classList.add("active");
	}

	public function addPane<T:Pane>(pTitle:String, pPane:T) : T {
		trace("DEBUG[PaneManager](addPane) New pane added: "+pTitle);
		_panes.push(pPane);
		_root.appendChild(pPane.root);

		var tTab = DebugUtils.newElem("div", { className:"tab", innerHTML:pTitle }, _tabCont);
		_tabs.push(tTab);
		tTab.addEventListener("click", function(pEvent:MouseEvent){ showPane(pPane); _selectTab(tTab); });

		if(_panes.length > 1) {
			pPane.root.style.display = "none";
		} else {
			tTab.classList.add("active");
		}

		return pPane;
	}
}
