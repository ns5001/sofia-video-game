package workinman;

import workinman.debug.DebugUtils;
import workinman.debug.DebugStylesheet;
import workinman.debug.windows.WindowManager;
import workinman.debug.windows.SpriteWindow;
import workinman.debug.windows.Window;
import workinman.debug.windows.ObjWindow;
import workinman.debug.windows.ControlWindow;
import workinman.debug.panes.PaneManager;
import workinman.debug.panes.CloudPane;
import workinman.debug.panes.ConfigPane;
import workinman.debug.DebugSpriteSelector;
import workinman.display.RootSprite;
import workinman.display.Sprite;
import js.Browser;
import js.html.CanvasElement;
import js.html.UIEvent;
import js.html.MouseEvent;
import haxe.Timer;
import world.World;
import app.ConstantsApp;

/**
* Debug - used to monitor and change values on the fly.
* # Usage #
* Shift + Click - open up a window for editing various values.
*
* When looking through debug code, please keep in mind that "Element" refers to html elments; WMSprite refers to WM element objects.
**/
class Debug {

	// Variables
	public static var canvas(default, null)		: CanvasElement;
	public static var windowManager(default, null)	: WindowManager;
	public static var paneManager(default, null)	: PaneManager;
	public static var spriteSelector(default, null): DebugSpriteSelector;
	private static var _requestId		: Int;

	// Properties
	public static var main(get, never) : Main;
	private static function get_main() : Main { return Reflect.field(Main, "_main"); }
	public static var world(get, never) : World;
	private static function get_world() : World { return Reflect.field(main, "_world"); }
	public static var root(get, never) : RootSprite;
	private static function get_root() : RootSprite { return Reflect.field(main, "_root"); }

	// Constants
	public static var CONTROL_WIDTH = 200;
	public static var CONTROL_MARGIN = 2;

	// Constructor
	public static function init() : Void {
		if ( !ConstantsApp.OPTION_DEBUG_FLAG ) {
			return;
		}
		canvas = cast DebugUtils.getElem("#content-canvas");
		if(canvas == null) canvas = cast DebugUtils.getElem("canvas");
		DebugStylesheet.createStyle();
		windowManager = new WindowManager();
		spriteSelector = new DebugSpriteSelector();
		paneManager = new PaneManager();

		// Wait for the rest of app to finish initializing
		WMTimer.start(function(){
			paneManager.addPane("Config", new ConfigPane());
			paneManager.addPane("CLOUD", new CloudPane());
		}, 0);

		_addEventHandlers();
	}

	/***************************************
	* Event Stuff
	****************************************/
	private static function _addEventHandlers() {
		_requestId = Browser.window.requestAnimationFrame(_update);
	}

	private static function _update(timestamp:Float) : Bool {
		windowManager.update();
		paneManager.update();
		_requestId = Browser.window.requestAnimationFrame(_update);
		return true;
	}

	/***************************************
	* Public Methods
	****************************************/
	public static function debugSprite(pElem:Sprite, ?pTitle:String) : SpriteWindow {
		var tAlreadyOpenedWindow = _objectCurrentWindow(pElem);
		if(tAlreadyOpenedWindow != null) {
			trace("[Debug](debugSprite) A window for this Sprite already exists.");
			windowManager.bringWindowToFront(tAlreadyOpenedWindow);
			return cast(tAlreadyOpenedWindow, SpriteWindow);
		}

		trace("[Debug](debugSprite) New sprite container added.");
		var tTitle:String = pTitle == null ? DebugUtils.getClassName(pElem) : pTitle;

		return windowManager.addWindow(new SpriteWindow({ object:pElem, title:tTitle, columns:2 }));
	}

	public static function debugObj(pObj:Dynamic, ?pTitle:String) : Window {
		trace("[Debug](debugObj) New object window added.");
		var tTitle:String = pTitle == null ? DebugUtils.getClassName(pObj) : pTitle;

		return windowManager.addWindow(new ObjWindow({ object:pObj, title:tTitle, columns:3 }));
	}

	/***************************************
	* Private Methods
	****************************************/
	private static function _objectCurrentWindow(pObj:Dynamic) : Window {
		for(tWindow in windowManager.windows) {
			if(Std.is(tWindow, ControlWindow) && cast(tWindow, ControlWindow).object != null && cast(tWindow, ControlWindow).object == pObj) {
				return tWindow;
			}
		}
		return null;
	}

	/***********************
	* Static Methods
	************************/
	public static function debug(pElem:Dynamic, ?pTitle:String) : Window {
		if(Std.is(pElem, Sprite)) {
			return Debug.debugSprite(pElem, pTitle);
		} else {
			return Debug.debugObj(pElem, pTitle);
		}
	}
}
