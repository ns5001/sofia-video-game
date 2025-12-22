package screen.button;

import workinman.display.spine.SpineElement;
import workinman.display.ImageSprite;
import workinman.tween.TweenUtils;
import workinman.tween.Tweener;
import workinman.tween.Ease;
import workinman.ui.Button;
import app.ConstantsEvent;

class ButtonSlot extends ImageSprite {

    public var slot         : SpineElement;
    public var button       : Button;
    public var allergen     : ImageSprite;

    public var full         : Bool = false;
    public var reserved     : Bool = false;
    private var _index      : Int;
	private var _tween		: Tweener;

    public function new( pProp:SlotButtonProp, ?pCallback:Void->Void = null) : Void {
        super({x: pProp.x, y: pProp.y, scale: pProp.scale, alpha: pProp.alpha});

        _tween = pProp.tween;

        slot = addElement (new SpineElement({ library: manifest.spine.park_effect.Info.name }));
        button = addElement(new Button( { tween: pProp.tween, clear: pProp.clear}));
        button.setCustomHitBox(200, 150).disable();
        button.eventDown.add( _empty );

        // button.eventDown.add( _click );
        if (pCallback != null) {
            button.eventDown.add( pCallback );
        }
    }

    public function collect( pAllergen : String, pPos : Dynamic, pIndex : Int ) {
        reserved = false;
        full = true;

        // var startPos = pPos;
        var startPos = {
            x : (pPos.x - x) * (1/scale),
            y : (pPos.y - y) * (1/scale)
        }

        _index = pIndex;

        allergen = addElement (new ImageSprite({
          asset: pAllergen, x: startPos.x, y: startPos.y, scale:0
        }));
        allergen.inputEnabled = false;

        // normalize travel time
        var tDiff = {
            x: startPos.x * startPos.x,
            y: startPos.y * startPos.y,
        }

        var tDuration = Math.sqrt(tDiff.x + tDiff.y) / 1000; // divided by average distance

        _tween.tween( { target: allergen, duration: .4, delay: 0, ease: Ease.inBounce }, { scale: 2.8 } );
        _tween.tween( { target: allergen, duration: .2, delay: 0, ease: Ease.inBack }, { scale: 2 } );
        _tween.tween( { target: allergen, duration: .25 * tDuration, delay: 0, ease: Ease.linear, complete:function() {
            slot.animate("clipboard", 1).eventAnimationComplete.add( function () {
                slot.animate("known_idle");
                button.enable();
            });
        }}, { x: 0, y: 0 } );
    }

    public function collectImmediate( pAllergen : String, pIndex : Int ) {
        reserved = false;
        full = true;

        _index = pIndex;

        allergen = addElement (new ImageSprite({ asset: pAllergen, x: 0, y: 0, scale: 2 }));
        allergen.inputEnabled = false;

        slot.animate("clipboard", 1).eventAnimationComplete.add( function () {
            slot.animate("known_idle");
            button.enable();
        });
    }

    private function _empty() : Void {
        
        full = false;

        allergen.alpha = 0;
        slot.animate("clipboard_remove", 1).eventAnimationComplete.add( function () {
            slot.animate("unknown_idle");
        });

        ConstantsEvent.releaseAllergen.dispatch(_index);
    }
}

typedef SlotButtonProp = {
	tween : Tweener,
	clear : Void->Bool,
	?alpha:Float,
	?scale:Float,
	?x:Float,
	?y:Float,
}