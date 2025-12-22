package workinman.display.spine;

@:enum
abstract BlendMode(String) from String to String {
	var normal = "normal";
	var additive = "additive";
	var multiply = "multiply";
	var screen = "screen";
}
