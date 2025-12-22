package workinman.debug.windows;

import js.Browser;
import js.html.Node;
import js.html.Document;
import js.html.InputElement;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.UIEvent;
import js.html.MouseEvent;

private typedef HTMLElement = js.html.Element;
private typedef DebugPoint = { x:Float, y:Float };

@:keep class Window {

	private var _root			: HTMLElement;	// The root HTML element
	private var _titleBar		: HTMLElement;
	private var _titleText		: HTMLElement;
	private var _xButton		: HTMLElement;
	private var _minMaxButton	: HTMLElement;
	private var _refreshButton	: HTMLElement;
	private var _contentDiv		: HTMLElement;

	public var doDelete(default, null)		: Bool;

	public var left(get, never) : Float;
	private function get_left() : Float { return Std.parseFloat(_root.style.left); }

	public var top(get, never) : Float;
	private function get_top() : Float { return Std.parseFloat(_root.style.top); }

	public var zIndex(get, set) : Int;
	private function get_zIndex() : Int { return Std.parseInt(_root.style.zIndex); }
	private function set_zIndex(pVal:Int) : Int { _root.style.zIndex = Std.string(pVal); return pVal; }

	/**
	 * pData can expect the following values:
	 * * title	: String - [default : "Container"] - The title of this container
	 * * col	: Int - [default : 1] - number of controls can fit into this
	 **/
	public function new(prop:WindowProp) {
		// Add elements
		_root = DebugUtils.newElem("div", {className:"debugWindow wm-debug"}, Browser.document.body);
		_titleBar = DebugUtils.newElem("div", {className:"titleBar"}, _root);
		var tTitle = (prop.title != null && prop.title != "" ? prop.title : "Container");
		_titleText = DebugUtils.newElem("div", {className:"title", innerHTML:tTitle}, _titleBar);

		var tButtonCont = DebugUtils.newElem("span", {className:"buttonContainer"}, _titleBar);
		_refreshButton = DebugUtils.newElem("span", {className:"button refresh", innerHTML:"↻", title:"Refresh window value(s) to reflect current object value(s)"}, tButtonCont);
		_minMaxButton = DebugUtils.newElem("span", {className:"button minmax", innerHTML:"－", title:"Minimize window"}, tButtonCont);//➖
		_xButton = DebugUtils.newElem("span", {className:"button exit", innerHTML:"✖", title:"Close window"}, tButtonCont);

		_contentDiv = DebugUtils.newElem("div", {className:"controlContainer"}, _root);
		var tCol = (prop.columns != null ? prop.columns : 1);
		_contentDiv.style.width = (tCol * Debug.CONTROL_WIDTH + (tCol*2) * Debug.CONTROL_MARGIN)+"px";

		doDelete = false;
		_buildWindow();

		_addEventHandlers();
	}

	private function _buildWindow() : Void {
		// Override
	}

	public function dispose() {
		_removeEventHandlers();
		_titleBar = null;
		_titleText = null;
		_xButton = null;
		_minMaxButton = null;
		_refreshButton = null;
		_contentDiv = null;
		DebugUtils.removeElem(_root);
		_root = null;
	}

	public function setPos(pX:Float, pY:Float) : Void {
		_root.style.left = pX+"px";
		_root.style.top  = pY+"px";
	}

	public function update() : Void {
		// Override
	}

	public function refresh() : Window {
		// Override
		return this;
	}

	/***************************************
	* Events
	****************************************/
	private function _addEventHandlers() {
		_root.addEventListener("mousedown", _onContainerClick);
		_titleBar.addEventListener("mousedown", _onTitleBarMouseDown);
		_refreshButton.addEventListener("click", _onRefreshButtonClick);
		_minMaxButton.addEventListener("click", _onMinMaxClick);
		_xButton.addEventListener("click", _onExitClick);
	}

	private function _removeEventHandlers() {
		_root.removeEventListener("mousedown", _onContainerClick);
		_titleBar.removeEventListener("mousedown", _onTitleBarMouseDown);
		_refreshButton.removeEventListener("click", _onRefreshButtonClick);
		_minMaxButton.removeEventListener("click", _onMinMaxClick);
		_xButton.removeEventListener("click", _onExitClick);
	}

	private function _onContainerClick(pEvent:MouseEvent) : Void {
		Debug.windowManager.bringWindowToFront(this);
	}

	private function _onTitleBarMouseDown(pEvent:MouseEvent) : Void {
		if((pEvent.target == _titleBar || pEvent.target == _titleText)) {
			Debug.windowManager.startDrag(this, pEvent);
		}
	}

	public function handleDrag(pEvent:MouseEvent, pOffsetX:Float, pOffsetY:Float) : Void {
		var tX = pEvent.clientX - pOffsetX;
		var tY = pEvent.clientY - pOffsetY;

		tX = Math.min(Browser.window.innerWidth-50, Math.max(-_titleBar.offsetWidth+cast(_xButton.parentNode, HTMLElement).offsetWidth + 25, tX));
		tY = Math.min(Browser.window.innerHeight-_titleBar.offsetHeight-4, Math.max(0, tY));

		setPos(tX, tY);
	}

	public function handleMouseUp(pEvent:MouseEvent) : Void {

	}

	private function _onRefreshButtonClick(pEvent:MouseEvent) : Void {
		refresh();
	}

	private function _onMinMaxClick(pEvent:MouseEvent) : Void {
		if(_contentDiv.hidden) {
			_contentDiv.hidden = false;
			_minMaxButton.innerHTML = "－";//"➖";
		} else {
			_contentDiv.hidden = true;
			_minMaxButton.innerHTML = "＋";//"➕";
		}
	}

	private function _onExitClick(pEvent:MouseEvent) : Void {
		doDelete = true;
	}
}
