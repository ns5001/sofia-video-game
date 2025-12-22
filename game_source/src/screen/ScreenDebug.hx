package screen;

import workinman.ui.ScreenBase;
import workinman.ui.Button;
import workinman.display.Sprite;
import workinman.display.FillSprite;
import workinman.display.Text;
import workinman.tween.TweenUtils;
import app.INPUT_TYPE;
import app.ConstantsApp;

class ScreenDebug extends ScreenBase {

	// ************************************************************
	// LOOK DOWN AT THE END OF THE CLASS FOR THE BUILD BUTTONS
	// FUNCTION - ADD YOUR OWN DEBUG FUNCTIONALITY THERE! THANKS!
	// ************************************************************

	private var _tray : Sprite;

	public function new( pRoot:Sprite ) : Void {
		trace("DEBUG building");
		super( pRoot );
	}

	private override function _buildScreen() : Void {
        super._buildScreen();
        
		// Create containers (helps with tweens!)
		_tray = _elementManager.addElement(new FillSprite( { color:0x000000, sizeX:ConstantsApp.STAGE_WIDTH,  sizeY:ConstantsApp.STAGE_HEIGHT, alpha:.5 } ) );
		// _tray.root.addChild( new Entity().add(_fill) );
		_tray.alpha = 0;

		// Add the title
		// var tText : Text = _tray.addElement( new Text( { text:manifest.localization.debug.Ids.debugfield, y:-ConstantsApp.STAGE_CENTER_Y + 20, scale:.5 } ) );
		// tText.setVariables(["Debug Screen"]);
		// // Add the version number
		// tText = _tray.addElement( new Text( { text:manifest.localization.debug.Ids.debugfield, y:ConstantsApp.STAGE_CENTER_Y - 20, scale:.5 } ) );
		// tText.setVariables(["Game Version: " + ConstantsApp.GAME_VERSION]);
		// tText = null;

		// Add your buttons here
		_buildButtons();
	}

	public override function dispose() : Void {
		super.dispose();
		_tray = null;
	}

	private function _addButton( pText:String, pX:Float, pY:Float, pCallback:Void->Void ) : Void {
		var tButton : Button = _tray.addElement(new Button( { tween:_tween, clear:_clearButtonInput, assetUp:manifest.Texture.btn_home, x:pX-ConstantsApp.STAGE_CENTER_X,  y:pY-ConstantsApp.STAGE_CENTER_Y } ));
		tButton.eventClick.add( pCallback );
		// var tText : Text = tButton.addElement( new Text( { text:manifest.localization.debug.Ids.debugfield } ) );
		// tText.setVariables([pText]);
		tButton = null;
		// tText = null;
	}

	private override function _setInState() : Void {
		// Do cool intro tweens/transitions
		TweenUtils.easeBounceIn( _tray, _tween ).onComplete( _finishInState );
	}

	private override function _setCloseState() : Void {
		// Do cool outro tweens/transitions
		TweenUtils.easeBounceOut( _tray, _tween ).onComplete( _finishCloseState );
	}

	// ************************************************************
	// HERE'S WHERE YOU ADD YOUR OWN BUTTONS!
	// ************************************************************

	private function _buildButtons() : Void {
		// Close button
		_addButton( "X", 50, 50, _onCloseClick );
		// Other buttons
	}

	// ************************************************************
	// HERE'S WHERE YOU ADD YOUR BUTTON FUNCTIONALITY!
	// SET FLAGS OR TRACE DATA ON BUTTON CLICKS!
	// ************************************************************

	private function _onCloseClick() : Void {
		app.ConstantsEvent.flow.dispatch( app.FLOW.DEBUG_CLOSE);
	}
}
