package workinman.display;

import js.html.CanvasRenderingContext2D;

class Graphics {

	public var ctx(default,null) : flambe.display.Graphics;
	public var canvasCtx(default,null) : CanvasRenderingContext2D;

	public function new( g:flambe.display.Graphics ) : Void {
		ctx = g;
		canvasCtx = null;
		if ( Std.is(g,flambe.platform.html.CanvasGraphics) ) {
			canvasCtx = Reflect.field(g,"_canvasCtx");
		}
	}
}
