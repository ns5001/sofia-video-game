package screen.button;

import workinman.display.ImageSprite;
import workinman.tween.Tweener;
import workinman.ui.Button;

class ButtonMenu extends ImageSprite {

    public var focus : ImageSprite;
    public var button : Button;

    public var targetAsset : String = "";
    public var altHighlight : String = "";
    public var isFocused : Bool;

    public function new( pProp:MenuButtonProp, ?pCallback:Void->Void = null) : Void {
        super({x: pProp.x, y: pProp.y, scale: pProp.scale, alpha: pProp.alpha});

        focus = addElement(new ImageSprite( { asset: pProp.highlight, alpha: 0 } ));
        button = addElement(new Button( { asset: pProp.asset, tween: pProp.tween, clear: pProp.clear}));
        targetAsset = pProp.asset;
        altHighlight = pProp.alt;

        // button.eventDown.add( _click );
        if (pCallback != null) {
            button.eventDown.add( pCallback );
        }
    }

    public function setButtonAsset(pNewAsset:String) : Void {
        button.setAsset(pNewAsset);
    }

    public function select() : Void {
        if (altHighlight != null) {
            button.asset = altHighlight;
        } else {
            focus.alpha = 1;
        }

        // ConstantsEvent.pickupSticker.dispatch(this);
    }

    public function deselect() : Void {
        if (altHighlight != null) {
            button.asset = targetAsset;
        } else {
            focus.alpha = 0;
        }
    }
}

typedef MenuButtonProp = {
	tween : Tweener,
	clear : Void->Bool,
	?asset:String,
	?alt:String,
	?highlight:String,
	?alpha:Float,
	?scale:Float,
	?x:Float,
	?y:Float,
}