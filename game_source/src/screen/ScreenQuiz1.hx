package screen;

import world.elements.MenuOptions;
import workinman.display.ImageSprite;
import workinman.display.Sprite;
import workinman.display.Text;
import workinman.tween.Ease;
import workinman.ui.ScreenBase;
import workinman.ui.Button;
import workinman.WMSound;
import app.ConstantsApp;
import workinman.WMInput;
import app.INPUT_TYPE;

class ScreenQuiz1 extends ScreenBase {
  private var _tray                     : ImageSprite;
  private var _clickTray			          : Button;
  private var _backgroundTray		        : ImageSprite;

  private var _menuOptions             : MenuOptions;
  private var _questionBacking		      : ImageSprite;
  private var _answerOne      		      : Button;
  private var _answerTwo       		      : Button;

  private var _definitionBar            : ImageSprite;
  private var _definitionText           : Text;
  private var _instructionIn            : Bool = false;
  private var _firstAnswer              : String = "";

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

      _menuOptions = _tray.addElement( new MenuOptions( { }, "", manifest.Texture.popup_panel_short, "", _tween, _clearButtonInput, true, true ));

      _definitionBar = _backgroundTray.addElement ( new ImageSprite( { asset: manifest.Texture.popup_panel, y:ConstantsApp.STAGE_CENTER_Y + 87, scale: 1 } ));
      _definitionText = _definitionBar.addElement(new Text( { text:manifest.localization.quiz1.Ids.research_study, x:0, y:10 } ));

      _clickTray = _backgroundTray.addElement( new Button( { tween:_tween, clear: _clearButtonInput } ));
      _clickTray.setCustomHitBox(ConstantsApp.STAGE_WIDTH, ConstantsApp.STAGE_HEIGHT);
      _clickTray.eventClick.add( _clearDefinition );

      _questionBacking = _backgroundTray.addElement ( new ImageSprite({ asset: manifest.Texture.quiz_question_1, x: -5, y:-170, scale: 1 }));
      
      _answerOne = _backgroundTray.addElement ( new Button( { asset: manifest.Texture.btn_quiz_1_true, x: -212, y: 100, tween:_tween, clear: _clearButtonInput}) );
      _answerOne.eventDown.add( function () {
        WMSound.playSound(manifest.Sound.sofia_correct_1, .5);
        WMSound.stopVO();

        if (_firstAnswer == "") _firstAnswer = "correct";

        _onEventClickAnswer();
        _answerOne.inputEnabled = _answerTwo.inputEnabled = false;

        WMSound.playVO(manifest.Sound.sofia_correct_research_study, "");
      });

      _answerTwo = _backgroundTray.addElement ( new Button( { asset: manifest.Texture.btn_quiz_1_false, x: 216, y: 100, tween:_tween, clear: _clearButtonInput}) );
      _answerTwo.eventDown.add( function () {
        WMSound.playSound(manifest.Sound.sofia_incorrect_1, .5);
        WMSound.stopVO();

        _answerTwo.inputEnabled = false;

        if (_firstAnswer == "") _firstAnswer = "incorrect";

        WMSound.playVO(manifest.Sound.sofia_wrong_research_study, "");
      });

      WMSound.playVO(manifest.Sound.sofia_question_research_study, "");
      WMInput.eventInput.add(_generalInput);
      
      app.GoogleAnalytics.LogEvent("Progress_web", { 'event_label': "2: Quiz #1"});
      // app.GoogleAnalytics.LogEvent("Progress", { 'event_label': "Progress", "screen":"2: Quiz #1"});
  }

  public override function update(dt:Float) : Void {
      super.update(dt);
  }

  public override function dispose() : Void {
    _tray                     = null;
    _clickTray			          = null;
    _backgroundTray		        = null;
  
    _questionBacking		      = null;
    _answerOne      		      = null;
    _answerTwo       		      = null;
    _definitionBar            = null;
    _menuOptions = null;

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

  private function _onEventClickAnswer() : Void {
    _clickDefinition();
  }
  private function _clickDefinition () : Void {
    _instructionIn = true;
    _tween.tween( { target: _definitionBar, duration: .4, delay: 0, ease: Ease.outQuad }, { y: ConstantsApp.STAGE_CENTER_Y - 87 } );
  }
  private function _clearDefinition () : Void {
    if (!_instructionIn) return;
    
    WMSound.stopVO();

    _instructionIn = false;
    _tween.tween( { target: _definitionBar, duration: .2, delay: 0, ease: Ease.outQuad }, { y: ConstantsApp.STAGE_CENTER_Y + 87 } );

    if ( _closing == false ) {
      _closing = true;

      app.GoogleAnalytics.LogEvent("Quiz 1 Answer_web", {'event_label':_firstAnswer});

      app.ConstantsEvent.addLoader.dispatch();
      app.ConstantsEvent.flow.dispatch( app.FLOW.CUTSCENE_SURVEY );
    }
  }
}