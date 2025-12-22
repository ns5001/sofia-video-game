package app;

// INPUT
// Many of these will not be enabled in your game by default
// Add them to Main._registerInput to enable them
enum INPUT_TYPE {

	// Built-in Engine Things
	POINTER;
	POINTER_MOVE;
	UI_OK;
	UI_DENY;
	UI_MENU;

	// Make your inputs here
	MOVE_UP;
	MOVE_DOWN;
	MOVE_LEFT;
	MOVE_RIGHT;
	JUMP;
	ATTACK;

	DEBUG_SHOW_PAINTING;
	DEBUG_SAVE_PAINTING;

	UI_TAB;
}
