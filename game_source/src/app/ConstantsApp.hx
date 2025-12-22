package app;

class ConstantsApp {

    // GAME OPTIONS
    public static inline var OPTION_DEBUG_FLAG          : Bool = #if debug true; #else false; #end
	public static inline var OPTION_SILENCE_AUDIO		: Bool = false;
	public static inline var OPTION_HAS_MENU_MUSIC		: Bool = true;
	public static inline var OPTION_SHOW_SAFE_GUIDES 	: Bool = #if debug false; #else false; #end
    public static inline var GAME_VERSION				: String = "1.0.0";
    
    public static inline var GRAVITY                    : Float = 8;
    public static inline var MAX_DRAWINGS_PER_HABITAT   : Int = 5;
    public static inline var HABITAT_COUNT              : Int = 3;
    public static inline var SAVE_STRING                : String = "savedPaintData";

	// RENDER CONSTANTS
	public static var STAGE_WIDTH						: Float = 1280; // Dynamically resizes based on embed size
	public static var STAGE_CENTER_X					: Float = 640; // Dynamically resizes based on embed size
	public static inline var STAGE_HEIGHT				: Float = 720; // These are hardcoded, since the engine only scales horizontally
	public static inline var STAGE_CENTER_Y				: Float = 360; // These are hardcoded, since the engine only scales horizontally
	public static inline var ALLOW_PORTRAIT				: Bool = false; // Whether or not the game auto-rotates to portrait, only works in jsembed "fill"
	public static inline var STAGE_WIDTH_MAX			: Int = 1280; // Hard coded letterboxes for unbounded embeds. 0 for no letterboxes

	// SERVICES
	public static var ANALYTICS_ID						: String = "X";
	public static var baseUrl							: String = "";

	// Default values
	public static inline var DEFAULT_MENU_MUSIC			: String = ""; // Default menu music to play on game start
	public static inline var DEFAULT_MENU_MUSIC_VOLUME	: Float = 0.10; // Default menu music volume

	public static inline var DEFAULT_GAME_MUSIC			: String = ""; // Default music to play on game start
	public static inline var DEFAULT_GAME_MUSIC_VOLUME	: Float = 0.3; // Default game music volume
	public static inline var DUCKING_GAME_MUSIC_VOLUME	: Float = 0.15; // Default game music volume

	public static inline var DEFAULT_BUTTON_CLICK		: String = ""; // Default sound for button presses
	public static inline var DEFAULT_BUTTON_CLICK_VOLUME : Float = 1.0; // Default volume for button presses

	public static inline var DEFAULT_BUTTON_OVER	 	: String = ""; // Default sound to play when button over
	public static inline var DEFAULT_BUTTON_OVER_VOLUME : Float = 1.0; // Default volume for button over sounds

	public static inline var COOKIE_LIFETIME : Int = 604800; //how long will cookies exist for users?

	public static inline var FULLSCREEN_BLOCK_DRAW		: Bool = false;

	private static var _isCocoon : Int = -1;
	public static var isCocoon( get,never ) : Bool;
	private static function get_isCocoon() : Bool {
		if ( _isCocoon < 0 ) {
			untyped {
				if ( window.CocoonJS ) {
					_isCocoon = 1;
				} else {
					_isCocoon = 0;
				}
			}
		}
		return _isCocoon == 1;
	}
}
