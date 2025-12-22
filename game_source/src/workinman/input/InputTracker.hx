package workinman.input;

import app.INPUT_TYPE;
import app.INPUT_VIRTUAL;
import flambe.input.Key;
import flambe.System;

class InputTracker {

	public var type( default,null ) : INPUT_TYPE;
	private var _keys : Array<Key>;
	private var _virtual : Array<INPUT_VIRTUAL>;
	private var _controller : Array<INPUT_CONTROLLER>;
	private var _fireDelegate : INPUT_TYPE->Bool->Void;
	private var _virtualTestDelegate : INPUT_VIRTUAL->Bool;
	private var _controllerTestDelegate : INPUT_CONTROLLER->Bool;
	private var _pointer : Pointer;

	public var fresh( default,null ) : Bool;
	public var down( default,null ) : Bool;

	public function new( pType:INPUT_TYPE, pFireDelegate:INPUT_TYPE->Bool->Void, pVirtualTestDelegate:INPUT_VIRTUAL->Bool, pControllerTestDelegate:INPUT_CONTROLLER->Bool ) : Void {
		type = pType;
		_keys = new Array<Key>();
		_virtual = new Array<INPUT_VIRTUAL>();
		_controller = [];
		_fireDelegate = pFireDelegate;
		_virtualTestDelegate = pVirtualTestDelegate;
		_controllerTestDelegate = pControllerTestDelegate;
		_pointer = null;
		down = false;
		fresh = false;
	}

	public function dispose() : Void {
		type = null;
		_keys = null;
		_virtual = null;
		_fireDelegate = null;
		_virtualTestDelegate = null;
		_controllerTestDelegate = null;
		_pointer = null;
		_controller = null;
	}

	public function setKeys( pKeys:Array<Key>, pVirtual:Array<INPUT_VIRTUAL>, pController:Array<INPUT_CONTROLLER> ) : Void {
		if ( pKeys != null ) {
			for ( k in pKeys ) {
				_keys.push( k );
			}
		}
		if ( pVirtual != null ) {
			for ( v in pVirtual ) {
				_virtual.push( v );
			}
		}
		if ( pController != null ) {
			for ( c in pController ) {
				_controller.push( c );
			}
		}
	}

	public function setPointer( pPointer:Pointer ) : Void {
		_pointer = pPointer;
	}

	public function resetStatus() : Void {
		down = false;
		fresh = false;
	}

	public function updateStatus() : Void {
		fresh = false;
		if ( down ) {
			if ( _isDown() == false ) {
				down = false;
				_fireDelegate( type, false );
			}
		} else {
			if ( _isDown() ) {
				down = true;
				fresh = true;
				_fireDelegate( type, true );
			}
		}
	}

	private function _isDown() : Bool {
		for ( k in _keys ) {
			if ( System.keyboard.isDown(k) ) {
				return true;
			}
		}
		for ( v in _virtual ) {
			if ( _virtualTestDelegate(v) ) {
				return true;
			}
		}
		for ( c in _controller ) {
			if ( _controllerTestDelegate(c) ) {
				return true;
			}
		}
		if ( _pointer != null && _pointer.down ) {
			return true;
		}
		return false;
	}
}
