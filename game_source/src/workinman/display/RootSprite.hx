package workinman.display;

import flambe.math.Point;
import flambe.System;
import app.ConstantsApp;
import app.ConstantsEvent;

class RootSprite extends flambe.display.Sprite {

	private var _root : Sprite;
	private var _updateDelegate : Float->Void;
	private var _scratchPoint : Point;
	private var _graphics : Graphics;

	private var _lastStageX : Float;
	private var _lastStageY : Float;
	private var _fullWidth : Float;

	public function new( pUpdateDelegate:Float->Void ) : Void {
		super();
		_root = new Sprite(null);
		_lastStageX = _lastStageX = 0;
		_updateDelegate = pUpdateDelegate;
		_calcScale();
		_scratchPoint = new Point();
		_graphics == null;
	}

	public override function dispose() : Void {
		_updateDelegate = null;
		_scratchPoint = null;
		super.dispose();
	}

	public override function onUpdate(dt:Float) : Void {
		_root.runUpdate(dt);
		_updateDelegate(dt);
	}

	public function hitTest( x:Float, y:Float ) : Sprite {
		return _root.hitTest(x,y,_scratchPoint);
	}

	private function _calcScale() : Void {
		if ( System.stage.width == _lastStageX && System.stage.height == _lastStageY ) {
			return;
		}

		_lastStageX = System.stage.width;
		_lastStageY = System.stage.height;
		_root.x = _lastStageX * .5;
		_root.y = _lastStageY * .5;

		var tScale : Float = _lastStageY / ConstantsApp.STAGE_HEIGHT;
		_fullWidth = _lastStageX / tScale;

		if ( ConstantsApp.ALLOW_PORTRAIT && _lastStageX < _lastStageY ) {
			_root.rotation = 90;
			tScale = _lastStageX / ConstantsApp.STAGE_HEIGHT;
			_fullWidth = _lastStageY / tScale;
		} else {
			_root.rotation = 0;
		}

		if ( ConstantsApp.STAGE_WIDTH_MAX > 0 ) {
			ConstantsApp.STAGE_WIDTH = Math.min( Math.ceil(_fullWidth), ConstantsApp.STAGE_WIDTH_MAX );
		} else {
			ConstantsApp.STAGE_WIDTH = Math.ceil(_fullWidth);
		}
		ConstantsApp.STAGE_CENTER_X = Math.floor( ConstantsApp.STAGE_WIDTH * .5 );
		_root.scale = tScale;
		app.ConstantsEvent.resizeCanvas.dispatch( tScale );
	}

	public function addChild( pChild:Sprite ) : Sprite {
		return _root.addChild(pChild);
	}

	public function removeChild( pChild:Sprite ) : Sprite {
		return _root.removeChild(pChild);
	}

	public override function draw( g:flambe.display.Graphics ) : Void {
		if ( _graphics == null ) {
			_graphics = new Graphics(g);
		}
		_calcScale();
		g.fillRect(0x000000,-ConstantsApp.STAGE_CENTER_X-1,-ConstantsApp.STAGE_CENTER_Y-1,ConstantsApp.STAGE_WIDTH+2,ConstantsApp.STAGE_HEIGHT+2);
		_root.render(_graphics,null);
		// Draw Letterboxes if necessary
		if ( ConstantsApp.STAGE_WIDTH_MAX > 0 ) {
			g.save();
			g.translate(_root.x,_root.y);
			g.scale(_root.scale,_root.scale);
			g.rotate(_root.rotation);
			var tDif : Int = Math.ceil( (_fullWidth - ConstantsApp.STAGE_WIDTH) * .5 );
			var tHalfWidth : Int = Math.ceil( _fullWidth * .5 );
			if ( tDif > 0 ) {
				g.fillRect(0x000000,-tHalfWidth,-ConstantsApp.STAGE_CENTER_Y-1,tDif,ConstantsApp.STAGE_HEIGHT+2);
				g.fillRect(0x000000,tHalfWidth-tDif,-ConstantsApp.STAGE_CENTER_Y-1,tDif,ConstantsApp.STAGE_HEIGHT+2);
			}
			g.restore();
		}
	}
}
