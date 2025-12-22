package world;

import workinman.display.spine.SpineElement;
import workinman.display.ElementManager;
import workinman.display.Sprite;
import workinman.pooling.CacheManager;
import workinman.math.WMPoint;
import workinman.math.WMMath;
import workinman.tween.*;
import workinman.WMCloud;
import workinman.WMPool;
import world.elements.*;
import flambe.System;
import workinman.WMRandom;
import app.ConstantsEvent;
import app.INPUT_TYPE;
import app.CLOUD;

private enum STATE {
	ALLOCATE;
	INITIALIZING;
	GAMEPLAY;
}

class World {

	// World Properties
	private var _elementManager 		: ElementManager;
	private var _cacheManager			: CacheManager;
	private var _tween					: Tweener;
	private var _inputPos				: WMPoint;
	private var _state 					: STATE;

	// Pools
	private static inline var _POOL_PARTICLE : String = "pool_particle";

	// Layers
	private static inline var _LAYER_BG : String = "layer_bg";
    private static inline var _LAYER_MIDGROUND1 : String = "layer_mid1";
    private static inline var _LAYER_MIDGROUND2 : String = "layer_mid2";
    private static inline var _LAYER_WORLD : String = "layer_world";
	private static inline var _LAYER_FG : String = "layer_fg";
	private static inline var _LAYER_EFFECTS : String = "layer_effects";

	public function new ( pTimeline:Sprite ) : Void {
		trace("[World](new) Constructed!");

		_inputPos = WMPoint.request();
		_tween = new Tweener();

		WMPool.tracePoolReport();

		_cacheManager = new CacheManager();
		_elementManager = new ElementManager( pTimeline, 0,0 );

		_elementManager.addLayer( _LAYER_BG );
		_elementManager.addLayer( _LAYER_MIDGROUND1 );
		_elementManager.addLayer( _LAYER_MIDGROUND2 );
		_elementManager.addLayer( _LAYER_WORLD, true );
		_elementManager.addLayer( _LAYER_FG );
		_elementManager.addLayer( _LAYER_EFFECTS );

		_addEventListeners();

		_setState( ALLOCATE );
	}

	public function start() : Void {
		_setState( GAMEPLAY );
	}

	public function dispose():Void {
		_tween.dispose();
		_tween = null;
		_elementManager.dispose();
		_elementManager = null;
		_removeEventListeners();
		_cacheManager.dispose();
		_cacheManager = null;
		_state = null;
		_inputPos.dispose();
		_inputPos = null;
	}

	private function _setState( pState:STATE ) : Void {
		_state = pState;
		switch ( pState ) {
			case ALLOCATE:
				_initPools();
			case INITIALIZING:
				_initWorld();
				_onGenerationComplete();
				// Nothing
			case GAMEPLAY:
		}
	}

	public function update( dt:Float ):Void {
		if ( WMCloud.getBool( CLOUD.BOOL_PAUSED ) == true ) {
			return;
		}

		switch ( _state ) {
			case ALLOCATE:
				if ( _cacheManager.processFill(10) ) {
					_setState( INITIALIZING );
				}
			case INITIALIZING:

			case GAMEPLAY:
				// Update elements
				_tween.update(dt);
				_elementManager.update(dt);
		}
	}

	private function _addEventListeners() : Void {
		workinman.WMInput.eventInput.add( _onInput );
		app.ConstantsEvent.pause.add( _onPause );
		// app.ConstantsEvent.spawnEffect.add( _onSpawnEffect );
	}

	private function _removeEventListeners() : Void {
		trace("REMOVE EVENT LISTENER");
		workinman.WMInput.eventInput.remove( _onInput );
        app.ConstantsEvent.pause.remove( _onPause );
		// app.ConstantsEvent.spawnEffect.remove( _onSpawnEffect );
	}

	private function _onPause( pPause:Bool ) : Void {
		if ( pPause ) {
			WMCloud.setBool( CLOUD.BOOL_PAUSED, cast true);
		} else {
			WMCloud.setBool( CLOUD.BOOL_PAUSED, cast false);
		}
	}

	private function _onInput( pType:INPUT_TYPE, pDown:Bool ) : Void {
		trace("ON INPUT WORLD");

		if ( pDown )
            trace("ON INPUT DETECTED");

		if ( WMCloud.getBool( CLOUD.BOOL_PAUSED ) || _state != GAMEPLAY ) {
			return;
		}
		// Stores the actual world input position in _inputPos
		_elementManager.camera.getWorldPositionOfScreenPoint( workinman.WMInput.pointer.currentPos.x, workinman.WMInput.pointer.currentPos.y, 0, _inputPos );

		if ( pType == INPUT_TYPE.POINTER && pDown ) {
			// WMCloud.modifyInt( CLOUD.INT_SCORE, 50 );
		}
	}

	private function _initPools() : Void {
        WMCloud.setInt( CLOUD.FLOAT_LOADING_PROGRESS, 1 );
        _cacheManager.addCache( _POOL_PARTICLE, Particle, 70 );
	}

	private function _initWorld() : Void {

    }
    
	private function _onGenerationComplete() : Void {
		ConstantsEvent.worldGenerationComplete.dispatch();
    }
}
