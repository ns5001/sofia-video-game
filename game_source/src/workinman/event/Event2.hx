package workinman.event;

// This abtract is used for operator overloading.
abstract Event2<T,V>(Event2Base<T,V>) {
	public function new() { this = new Event2Base<T,V>(); }

	// Operator Overloading - uses same names as in base class to allow calling them directly as functions.
	@:op(A += B) public inline function add(listener : T->V->Void):Void { this.add(listener); }
	@:op(A -= B) public inline function remove(listener : T->V->Void):Void { this.remove(listener); }

	// Have to duplicate function names to explose calls from the abstract.
	public inline function dispatch(val0 : T, val1 : V) : Void { this.dispatch(val0, val1); }
	public inline function dispose() : Void { this.dispose(); }
	public inline function clear() : Void { this.clear(); }
}

// This class contains the actual class logic
private class Event2Base<T,V> {

	private var _list : Array<T->V->Void>;

	public function new() : Void {
		_list = new Array<T->V->Void>();
	}

	public function add( listener : T->V->Void ) : Void {
		if ( _list.indexOf(listener) >= 0 ) {
			return;
		}
		_list.push(listener);
		return;
	}

	public function remove( listener : T->V->Void ) : Void {
		var tI : Int = _list.length;
		while ( tI-- > 0 ) {
			if ( _list[tI] == listener ) {
				_list.remove(listener);
				return;
			}
		}
	}

	public function dispatch( val0 : T, val1 : V ) : Void {
		for ( l in _list ) {
			l(val0,val1);
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
