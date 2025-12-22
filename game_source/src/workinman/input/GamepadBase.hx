package workinman.input;

import js.html.Gamepad;
import workinman.input.GAMEPAD_TYPE;

class GamepadBase {

  public var gamepad(default,null) : Gamepad;
  public var type(default,null) : GAMEPAD_TYPE;
  private var _buttons(default,null) : Map<INPUT_CONTROLLER,Bool>;

  public var leftX(default,null) : Float;
  public var leftY(default,null) : Float;
  public var rightX(default,null) : Float;
  public var rightY(default,null) : Float;

	private static inline var _GAMEPAD_DEAD_ZONE : Float = .15;

  public function new( pGamepad:Gamepad, pType:GAMEPAD_TYPE ) : Void {
    gamepad = pGamepad;
    type = pType;

    _buttons = new Map<INPUT_CONTROLLER,Bool>();
    _addButton(A);
    _addButton(B);
    _addButton(X);
    _addButton(Y);
    _addButton(RB);
    _addButton(LB);
    _addButton(RT);
    _addButton(LT);
    _addButton(DPAD_UP);
    _addButton(DPAD_DOWN);
    _addButton(DPAD_LEFT);
    _addButton(DPAD_RIGHT);
    _addButton(LSTICK_UP);
    _addButton(LSTICK_DOWN);
    _addButton(LSTICK_LEFT);
    _addButton(LSTICK_RIGHT);
    _addButton(RSTICK_UP);
    _addButton(RSTICK_DOWN);
    _addButton(RSTICK_LEFT);
    _addButton(RSTICK_RIGHT);
    _addButton(START);
    _addButton(SELECT);
    _addButton(LSTICK_BUTTON);
    _addButton(RSTICK_BUTTON);
  }

  public function setGamepad(pGamepad:Gamepad) : Void {
    gamepad = pGamepad;
  }

  public function dispose() : Void {
    gamepad = null;
    type = null;
    _buttons = null;
  }

  public function update() : Void {
    leftX = leftY = rightX = rightY = 0;
  }

	private function _normalizeAxis( pVal:Float ) : Float {
		pVal = Math.floor(pVal*100)/100;
		if ( Math.abs(pVal) < _GAMEPAD_DEAD_ZONE ) {
			pVal = 0;
		}
		return pVal;
	}

  private function _addButton(pVirt:INPUT_CONTROLLER) : Void {
    _buttons[pVirt] = false;
  }

  private function _testButton(pController:INPUT_CONTROLLER,pVal:Bool) : Void {
    if ( _buttons[pController] == false && pVal ) {
      _buttons[pController] = true;
      workinman.WMInput.onControllerDown(pController);
    } else if ( _buttons[pController] == true && pVal == false ) {
      _buttons[pController] = false;
      workinman.WMInput.onControllerUp(pController);
    }
  }

}
