package app;

import world.elements.AvatarProp;
import app.ALLERGEN_TYPE;
import js.Cookie;

class PlayerData {

    public static var debug : Bool = false;

    // Is this the first play?
    private static var _flagIsFirstPlay : Bool = true;
    public static var flagIsFirstPlay(get, set) : Bool;
    static function get_flagIsFirstPlay() { return _flagIsFirstPlay; }
    static function set_flagIsFirstPlay(pValue:Bool) { 
        Cookie.set("isFirstPlay", pValue ? "true" : "false", app.ConstantsApp.COOKIE_LIFETIME );
        return _flagIsFirstPlay = pValue; 
    }

    private static var _flagBlockDrawing : Bool = false;
    public static var flagBlockDrawing(get, set) : Bool;
    static function get_flagBlockDrawing() { return _flagBlockDrawing; }
    static function set_flagBlockDrawing(pValue:Bool) { 
        return _flagBlockDrawing = pValue; 
    }

    private static var _avatarSettings : AvatarProp = {
        skinColor : 0, bodyType : 0, hairColor : 0, hairStyle : 0,
        eyeColor : 0, eyeShape : 0, outfitType : 0, outfitColor : 0, facewear : 0,
      };
    public static var avatarSettings(get, set) : AvatarProp;
    static function get_avatarSettings() { return _avatarSettings; }
    static function set_avatarSettings(pValue : AvatarProp) { 
        return _avatarSettings = pValue; 
    }

    private static var _selectedAllergens : Array<ALLERGEN_TYPE> = [null, null, null, null, null];
    public static var selectedAllergens(get, never) : Array<ALLERGEN_TYPE>;
    static function get_selectedAllergens() { return _selectedAllergens; }

    public static function loadCookies() : Void {
        // TODO: Load save data from cookies.
        // if (debug) ClearCookies();
        flagIsFirstPlay = ( Cookie.get("isFirstPlay") == "true" || Cookie.get("isFirstPlay") == null ) ? true : false;
    }

    public static function ClearCookies() : Void
    {
        var cookies = js.Cookie.all();
        for(cookie in cookies.keys())
        {
            js.Cookie.remove(cookie);
        }
    }

    public static function reset() : Void {
        _selectedAllergens = [null, null, null, null, null];
    }
    public static function addAllergen(pIndex : Int, pAllergen : ALLERGEN_TYPE) : Void {
        _selectedAllergens[pIndex] = pAllergen;
    }
}