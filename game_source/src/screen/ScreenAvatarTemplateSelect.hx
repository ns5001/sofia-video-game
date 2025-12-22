package screen;

import workinman.ui.ScreenBase;
import workinman.display.Sprite;
import workinman.display.Text;
import workinman.display.ImageSprite;
import workinman.tween.TweenUtils;
import flambe.display.Font;
import workinman.WMTimer;
import workinman.WMSound;
import workinman.tween.Ease;
import app.ConstantsApp;
import workinman.ui.Button;
import workinman.display.spine.SpineElement;
import workinman.WMSound;

class ScreenAvatarTemplateSelect extends ScreenBase {

  private var _tray                   : ImageSprite;
  private var _clickTray			        : Button;

  public function new( pRoot:Sprite ) : Void {
    trace("CUTSCENE ENDING building");
    super( pRoot );
  }
  
  private override function _buildScreen() : Void {
      super._buildScreen();
      _closing = false;

      _tray = _elementManager.addElement ( new ImageSprite({}));
      _tray.addElement ( new ImageSprite( { asset: manifest.Texture.doctors_office_start, scale: 1} ));
      _clickTray = _tray.addElement( new Button( { asset: manifest.Texture.doctors_office_start, x: 0, y: 0, tween:_tween, clear: _clearButtonInput, scale: 1, alpha: 0 } ));
      _clickTray.eventClick.add( _onEventClickPlay );
      
  }

  public override function update(dt:Float) : Void {
      super.update(dt);
  }
  
  public override function dispose() : Void {
      super.dispose();
  }

  private function _onEventClickPlay() {
    if ( _closing == false ) {
      _closing = true;
      app.ConstantsEvent.addLoader.dispatch();
      app.ConstantsEvent.flow.dispatch( app.FLOW.IMAGE_HUNT );
    }
  }
}