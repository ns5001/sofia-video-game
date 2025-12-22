package workinman.display;

import app.ConstantsApp;

class GuideSprite extends Sprite {

	private static inline var _BUTTON_BLANK_PIXELS : Float = 40;
	private static inline var _43_SIZE : Float = ConstantsApp.STAGE_HEIGHT * (4/3);
	private static inline var _169_SIZE : Float = ConstantsApp.STAGE_HEIGHT * (16/9);
	private static inline var _43_HALF : Float = _43_SIZE/2;
	private static inline var _169_HALF : Float = _169_SIZE/2;
	private static inline var _169_RENDER_WIDTH : Float = _169_HALF-_43_HALF;

	public function new() : Void {
		super(null);
	}

	private override function _draw( g:Graphics ) : Void {
		g.ctx.save();
		g.ctx.setAlpha(.5);
		var tTotalDif : Float = ConstantsApp.STAGE_CENTER_X - _169_HALF;
		// 4:3 Center
		g.ctx.fillRect(0x00FF00,-_43_HALF,-ConstantsApp.STAGE_CENTER_Y,_43_SIZE,ConstantsApp.STAGE_HEIGHT);
		// 16:9 Edges
		g.ctx.fillRect(0xE3871B,-_169_HALF,-ConstantsApp.STAGE_CENTER_Y,_169_RENDER_WIDTH,ConstantsApp.STAGE_HEIGHT);
		g.ctx.fillRect(0xE3871B,_169_HALF-_169_RENDER_WIDTH,-ConstantsApp.STAGE_CENTER_Y,_169_RENDER_WIDTH,ConstantsApp.STAGE_HEIGHT);
		// Extreme edge
		if ( tTotalDif > 0 ) {
			g.ctx.fillRect(0xFF0000,-ConstantsApp.STAGE_CENTER_X,-ConstantsApp.STAGE_CENTER_Y,tTotalDif,ConstantsApp.STAGE_HEIGHT);
			g.ctx.fillRect(0xFF0000,ConstantsApp.STAGE_CENTER_X-tTotalDif,-ConstantsApp.STAGE_CENTER_Y,tTotalDif,ConstantsApp.STAGE_HEIGHT);
		}
		// Button Blank
		g.ctx.fillRect(0xFFFFFF,-ConstantsApp.STAGE_CENTER_X,-ConstantsApp.STAGE_CENTER_Y,ConstantsApp.STAGE_WIDTH,_BUTTON_BLANK_PIXELS);
		g.ctx.fillRect(0xFFFFFF,-ConstantsApp.STAGE_CENTER_X,ConstantsApp.STAGE_CENTER_Y-_BUTTON_BLANK_PIXELS,ConstantsApp.STAGE_WIDTH,_BUTTON_BLANK_PIXELS);
		g.ctx.restore();
	}

}
