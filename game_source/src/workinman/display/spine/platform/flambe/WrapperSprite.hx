package workinman.display.spine.platform.flambe;

import workinman.display.Camera;
import flambe.math.Matrix;

class WrapperSprite extends Sprite {

	public var a(default,default) : Float;
	public var b(default,default) : Float;
	public var c(default,default) : Float;
	public var d(default,default) : Float;
	public var e(default,default) : Float;
	public var f(default,default) : Float;

 	public function new() {
		super(null);
		a = b = c = d = e = f = 0;
		a = 1;
		d = -1;
	}

	public override function render( g:Graphics, camera:Camera ) : Void {
		// Don't render this or children if we're not visible
		if ( visible == false ) {
			return;
		}
		//_matrix.compose(tRenderX,tRenderY,scaleX*tRenderScale,scaleY*tRenderScale,FMath.toRadians(rotation));
		_matrix.set(a,c,-b,-d,e,f);
		// Calculate view
		if ( parent != null ) {
			Matrix.multiply(parent.viewMatrix,_matrix,_viewMatrix);
		}
		g.ctx.save();
		if ( alpha < 1 ) {
			g.ctx.multiplyAlpha(alpha);
		}
		g.ctx.transform(_matrix.m00, _matrix.m10, _matrix.m01, _matrix.m11, _matrix.m02, _matrix.m12);
		g.ctx.save();
		g.ctx.translate(-width*originX+offsetX,-height*originY+offsetY);
		_draw(g);
		g.ctx.restore();
		for ( i in 0...children.length ) {
			children[i].render(g,null);
		}
		g.ctx.restore();
	}

}
