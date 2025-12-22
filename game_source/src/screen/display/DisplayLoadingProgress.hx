package screen.display;

import workinman.display.spine.SpineElement;
import workinman.display.ImageSprite;
import workinman.display.FillSprite;
import workinman.tween.TweenUtils;
import workinman.ui.DisplayProp;
import workinman.ui.Display;
import workinman.WMSound;
import app.ConstantsApp;

class DisplayLoadingProgress extends Display {

	private var _active 	: Bool;
	private var _scale 		: Float;

	private var _spine : SpineElement;
	private var _currentString : String = "";

	public function new( pData:DisplayProp ) : Void {
		super( pData );

		_active = false;
		_scale = 0.5;

		// addElement( new ImageSprite( { asset:manifest.Texture.loading_background, scale: 1, alpha: 1} ));

		// Create the loading overlay
        _spine = addElement( new SpineElement( { library:manifest.spine.transition.Info.name, scale:_scale } ));
		_spine.animate( manifest.spine.loading.Anim.loading, 0, 1, 2 );

		// addElement( new FillSprite( { color:0x000000, sizeX:ConstantsApp.STAGE_WIDTH,  sizeY:ConstantsApp.STAGE_HEIGHT, alpha:1 } ) );

		alpha = 0;
	}

	public override function dispose() : Void {
		super.dispose();
	}

	public var active( get_active, never ) : Bool;
	private function get_active() : Bool { return _active; }

	public override function update( dt:Float ) : Void {
		super.update(dt);
	}

	public function tweenIn( pReset:Bool ) : Void {
		if ( _active ) { return; }

		// Do cool intro tweens/transitions
		TweenUtils.easeFadeIn( this, _tween );
        _spine.animate( manifest.spine.transition.Anim.intro, 1, 1, 1 ).eventAnimationComplete.add(function() {
			_spine.animate( manifest.spine.transition.Anim.middle_loop );
		});
		// workinman.WMSound.playSound(manifest.Sound.PAW_Ocean_Bubble_Transition, 2, null, true);

		_active = true;
	}

	public function tweenOut() : Void {
		if ( _active == false ) {
			return;
		}

		WMSound.stopSound(_currentString);

		// Do cool outro tweens/transitions
		TweenUtils.easeFadeOut( this, _tween );
        _spine.animate( manifest.spine.transition.Anim.outro, 1, 1, 1 );

		// stopBounce();
		_active = false;
    }
}
