package screen;

import world.elements.MenuOptions;
import workinman.display.ImageSprite;
import workinman.display.Sprite;
import workinman.ui.ScreenBase;
import workinman.ui.Button;
import workinman.WMSound;
import workinman.WMInput;
import app.INPUT_TYPE;

class ScreenQuiz3 extends ScreenBase {
  private var _tray                     : ImageSprite;
  private var _backgroundTray		        : ImageSprite;

  private var _menuOptions             : MenuOptions;
  private var _questionBacking		      : ImageSprite;
  private var _answerOne      		      : Button;
  private var _answerTwo       		      : Button;
  private var _answerThree       		    : Button;

  private var _selection                : String = "";

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

      _questionBacking = _backgroundTray.addElement ( new ImageSprite({ asset: manifest.Texture.quiz_question_3, x: -5, y:-157, scale: 1 }));
      
      _answerOne = _backgroundTray.addElement ( new Button( { asset: manifest.Texture.btn_quiz_3_notsure, x: -300, y: 150, tween:_tween, clear: _clearButtonInput, scale:.75}) );
      _answerOne.eventDown.add( function () {
        _selection = "not sure";
        _onEventClickAnswer(manifest.Sound.sofia_conclusion_quiz_notsure);
      } );

      _answerTwo = _backgroundTray.addElement ( new Button( { asset: manifest.Texture.btn_quiz_3_scientist, x: 0, y: 150, tween:_tween, clear: _clearButtonInput, scale:.75}) );
      _answerTwo.eventDown.add( function () {
        _selection = "scientist";
        _onEventClickAnswer(manifest.Sound.sofia_conclusion_quiz_scientist);
      } );
      
      _answerThree = _backgroundTray.addElement ( new Button( { asset: manifest.Texture.btn_quiz_3_sofia, x: 300, y: 150, tween:_tween, clear: _clearButtonInput, scale:.75}) );
      _answerThree.eventDown.add( function () {
        _selection = "participate";
        _onEventClickAnswer(manifest.Sound.sofia_conclusion_quiz_participant);
      } );
      
      WMSound.playVO(manifest.Sound.sofia_conclusion_quiz, "");

      WMInput.eventInput.add(_generalInput);

      app.GoogleAnalytics.LogEvent("Progress_web", { 'event_label': "11: Quiz #3"});
      // app.GoogleAnalytics.LogEvent("Progress", { 'event_label': "Progress", "screen":"11: Quiz #3"});
  }

  public override function update(dt:Float) : Void {
      super.update(dt);
  }

  public override function dispose() : Void {
    _tray = null;
    _backgroundTray = null;
  
    _menuOptions = null;
    _questionBacking = null;
    _answerOne = null;
    _answerTwo = null;
    _answerThree = null;

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

  private function _onEventClickAnswer(pAudio : String) : Void {
    if ( _closing == false ) {
      _closing = true;

      WMSound.stopVO();

      WMSound.playSound(manifest.Sound.sofia_correct_2);
      WMSound.playVO(pAudio, "", true, function () {
        app.GoogleAnalytics.LogEvent("Quiz 3 Answer_web", { 'event_label': _selection});  

        app.ConstantsEvent.addLoader.dispatch();
        app.ConstantsEvent.flow.dispatch( app.FLOW.ENDSCREEN );
      });
    }
  }
}