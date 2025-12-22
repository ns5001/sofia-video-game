package screen;

import workinman.display.spine.SpineElement;
import workinman.tween.Ease;
import workinman.display.ImageSprite;
import workinman.display.Sprite;
import screen.button.SpineAllergen;
import screen.button.ButtonSlot;
import workinman.ui.ScreenBase;
import world.elements.MenuOptions;
import world.elements.AvatarObj;
import workinman.ui.Button;
import workinman.WMRandom;
import workinman.WMTimer;
import workinman.WMSound;
import app.ConstantsEvent;
import app.ALLERGEN_TYPE;
import app.ConstantsApp;
import app.PlayerData;
import workinman.WMInput;
import app.INPUT_TYPE;

class ScreenImageHunt extends ScreenBase {
	private var _tray:ImageSprite;
	private var _clickTray:Button;
	private var _acceptButton:Button;

	private var _backgroundTray:ImageSprite;

	private var _menuOptions             : MenuOptions;
	private var _clipboardTray:ImageSprite;
	private var _collectedAllergens:Array<ButtonSlot> = [null, null, null, null, null];
	private var _sceneAllergens:Array<SpineAllergen> = [null, null, null, null, null, null, null, null, null, null, null, null];
	private var _allergensIndex:Int = 0;
	private var _allergensCount:Int = 0;
	private var _reservedCount:Int = 0;

	private var _sofia:SpineElement;
	private var _sofiaRunnning:Bool = false;
	private var _sofiaCollected:Bool = false;
    private var _hasUpdated             : Bool = false;
	private var _avatar:AvatarObj;

	private var _randomToSpawn:Array<Int> = [0, 2, 3, 9];

	public function new(pRoot:Sprite):Void {
		super(pRoot);
	}

	private override function _buildScreen():Void {
		super._buildScreen();
		_closing = false;

        WMSound.stopMusic();
        WMSound.playMusic(manifest.Sound.sofia_park_bg_music, ConstantsApp.DEFAULT_GAME_MUSIC_VOLUME);

		_tray = _elementManager.addElement(new ImageSprite({}));

		_backgroundTray = _tray.addElement(new ImageSprite({}));
		_backgroundTray.addElement(new ImageSprite({
			asset: manifest.Texture.sky,
			x: 0,
			y: -ConstantsApp.STAGE_HEIGHT / 2 + 87.5,
			scale: 1
		}));
		_backgroundTray.addElement(new ImageSprite({
			asset: manifest.Texture.bg, x: 0, y: 0, scale: .4998
    	}));

		_backgroundTray.addElement(new ImageSprite({asset: manifest.Texture.bench, x: 163, y: 123}));

		// // Not clickable yet
		_backgroundTray.addElement(new ImageSprite({asset: manifest.Texture.pond, x: 425, y: -73})).inputEnabled = false;
		_backgroundTray.addElement(new SpineElement({ library: manifest.spine.park_trees.Info.name, x: 0, y: 0, scale: .4998 })).animate("scene_trees_all_idle");

		// randomly remove 2 values
		while (_randomToSpawn.length > 2) {
			var tRandIndex = WMRandom.randomInt(0, _randomToSpawn.length);
			var tRandValue = _randomToSpawn[tRandIndex];
			_randomToSpawn.remove(tRandValue);
		}
		
		// Set up allergens in the environment
		_sceneAllergens[0] = _backgroundTray.addElement(new SpineAllergen({x: 0, y: 0, scale: .5}, 845, -150, 750, 275, manifest.spine.park_pond.Info.name, ALLERGEN_TYPE.POND, 0, "sofia_fish_pond", _tween, _clearButtonInput));
			_sceneAllergens[0].setAnimations("scene_pond", "", "", PICKUP_TYPE.ANIMATE_THEN_TRANSITION);
			if (_randomToSpawn.indexOf(0) == -1) _sceneAllergens[0].inputEnabled = false;

		_backgroundTray.addElement(new SpineElement({ library: manifest.spine.park_flowers.Info.name, x: 0, y: 0, scale: .4998 })).animate("scene_flowers");

		_sceneAllergens[1] = _backgroundTray.addElement(new SpineAllergen({x: 0, y: 0, scale: .5}, -570, -220, 300, 170, manifest.spine.park_car.Info.name, ALLERGEN_TYPE.CAR, 1, "sofia_car_drive_by", _tween, _clearButtonInput));
			_sceneAllergens[1].setAnimations("scene_car_idle", "scene_car_out", "scene_car_in", PICKUP_TYPE.ANIMATE_THEN_IMMEDIATE_AND_HIDE, function() { _playSofiaReaction("park_cough"); });

		_sceneAllergens[2] = _backgroundTray.addElement(new SpineAllergen({x: 0, y: 0, scale: .5}, -1120, -400, 150, 150, manifest.spine.park_tree_bird.Info.name, ALLERGEN_TYPE.BIRD, 2, "sofia_blue_bird", _tween, _clearButtonInput));
			_sceneAllergens[2].setAnimations("scene_tree_idle", "scene_bird_chirp", "", PICKUP_TYPE.BIRD);
			if (_randomToSpawn.indexOf(2) == -1){
				_sceneAllergens[2].inputEnabled = false;
				_sceneAllergens[2].animate("scene_tree_idle2");
			}

		if (_randomToSpawn.indexOf(3) != -1){
			_sceneAllergens[3] = _backgroundTray.addElement(new SpineAllergen({x: 0, y: 0, scale: .5}, 680, 70, 130, 130, manifest.spine.duck.Info.name, ALLERGEN_TYPE.DUCK, 3, "sofia_duck_quack", _tween, _clearButtonInput));
			_sceneAllergens[3].setAnimations("idle", "animation", "", PICKUP_TYPE.ANIMATE_THEN_TRANSITION_AND_HIDE);
		}

		_sceneAllergens[4] = _backgroundTray.addElement(new SpineAllergen({x: 0, y: 0, scale: .5}, -375, 150, 200, 600, manifest.spine.cigarette.Info.name, ALLERGEN_TYPE.CIGARETTE, 4, "sofia_cough", _tween, _clearButtonInput));
			_sceneAllergens[4].setAnimations("idle", "animation", "", PICKUP_TYPE.ANIMATE_THEN_TRANSITION, function() { _playSofiaReaction("park_cough"); });
		_sceneAllergens[5] = _backgroundTray.addElement(new SpineAllergen({x: 0, y: 0, scale: .5}, -940, 60, 500, 500, manifest.spine.vegetables.Info.name, ALLERGEN_TYPE.BROCCOLI, 5, "sofia_broccoli_boop", _tween, _clearButtonInput));
			_sceneAllergens[5].setAnimations("idle", "animation", "", PICKUP_TYPE.ANIMATE_THEN_TRANSITION );
		_sceneAllergens[7] = _backgroundTray.addElement(new SpineAllergen({x: 0, y: 0, scale: .5}, -60, -200, 150, 170, manifest.spine.park_fire.Info.name, ALLERGEN_TYPE.FIRE, 7, "sofia_fire", _tween, _clearButtonInput));
			_sceneAllergens[7].setAnimations("scene_fire", "", "", PICKUP_TYPE.ANIMATE_THEN_TRANSITION_AND_HIDE, function() { _playSofiaReaction("park_cough"); });
		_sceneAllergens[8] = _backgroundTray.addElement(new SpineAllergen({x: 0, y: 0, scale: .5}, 995, 195, 260, 540, manifest.spine.perfume.Info.name, ALLERGEN_TYPE.PERFUME, 8, "sofia_perfume", _tween, _clearButtonInput));
			_sceneAllergens[8].setAnimations("idle", "animation", "", PICKUP_TYPE.ANIMATE_THEN_TRANSITION, function() { _playSofiaReaction("park_sneeze"); });
		_sceneAllergens[10] = _backgroundTray.addElement(new SpineAllergen({x: 0, y: 0, scale: .5}, 100, -600, 230, 200, manifest.spine.pollution.Info.name, ALLERGEN_TYPE.POLLUTION, 10, "", _tween, _clearButtonInput));
			_sceneAllergens[10].setAnimations("idle", "animation", "", PICKUP_TYPE.ANIMATE_THEN_TRANSITION, function() { _playSofiaReaction("park_cough"); });
		_sceneAllergens[11] = _backgroundTray.addElement(new SpineAllergen({x: 0, y: 0, scale: .5}, 100, -200, 160, 200, manifest.spine.park_boy.Info.name, ALLERGEN_TYPE.SPORTS, 11, "sofia_basketball_spin", _tween, _clearButtonInput));
			_sceneAllergens[11].setAnimations("scene_boy_idle", "scene_boy_spin", "", PICKUP_TYPE.ANIMATE_THEN_TRANSITION );

		if (_randomToSpawn.indexOf(9) != -1){
			_sceneAllergens[9] = _backgroundTray.addElement(new SpineAllergen({x: 0, y: 0, scale: .5}, -940, -610, 200, 150, manifest.spine.park_ufo.Info.name, ALLERGEN_TYPE.UFO, 9, "sofia_ufo", _tween, _clearButtonInput));
			_sceneAllergens[9].setAnimations("scene_ufo_idle", "scene_ufo_out", "scene_ufo_in", PICKUP_TYPE.ANIMATE_THEN_IMMEDIATE_AND_HIDE);
		}

		_avatar = _backgroundTray.addElement(new AvatarObj({x: 112, y: 220, scale: .2}, PlayerData.avatarSettings, _tween));
		_avatar.animate("write_idle");
		_avatar.addElement(new Button({
			x: 0,
			y: -570,
			tween: _tween,
			clear: _clearButtonInput,
		})).setCustomHitBox(500, 1250).eventDown.add(function() {
			if (_avatar.animating) return;
			_avatar.animate("write_tap", 1, true);
		});

		// create sofia - add click functionality
		_sofia = _backgroundTray.addElement(new SpineElement({
			library: manifest.spine.sofia.Info.name, x: 223, y: 224, scale: .2, scaleX: -.2
		}));
		_sofia.animate("thinking_idle");
		_sofia.addElement(new Button({
			x: 0,
			y: -550,
			tween: _tween,
			clear: _clearButtonInput,
		})).setCustomHitBox(400, 1250).eventDown.add(function() {
			if(_sofiaRunnning || _sofiaCollected || (_reservedCount + _allergensCount >= 5)) return;
			_playSofiaRun();
		});

		_sceneAllergens[6] = _backgroundTray.addElement ( new SpineAllergen( { x: 0, y: 0, scale:.5 }, 340, -300, 200, 200, manifest.spine.park_cold_air.Info.name, ALLERGEN_TYPE.COLD, 6, "sofia_cold_air", _tween, _clearButtonInput));
		_sceneAllergens[6].setAnimations("scene_cold_air_snowflake","scene_cold_air", "", PICKUP_TYPE.ANIMATE_THEN_IMMEDIATE_AND_HIDE, function() { _playSofiaReaction("park_shiver"); });

		_clipboardTray = _tray.addElement(new ImageSprite({asset: manifest.Texture.clipboard, x: 0, y: ConstantsApp.STAGE_HEIGHT / 2 - 100.5}));
		for (i in 0...5) {
			_collectedAllergens[i] = _clipboardTray.addElement(new ButtonSlot({
				scale: .5,
				alpha: 1,
				x: -300 + (i * 150),
				y: 55,
				tween: _tween,
				clear: _clearButtonInput
			}));
		}

		_acceptButton = _tray.addElement(new Button({
			asset: manifest.Texture.btn_check_gray,
			x: ConstantsApp.STAGE_WIDTH / 2 - 75,
			y: ConstantsApp.STAGE_HEIGHT / 2 - 75,
			tween: _tween,
			clear: _clearButtonInput,
			scale: 1,
			alpha: 1
		}));
		_acceptButton.eventClick.add(_advanceGame);
		_acceptButton.inputEnabled = false;

		_menuOptions = _tray.addElement(new MenuOptions({}, "6: Image Hunt", manifest.Texture.park_popup, manifest.Sound.sofia_park_02, _tween, _clearButtonInput));

        WMInput.eventInput.add(_generalInput);

		// Add Listeners 
		app.ConstantsEvent.selectAllergen.add(_collectAllergen);
		app.ConstantsEvent.collectAllergen.add(_immediatelyCollectAllergen);
		app.ConstantsEvent.releaseAllergen.add(_releaseAllergen);
		app.ConstantsEvent.reserveSlot.add(_reserveAllergen);

		app.PlayerData.reset();

		app.GoogleAnalytics.LogEvent("Progress_web", { 'event_label': "6: Image Hunt"});
		// app.GoogleAnalytics.LogEvent("Progress", { 'event_label': "Progress", "screen":"6: Image Hunt"});
	}

	public override function update(dt:Float):Void {
		super.update(dt);
	}

	public override function dispose():Void {
		WMTimer.stop("hide_timer");

		app.ConstantsEvent.selectAllergen.remove(_collectAllergen);
		app.ConstantsEvent.collectAllergen.remove(_immediatelyCollectAllergen);
		app.ConstantsEvent.releaseAllergen.remove(_releaseAllergen);
		app.ConstantsEvent.reserveSlot.remove(_reserveAllergen);

		_tray = null;
		_clickTray = null;
		_clipboardTray = null;
		_backgroundTray = null;

		_sofia = null;
		_acceptButton = null;

        WMInput.eventInput.remove(_generalInput);
		
		super.dispose();
	}
    
    private function _generalInput(pType:INPUT_TYPE , pDown:Bool) : Void {
      switch ( pType ) {
        case INPUT_TYPE.POINTER:
          if ( pDown )
            _menuOptions.resetCountdown();
        default:
      }
    }

	private function _collectAllergen(pType:ALLERGEN_TYPE, pIndex:Int):Void {
		trace("Collect ALLERGEN: " + pType);

		_avatar.animate("write_active", 1, true);

		for (i in 0...5) {
			if (!_collectedAllergens[i].full) {
				_allergensIndex = i;
				break;
			}
		}

		_collectedAllergens[_allergensIndex].collect(_getTargetedAllergen(pType), _getAllergenPositions(pType), pIndex);

		app.PlayerData.addAllergen(_allergensIndex, pType);

		_allergensCount++;
		ConstantsEvent.setCollectedCount.dispatch(_allergensCount);
		_reservedCount--;
		ConstantsEvent.setReservedCount.dispatch(_reservedCount);

		// if (_allergensCount >= 5){
		// 	_acceptButton.inputEnabled = true;
		// 	_acceptButton.setAsset(manifest.Texture.btn_check);
		// }
		_enabledAcceptButton();
	}

	private function _immediatelyCollectAllergen(pType:ALLERGEN_TYPE, pIndex:Int):Void {
		trace("Immediately Collect ALLERGEN: " + pType);

		for (i in 0...5) {
			if (!_collectedAllergens[i].full) {
				_allergensIndex = i;
				break;
			}
		}

		_collectedAllergens[_allergensIndex].collectImmediate(_getTargetedAllergen(pType), pIndex);

		app.PlayerData.addAllergen(_allergensIndex, pType);

		_allergensCount++;
		ConstantsEvent.setCollectedCount.dispatch(_allergensCount);
		_reservedCount--;
		ConstantsEvent.setReservedCount.dispatch(_reservedCount);

		// if (_allergensCount >= 5){
		// 	_acceptButton.inputEnabled = true;
		// 	_acceptButton.setAsset(manifest.Texture.btn_check);
		// }
		_enabledAcceptButton();
	}

	private function _collectExercise () : Void {
		for (i in 0...5) {
			if (!_collectedAllergens[i].full) {
				_allergensIndex = i;
				break;
			}
		}

		_collectedAllergens[_allergensIndex].collectImmediate(_getTargetedAllergen(ALLERGEN_TYPE.EXERCISE), -1);

		app.PlayerData.addAllergen(_allergensIndex, ALLERGEN_TYPE.EXERCISE);

		_allergensCount++;
		ConstantsEvent.setCollectedCount.dispatch(_allergensCount);
		_reservedCount--;
		ConstantsEvent.setReservedCount.dispatch(_reservedCount);

		// if (_allergensCount >= 5){
		// 	_acceptButton.inputEnabled = true;
		// 	_acceptButton.setAsset(manifest.Texture.btn_check);
		// }
		_enabledAcceptButton();
	}

	private function _enabledAcceptButton() {
		if (_allergensCount >= 5){
			_acceptButton.inputEnabled = true;
			_acceptButton.setAsset(manifest.Texture.btn_check);

			if (!_hasUpdated) {
				_hasUpdated = true;
				_menuOptions.updateInstructions();
			}
		}
	}

	private function _releaseAllergen(pIndex:Int):Void {
		trace("Release ALLERGEN: " + pIndex);
		
		trace("RELEASE");

		if (pIndex == -1)
			_sofiaCollected = false;
		else
			_sceneAllergens[pIndex].release();

		_acceptButton.inputEnabled = false;
		_acceptButton.setAsset(manifest.Texture.btn_check_gray);

		_allergensCount--;
		ConstantsEvent.setCollectedCount.dispatch(_allergensCount);
	}

	private function _reserveAllergen(pType:ALLERGEN_TYPE, pIndex:Int) : Void {
		trace("RESERVING SLOT: " + pIndex + " - " + pType);
		for (i in 0...5) {
			if (!_collectedAllergens[i].full && !_collectedAllergens[i].reserved) {
				_collectedAllergens[i].reserved = true;
				_reservedCount++;
				ConstantsEvent.setReservedCount.dispatch(_reservedCount);
				break;
			}
		}
	}

	private function _getTargetedAllergen(pType:ALLERGEN_TYPE):String {
		switch (pType) {
			case BIRD:
				return manifest.Texture.clipboard_bird;
			case BROCCOLI:
				return manifest.Texture.clipboard_broccoli;
			case CAR:
				return manifest.Texture.clipboard_car;
			case CIGARETTE:
				return manifest.Texture.clipboard_cigarette;
			case COLD:
				return manifest.Texture.clipboard_cold_air;
			case DUCK:
				return manifest.Texture.clipboard_duck;
			case EXERCISE:
				return manifest.Texture.clipboard_exercise;
			case FIRE:
				return manifest.Texture.clipboard_fire;
			case PERFUME:
				return manifest.Texture.clipboard_perfume;
			case POLLUTION:
				return manifest.Texture.clipboard_pollution;
			case POND:
				return manifest.Texture.clipboard_goldfish;
			case SPORTS:
				return manifest.Texture.clipboard_basketball;
			case UFO:
				return manifest.Texture.clipboard_ufo;
			default:
				return manifest.Texture.clipboard_fire;
		}
	}

	private function _advanceGame() {
		if (_closing == false) {
			_closing = true;

			app.GoogleAnalytics.LogEvent("Trigger Selection_web", { 'event_label' : _getAllergenName(app.PlayerData.selectedAllergens[0])});
			app.GoogleAnalytics.LogEvent("Trigger Selection_web", { 'event_label' : _getAllergenName(app.PlayerData.selectedAllergens[1])});
			app.GoogleAnalytics.LogEvent("Trigger Selection_web", { 'event_label' : _getAllergenName(app.PlayerData.selectedAllergens[2])});
			app.GoogleAnalytics.LogEvent("Trigger Selection_web", { 'event_label' : _getAllergenName(app.PlayerData.selectedAllergens[3])});
			app.GoogleAnalytics.LogEvent("Trigger Selection_web", { 'event_label' : _getAllergenName(app.PlayerData.selectedAllergens[4])});

			app.ConstantsEvent.addLoader.dispatch();
			app.ConstantsEvent.flow.dispatch(app.FLOW.CUTSCENE_MID);

			WMSound.playSound(manifest.Sound.sofia_click_confirm);

			WMSound.stopMusic();
			WMSound.playMusic(manifest.Sound.sofia_bg_music, ConstantsApp.DEFAULT_GAME_MUSIC_VOLUME);
		}
	}

	private function _getAllergenPositions(pType:ALLERGEN_TYPE):Dynamic {
		var position:Dynamic;

		switch (pType) {
			case BIRD:
				position = {x: -560, y: -200};
			case BROCCOLI:
				position = {x: -480, y: 30};
			case CAR:
				position = {x: -285, y: -110};
			case CIGARETTE:
				position = {x: -190, y: 75};
			case COLD:
				position = {x: -190, y: 75};
			case DUCK:
				position = {x: 338, y: 35};
			case EXERCISE:
				position = {x: 338, y: 35};
			case FIRE:
				position = {x: -30, y: -100};
			case PERFUME:
				position = {x: 495, y: 95};
			case POLLUTION:
				position = {x: 45, y: -300};
			case POND:
				position = {x: 422, y: -75};
			case SPORTS:
				position = {x: 50, y: -100};
			case UFO:
				position = {x: -470, y: -305};
			default:
				position = {x: 0, y: 0};
		}

		position.y -= _clipboardTray.y;

		return position;
  }
  private function _getAllergenName(pType:ALLERGEN_TYPE):Dynamic {
	  switch (pType) {
		  case BIRD:
			return "bird";
		  case BROCCOLI:
			return "broccoli";
		  case CAR:
			return "car";
		  case CIGARETTE:
			return "cigarette";
		  case COLD:
			return "cold";
		  case DUCK:
			return "duck";
		  case EXERCISE:
			return "exercise";
		  case FIRE:
			return "fire";
		  case PERFUME:
			return "perfume";
		  case POLLUTION:
			return "pollution";
		  case POND:
			return "pond";
		  case SPORTS:
			return "sports";
		  case UFO:
			return "ufo";
		  default:
			return "bird";
	  }
}
  
  private function _playSofiaReaction (pAnim:String) : Void {
    if (pAnim == "" || _sofiaRunnning)
        return;

	_sofia.animate(pAnim, 1);
	_sofia.queueAnimation("thinking_idle");
  }
  private function _playSofiaRun() : Void {
	_sofiaRunnning = true;

	_reserveAllergen(ALLERGEN_TYPE.EXERCISE, -1);
	WMSound.playSound(manifest.Sound.sofia_running);

	_sofia.clearQueue();
	_sofia.animate("park_run");

	_sofia.scaleX = .2;
	_tween.tween( { target: _sofia, duration: 2, delay: 0, ease: Ease.outQuad, complete:function() {
		_sofia.scaleX = -.2;
		_tween.tween( { target: _sofia, duration: 2, delay: 0, ease: Ease.outQuad, complete:function() {
			_sofia.animate("park_run_into_idle", 1);
			_sofia.queueAnimation("park_breathing", 1);
			_sofia.queueAnimation("park_idle");

			WMTimer.start(function() {
				_sofiaRunnning = false;
				_sofiaCollected = true;
				_collectExercise();
			}, 2);
		}}, { x: 223 } );
	}}, { x: 800 } );
  }
}
