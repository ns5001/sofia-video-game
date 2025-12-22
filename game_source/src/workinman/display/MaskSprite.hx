package workinman.display;

import flambe.math.Matrix;
import flambe.math.FMath;
import flambe.math.Point;
import workinman.math.WMPoint;
import workinman.display.Camera;
import workinman.display.Graphics;

enum MASK_TYPE {
	CIRCLE;
	RECTANGLE;
}

class MaskSprite extends ImageSprite {

    private var _maskX : Float;
    private var _maskY : Float;
    private var _maskWidth : Float;
    private var _maskHeight : Float;
	private var _maskRadius : Float;

	private var _type : MASK_TYPE;

    private var _flagMask : Bool;

    public function new( prop:ImageSpriteProp ) : Void {
		super(prop);
        _flagMask = false;
    }

    //uses top left for x and y
    public function setMask( pX : Float, pY : Float, pW : Float, pH : Float ) : Void {
        _flagMask = true;
        _maskX = pX;
        _maskY = pY;
        _maskWidth = pW;
        _maskHeight = pH;
		_type = RECTANGLE;
    }

	public function setCircleMask(pX : Float, pY : Float, pRad : Float) : Void {
		_flagMask = true;
		_maskX = pX;
		_maskY = pY;
		_maskRadius = pRad;
		_type = CIRCLE;
	}

    public function clearMask() : Void {
        _flagMask = false;
    }

    //Overrides the full render so scissor is applied to children properly
    public override function render( g:Graphics, c:Camera ) : Void {
		// Don't render this or children if we're not visible
		if ( visible == false ) {
			return;
		}
		var tRenderX : Float = 0;
		var tRenderY : Float = 0;
		var tRenderZ : Float = 0;
		var tRenderScale : Float = 1;
		if ( c == null || useCamera == false || usePerspective == false ) {
			tRenderX = pos.x;
			tRenderY = pos.y;
			tRenderZ = pos.z;
			tRenderScale = 1;
		} else {
			// Check for z culling
			tRenderZ = pos.z - c.pos.z + offsetZ;
			if ( tRenderZ < -c.focalLength ) {
				return;
			}
			// Perspective disabled
			if ( c.focalLength <= 0 ) {
				tRenderScale = 1;
			} else {
				tRenderScale = c.focalLength / (c.focalLength + tRenderZ);
			}
			tRenderX = c.worldCenterX + ((pos.x - c.pos.x) - c.worldCenterX) * tRenderScale;
			tRenderY = c.worldCenterY + ((pos.y - c.pos.y) - c.worldCenterY) * tRenderScale;
		}
		_matrix.compose(tRenderX,tRenderY,scaleX*tRenderScale,scaleY*tRenderScale,FMath.toRadians(rotation));
		// Calculate view
		if ( parent != null ) {
			Matrix.multiply(parent.viewMatrix,_matrix,_viewMatrix);
		}
		g.ctx.save();
		if ( alpha < 1 ) {
			g.ctx.multiplyAlpha(alpha);
		}
		g.ctx.transform(_matrix.m00, _matrix.m10, _matrix.m01, _matrix.m11, _matrix.m02, _matrix.m12);
        if (_flagMask) {
			switch (_type) {
				case RECTANGLE:
				g.canvasCtx.beginPath();
				g.canvasCtx.rect(Std.int((-width*originX+offsetX)+_maskX), Std.int((-height*originY+offsetY)+_maskY), Std.int(_maskWidth), Std.int(_maskHeight));
				g.canvasCtx.clip();
				case CIRCLE:
				g.canvasCtx.beginPath();
				g.canvasCtx.arc(Std.int((-width*originX+offsetX)+_maskX), Std.int((-height*originY+offsetY)+_maskY), Std.int(_maskRadius),  0, Math.PI*2, false);
				g.canvasCtx.clip();

			}
            //g.ctx.applyScissor((-width*originX+offsetX)+_maskX, (-height*originY+offsetY)+_maskY, _maskWidth, _maskHeight);
        }
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
