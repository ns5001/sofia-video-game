package workinman.input;

@:native("GamepadButton")
extern class GamepadButton {
  var pressed(default,null) : Bool;
  var value(default,null) : Float;
}
