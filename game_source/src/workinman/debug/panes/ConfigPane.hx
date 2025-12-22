package workinman.debug.panes;

import workinman.debug.inputs.Input;
import workinman.debug.inputs.PercentSliderInput;
import workinman.debug.inputs.SwitchInput;
import workinman.debug.inputs.StringInput;
import workinman.display.GuideSprite;
import workinman.WMSaving;
import js.Browser;
import js.html.*;
import app.ConstantsApp;
// TODO Achievements is now optional in a submodule
// import app.ConstantsAchievement;

class ConfigPane extends Pane {

	// Storage
	private var _mouseXElem		: Element;
	private var _mouseYElem		: Element;
	private var _inputs			: Array<Input>;

	// Constructor
	public function new(?prop:Dynamic) {
		super(prop);
	}

	private override function _buildPane() : Void {
		_inputs = [];
		_buildInputControlsSection();
		_buildMetaSection();
		_buildStorageSection();
		_buildWelcomeSection();
		_buildDebugScreenSection();
	}

	private function _buildInputControlsSection() : Void {
		var tCont = _addSection("Input & Controls");
		var tTable = DebugUtils.newElem("table", { style:"text-align:center;" }, tCont);

		var tRow = DebugUtils.newElem("tr", null, tTable);
		DebugUtils.newElem("th", { innerHTML:"Mouse:", style:"min-width:100px" }, tRow);
		_mouseXElem = DebugUtils.newElem("td", { style:"width:35px;" }, tRow);
		DebugUtils.newElem("td", { innerHTML:"," }, tRow);
		_mouseYElem = DebugUtils.newElem("td", { style:"width:35px;" }, tRow);

		DebugUtils.newElem("label", { innerHTML:"Time Scale: " }, tCont);
		new PercentSliderInput({ keyObj:{ key:"_timeScale", obj:Debug.main }, parent:tCont });

		DebugUtils.newElem("br", null, tCont);

		DebugUtils.newElem("label", { innerHTML:"Show Guides: " }, tCont);
		new SwitchInput({ keyObj: { key:"v", obj:{ v:Debug.main.guidesSprite != null } }, parent:tCont, onChange:_onShowGuidesChanged });
	}

	private function _buildMetaSection() : Void {
		var tCont = _addSection("Meta");
		DebugUtils.newElem("p", { innerHTML:"<b>Game Version</b>: "+ConstantsApp.GAME_VERSION }, tCont);
		// var tButtons = DebugUtils.newElem("p", { style:"text-align:center;" }, tCont);
		// DebugUtils.newElem("button", { innerHTML:"Production Check" }, tButtons).addEventListener("click", _onProductionCheckClicked);
		DebugUtils.newElem("strong", { innerHTML:"Pre-flight Check" }, tCont);
		tCont.appendChild(_buildPreFlightList());

		var tInput:Input;
		DebugUtils.newElem("label", { innerHTML:"Manifests Loaded: " }, tCont);
		_inputs.push(tInput = new StringInput({ keyObj:{ key:"_manifestsLoaded", obj:workinman.WMAssets }, style:"width:45px; text-align: center;", parent:tCont }));
		tInput.input.disabled = true;

		tInput = null;
	}

	private function _buildPreFlightList() : Element {
		var tCont = DebugUtils.newElem("ul");
		tCont.appendChild(_createPreFlightItemCheck("OPTION_DEBUG_FLAG", ConstantsApp.OPTION_DEBUG_FLAG, true));
		tCont.appendChild(_createPreFlightItemCheck("OPTION_SILENCE_AUDIO", ConstantsApp.OPTION_SILENCE_AUDIO, true));
		return tCont;
	}

	private function _createPreFlightItemCheck(pTitle:String, pValue:Dynamic, pBad:Dynamic) : Element {
		return DebugUtils.newElem("li", { innerHTML:"<b>"+pTitle+"</b>: "+(pValue == pBad ? "<span class='red'>"+pValue+"</span>" : pValue) });
	}

	private function _buildStorageSection() : Void {
		var tCont = _addSection("Local Storage");
		tCont.style.textAlign = "center";
		// DebugUtils.newElem("button", { innerHTML:"Delete Achievements", disabled:ConstantsAchievement.ACHIEVEMENTS_ID == "X" }, tCont).addEventListener("click", _onResetAcheievementsClicked);
		DebugUtils.newElem("button", { innerHTML:"Delete All Storage" }, tCont).addEventListener("click", _onResetSaveClicked);
		DebugUtils.newElem("p", { innerHTML:"Warning: 'All Storage' includes save data from other apps on localhost." }, tCont);
	}

	private function _buildWelcomeSection() : Void {
		var tCont = _addSection("Welcome");
		DebugUtils.newElem("p", { innerHTML:"
			This debug tool is only included in the build when the --debug flag is present.
			It is purely JavaScript (via Haxe js library), and as such requires no assets to be loaded in.
		" }, tCont);
		DebugUtils.newElem("p", { innerHTML:"
			This tool has two main components.
			The first is this sidebar, which can be opened and closed via <kbd class='key'>shift</kbd> + <kbd class='key'>~</kbd>.
			The second is WMSprite editing, which can be done via <kbd class='key'>shift</kbd> + click.
			For both of these, keyboard shortcuts only work if the canvas has focus (vs one of the debug elements having focus).
			Just click onto the game to give it focus.
		" }, tCont);
	}

	private function _buildDebugScreenSection() : Void {
		var tCont = _addSection("Debug Screen");
		var tButtons = DebugUtils.newElem("p", { style:"text-align:center;" }, tCont);
		DebugUtils.newElem("button", { innerHTML:"Open Debug Screen" }, tButtons).addEventListener("click", _onOpenDebugScreenClicked);
		DebugUtils.newElem("p", { innerHTML:"
			Unrelated to this tool, the debug screen is a default screen in all games.
			Unlike this tool it can even be opened in a production build.
			While the button above may be used as a shortcut, the correct way to open it is to
			first hold down <kbd class='key'>control</kbd>+<kbd class='key'>F</kbd>+<kbd class='key'>Y</kbd> (this only needs to be done once to unlock it)
			and then hold down <kbd class='key'>shift</kbd>+<kbd class='key'>V</kbd>+<kbd class='key'>Y</kbd> to open it.
		" }, tCont);
	}

	public override function dispose() : Void {
		super.dispose();
		_mouseXElem = null;
		_mouseYElem = null;
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
	private override function _addEventHandlers() : Void {
		Browser.document.addEventListener("mousemove", _onMouseMove);
	}

	private override function _removeEventHandlers() : Void {
		Browser.document.removeEventListener("mousemove", _onMouseMove);
	}


	public override function update() : Void {
		super.update();
		for(tInput in _inputs) {
			tInput.refreshIfUpdated();
		}
	}

	private function _onMouseMove(pEvent:MouseEvent) : Void {
		_mouseXElem.innerHTML = Std.string( Math.floor( Debug.spriteSelector.screenX ) );
		_mouseYElem.innerHTML = Std.string( Math.floor( Debug.spriteSelector.screenY ) );
	}

	private function _onResetSaveClicked(pEvent:MouseEvent) : Void {
		var i = js.Browser.window.localStorage.length;
		while ( i-- > 0 ) {
			js.Browser.window.localStorage.removeItem(js.Browser.window.localStorage.key(i));
		}
	}

	// TODO Achievements is now optional in a submodule
	// private function _onResetAcheievementsClicked(pEvent:MouseEvent) : Void {
	// 	if ( ConstantsAchievement.ACHIEVEMENTS_ID != "X" ) {
	// 		WMSaving.dataDelete( ConstantsAchievement.ACHIEVEMENTS_ID );
	// 	}
	// }

	private function _onShowGuidesChanged() {
		if ( Debug.main.guidesSprite == null ) {
			Debug.main.guidesSprite = Debug.root.addChild(new GuideSprite());
		} else {
			Debug.main.guidesSprite.doDelete = true;
			Debug.main.guidesSprite = null;
		}
	}

	private function _onOpenDebugScreenClicked(pEvent:MouseEvent) {
		Reflect.field( Debug.main, "_ui" ).openScreen( screen.ScreenDebug );
	}
}
