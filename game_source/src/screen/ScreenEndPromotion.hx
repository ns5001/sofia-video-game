package screen;

import workinman.display.spine.SpineElement;
import workinman.display.ImageSprite;
import workinman.display.Sprite;
import workinman.display.Text;
import workinman.ui.ScreenBase;
import workinman.ui.Button;
import world.elements.AvatarObj;
import workinman.WMSound;
import app.ConstantsApp;
import app.PlayerData;

class ScreenEndPromotion extends ScreenBase {

  private var _tray                   : ImageSprite;
  private var _clickTray			        : Button;

  private var _sofia                    : SpineElement;
  private var _avatar                   : AvatarObj;

  public function new( pRoot:Sprite ) : Void {
    trace("CUTSCENE ENDING building");
    super( pRoot );
  }

  private override function _buildScreen() : Void {
      super._buildScreen();
      _closing = false;

      _tray = _elementManager.addElement ( new ImageSprite({}));
      _tray.addElement ( new ImageSprite( { asset: manifest.Texture.endscreen, scale: 1 } ));

      _sofia = _tray.addElement ( new SpineElement({ library: manifest.spine.sofia.Info.name, x: -90, y: 224, scale: .35, scaleX: -.35 }) );
      _sofia.animate("splash");
      _avatar = _tray.addElement ( new AvatarObj({x: -340, y: 230, scale:.35}, PlayerData.avatarSettings, _tween));
      _avatar.animate("heroic_pose");

      var tX = 404;
      var tY = -185;

      // _tray.addElement(new Text( { text:manifest.localization.ending.Ids.part1, x: tX, y: tY - 85 } ));
      // _tray.addElement(new Text( { text:manifest.localization.ending.Ids.part2, x: tX, y: tY + 0 } ));
      // _tray.addElement(new Text( { text:manifest.localization.ending.Ids.part3, x: tX, y: tY + 65 } ));

      //_tray.addElement ( new ImageSprite( { asset: manifest.Texture.qr_code_2, scale: .33, x: tX, y: 35 } ));
      _clickTray = _tray.addElement( new Button( { x: 0, y: 0, tween:_tween, clear: _clearButtonInput, scale: 1, alpha: 0 } ));
      _clickTray.setCustomHitBox(ConstantsApp.STAGE_WIDTH, ConstantsApp.STAGE_HEIGHT);
      _clickTray.eventClick.add( _onEventClickPlay );
      

      var _button = _tray.addElement( new Button({ asset: manifest.Texture.popup_panel_short, x:tX, y:tY, tween:_tween, clear: _clearButtonInput, scale:0.8}));
      _button.addElement(new ImageSprite({asset:manifest.Texture.button_website, x: -250, scale:1.3})).inputEnabled = false;
		  _button.addElement(new Text( { text:manifest.localization.ending.Ids.link, x: 30,y:5} ));
      _button.eventClick.add(_onEventClickLink);

      
      
      WMSound.playVO(manifest.Sound.sofia_thanks_for_playing, "");

      app.GoogleAnalytics.LogEvent("Progress_web", { 'event_label': "12: Endscreen"});
      // app.GoogleAnalytics.LogEvent("Progress", { 'event_label': "Progress", "screen":"12: Endscreen"});
  }

  public override function update(dt:Float) : Void {
      super.update(dt);
  }
  
  public override function dispose() : Void {

    _tray = null;
    _clickTray = null;
  
    _sofia = null;

      super.dispose();
  }

  private function _onEventClickPlay() {
    if ( _closing == false ) {

      WMSound.stopVO();
      
      _closing = true;

      app.GoogleAnalytics.LogEvent("Completion_web", { 'event_label':"finished"});

      app.ConstantsEvent.addLoader.dispatch();
      app.ConstantsEvent.flow.dispatch( app.FLOW.ATTRACT_PLAY );
    }
  }

  private function _onEventClickLink() {
    if (_closing == false) {
      // TODO analytics for link click
      app.GoogleAnalytics.LogEvent("Completion_web", { 'event_label':"link"});
    untyped {
      window.open("https://www.research.buffalo.edu/sofia/", "_blank");
    }
    }
  }
}