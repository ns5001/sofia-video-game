package workinman.input;

import js.html.Gamepad;

class GamepadXbox360 extends GamepadBase {

	public function new( pGamepad:Gamepad ) : Void {
		super(pGamepad,XBOX_360);
		trace("[GamePadBase](new) Initialized XBox 360 Gamepad");
		leftX = leftY = rightX = rightY = 0;
	}

	public override function update() : Void {
		super.update();

		leftX = _normalizeAxis(gamepad.axes[0]);
		leftY = _normalizeAxis(gamepad.axes[1]);
		rightX = _normalizeAxis(gamepad.axes[2]);
		rightY = _normalizeAxis(gamepad.axes[3]);

		_testButton(A,cast(gamepad.buttons[0],GamepadButton).pressed);
		_testButton(B,cast(gamepad.buttons[1],GamepadButton).pressed);
		_testButton(X,cast(gamepad.buttons[2],GamepadButton).pressed);
		_testButton(Y,cast(gamepad.buttons[3],GamepadButton).pressed);
		_testButton(LB,cast(gamepad.buttons[4],GamepadButton).pressed);
		_testButton(RB,cast(gamepad.buttons[5],GamepadButton).pressed);
		_testButton(LT,cast(gamepad.buttons[6],GamepadButton).pressed);
		_testButton(RT,cast(gamepad.buttons[7],GamepadButton).pressed);
		_testButton(SELECT,cast(gamepad.buttons[8],GamepadButton).pressed);
		_testButton(START,cast(gamepad.buttons[9],GamepadButton).pressed);
		_testButton(LSTICK_BUTTON,cast(gamepad.buttons[10]).pressed);
		_testButton(RSTICK_BUTTON,cast(gamepad.buttons[11]).pressed);
		_testButton(DPAD_UP,cast(gamepad.buttons[12],GamepadButton).pressed);
		_testButton(DPAD_DOWN,cast(gamepad.buttons[13],GamepadButton).pressed);
		_testButton(DPAD_LEFT,cast(gamepad.buttons[14],GamepadButton).pressed);
		_testButton(DPAD_RIGHT,cast(gamepad.buttons[15],GamepadButton).pressed);

		_testButton(LSTICK_LEFT,leftX<0);
		_testButton(LSTICK_RIGHT,leftX>0);
		_testButton(LSTICK_UP,leftY<0);
		_testButton(LSTICK_DOWN,leftY>0);
		_testButton(RSTICK_LEFT,rightX<0);
		_testButton(RSTICK_RIGHT,rightX>0);
		_testButton(RSTICK_UP,rightY<0);
		_testButton(RSTICK_DOWN,rightY>0);
	}
}
