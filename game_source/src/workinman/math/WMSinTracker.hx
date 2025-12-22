package com.workinman.math;

import com.workinman.pooling.*;
import com.workinman.cloud.WMCloud;

class WMSinTracker {

	private var _trackers : Array<WMSinProperty>;

	public function new() : Void {
		_trackers = new Array<WMSinProperty>();
	}

	public function dispose() : Void {
		for ( t in _trackers ) {
			t.dispose();
		}
		_trackers = null;
	}

	public function startSin( pObject:Dynamic, pRate:Float, pAmp:Float, pProperties:Array<String> ) : Void {
		for ( p in pProperties ) {
			_trackers.push( WMSinProperty.request( pObject, SIN, p, pAmp, pRate ) );
		}
	}

	public function startCos( pObject:Dynamic, pRate:Float, pAmp:Float, pProperties:Array<String> ) : Void {
		for ( p in pProperties ) {
			_trackers.push( WMSinProperty.request( pObject, COS, p, pAmp, pRate) );
		}
	}

	public function stop( pObject:Dynamic ) : Void {
		var tI : Int = _trackers.length;
		while ( tI-- > 0 ) {
			if ( _trackers[tI].target == pObject ) {
				_trackers[tI].dispose();
				_trackers.splice(tI,1);
			}
		}
	}

	public function update( dt:Float ) : Void {
		for ( t in _trackers ) {
			t.update(dt);
		}
	}
}

enum SIN_TYPE {
	SIN;
	COS;
}

@:keep class WMSinProperty extends PoolStrictBase implements IStrictPoolable {

	public static function request( pTarget:Dynamic, pType:SIN_TYPE, pProperty:String, pAmp:Float, pRate:Float ) : WMSinProperty {
		return WMCloud.instance.pool.requestObject("WMSinProperty",WMSinProperty).init( pTarget,pType,pProperty,pAmp,pRate );
	}

	private var _target : Dynamic;
	private var _property : String;
	private var _type : SIN_TYPE;

	private var _origin : Float;
	private var _val : Float;
	private var _amp : Float;
	private var _rate : Float;

	public function init( pTarget:Dynamic, pType:SIN_TYPE, pProperty:String, pAmp:Float, pRate:Float ) : WMSinProperty {
		_target = pTarget;
		_amp = pAmp;
		_val = 0;
		_rate = pRate;
		_type = pType;
		_origin = 0;
		_property = pProperty;
		if ( Reflect.hasField( _target, _property ) ) {
			_origin = Reflect.field( _target, _property );
		} else if ( Reflect.getProperty( _target, _property ) != null ) {
			_origin = Reflect.getProperty( _target, _property );
		}
		return this;
	}

	public override function dispose() : Void {
		_target = null;
		_property = null;
		_type = null;
		super.dispose();
	}

	public var target( get,never ) : Dynamic;
	private function get_target() : Dynamic { return _target; }

	public function update( dt:Float ) : Void {
		_val = ( _val + dt * _rate ) % ( Math.PI * 2 );
		var tSin : Float = 0;
		switch ( _type ) {
			case SIN:
				tSin = _origin + Math.sin( _val ) * _amp;
			case COS:
				tSin = _origin + Math.cos( _val ) * _amp;
		}
		Reflect.setProperty( _target, _property, tSin );
	}
}
