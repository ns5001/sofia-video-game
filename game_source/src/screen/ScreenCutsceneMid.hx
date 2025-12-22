package screen;

import workinman.display.spine.SpineElement;
import workinman.display.ImageSprite;
import workinman.display.Sprite;
import workinman.tween.Ease;
import world.elements.MenuOptions;
import world.elements.AvatarObj;
import workinman.ui.ScreenBase;
import workinman.ui.Button;
import workinman.WMSound;
import app.ConstantsApp;
import app.PlayerData;
import workinman.WMInput;
import app.INPUT_TYPE;

class ScreenCutsceneMid extends ScreenBase {

  private var _tray                     : ImageSprite;
  private var _clickTray			          : Button;

  private var _menuOptions             : MenuOptions;
  private var _storyPage                : ImageSprite;
  private var _nextButton               : ImageSprite;
  private var _nextButtonHitbox             : Button;
  private var _pageIndex                : Int = 0;

  private var _clickableTextContainer1  : Button;
  private var _definitionBar            : ImageSprite;

  private var _instructionIn          : Bool = false;
  private var _avatar                   : AvatarObj;
  private var _sofia                    : SpineElement;

  public function new( pRoot:Sprite ) : Void {
    trace("CUTSCENE ENDING building");
    super( pRoot );
  }
  
  private override function _buildScreen() : Void {
      super._buildScreen();
      _closing = false;

      _tray = _elementManager.addElement ( new ImageSprite({}));

      _storyPage = _tray.addElement ( new ImageSprite( { asset: manifest.Texture.story_6 } ));

      _avatar = _tray.addElement ( new AvatarObj({x: -100, y: 160, scale:.32, scaleX:-.32 }, PlayerData.avatarSettings, _tween, true));
      _avatar.animate("write_idle");

      _tray.addElement ( new ImageSprite( { asset: manifest.Texture.survey_prop, x: -200, y: 90 } ));

      _sofia = _tray.addElement ( new SpineElement({library: manifest.spine.sofia.Info.name, scale:.32, x:-430, y:188 }));
      _sofia.animate("park_idle");
      
      _definitionBar = _tray.addElement ( new ImageSprite( { asset: manifest.Texture.story_popup_survey, y:ConstantsApp.STAGE_CENTER_Y + 87, scale: 1 } ));

      _clickTray = _tray.addElement( new Button( { tween:_tween, clear: _clearButtonInput } ));
      _clickTray.setCustomHitBox(ConstantsApp.STAGE_WIDTH, ConstantsApp.STAGE_HEIGHT);
      _clickTray.eventClick.add( _clearDefinition );

      _nextButton = _tray.addElement(new ImageSprite({asset: manifest.Texture.btn_next_side, x:ConstantsApp.STAGE_CENTER_X - 44, y:0, scale:.5}));
      _nextButtonHitbox = _nextButton.addElement(new Button({asset: manifest.Texture.btn_next_side_arrow, tween:_tween, clear:_clearButtonInput }));
      _nextButtonHitbox.setCustomHitBox(200, 1440);
      _nextButtonHitbox.eventClick.add( _clickNextButton );

      _clickableTextContainer1 = _tray.addElement(new Button({x:150, y:-152, tween:_tween, clear:_clearButtonInput}));
      _clickableTextContainer1.setCustomHitBox(160, 55);
      _clickableTextContainer1.eventDown.add(function() {
        if (!_instructionIn)
          _clickDefinition();
        else
          _clearDefinition();
      });

      _menuOptions = _tray.addElement( new MenuOptions( { }, "", manifest.Texture.avatar_popup, "", _tween, _clearButtonInput, true, true ));

      WMSound.playVO(manifest.Sound.sofia_outro_01, "");
      WMInput.eventInput.add(_generalInput);

      app.GoogleAnalytics.LogEvent("Progress_web", { 'event_label': "7: Cutscene #4"});
      // app.GoogleAnalytics.LogEvent("Progress", { 'event_label': "Progress", "screen":"7: Cutscene #4"});
  }

  public override function update(dt:Float) : Void {
      super.update(dt);
  }
  
  public override function dispose() : Void {
    
    super.dispose();

    _tray = null;
    _clickTray = null;
  
    _menuOptions = null;
    _storyPage = null;
    _nextButton = null;
    _nextButtonHitbox = null;
    _clickableTextContainer1 = null;
    _definitionBar = null;

    WMInput.eventInput.remove(_generalInput);
  
    _sofia = null;
    // _avatar.dispose();
  }
    
  private function _generalInput(pType:INPUT_TYPE , pDown:Bool) : Void {
    switch ( pType ) {
      case INPUT_TYPE.POINTER:
        if ( pDown )
          _menuOptions.resetCountdown();
      default:
    }
  }

  private function _onEventAdvanceScreen() {
    if ( _closing == false ) {
      _closing = true;

      WMSound.stopVO();
      
      app.ConstantsEvent.addLoader.dispatch();
      app.ConstantsEvent.flow.dispatch( app.FLOW.EXPERIMENT );
    }
  }

  public function _clickNextButton() : Void {
    _pageIndex++;
    switch(_pageIndex) {
      case 1:
        _onEventAdvanceScreen();
    }
  }

  public function _clickDefinition () : Void {

    WMSound.stopVO();
    WMSound.playSound(manifest.Sound.sofia_click);

    _instructionIn = true;
    _tween.tween( { target: _definitionBar, duration: .4, delay: 0, ease: Ease.outQuad }, { y: ConstantsApp.STAGE_CENTER_Y - 87 } );

    WMSound.playVO(manifest.Sound.sofia_survey_definition, "");

    app.GoogleAnalytics.LogEvent("Clicked Definition_web", { 'event_label':"survey"});
  }
  public function _clearDefinition () : Void {
    if (!_instructionIn) return;

    WMSound.stopVO();
    
    _instructionIn = false;
    _tween.tween( { target: _definitionBar, duration: .2, delay: 0, ease: Ease.outQuad }, { y: ConstantsApp.STAGE_CENTER_Y + 87 } );
  }
}