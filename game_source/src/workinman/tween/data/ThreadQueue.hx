package workinman.tween.data;

class ThreadQueue {

	public var id(default,null) : String;
	private var _tweens : Array<TweenStep>;

	public function new( pId:String ) : Void {
		id = pId;
		_tweens = new Array<TweenStep>();
	}

	public function dispose() : Void {
		if ( id == null ) {
			// Double dispose
			return;
		}
		id = null;
		for ( t in _tweens ) {
			t.dispose();
		}
		_tweens = null;
	}

	public var isComplete(get,never) : Bool;
	private function get_isComplete() : Bool { return _tweens == null || _tweens.length < 1; }

	public function update( dt:Float ) : Void {
		if ( isComplete ) {
			return;
		}
		var tStep = _tweens[0];
		var dtRemaining = tStep.update( dt );
		if ( tStep.isComplete && _tweens != null ) {
			tStep.dispose();
			_tweens.shift();
			update(dtRemaining);
		}
	}

	public function queueStep( pStep:TweenStep ) : Void {
		_tweens.push( pStep );
	}
}
