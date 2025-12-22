package workinman.tween.data;

typedef TweenInfo = {
	target : Dynamic,
	duration : Float,
	ease : Float->Float->Float->Float->Float,
	?overwrite : Bool,
	?delay : Float,
	?postDelay : Float,
	?thread : String,
	?complete : Void->Void,
}
