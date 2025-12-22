package screen;

import workinman.display.spine.SpineElement;
import workinman.display.ImageSprite;
import workinman.display.Sprite;
import workinman.display.Text;
import workinman.ui.ScreenBase;
import workinman.ui.Button;
import workinman.tween.*;
import workinman.WMSound;
import app.ConstantsEvent;
import app.ALLERGEN_TYPE;
import app.Services;
import app.INPUT_TYPE;
import screen.button.*;
import app.ConstantsApp;

class ScreenAttract extends ScreenBase {
	private var _tray:ImageSprite;
	private var _bg:ImageSprite;
	private var _clickTray:Button;

	private var _sofia:SpineElement;
	private var _background:SpineElement;


	public function new(pRoot:Sprite):Void {
		trace("ATTRACT building");
		super(pRoot);
	}

	private override function _buildScreen():Void {
		super._buildScreen();

		WMSound.stopMusic();

		_closing = false;
		_beginPreload();

		app.PlayerData.loadCookies();

		// WMSound.playMusic(manifest.Sound.sofia_bg_music_intro);

		_tray = _elementManager.addElement(new ImageSprite({}));
		_tray.addElement(new ImageSprite({asset: manifest.Texture.splash_bg, scale: .5}));

		_background = _tray.addElement(new SpineElement({library: manifest.spine.splash.Info.name, scale: .5, alpha: 0}));
		_background.animate(manifest.spine.splash.Anim.animation);

		_sofia = _background.addElement(new SpineElement({
			library: manifest.spine.sofia.Info.name,
			x: 500,
			y: 400,
			scale: .7,
			scaleX: -.7
		}));
		_sofia.animate("splash");

		_clickTray = _tray.addElement(new Button({
			asset: manifest.Texture.splash_bg,
			x: 0,
			y: 0,
			tween: _tween,
			clear: _clearButtonInput,
			scale: 1,
			alpha: 0
		}));
		_clickTray.eventClick.add(_onEventClickPlay);

		

		_onEventResizeCanvas();
	}

	public override function dispose():Void {
		_loadWidget = null;

		_tray = null;
		_clickTray = null;
		_bg = null;
		_sofia = null;
		_background = null;

		super.dispose();
	}

	/**********************************************************
		@description [Added by Justin Dambra 6/24/13]
		* Loads in fonts before anything else
	**********************************************************/
	private function _beginPreload():Void {
		trace("[Main](_beginPreload) Beginning preload (contains fonts).");
		var tPacks:Array<String> = ["preload", "fonts_" + workinman.WMLocalize.region];
		workinman.WMAssets.load(_onPreloadFinished, tPacks, 0);
	}

	/**********************************************************
		@description [Added by Justin Dambra 6/24/13]
		* Lets game know font folder was loaded in, begins initial loading
	**********************************************************/
	private function _onPreloadFinished():Void {
		trace("[Main](_onPreloadFinished) Preload complete!");
		Services.onPreloadFinished();
		workinman.WMLocalize.parseLocalization();
		_addPreload();
		// Check performance to determine what to load
		_beginInitialLoad();
	}

	/**********************************************************
		@description
	**********************************************************/
	private function _beginInitialLoad():Void {
		trace("[Main](_beginInitialLoad) Beginning initial load.");
		// TODO LOAD PACKS!
		var tPacks:Array<String> = ["initial_universal", "initial_audio_required"];
		workinman.WMAssets.load(_eventLoadCompleteInitial, tPacks, 1.2);
	}

	/**********************************************************
		@description
	**********************************************************/
	private function _eventLoadCompleteInitial():Void {
		trace("[ScreenSplash](_eventLoadCompleteInitial) Initial load complete");
		// Create the tap/click text and it's contain if it has one
		_addClickTray();
		// _bg.alpha = 1;
		_tray.alpha = 1;
		_background.alpha = 1;
		app.ConstantsEvent.removeLoader.dispatch();

		_tray.addElement(new ButtonSoundToggle({assetUp:manifest.Texture.button_sound_on, assetUpOff:manifest.Texture.button_sound_off, tween:_tween, clear: _clearButtonInput, x: ConstantsApp.STAGE_CENTER_X - 50, y: -ConstantsApp.STAGE_CENTER_Y + 50, scale:0.5}));
		// app.ConstantsEvent.flow.dispatch( app.FLOW.CUTSCENE_OPENING );

		
		Services.onInitialFinished();
		Services.onTitleStart();
		ConstantsEvent.initialLoadComplete.dispatch();
	}

	private function _addPreload():Void {
		// var tTitle : Text = _tray.addElement(new Text( { text:manifest.localization.splash.Ids.title1, x:0, y:-100 } ));
		// tTitle.addElement(new Text( { text:manifest.localization.splash.Ids.title2, x:0, y:60 } ));
		// TweenUtils.easeBounceIn( tTitle, _tween );
		app.ConstantsEvent.addLoader.dispatch();
	}

	private function _addClickTray():Void {
		if (_clickTray != null) {
			return;
		}

		// Tween the click tray and the buttons in.
		TweenUtils.easeBounceIn(_clickTray, _tween);

		
	}

	public override function update(dt:Float):Void {
		super.update(dt);
	}

	private override function _setCloseState():Void {
		TweenUtils.easeBounceOut(_tray, _tween).onComplete(_finishCloseState);
	}

	private function _onEventClickPlay() {
		if (_closing == false) {
			_closing = true;

			// WMSound.stopMusic(.1);
			WMSound.playMusic(manifest.Sound.sofia_bg_music, app.ConstantsApp.DEFAULT_GAME_MUSIC_VOLUME);

			app.ConstantsEvent.addLoader.dispatch();

			app.ConstantsEvent.flow.dispatch(app.FLOW.AVATAR_BUILDER);
			// app.ConstantsEvent.flow.dispatch(app.FLOW.CUTSCENE_OPENING);

			// app.ConstantsEvent.flow.dispatch( app.FLOW.CUTSCENE_DOCTOR_END );

			// app.PlayerData.addAllergen(0, ALLERGEN_TYPE.BIRD);
			// app.PlayerData.addAllergen(1, ALLERGEN_TYPE.CIGARETTE);
			// app.PlayerData.addAllergen(2, ALLERGEN_TYPE.COLD);
			// app.PlayerData.addAllergen(3, ALLERGEN_TYPE.SPORTS);
			// app.PlayerData.addAllergen(4, ALLERGEN_TYPE.UFO);
			// app.ConstantsEvent.flow.dispatch( app.FLOW.EXPERIMENT );
		}
	}

	private override function _onEventResizeCanvas():Void {
		super._onEventResizeCanvas();
		_tray.scaleX = 1 * (app.ConstantsApp.STAGE_WIDTH / app.ConstantsApp.STAGE_WIDTH_MAX);
	}
}
