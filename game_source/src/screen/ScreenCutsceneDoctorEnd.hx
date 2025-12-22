package screen;

import workinman.display.spine.SpineElement;
import workinman.display.ImageSprite;
import workinman.display.Sprite;
import world.elements.MenuOptions;
import world.elements.AvatarObj;
import workinman.ui.ScreenBase;
import workinman.ui.Button;
import workinman.WMSound;
import app.ConstantsApp;
import app.PlayerData;
import workinman.WMInput;
import app.INPUT_TYPE;

class ScreenCutsceneDoctorEnd extends ScreenBase {

  private var _tray                   : ImageSprite;
  private var _nextButton             : ImageSprite;
  private var _nextButtonHitbox       : Button;

  private var _menuOptions             : MenuOptions;
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
      _tray.addElement ( new ImageSprite( { asset: manifest.Texture.doctors_office_end, scale: 1 } ));

      _avatar = _tray.addElement ( new AvatarObj({x: 40, y: 175, scale:.35}, PlayerData.avatarSettings, _tween));
      _avatar.animate("idle");

      _sofia = _tray.addElement ( new SpineElement({library: manifest.spine.sofia.Info.name, scale:.35, x:330, y:175}));
      _sofia.animate("doctors_office_end");
      
      _nextButton = _tray.addElement(new ImageSprite({asset: manifest.Texture.btn_next_side, x:ConstantsApp.STAGE_CENTER_X - 44, y:0, scale:.5}));
      _nextButtonHitbox = _nextButton.addElement(new Button({asset: manifest.Texture.btn_next_side_arrow, tween:_tween, clear:_clearButtonInput }));
      _nextButtonHitbox.setCustomHitBox(200, 1440);
      _nextButtonHitbox.eventClick.add( _onEventClickPlay );

      _menuOptions = _tray.addElement( new MenuOptions( { }, "", manifest.Texture.avatar_popup, "", _tween, _clearButtonInput, true, true ));

      WMSound.playVO(manifest.Sound.sofia_conclusion, "");

      WMInput.eventInput.add(_generalInput);

      app.GoogleAnalytics.LogEvent("Progress_web", { 'event_label': "10: Cutscene #5"});
      // app.GoogleAnalytics.LogEvent("Progress", { 'event_label': "Progress", "screen":"10: Cutscene #5"});
  }

  public override function update(dt:Float) : Void {
      super.update(dt);
  }
  
  public override function dispose() : Void {
    _tray = null;
    _nextButton = null;
    _nextButtonHitbox = null;
    
    _sofia = null;

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
      app.ConstantsEvent.flow.dispatch( app.FLOW.QUIZ3 );
    }
  }
}