package screen;

import workinman.display.spine.SpineElement;
import workinman.display.ImageSprite;
import workinman.display.Sprite;
import workinman.tween.Ease;
import workinman.ui.ScreenBase;
import workinman.ui.Button;
import workinman.WMSound;
import world.elements.MenuOptions;
import world.elements.AvatarObj;
import app.ConstantsApp;
import app.PlayerData;
import workinman.WMInput;
import app.INPUT_TYPE;

class ScreenCutsceneDoctorStart extends ScreenBase {

  private var _tray                   : ImageSprite;
  private var _clickTray			        : Button;

  private var _menuOptions             : MenuOptions;
  private var _clickableTextContainer1  : Button;
  private var _definitionBar            : ImageSprite;
  private var _avatar                   : AvatarObj;
  private var _sofia                    : SpineElement;

  private var _instructionIn          : Bool = false;
  private var _nextButton             : ImageSprite;
  private var _nextButtonHitbox             : Button;

  public function new( pRoot:Sprite ) : Void {
    trace("CUTSCENE ENDING building");
    super( pRoot );
  }
  
  private override function _buildScreen() : Void {
      super._buildScreen();
      _closing = false;

      _tray = _elementManager.addElement ( new ImageSprite({}));
      _tray.addElement ( new ImageSprite( { asset: manifest.Texture.doctors_office_start, scale: 1} ));

      _avatar = _tray.addElement ( new AvatarObj({x: 80, y: 161, scale:.35}, PlayerData.avatarSettings, _tween));
      _avatar.animate("wave", 1);
      _avatar.queueAnimation("write_in", 1);
      _avatar.queueAnimation("write_idle");

      _sofia = _tray.addElement ( new SpineElement({library: manifest.spine.sofia.Info.name, scale:.35, x:390, y:150}));
      _sofia.animate("doctors_office_start");

      _definitionBar = _tray.addElement ( new ImageSprite( { asset: manifest.Texture.popup_asthmatriggers, y:ConstantsApp.STAGE_CENTER_Y + 87, scale: 1 } ));

      _clickTray = _tray.addElement( new Button( { tween:_tween, clear: _clearButtonInput } ));
      _clickTray.setCustomHitBox(ConstantsApp.STAGE_WIDTH, ConstantsApp.STAGE_HEIGHT);
      _clickTray.eventClick.add( _clearDefinition );
      
      _nextButton = _tray.addElement(new ImageSprite({asset: manifest.Texture.btn_next_side, x:ConstantsApp.STAGE_CENTER_X - 44, y:0, scale:.5}));
      _nextButtonHitbox = _nextButton.addElement(new Button({asset: manifest.Texture.btn_next_side_arrow, tween:_tween, clear:_clearButtonInput }));
      _nextButtonHitbox.setCustomHitBox(200, 1440);
      _nextButtonHitbox.eventClick.add( _onEventClickPlay );

      _clickableTextContainer1 = _tray.addElement(new Button({x:-305, y:5, tween:_tween, clear:_clearButtonInput}));
      _clickableTextContainer1.setCustomHitBox(375, 80);
      _clickableTextContainer1.eventDown.add(function() {
        if (!_instructionIn)
          _clickDefinition();
        else
          _clearDefinition();
      });

      _menuOptions = _tray.addElement( new MenuOptions( { }, "", manifest.Texture.avatar_popup, "", _tween, _clearButtonInput, true, true ));

      WMSound.playVO(manifest.Sound.sofia_park_01, "");
      WMInput.eventInput.add(_generalInput);

      app.GoogleAnalytics.LogEvent("Progress_web", { 'event_label': "5: Cutscene #3"});
      // app.GoogleAnalytics.LogEvent("Progress", { 'event_label': "Progress", "screen":"5: Cutscene #3"});
  }

  public override function update(dt:Float) : Void {
      super.update(dt);
  }
  
  public override function dispose() : Void {
    _tray = null;
    _clickTray = null;
  
    _clickableTextContainer1 = null;
    _definitionBar = null;
    _sofia = null;
    _nextButton = null;
    _nextButtonHitbox = null;

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

  private function _onEventClickPlay() {
    if ( _closing == false ) {
      _closing = true;

      WMSound.stopVO();
      
      app.ConstantsEvent.addLoader.dispatch();
      app.ConstantsEvent.flow.dispatch( app.FLOW.IMAGE_HUNT );
    }
  }

  public function _clickDefinition () : Void {

    WMSound.stopVO();
    WMSound.playSound(manifest.Sound.sofia_click);

    _instructionIn = true;
    _tween.tween( { target: _definitionBar, duration: .4, delay: 0, ease: Ease.outQuad }, { y: ConstantsApp.STAGE_CENTER_Y - 87 } );

    WMSound.playVO(manifest.Sound.sofia_asthma_trigger_definition, "");

    app.GoogleAnalytics.LogEvent("Clicked Definition_web", { 'event_label':"asthma triggers"});
  }
  public function _clearDefinition () : Void {
    if (!_instructionIn) return;

    WMSound.stopVO();
    
    _instructionIn = false;
    _tween.tween( { target: _definitionBar, duration: .2, delay: 0, ease: Ease.outQuad }, { y: ConstantsApp.STAGE_CENTER_Y + 87 } );
  }
}