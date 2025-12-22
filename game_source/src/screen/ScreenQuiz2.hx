package screen;

import world.elements.MenuOptions;
import workinman.display.ImageSprite;
import workinman.display.Sprite;
import workinman.display.Text;
import workinman.ui.ScreenBase;
import workinman.ui.Button;
import workinman.WMSound;
import app.ALLERGEN_TYPE;
import app.ConstantsApp;
import app.PlayerData;
import workinman.WMInput;
import app.INPUT_TYPE;

class ScreenQuiz2 extends ScreenBase {
  private var _tray                     : ImageSprite;
  // private var _clickTray			          : Button;
  private var _backgroundTray		        : ImageSprite;
  private var _acceptButton			        : Button;

  private var _menuOptions             : MenuOptions;
  private var _questionBacking		      : ImageSprite;
  private var _answerOne      		      : Button;
  private var _answerTwo       		      : Button;
  private var _answerThree       		    : Button;

  private var _acceptableAllergens      : Array<ALLERGEN_TYPE> = [ALLERGEN_TYPE.CAR, ALLERGEN_TYPE.CIGARETTE, ALLERGEN_TYPE.COLD, ALLERGEN_TYPE.EXERCISE, ALLERGEN_TYPE.FIRE, ALLERGEN_TYPE.PERFUME, ALLERGEN_TYPE.POLLUTION];

  // private var _definitionBar            : ImageSprite;
  private var _definitionText           : Text;
  // private var _instructionIn            : Bool = false;
  private var _answers                  : Int = 0;
  private var _didClickIncorrect        : Bool = false;

  public function new( pRoot:Sprite ) : Void {
    trace("IMAGE HUNT building");
    super( pRoot );
  }

  private override function _buildScreen() : Void {
      super._buildScreen();
      _closing = false;

      _tray = _elementManager.addElement ( new ImageSprite({}));
      _backgroundTray = _tray.addElement ( new ImageSprite({}));
      _backgroundTray.addElement ( new ImageSprite({ asset: manifest.Texture.quiz_bg, x: 0, y: 0, scale: 1 }));
      
      _questionBacking = _backgroundTray.addElement ( new ImageSprite({ asset: manifest.Texture.quiz_question_2, x: -5, y:-200, scale: 1 }));

      // _clickTray = _backgroundTray.addElement( new Button( { tween:_tween, clear: _clearButtonInput } ));
      // _clickTray.setCustomHitBox(ConstantsApp.STAGE_WIDTH, ConstantsApp.STAGE_HEIGHT);
      // _clickTray.eventClick.add( _clearDefinition );

      var tClipboard = _backgroundTray.addElement ( new ImageSprite({ asset: manifest.Texture.quiz_clipboard, x: 0, y: 130, scale: 1 }));

      // _definitionBar = _backgroundTray.addElement ( new ImageSprite( { asset: manifest.Texture.popup_panel, y:ConstantsApp.STAGE_CENTER_Y + 87, scale: 1 } ));

      var tTriggers = _getTriggerOptions();

      _answerOne = tClipboard.addElement ( new Button( { asset: manifest.Texture.btn_quiz_2, x: -250, y: 0, scale:.9, tween:_tween, clear: _clearButtonInput}) );
      _answerOne.addElement ( new ImageSprite({ asset: _getTriggerAsset(tTriggers[0]), scale: 1.5  })).inputEnabled = false;
      _answerOne.eventDown.add( function () {

        WMSound.stopVO();
        WMSound.playSound(manifest.Sound.sofia_correct_1, .5);

        _onEventClickAnswer(tTriggers[0]);
        _answerOne.inputEnabled = false;
        _answerOne.setAsset(manifest.Texture.btn_quiz_2_correct);

        WMSound.playVO(_getDefintionVO(tTriggers[0]), "");
      });

      _answerTwo = tClipboard.addElement ( new Button( { asset: manifest.Texture.btn_quiz_2, x: 0, y: 0, scale:.9, tween:_tween, clear: _clearButtonInput}) );
      _answerTwo.addElement ( new ImageSprite({ asset: _getTriggerAsset(tTriggers[1]), scale: 1.5  })).inputEnabled = false;
      _answerTwo.eventDown.add( function () {

        WMSound.stopVO();
        WMSound.playSound(manifest.Sound.sofia_incorrect_1, .5);

        _didClickIncorrect = true;
        
        _onEventClickAnswer(tTriggers[1]);
        _answerTwo.inputEnabled = false;
        _answerTwo.setAsset(manifest.Texture.btn_quiz_2_incorrect);

      });
      
      _answerThree = tClipboard.addElement ( new Button( { asset: manifest.Texture.btn_quiz_2, x: 250, y: 0, scale:.9, tween:_tween, clear: _clearButtonInput}) );
      _answerThree.addElement ( new ImageSprite({ asset: _getTriggerAsset(tTriggers[2]), scale: 1.5  })).inputEnabled = false;
      _answerThree.eventDown.add( function () {

        WMSound.stopVO();
        WMSound.playSound(manifest.Sound.sofia_correct_1, .5);
        
        _onEventClickAnswer(tTriggers[2]);
        _answerThree.inputEnabled = false;
        _answerThree.setAsset(manifest.Texture.btn_quiz_2_correct);

        WMSound.playVO(_getDefintionVO(tTriggers[2]), "");
      });

      _definitionText = tClipboard.addElement(new Text( { text:manifest.localization.quiz2.Ids.definition, x:0, y:167 } ));
      _definitionText.setVariables(["Select all of the triggers!"]);
      _definitionText.inputEnabled = false;

      _acceptButton = _tray.addElement( new Button( { asset: manifest.Texture.btn_check_gray, x: ConstantsApp.STAGE_WIDTH/2 - 75, y: ConstantsApp.STAGE_HEIGHT/2 - 75, tween:_tween, clear: _clearButtonInput, scale: 1, alpha: 1 } ));
      _acceptButton.eventClick.add( _onEventClickPlay );
      _acceptButton.inputEnabled = false;

      _menuOptions = _tray.addElement( new MenuOptions( { }, "", manifest.Texture.popup_panel_short, "", _tween, _clearButtonInput, true, true ));

      WMSound.playVO(manifest.Sound.sofia_research_asthma_triggers_01, "");
      WMInput.eventInput.add(_generalInput);
      
      app.GoogleAnalytics.LogEvent("Progress_web", { 'event_label': "9: Quiz #2"});
      // app.GoogleAnalytics.LogEvent("Progress", { 'event_label': "Progress", "screen":"9: Quiz #2"});
  }

  public override function update(dt:Float) : Void {
      super.update(dt);
  }

  public override function dispose() : Void {
    _tray = null;
    _backgroundTray = null;

    _menuOptions = null;
    _acceptButton = null;
    _questionBacking = null;
    _answerOne = null;
    _answerTwo = null;
    _answerThree = null;
    _definitionText = null;
  
    _acceptableAllergens = [];

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

  private function _onEventClickAnswer(pTriggerType : ALLERGEN_TYPE) : Void {
    _setDefinition(pTriggerType);
    if (_acceptableAllergens.indexOf(pTriggerType) != -1) _clickDefinition();
  }

  private function _getTriggerOptions () : Array<ALLERGEN_TYPE> {
    var tSelectedTriggers = PlayerData.selectedAllergens;
    // var tSelectedTriggers = [ALLERGEN_TYPE.CAR, ALLERGEN_TYPE.DUCK, ALLERGEN_TYPE.COLD, ALLERGEN_TYPE.BROCCOLI, ALLERGEN_TYPE.CIGARETTE];
    var tReturnTriggers = [ALLERGEN_TYPE.CAR, ALLERGEN_TYPE.DUCK, ALLERGEN_TYPE.COLD];
    var tFirstSpotTaken = false;

    for(i in 0...tSelectedTriggers.length) {
      if (_acceptableAllergens.indexOf(tSelectedTriggers[i]) != -1) {
        if (!tFirstSpotTaken) {
          tFirstSpotTaken = true;
          tReturnTriggers[0] = tSelectedTriggers[i];
        } else {
          tReturnTriggers[2] = tSelectedTriggers[i];
        }
      } else {
        tReturnTriggers[1] = tSelectedTriggers[i];
      }
    }

    return tReturnTriggers;
  }
  private function _getTriggerAsset (pType : ALLERGEN_TYPE) : String {
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

  private function _getDefintionVO (pType : ALLERGEN_TYPE) : String {
    switch(pType) {
      case BIRD:
        return "";
      case BROCCOLI:
        return "";
      case CAR:
        return manifest.Sound.sofia_experiment_cars;
      case CIGARETTE:
        return manifest.Sound.sofia_experiment_fire;
      case COLD:
        return manifest.Sound.sofia_experiment_cold;
      case DUCK:
        return "";
      case EXERCISE:
        return manifest.Sound.sofia_experiment_exercise;
      case FIRE:
        return manifest.Sound.sofia_experiment_fire_alt;
      case PERFUME:
        return manifest.Sound.sofia_experiment_perfume;
      case POLLUTION:
        return manifest.Sound.sofia_experiment_factory;
      case POND:
        return "";
      case SPORTS:
        return manifest.Sound.sofia_experiment_exercise;
      case UFO:
        return "";
      default:
        return manifest.Sound.sofia_experiment_cars;
    }
  }

  private function _setDefinition (pType : ALLERGEN_TYPE) : Void {
    switch(pType) {
      case BIRD:
        _definitionText.setVariables(["Actually, birds are not a\ntrigger for asthma."]);
      case BROCCOLI:
        _definitionText.setVariables(["Actually, broccoli is not a\ntrigger for asthma."]);
      case CAR:
        _definitionText.setVariables(["Correct! Car exhaust is an\nasthma trigger!"]);
      case CIGARETTE:
        _definitionText.setVariables(["Correct! Cigarette smoke is\nan asthma trigger!"]);
      case COLD:
        _definitionText.setVariables(["Correct! Cold air is an asthma\ntrigger!"]);
      case DUCK:
        _definitionText.setVariables(["Actually, ducks are not a\ntrigger for asthma."]);
      case EXERCISE:
        _definitionText.setVariables(["Correct! Exercise can be an\nasthma trigger!"]);
      case FIRE:
        _definitionText.setVariables(["Correct! Smoke is an asthma\ntrigger!"]);
      case PERFUME:
        _definitionText.setVariables(["Correct! Perfume can be an\nasthma trigger!"]);
      case POLLUTION:
        _definitionText.setVariables(["Correct! Pollution is an\nasthma trigger!"]);
      case POND:
        _definitionText.setVariables(["Actually, fish are not a\ntrigger for asthma."]);
      case SPORTS:
        _definitionText.setVariables(["Correct! Sports can be an\nasthma trigger!"]);
      case UFO:
        _definitionText.setVariables(["Actually, UFO's are not a\ntrigger for asthma."]);
      default:
        _definitionText.setVariables(["Correct! Car exhaust is an\nasthma trigger!"]);
    }
  }
  private function _clickDefinition () : Void {
    _answers++;

    if (_answers >= 2) {
      _acceptButton.setAsset(manifest.Texture.btn_check);
      _acceptButton.inputEnabled = true;
    }

    // _instructionIn = true;
    // _tween.tween( { target: _definitionBar, duration: .4, delay: 0, ease: Ease.outQuad }, { y: ConstantsApp.STAGE_CENTER_Y - 87 } );
  }
  // private function _clearDefinition () : Void {
  //   // if (!_instructionIn) return;

  //   // _instructionIn = false;
  //   // _tween.tween( { target: _definitionBar, duration: .2, delay: 0, ease: Ease.outQuad }, { y: ConstantsApp.STAGE_CENTER_Y + 87 } );

  //   if (_answers >= 2) {
  //     if ( _closing == false ) {
  //       _closing = true;
  //       app.ConstantsEvent.addLoader.dispatch();
  //       app.ConstantsEvent.flow.dispatch( app.FLOW.CUTSCENE_DOCTOR_END );
  //     }
  //   }
  // }

  private function _onEventClickPlay() : Void {
    if (_answers >= 2) {
      if ( _closing == false ) {
        _closing = true;

        WMSound.stopVO();
        WMSound.playSound(manifest.Sound.sofia_click_confirm);

        app.GoogleAnalytics.LogEvent("Quiz 2 Answer_web", { 'event_label': _didClickIncorrect ? "1 incorrect" : "all correct"});  

        app.ConstantsEvent.addLoader.dispatch();
        app.ConstantsEvent.flow.dispatch( app.FLOW.CUTSCENE_DOCTOR_END );
      }
    }
  }
}