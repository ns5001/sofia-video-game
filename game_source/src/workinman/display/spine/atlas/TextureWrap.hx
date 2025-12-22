package workinman.display.spine.atlas;

@:enum
abstract TextureWrap(String) from String to String {
	var mirroredRepeat = "mirroredRepeat";
	var clampToEdge = "clampToEdge";
	var repeat = "repeat";
}
