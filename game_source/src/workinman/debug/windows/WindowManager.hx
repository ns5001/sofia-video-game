package workinman.debug.windows;

import js.Browser;
import js.html.MouseEvent;

class WindowManager {

	// Storage
	private var _windows		: Array<Window>;
	private var _selectedWindow	: Window;
	private var _topWindow		: Window; // Used for z-indexing
	private var _dragOffset		: { x:Float, y:Float };

	// Properties
	public var windows(get, never) : Array<Window>;
	private function get_windows() : Array<Window> { return _windows; }

	public var selectedWindow(get, set) : Window;
	private function get_selectedWindow() : Window { return _selectedWindow; }
	private function set_selectedWindow(pVal:Window) : Window { return _selectedWindow = pVal; }

	public var topWindow(get, set) : Window;
	private function get_topWindow() : Window { return _topWindow; }
	private function set_topWindow(pVal:Window) : Window { return _topWindow = pVal; }

	// Constructor
	public function new() {
		_windows = [];
		_dragOffset = { x:0, y:0 };
		_addEventHandlers();
	}

	public function dispose() : Void {
		_removeEventHandlers();
		for(i in 0..._windows.length) { _windows[i].dispose(); _windows[i]=null; }
		_windows = null;
		_dragOffset = null;
		_selectedWindow = null;
		_topWindow = null;
	}

	/***************************************
	* Event Stuff
	****************************************/
	private function _addEventHandlers() {
		Browser.document.addEventListener("mouseup", _onMouseUp);
		Browser.document.addEventListener("mousemove", _onMouseMove);
	}

	private function _removeEventHandlers() : Void {
		Browser.document.removeEventListener("mouseup", _onMouseUp);
		Browser.document.removeEventListener("mousemove", _onMouseMove);
	}

	private function _onMouseUp(pEvent:MouseEvent) : Void {
		if(_selectedWindow != null) {
			_selectedWindow.handleMouseUp(pEvent); _selectedWindow = null;
		}
	}

	private function _onMouseMove(pEvent:MouseEvent) : Void {
		if(_selectedWindow != null) {
			_selectedWindow.handleDrag(pEvent, _dragOffset.x, _dragOffset.y);
		}
	}

	public function update() : Void {
		var i = _windows.length;
		while(i > 0) { i--;
			if(_windows[i].doDelete) {
				if(_topWindow == _windows[i]) {
					_topWindow = i-1 >= 0 ? _windows[i-1] : null;
				}
				_windows[i].dispose();
				_windows[i] = null;
				_windows.splice(i,1);
				Debug.canvas.focus();
			} else {
				_windows[i].update();
			}
		}
	}

	/***************************************
	* Public Methods
	****************************************/
	public function addWindow<T:Window>(pWindow:T) : T {
		// trace("[WindowManager](add) New window added.");
		_windows.push(pWindow);

		if(_topWindow != null) {
			pWindow.setPos(_topWindow.left+50, _topWindow.top+50);
			pWindow.zIndex = _topWindow.zIndex+1;
		} else {
			pWindow.setPos(100, 100);
			pWindow.zIndex = 1;
		}
		_topWindow = pWindow;

		return pWindow;
	}

	public function bringWindowToFront<T:Window>(pWindow:T) : T {
		if(_topWindow == pWindow) { return pWindow; }
		_topWindow = pWindow;
		_windows.splice(_windows.indexOf(pWindow),1);
		_windows.push(pWindow);
		for(i in 0..._windows.length) {
			_windows[i].zIndex = i;
		}
		return pWindow;
	}

	public function isDraggingElement() : Bool {
		return _selectedWindow != null;
	}
	public function startDrag(pWindow:Window, pEvent:MouseEvent) : Window {
		if(isDraggingElement() == false) {
			_selectedWindow = pWindow;
			_dragOffset.x = pEvent.pageX - pWindow.left;
			_dragOffset.y = pEvent.pageY - pWindow.top;
		}
		return pWindow;
	}
}
