package workinman.event;

// This abtract is used for operator overloading.
abstract Event0(Event0Base) {
	public function new() { this = new Event0Base(); }

	// Operator Overloading - uses same names as in base class to allow calling them directly as functions.
	@:op(A += B) public inline function add(listener : Void->Void):Void { this.add(listener); }
	@:op(A -= B) public inline function remove(listener : Void->Void):Void { this.remove(listener); }

	// Have to duplicate function names to explose calls from the abstract.
	public inline function dispatch() : Void { this.dispatch(); }
	public inline function dispose() : Void { this.dispose(); }
	public inline function clear() : Void { this.clear(); }
}

// This class contains the actual class logic
private class Event0Base {

	private var _list : Array<Void->Void>;

	public function new() : Void {
		_list = new Array<Void->Void>();
	}

	public function add( listener : Void->Void ) : Void {
		if ( _list.indexOf(listener) >= 0 ) {
			return;
		}
		_list.push(listener);
		return;
	}

	public function remove( listener : Void->Void ) : Void {
		var tI : Int = _list.length;
		while ( tI-- > 0 ) {
			if ( _list[tI] == listener ) {
				_list.remove(listener);
				return;
			}
		}
	}

	public function dispatch() : Void {
		for ( l in _list ) {
			l();
		}
	}

	public function dispose():Void{
		while( _list.length > 0){_list.pop();}
		_list = null;
	}

	public function clear():Void{
		while( _list.length > 0){_list.pop();}
	}
}
