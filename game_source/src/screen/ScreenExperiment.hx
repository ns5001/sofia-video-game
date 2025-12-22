package screen;

import workinman.display.spine.SpineElement;
import workinman.display.ImageSprite;
import workinman.display.Element;
import workinman.display.Sprite;
import workinman.display.Text;
import workinman.math.WMPoint;
import world.elements.AvatarObj;
import screen.button.ButtonAllergen;
import world.elements.MenuOptions;
import workinman.ui.ScreenBase;
import workinman.ui.Button;
import workinman.WMTimer;
import workinman.WMSound;
import app.ALLERGEN_TYPE;
import app.INPUT_TYPE;
import app.PlayerData;
import workinman.WMInput;
import app.INPUT_TYPE;

class ScreenExperiment extends ScreenBase {

    private var _tray                   : ImageSprite;

    private var _menuOptions            : MenuOptions;

    private var _sofia                  : SpineElement;
    private var _avatar                 : AvatarObj;
    private var _largeCheck             : ImageSprite;
    private var _testText               : Text;

    private var _clipboard              : ImageSprite;
    private var _clipboardCover         : ImageSprite;
    private var _allergenDraggables     : Array<ButtonAllergen> = [null, null, null, null, null];
    private var _allergenCheckmarks     : Array<ImageSprite> = [null, null, null, null, null];
    private var _coverButtons           : Array<Button> = [null, null, null, null, null];
    private var _acceptableAllergens    : Array<ALLERGEN_TYPE> = [ALLERGEN_TYPE.CAR, ALLERGEN_TYPE.CIGARETTE, ALLERGEN_TYPE.COLD, ALLERGEN_TYPE.EXERCISE, ALLERGEN_TYPE.FIRE, ALLERGEN_TYPE.PERFUME, ALLERGEN_TYPE.POLLUTION];

    // Spine assets
    private var _background             : SpineElement;

    // For dragging items
    private var _dragger                : Element;
    private var _inputPos               : WMPoint;
    private var _curAllergenIndex       : Int = -1;
    private var _testingIndex           : Int = 0;

    public function new( pRoot:Sprite ) : Void {
      trace("EXPERIMENT building");
      super( pRoot );
    }
    
    private override function _buildScreen() : Void {
        super._buildScreen();
		    _closing = false;

        WMSound.stopMusic();
        WMSound.playMusic(manifest.Sound.sofia_park_lab_track, app.ConstantsApp.DEFAULT_GAME_MUSIC_VOLUME);

        _tray = _elementManager.addElement ( new ImageSprite({}));
        _background = _tray.addElement ( new SpineElement( { library: manifest.spine.lab.Info.name, scale: .5, alpha: 1 }));
        _background.animate(manifest.spine.lab.Anim.idle, 1);
        _background.setSkin("perfume");

        // _sofia =  _tray.addElement ( new ImageSprite( { asset: manifest.Texture.sofia_experiment, scale: 1, x: 300, y: 130 } ));
        // _avatar =  _tray.addElement ( new ImageSprite( { asset: manifest.Texture.avatar_experiment, scaleY: 1.75, scaleX: -1.75, x: 489, y: 128 } ));
  
        //create characters
        _avatar = _tray.addElement ( new AvatarObj({x: 489, y: 328, scale:.35, scaleX: -.35}, PlayerData.avatarSettings, _tween, true));
        _avatar.animate("write_idle");
        _sofia = _tray.addElement ( new SpineElement({ library: manifest.spine.sofia.Info.name, x: 300, y: 330, scale: .35, scaleX: -.35 }) );
        _sofia.animate("thinking_idle");

        _testText = _tray.addElement( new Text( { text:manifest.localization.experiment.Ids.testing, x: 20, y: 158, scale: .8 } ) );
        _testText.setVariables([""]);

        _clipboard =  _tray.addElement ( new ImageSprite( { asset: manifest.Texture.clipboard_full, x: -380, y: 165, rotation: -7 } ));
        
        _allergenDraggables[0] = _clipboard.addElement ( new ButtonAllergen( { asset: _getTargetedAllergen(app.PlayerData.selectedAllergens[0]), x: -129, y: -122, scale: .75, tween:_tween, clear: _clearButtonInput}, app.PlayerData.selectedAllergens[0], 0));
        _clipboard.addElement( new Text( { text:manifest.localization.experiment.Ids.clipboard_allergen, x: 10, y:-118, scale:1 } ) ).setVariables([_getAllergenText(app.PlayerData.selectedAllergens[0])]);
          _allergenCheckmarks[0] = _clipboard.addElement( new ImageSprite( { asset: manifest.Texture.little_question, x: 138, y: -118 } ));
        _allergenDraggables[1] = _clipboard.addElement ( new ButtonAllergen( { asset: _getTargetedAllergen(app.PlayerData.selectedAllergens[1]), x: -129, y: -54, scale: .75, tween:_tween, clear: _clearButtonInput}, app.PlayerData.selectedAllergens[1], 1));
          _clipboard.addElement( new Text( { text:manifest.localization.experiment.Ids.clipboard_allergen, x: 10, y:-51, scale:1 } ) ).setVariables([_getAllergenText(app.PlayerData.selectedAllergens[1])]);
          _allergenCheckmarks[1] = _clipboard.addElement( new ImageSprite( { asset: manifest.Texture.little_question, x: 138, y: -52 } ));
        _allergenDraggables[2] = _clipboard.addElement ( new ButtonAllergen( { asset: _getTargetedAllergen(app.PlayerData.selectedAllergens[2]), x: -129, y: 15, scale: .75, tween:_tween, clear: _clearButtonInput}, app.PlayerData.selectedAllergens[2], 2));
          _clipboard.addElement( new Text( { text:manifest.localization.experiment.Ids.clipboard_allergen, x: 10, y:17, scale:1 } ) ).setVariables([_getAllergenText(app.PlayerData.selectedAllergens[2])]);
          _allergenCheckmarks[2] = _clipboard.addElement( new ImageSprite( { asset: manifest.Texture.little_question, x: 138, y: 15 } ));
        _allergenDraggables[3] = _clipboard.addElement ( new ButtonAllergen( { asset: _getTargetedAllergen(app.PlayerData.selectedAllergens[3]), x: -129, y: 83, scale: .75, tween:_tween, clear: _clearButtonInput}, app.PlayerData.selectedAllergens[3], 3));
          _clipboard.addElement( new Text( { text:manifest.localization.experiment.Ids.clipboard_allergen, x: 10, y:85, scale:1 } ) ).setVariables([_getAllergenText(app.PlayerData.selectedAllergens[3])]);
          _allergenCheckmarks[3] = _clipboard.addElement( new ImageSprite( { asset: manifest.Texture.little_question, x: 138, y: 82 } ));
        _allergenDraggables[4] = _clipboard.addElement ( new ButtonAllergen( { asset: _getTargetedAllergen(app.PlayerData.selectedAllergens[4]), x: -129, y: 154, scale: .75, tween:_tween, clear: _clearButtonInput}, app.PlayerData.selectedAllergens[4], 4));
          _clipboard.addElement( new Text( { text:manifest.localization.experiment.Ids.clipboard_allergen, x: 10, y:153, scale:1 } ) ).setVariables([_getAllergenText(app.PlayerData.selectedAllergens[4])]);
          _allergenCheckmarks[4] = _clipboard.addElement( new ImageSprite( { asset: manifest.Texture.little_question, x: 138, y: 153 } ));


          _allergenDraggables[0].disable();  
          _allergenDraggables[1].disable();  
          _allergenDraggables[2].disable();  
          _allergenDraggables[3].disable();  
          _allergenDraggables[4].disable();  

        _coverButtons[0] = _clipboard.addElement(new Button({x: 0, y: -125, tween:_tween, clear:_clearButtonInput}));
          _coverButtons[0].setCustomHitBox(340, 60);
          _coverButtons[0].eventDown.add(function() { _clickAllergen(0); });
        _coverButtons[1] = _clipboard.addElement(new Button({x: 0, y: -55, tween:_tween, clear:_clearButtonInput}));
          _coverButtons[1].setCustomHitBox(340, 60);
          _coverButtons[1].eventDown.add(function() { _clickAllergen(1); });
        _coverButtons[2] = _clipboard.addElement(new Button({x: 0, y: 15, tween:_tween, clear:_clearButtonInput}));
          _coverButtons[2].setCustomHitBox(340, 60);
          _coverButtons[2].eventDown.add(function() { _clickAllergen(2); });
        _coverButtons[3] = _clipboard.addElement(new Button({x: 0, y: 85, tween:_tween, clear:_clearButtonInput}));
          _coverButtons[3].setCustomHitBox(340, 60);
          _coverButtons[3].eventDown.add(function() { _clickAllergen(3); });
        _coverButtons[4] = _clipboard.addElement(new Button({x: 0, y: 155, tween:_tween, clear:_clearButtonInput}));
          _coverButtons[4].setCustomHitBox(340, 60);
          _coverButtons[4].eventDown.add(function() { _clickAllergen(4); });
        
        _clipboardCover =  _tray.addElement ( new ImageSprite( { asset: manifest.Texture.clipboard_full, x: -380, y: 165, rotation: -7, alpha:0 } ));
        _clipboardCover.inputEnabled = false;

        // The draggable sticker
        _dragger = _elementManager.addElement( new Element({ }) );
        _dragger.scale = 1;
        _dragger.visible = false;
        _dragger.setAsset(manifest.Texture.little_x);
        _inputPos = WMPoint.request(0, 0);

        _menuOptions = _tray.addElement( new MenuOptions( { }, "8: Laboratory", manifest.Texture.lab_popup, manifest.Sound.sofia_experiment, _tween, _clearButtonInput ));

        app.ConstantsEvent.selectAllergen.add( _pickupAllergen );

        WMInput.eventInput.add(_generalInput);

        app.GoogleAnalytics.LogEvent("Progress_web", { 'event_label': "8: Laboratory"});
        // app.GoogleAnalytics.LogEvent("Progress", { 'event_label': "Progress", "screen":"8: Laboratory"});
    }

    public override function update(dt:Float) : Void {
        super.update(dt);

        _draggerToCursor();
    }
    
    public override function dispose() : Void {
        super.dispose();

        app.ConstantsEvent.selectAllergen.remove( _pickupAllergen );

        _inputPos.dispose();
        _inputPos = null;
        _dragger = null;

        _sofia = null;
        // _avatar.dispose();

        _tray = null;
        _largeCheck = null;
        _testText = null;
        _clipboard = null;
        _clipboardCover  = null;
        _acceptableAllergens = null;
        _background = null;

        WMInput.eventInput.remove(_generalInput);

        WMTimer.stop("hide_timer");
    }
    
    private function _generalInput(pType:INPUT_TYPE , pDown:Bool) : Void {
      switch ( pType ) {
        case INPUT_TYPE.POINTER:
          if ( pDown )
            _menuOptions.resetCountdown();
        default:
      }
    }

    private function _onEventClickPlay() {
      if ( _closing == false ) {
        _closing = true;
        app.ConstantsEvent.addLoader.dispatch();
        app.ConstantsEvent.flow.dispatch( app.FLOW.QUIZ2 );
      }
    }

    private function _getTargetedSFX (pType : ALLERGEN_TYPE) : String { 
      switch(pType) {
        case BIRD:
          return manifest.Sound.sofia_blue_bird;
        case BROCCOLI:
          return "";
        case CAR:
          return manifest.Sound.sofia_car_drive_by;
        case CIGARETTE:
          return "";
        case COLD:
          return manifest.Sound.sofia_cold_air;
        case DUCK:
          return manifest.Sound.sofia_duck_quack;
        case EXERCISE:
          return manifest.Sound.sofia_running;
        case FIRE:
          return manifest.Sound.sofia_fire;
        case PERFUME:
          return manifest.Sound.sofia_perfume;
        case POLLUTION:
          return "";
        case POND:
          return manifest.Sound.sofia_fish_pond;
        case SPORTS:
          return "";
        case UFO:
          return manifest.Sound.sofia_ufo;
        default:
          return manifest.Sound.sofia_fire;
      }
    }

    private function _getTargetedAllergen (pType : ALLERGEN_TYPE) : String { 
      switch(pType) {
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
    private function _getAllergenText (pType : ALLERGEN_TYPE, ?pIsPath = false) : String {
      switch(pType) {
        case BIRD:
          return "bird";
        case BROCCOLI:
          return "broccoli";
        case CAR:
          return "car";
        case CIGARETTE:
          return "cigarette";
        case COLD:
          return pIsPath ? "cold_air" : "cold air";
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
          return "goldfish";
        case SPORTS:
          return "sports";
        case UFO:
          return "ufo";
        default:
          return "fire";
      }
    }

    private function _pickupAllergen(pType : ALLERGEN_TYPE, pIndex : Int) : Void {
      _allergenDraggables[pIndex].visible = false;

      _dragger.asset = _getTargetedAllergen(pType);
      _dragger.visible = true;
      
      _curAllergenIndex = pIndex;
    }
    private function _releaseAllergen() : Void {
      _dragger.visible = false;

      trace("POS x:" + _dragger.x + " y:" + _dragger.y);
      if (_checkPosition(_dragger.x, _dragger.y)) {
        // disable other buttons
        _clipboardCover.inputEnabled = true;

        // set correct text
        _testText.setVariables([_getAllergenText(app.PlayerData.selectedAllergens[_curAllergenIndex]).toUpperCase()]);

        //prep and play target animation
        _background.setSkin(_getAllergenText(app.PlayerData.selectedAllergens[_curAllergenIndex], true));
        _background.animate(manifest.spine.lab.Anim.item_start, 1).eventAnimationComplete.add(_testAllergen);
      } else {
        _allergenDraggables[_curAllergenIndex].release();
      }

    }
    private function _clickAllergen(pIndex : Int) : Void {
      _clipboardCover.inputEnabled = true;
      _allergenDraggables[pIndex].visible = false;
      _curAllergenIndex = pIndex;

      // set correct text
      _testText.setVariables([_getAllergenText(app.PlayerData.selectedAllergens[_curAllergenIndex]).toUpperCase()]);

      // play sfx
      WMSound.playSound(_getTargetedSFX(app.PlayerData.selectedAllergens[_curAllergenIndex]));
      WMSound.playSound(manifest.Sound.sofia_machine_start, .5);

      //prep and play target animation
      _background.setSkin(_getAllergenText(app.PlayerData.selectedAllergens[_curAllergenIndex], true));
      _background.animate(manifest.spine.lab.Anim.item_start, 1).eventAnimationComplete.add(_testAllergen);
    }
    private function _testAllergen() : Void {
      _background.eventAnimationComplete.remove(_testAllergen);

      _background.animate(manifest.spine.lab.Anim.test, 1);

      WMTimer.start(function() {
        if (_acceptableAllergens == null) return;
        if (_acceptableAllergens.indexOf(app.PlayerData.selectedAllergens[_curAllergenIndex]) != -1) {
          WMSound.playSound(manifest.Sound.sofia_machine_done, .5);
          _background.animate(manifest.spine.lab.Anim.check, 1).eventAnimationComplete.add(_provideFeedback);
          _allergenCheckmarks[_curAllergenIndex].asset = manifest.Texture.little_check;
          _avatar.animate("write_positive", 1);
          _sofia.animate("thinking_positive", 1).eventAnimationComplete.add(function () {
            _sofia.animate("thinking_idle");
          });
        } else {
          WMSound.playSound(manifest.Sound.sofia_machine_incorrect, .5);
          _background.animate(manifest.spine.lab.Anim.x, 1).eventAnimationComplete.add(_provideFeedback);
          _allergenCheckmarks[_curAllergenIndex].asset = manifest.Texture.little_x;
          _avatar.animate("write_negative", 1);
          _sofia.animate("thinking_negative", 1).eventAnimationComplete.add(function () {
            _sofia.animate("thinking_idle");
          });
        }
        _allergenCheckmarks[_curAllergenIndex].alpha = 1;
      }, 2, "testing_delay");
    }
    private function _provideFeedback () : Void {
      _background.eventAnimationComplete.remove(_provideFeedback);
      _background.animate(manifest.spine.lab.Anim.item_end, 1);
      _allergenDraggables[_curAllergenIndex].visible = true;
      _coverButtons[_curAllergenIndex].disable();
      _clipboardCover.inputEnabled = false;
      
      _testingIndex++;
      if (_testingIndex >= 5)
        WMTimer.start(_advanceGame, .5);
    }

    private function _draggerToCursor() : Void {
      _elementManager.camera.getWorldPositionOfScreenPoint( workinman.WMInput.pointer.currentPos.x, workinman.WMInput.pointer.currentPos.y, 0, _inputPos );

		  _dragger.pos.x = _inputPos.x;
      _dragger.pos.y = _inputPos.y;
    }
    private override function _onInput( pType:INPUT_TYPE, pDown:Bool ) : Void {
      if (pDown == false && _dragger.visible) {
        _releaseAllergen();
      }
    }

    private function _checkPosition(pX: Float, pY: Float) : Bool {
      if (pY < -80 || pY > 110) return false;
      if (pX < -75 || pX > 125) return false;
      return true;
    }

    private function _advanceGame() {
      if ( _closing == false ) {
        _closing = true;

        WMSound.stopMusic();
        WMSound.playMusic(manifest.Sound.sofia_bg_music, app.ConstantsApp.DEFAULT_GAME_MUSIC_VOLUME);

        app.ConstantsEvent.addLoader.dispatch();
        app.ConstantsEvent.flow.dispatch( app.FLOW.QUIZ2 );
      }
    }
    // private function _addInstruction () : Void {
    //   var tPopup = _tray.addElement ( new ImageSprite({ asset: manifest.Texture.lab_popup, x: 0, y: - ConstantsApp.STAGE_HEIGHT/2 - 80 , scale: 1 }));
    //   tPopup.addElement ( new Button ({ tween:_tween, clear: _clearButtonInput })).setCustomHitBox(500, 150).eventDown.add(function () {
    //     WMTimer.stop("hide_timer");
    //     _tween.tween( { target: tPopup, duration: .4, ease: Ease.outQuad }, { y: - ConstantsApp.STAGE_HEIGHT/2 - 80 } );
    //   });

    //   _tween.tween( { target: tPopup, duration: .4, ease: Ease.inQuad }, { y: - ConstantsApp.STAGE_HEIGHT/2 + 80 } );

    //   WMTimer.start(function () {
    //     _tween.tween( { target: tPopup, duration: .4, ease: Ease.inBounce }, { y: - ConstantsApp.STAGE_HEIGHT/2 - 80 } );
    //   }, 6, "hide_timer");
    // }
}