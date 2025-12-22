import workinman.display.GuideSprite;
import workinman.display.RootSprite;
import workinman.display.Sprite;
import workinman.input.INPUT_CONTROLLER;
import workinman.utils.JSEmbed;
import workinman.event.Event1;
import workinman.ui.ScreenBase;
import workinman.ui.ScreenManager;
import workinman.ui.SubtitleManager;
import workinman.ui.ChangeActionData;
import workinman.ui.CHANGE_TYPE;
import workinman.WMTimer;
import workinman.WMUtils;
import workinman.WMCloud;
import workinman.WMSound;
import workinman.WMInput;
import world.World;
import flambe.platform.html.HtmlUtil;
import flambe.input.Key;
import flambe.System;
import app.ConstantsEvent;
import app.INPUT_VIRTUAL;
import app.ConstantsApp;
import app.INPUT_TYPE;
import app.Services;
import app.SaveData;
import app.CLOUD;
import app.FLOW;
import js.Browser;
import screen.*;

class Main {

	private static var _main : Main;

	private static function main() {
		// Init
		System.init();

		// Determine the base url
		if( JSEmbed != null && JSEmbed.exists() ) {
			// Set crossdomain base URL.
			if( JSEmbed.isBaseCrossdomain() ) {
				workinman.WMAssets.setCrossdomainBaseUrl( WMUtils.appendAssetsToUrl( JSEmbed.baseUrl() ) );
			} else {
				workinman.WMAssets.baseUrl = WMUtils.trimUrl( JSEmbed.baseUrl() );
			}
		} else {
			workinman.WMAssets.baseUrl = "";
		}

		// Call Secondary Services Init
		Services.initMain();
		// Never put a delay on bootstrap, we don't start the updater until after bootstrap has loaded!
		workinman.WMAssets.load( _onBootstrapLoad, ["bootstrap", "attract_assets", "attract_audio"] );
	}

	private static function _onBootstrapLoad() : Void {
		Services.onBootstrapFinished();
		_main = new Main();
	}

	// Storage
	private var _root 						: RootSprite;
	private var _ui							: ScreenManager;
	private var _world						: World;
	private var _layerWorld					: Sprite;
	private var _layerUI					: Sprite;
	private var _layerSub					: Sprite;
	public var guidesSprite					: Sprite;
	private var _sub						: SubtitleManager;
	private var _timeScale					: Float;

	// Flags
	private var _flagWonPreviousGame		: Bool;
	private var _flagWebAudioUnlocked		: Bool;
	private var _flagGameplayPaused			: Bool;
	private var _flagJSEmbedExists			: Bool;
	private var _flagJSEmbedPauseState 		: Bool;

	// Flow
	private var _flowstack					: Array<String>;
	private var _changeActions 				: Array<ChangeActionData>;
	public static var eventUpdate			: Event1<Float> = new Event1<Float>();

	private static inline var _MIN_FPS		: Float = 1/15;
	
	public function new() {
		trace("[Main] Constructed");
		_root = new RootSprite(_onEventUpdate);
		System.root.add(_root);
		System.uncaughtError.connect(errorHandler);

		workinman.WMInput.prime(_root);
		workinman.WMInput.setDelegateUnlockWebAudio( _handleWebAudioUnlock );
		ConstantsEvent.flow.add( _addFlowEvent );

		// Bubbles on click
		_layerWorld = _root.addChild( new Sprite(null) );
		_layerUI = _root.addChild( new Sprite(null) );
		_layerSub = _root.addChild( new Sprite(null) );
		if ( ConstantsApp.OPTION_SHOW_SAFE_GUIDES ) {
			guidesSprite = _root.addChild( new GuideSprite() );
		}
		_timeScale = 1;

		_flagWebAudioUnlocked = false;
		_flagGameplayPaused = true;
		_flagJSEmbedPauseState = false;
		_flagJSEmbedExists = false;

		#if debug
		workinman.Debug.init();
		#end

		Services.setPlaybackToggle( function( enabled:Bool ) : Void {
			if (!enabled) {
				_pauseGameplay();
			} else {
				_unpauseGameplay();
			}
		} );

		// Load Save Data
		SaveData.instance.load();

		_calculateScaleFactor();
		_flagJSEmbedExists = JSEmbed != null && JSEmbed.exists();
		_ui = new ScreenManager( _layerUI, _onInterfaceChange );
		_changeActions = [];
		_flowstack = [];
		_addEventListeners();
		_setDefaults();
		Services.initServices();
		_parseConfigXML();
		_registerInput();
		_openSplash();
	}

	private function _calculateScaleFactor() : Void {
		if ( Std.is(System.stage,flambe.platform.html.HtmlStage) == false ) {
			return;
		}
		var devicePixelRatio = Browser.window.devicePixelRatio;
        if (devicePixelRatio == null) {
            devicePixelRatio = 1;
        }
		// Take into account any behind-the-scenes scaling of canvas elements
        var canvas = Browser.document.createCanvasElement();
        var ctx = canvas.getContext2d();
        var backingStorePixelRatio = HtmlUtil.loadExtension("backingStorePixelRatio", ctx).value;
        if ( backingStorePixelRatio == null ) {
            backingStorePixelRatio = 1;
        }
		// Check for blacklisted devices instead of calculating based on a magic number -
		// This is to prevent false positives on newer high dpi displays
		var tUserAgent = Browser.navigator.userAgent.toLowerCase();
		var scale = devicePixelRatio / backingStorePixelRatio;
		// Only ignore iPad for now?
		if ( tUserAgent.indexOf("ipad") != -1 ) {
			scale = 1;
		}

		var tStage : flambe.platform.html.HtmlStage = cast System.stage;
		if ( scale != tStage.scaleFactor ) {
			Reflect.setField( tStage, "scaleFactor", scale );
			HtmlUtil.setVendorStyle( Reflect.field( tStage, "_canvas" ), "transform-origin", "top left");
        	HtmlUtil.setVendorStyle( Reflect.field( tStage, "_canvas" ), "transform", "scale(" + (1/tStage.scaleFactor) + ")");
			tStage.requestResize(tStage.width, tStage.height);
		}
		canvas = null;
		ctx = null;
		tStage = null;
	}

	/**********************************************************
	@description
	**********************************************************/
	private function errorHandler( e:String ) : Void {
		trace( "Error: " + e );
	}

	/**********************************************************
	@description
	**********************************************************/
	private function _parseConfigXML():Void  {
		trace("[Main](_parseConfigXML) Parse Config XML files" );

		// Initial values
		var tUnlockCode : String = "000000";
		var tAllowUnlock : Bool = false;
		var tHasAchievements : Bool = false;
		var tRegion : String = "en";

		// Scrape through all config files
		for ( tFast in workinman.WMAssets.allConfig() ) {
			// Unlock code
			if ( tFast.hasNode.unlockCode ) {
				tUnlockCode = tFast.node.unlockCode.innerData;
			}

			// Allow unlock
			if ( tFast.hasNode.unlockEnabled ) {
				tAllowUnlock = tFast.node.unlockEnabled.innerData == "true";
			}

			// Achievments
			if ( tFast.hasNode.achievements && tFast.node.achievements.att.enabled.toString() == "true" ) {
				tHasAchievements = true;
			}

			// Region
			if ( tFast.hasNode.localization ) {
				tRegion = Std.string(tFast.node.localization.node.region.innerData);
			}
		}

		workinman.WMLocalize.region = tRegion;
		trace("[Main] Localization : Set Region: \"" + tRegion + "\"" );
	}

	/**********************************************************
	@description
	**********************************************************/
	private function _eventLoadCompleteGameplay() : Void {
		trace("[Main](_eventLoadCompleteGameplay) Gameplay load complete!");
		_playGameMusic();
		// if ( _world != null && Std.is(_world, WorldHabitat) ) {
		// 	trace("[Main](_eventLoadCompleteGameplay) World already exists. Using existing world instead of creating a new one.");
		// } else {
		// 	_generateWorld( FLOW.HABITAT_GAMEPLAY );
		// 	// Now wait for _onWorldGenerationComplete to progress.
		// }
    }

	/**********************************************************
	@description
	**********************************************************/
	private function _eventInitialLoadComplete() : Void {
		_enableSplash();
		_sub = new SubtitleManager( _layerSub );
	}

	private function _openSplash() : Void {
		//Remove loading overlay from page, if your Index uses one.
		var div = Browser.document.getElementById( "loadingOverlay" );
		if ( div != null ) {
			trace( "[Main](_openSplash) Removed loading overlay." );
			div.parentNode.removeChild( div );
		}
		_ui.changeScreenTo( ScreenAttract, false );
	}

	/**********************************************************
	@description
	**********************************************************/
	private function _setDefaults() : Void {
		WMCloud.setBool( CLOUD.BOOL_PAUSED, false );

		WMSound.muteAll = ConstantsApp.OPTION_SILENCE_AUDIO;
	}

	/**********************************************************
	@description
	**********************************************************/
	private function _registerInput():Void {
		WMInput.registerInput( INPUT_TYPE.MOVE_LEFT, 	[Key.Left,Key.A] );
		WMInput.registerInput( INPUT_TYPE.MOVE_RIGHT, 	[Key.Right,Key.D] );
		WMInput.registerInput( INPUT_TYPE.MOVE_UP, 		[Key.Up,Key.W] );
		WMInput.registerInput( INPUT_TYPE.MOVE_DOWN, 	[Key.Down,Key.S] );
		WMInput.registerInput( INPUT_TYPE.ATTACK, 		[Key.Z], [INPUT_VIRTUAL.ATTACK] );
		WMInput.registerInput( INPUT_TYPE.JUMP, 		[Key.Space], [INPUT_VIRTUAL.JUMP] );
		WMInput.registerInput( INPUT_TYPE.UI_OK,		[Key.Space, Key.Enter], null, [INPUT_CONTROLLER.START,INPUT_CONTROLLER.A] );
		WMInput.registerInput( INPUT_TYPE.UI_DENY, 		[Key.Escape], null, [INPUT_CONTROLLER.B] );
		WMInput.registerInput( INPUT_TYPE.UI_MENU, 		[Key.Escape], null, [INPUT_CONTROLLER.START] );
		WMInput.registerInput( INPUT_TYPE.DEBUG_SAVE_PAINTING, [Key.Space]);
		WMInput.registerInput( INPUT_TYPE.DEBUG_SHOW_PAINTING, [Key.Enter]);
		WMInput.registerInput( INPUT_TYPE.UI_TAB, [Key.Tab]);
	}

    private function _gotoAndPlayGame() : Void {
		// Load gameplay assets
		var tGameplayPacks : Array<String> = [];
		tGameplayPacks.push( "gameplay_universal" );
        tGameplayPacks.push( "gameplay_audio_required" );
        trace(tGameplayPacks);

        workinman.WMAssets.load( function() {
           // _ui.changeScreenTo( ScreenHabitatHud, true );
            _disposeWorld();
            _eventLoadCompleteGameplay();
        }, tGameplayPacks, 1.2 );

        Services.onGameStart();
    }
    
    private function _loadPacksAndGotoScreen(pScreen:Class<ScreenBase>, ?pPacks : Array<String> = null) : Void {
        // Begin Loading
				app.ConstantsEvent.addLoader.dispatch();

        workinman.WMAssets.load( function() {
            _ui.changeScreenTo( pScreen, true );
            _disposeWorld();
        }, pPacks, 1.2 );
    }

	/**********************************************************
	@description
	**********************************************************/
	private function _onWorldGenerationComplete() : Void {
		WMTimer.start( _onWorldGenerationCompleteDelay, .3 );
		// if( Std.is(_world, WorldCustomization) )
		// {
		// 	_ui.changeScreenTo( ScreenColoringHud, true );
		// } else 
        //    _ui.changeScreenTo( ScreenHabitatHud, true );
    }

	/**********************************************************
	@description
	**********************************************************/
	private function _onWorldGenerationCompleteDelay() : Void {
		_world.start();
		_unpauseGameplay();
	}

	/**********************************************************
	@description
	**********************************************************/
	private function _enableSplash() : Void {
		trace("[Main](_enableSplash) Splash enabled!");
		_playMenuMusic();
		_enableInput();
	}

	/**********************************************************
	@description
	**********************************************************/
	private function _onGameNew() : Void {
		// Fill as needed
		_resetFlagsResults();
	}

	/**********************************************************
	@description
	**********************************************************/
	private function _resetFlagsResults() : Void {
		// Fill as needed.
	}

	private function _resetGameResults() : Void {
        // Fill as needed.
	}

	/**********************************************************
	@description
	**********************************************************/
	private function _generateWorld( pWorldFlow:FLOW ) : Void {
		if ( _world != null ) {
			_disposeWorld();
		}
        trace("[Main] (_generateWorld: " + pWorldFlow + ")");
        
        // switch(pWorldFlow) {
        //     default: 
        //         _world = new WorldCustomization( _layerWorld );
        // }
	}

	/**********************************************************
	@description
	**********************************************************/
	private function _onEventUpdate( dt:Float ):Void 	{
		dt = (Math.round(dt * 1000) / 1000) * _timeScale;

		if ( dt > _MIN_FPS ) {
			dt = _MIN_FPS;
		}

		if ( _flagJSEmbedExists && JSEmbed.isPaused() != _flagJSEmbedPauseState ) {
			_flagJSEmbedPauseState = JSEmbed.isPaused();
			if ( _flagJSEmbedPauseState ) {
				_pauseGameplay(false);
			} else {
				if ( !_flagGameplayPaused ) {
					_unpauseGameplay();
				}
			}
		}

		eventUpdate.dispatch(dt);
		Services.update( dt );
		_updateCloud( dt );

		if ( _ui != null ) {
			_ui.update(dt);
		}

		if ( _sub != null ) {
			_sub.update(dt);
		}

		if( _world != null ) {
			_world.update(dt);
		}

		// clear out the flow stack, if anything has changed.
		_runFlowStack();
	}

	private function _updateCloud( dt:Float ) {
		workinman.WMTimer.update( dt );
		workinman.WMSound.update( dt );
		workinman.WMInput.update( dt );
		workinman.WMAssets.update( dt );
	}

	/**********************************************************
	@description
	**********************************************************/
	private function _addFlowEvent(pId:FLOW) : Void {
		_flowstack.push(pId);
	}

	/**********************************************************
	@description
	**********************************************************/
	private function _runFlowStack() : Void {
		while ( _flowstack.length > 0 ) {
			_executeFlowStack(_flowstack[0]);
			_flowstack.shift();
		}
	}

	/**********************************************************
	@description
	**********************************************************/
	private function _executeFlowStack( pId:FLOW ) : Void {
		switch ( pId ) {
            // Utility //
      		case FLOW.DEBUG_CLOSE:
				_ui.closeScreen( ScreenDebug, true);

			// Gameplay //
			case FLOW.ATTRACT_PLAY:
				_handleWebAudioUnlock ();
				Services.onSplashPlay();

				_loadPacksAndGotoScreen( ScreenAttract, ["attract_audio", "attract_assets"] );
				
			case FLOW.AVATAR_BUILDER:
          		_loadPacksAndGotoScreen( ScreenAvatarBuilder, ["avatar_builder_audio", "avatar_builder_assets"] );
				
			case FLOW.EXPERIMENT:
          		_loadPacksAndGotoScreen( ScreenExperiment, ["experiment_audio", "experiment_assets"] );
				
			case FLOW.QUIZ1:
          		_loadPacksAndGotoScreen( ScreenQuiz1, ["quiz_audio", "quiz_assets"] );
				
			case FLOW.QUIZ2:
          		_loadPacksAndGotoScreen( ScreenQuiz2, ["quiz_audio", "quiz_assets"] );
				
			case FLOW.QUIZ3:
          		_loadPacksAndGotoScreen( ScreenQuiz3, ["quiz_audio", "quiz_assets"] );
				
			case FLOW.IMAGE_HUNT:
          		_loadPacksAndGotoScreen( ScreenImageHunt, ["image_hunt_audio", "image_hunt_assets"] );
				
			// Cutscenes //
			case FLOW.CUTSCENE_OPENING:
				_loadPacksAndGotoScreen( ScreenCutsceneOpening, ["cutscene_opening_audio", "cutscene_opening_assets"] );
			  
		  	case FLOW.CUTSCENE_SURVEY:
				_loadPacksAndGotoScreen( ScreenCutsceneSurvey, ["cutscene_opening_audio", "cutscene_opening_assets"] );
			  
		  	case FLOW.CUTSCENE_MID:
				_loadPacksAndGotoScreen( ScreenCutsceneMid, ["cutscene_mid_audio", "cutscene_mid_assets"] );

			case FLOW.CUTSCENE_DOCTOR_START:
				_loadPacksAndGotoScreen( ScreenCutsceneDoctorStart, ["cutscene_doctor_start_audio", "cutscene_doctor_start_assets"] );
				
			case FLOW.CUTSCENE_DOCTOR_END:
				_loadPacksAndGotoScreen( ScreenCutsceneDoctorEnd, ["cutscene_doctor_end_audio", "cutscene_doctor_end_assets"] );

			case FLOW.ENDSCREEN:
				_loadPacksAndGotoScreen( ScreenEndPromotion, ["endscreen_assets", "endscreen_audio"] );
		}
	}

	/**********************************************************
	@description
	**********************************************************/
	private function _pauseGameplay( flagChange:Bool = true ) : Void {
		if ( flagChange ) {
			_flagGameplayPaused = true;
		}
		Services.onPauseEvent();
		ConstantsEvent.pause.dispatch( true );
	}

	/**********************************************************
	@description
	**********************************************************/
	private function _unpauseGameplay( flagChange:Bool = true ) : Void {
		if ( flagChange ) {
			_flagGameplayPaused = false;
		}
		Services.onResumeEvent();
		ConstantsEvent.pause.dispatch( false );
	}

	/**********************************************************
	@description
	**********************************************************/
	private function _newOnChangeAction( pScreenId:Class<ScreenBase>, pChangeEvent:CHANGE_TYPE, pAction:Void->Void ) : Void {
		_changeActions.push( new ChangeActionData( pScreenId, pChangeEvent, pAction ));
	}

	/**********************************************************
	@description
	**********************************************************/
	private function _executeInterfaceChange( pEventId:CHANGE_TYPE, pScreenId:Class<ScreenBase> ) : Void {
		var tI : Int = _changeActions.length;
		var tCA : ChangeActionData;
		while( tI-- > 0 ) {
			tCA = _changeActions[tI];
			if ( tCA.screenId == pScreenId && tCA.changeEvent == pEventId ) {
				_changeActions.splice(tI,1);
				tCA.action();
			}
		}
		tCA = null;
	}

	/**********************************************************
	@description
	**********************************************************/
	private function _addEventListeners() : Void {
		ConstantsEvent.worldGenerationComplete.add( _onWorldGenerationComplete );
		ConstantsEvent.initialLoadComplete.add( _eventInitialLoadComplete );
	}

	/**********************************************************
	@description
	**********************************************************/
	private function _removeEventListeners() : Void {
		ConstantsEvent.worldGenerationComplete.remove( _onWorldGenerationComplete );
		ConstantsEvent.initialLoadComplete.remove( _eventInitialLoadComplete );
	}

	/**********************************************************
	@description
	**********************************************************/
	private function _enableInput() : Void {
		WMInput.enabled = true;
	}

	/**********************************************************
	@description
	**********************************************************/
	private function _disableInput() : Void {
		WMInput.enabled = false;
	}

	/**********************************************************
	@description
	**********************************************************/
	private function _handleWebAudioUnlock() : Void {
		if ( _flagWebAudioUnlocked ) {
			return;
		}
		_flagWebAudioUnlocked = true;
	}

	/**********************************************************
	@description
	**********************************************************/
	private function _onInterfaceChange( pFlowId:CHANGE_TYPE, pScreenId:Class<ScreenBase> ) : Void {
		_executeInterfaceChange( pFlowId, pScreenId );
	}

	/**********************************************************
	@description
	**********************************************************/
	private function _disposeWorld():Void {
		if ( _world == null ) {
			return;
		}
		trace( "[Main](_disposeWorld)" );
		_world.dispose();
		_world = null;
	}

	/**********************************************************
	@description	Starts the game music.
	**********************************************************/
	private function _playGameMusic() : Void {
		WMSound.playMusic( ConstantsApp.DEFAULT_GAME_MUSIC, ConstantsApp.DEFAULT_GAME_MUSIC_VOLUME );
	}

	/**********************************************************
	@description	Starts the menu music if enabled.
	**********************************************************/
	private function _playMenuMusic() : Void {
		WMSound.playMusic( ConstantsApp.DEFAULT_MENU_MUSIC, ConstantsApp.DEFAULT_MENU_MUSIC_VOLUME );
	}
}
