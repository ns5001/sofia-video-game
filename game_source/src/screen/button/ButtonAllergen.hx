package screen.button;

import workinman.ui.ButtonProp;
import workinman.ui.Button;
import app.ConstantsEvent;
import app.ALLERGEN_TYPE;

class ButtonAllergen extends Button {

    public var type         : ALLERGEN_TYPE;
    public var collected    : Bool = false;
    public var index        : Int;

    public function new( pData:ButtonProp, pType:ALLERGEN_TYPE, pIndex:Int, ?pCallback:Void->Void = null) : Void {
        super(pData);

        type = pType;
        index = pIndex;

        eventDown.add( _select );
        if (pCallback != null) {
            eventDown.add( pCallback );
        }
    }

    private function _select() {
        if (collected)
            return;

        collected = true;

        ConstantsEvent.selectAllergen.dispatch(type, index);
    }

    public function release() {
        visible = true;
        collected = false;
    }
}