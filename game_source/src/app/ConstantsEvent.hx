package app;

import workinman.event.*;
import app.ALLERGEN_TYPE;

class ConstantsEvent {

    // COMMON
	public static var flow                          : Event1<String> = new Event1<String>();
	public static var resizeCanvas                  : Event1<Float> = new Event1<Float>();
	public static var updateDisplay                 : Event1<String> = new Event1<String>();
    public static var pause                         : Event1<Bool> = new Event1<Bool>();
	public static var initialLoadComplete           : Event0 = new Event0();
    public static var worldGenerationComplete       : Event0 = new Event0();
    public static var addLoader                     : Event0 = new Event0();
    public static var removeLoader                  : Event0 = new Event0();

    // TUTORIALIZATION
    public static var moveTutorialHand              : Event1<Array<Dynamic>> = new Event1<Array<Dynamic>>();
    public static var tapTutorialHand               : Event1<Dynamic> = new Event1<Dynamic>();
    public static var hideTutorialHand              : Event0 = new Event0();
    public static var setCollectedCount             : Event1<Int> = new Event1<Int>();
    public static var setReservedCount              : Event1<Int> = new Event1<Int>();

    // CUSTOM
    public static var selectAllergen                : Event2<ALLERGEN_TYPE, Int> = new Event2<ALLERGEN_TYPE, Int>();
    public static var collectAllergen               : Event2<ALLERGEN_TYPE, Int> = new Event2<ALLERGEN_TYPE, Int>();
    public static var releaseAllergen               : Event1<Int> = new Event1<Int>();

    public static var reserveSlot                   : Event2<ALLERGEN_TYPE, Int> = new Event2<ALLERGEN_TYPE, Int>();
}
