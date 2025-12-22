package workinman.display;

import flambe.display.Texture;
import flambe.System;
import flambe.math.FMath;

class SliceSprite extends ImageSprite {

	public var outerWidth(get,set) : Float;
	public var outerHeight(get,set) : Float;
	public var innerWidth(default,set) : Float;
	public var innerHeight(default,set) : Float;
	public var borderLeft(default,set) : Float;
	public var borderRight(default,set) : Float;
	public var borderTop(default,set) : Float;
	public var borderBottom(default,set) : Float;
	private var _bufferW : Int;
	private var _bufferH : Int;
	private var _buffer : Texture;

	public function new( prop:SliceSpriteProp ) : Void {
		borderLeft = 5;
		borderRight = 5;
		borderTop = 5;
		borderBottom = 5;
		innerWidth = 100;
		innerHeight = 100;
		_bufferW = _bufferH = -1;
		if ( prop.borderL != null ) { borderLeft = prop.borderL; }
		if ( prop.borderR != null ) { borderRight = prop.borderR; }
		if ( prop.borderT != null ) { borderTop = prop.borderT; }
		if ( prop.borderB != null ) { borderBottom = prop.borderB; }
		if ( prop.innerW != null ) { innerWidth = prop.innerW; }
		if ( prop.innerH != null ) { innerHeight = prop.innerH; }
		if ( prop.bufferW != null ) { _bufferW = Math.floor(prop.bufferW); }
		if ( prop.bufferH != null ) { _bufferH = Math.floor(prop.bufferH); }
		// Init late so rebuild buffer doesn't trigger early
		super(prop);
		_rebuildBuffer( _bufferW, _bufferH );
	}

	public function set_innerWidth( pVal:Float ) : Float {
		innerWidth = pVal;
		_rebuildBuffer();
		return pVal;
	}

	public function set_innerHeight( pVal:Float ) : Float {
		innerHeight = pVal;
		_rebuildBuffer();
		return pVal;
	}

	private function set_borderLeft( pVal:Float ) : Float {
		borderLeft = pVal;
		_rebuildBuffer();
		return pVal;
	}

	private function set_borderRight( pVal:Float ) : Float {
		borderRight = pVal;
		_rebuildBuffer();
		return pVal;
	}

	private function set_borderTop( pVal:Float ) : Float {
		borderTop = pVal;
		_rebuildBuffer();
		return pVal;
	}

	private function set_borderBottom( pVal:Float ) : Float {
		borderBottom = pVal;
		_rebuildBuffer();
		return pVal;
	}

	public function get_outerWidth() : Float { return width; }
	public function set_outerWidth( pVal:Float ) : Float {
		innerWidth = pVal - borderLeft - borderRight;
		return pVal;
	}

	public function get_outerHeight() : Float { return height; }
	public function set_outerHeight( pVal:Float ) : Float {
		innerHeight = pVal - borderTop - borderBottom;
		return pVal;
	}

	public override function get_width() : Int {
		return Math.floor( innerWidth + borderLeft + borderRight );
	}

	public override function get_height() : Int {
		return Math.floor( innerHeight + borderTop + borderBottom );
	}

	public function setInnerSize(pX: Int, pY: Int) : Void {
		innerWidth = pX;
		innerHeight = pY;
		_rebuildBuffer();
	} 

	public function setBufferSize( pWidth:Int, pHeight:Int ) : Void {
		if ( _buffer != null ) {
			_buffer.dispose();
			_buffer = null;
		}
		_rebuildBuffer( pWidth, pHeight );
	}

	private function _rebuildBuffer( ?pWidth:Int, ?pHeight:Int ) {
		if ( texture == null ) {
			return;
		}
		if ( pWidth == null ) {
			pWidth = Math.floor(outerWidth);
		}
		if ( pHeight == null ) {
			pHeight = Math.floor(outerHeight);
		}
		if ( _buffer != null && _bufferW >= pWidth && _bufferH >= pHeight ) {
			// Our buffer's already big enough
			WMUtils.clearTexture( _buffer );
			_redrawBuffer();
			return;
		}
		if ( _buffer != null ) {
			_buffer.dispose();
			_buffer = null;
		}
		_bufferW = FMath.max( _bufferW, pWidth );
		_bufferH = FMath.max( _bufferH, pHeight );
		_buffer = System.renderer.createTexture( _bufferW, _bufferH );
		_redrawBuffer();
	}

	private function _redrawBuffer() {
		if ( rect != null ) {
			if ( rect.rotate ) {
				_buffer.graphics.save();
				_buffer.graphics.translate( width, 0 );
				_buffer.graphics.rotate(90);
				_drawSlices(
					rect.x,	rect.y,
					rect.sizeY,	rect.sizeX,
					borderTop, borderBottom,
					borderLeft, borderRight,
					innerHeight, innerWidth,
					_buffer.graphics );
				_buffer.graphics.restore();
			} else {
				_drawSlices(
					rect.x, rect.y,
					rect.sizeX, rect.sizeY,
					borderLeft, borderRight,
					borderTop, borderBottom,
					innerWidth, innerHeight,
					_buffer.graphics );
			}
			return;
		}
		_drawSlices(
			0, 0,
			texture.width, texture.height,
			borderLeft,	borderRight,
			borderTop, borderBottom,
			innerWidth, innerHeight,
			_buffer.graphics );
	}

	private function _drawSlices(
		pTexX:Int, pTexY:Int,
		pWidth:Int, pHeight:Int,
		pL:Float, pR:Float,
		pT:Float, pB:Float,
		pW:Float, pH:Float,
		g:flambe.display.Graphics
	) {
		var borderL : Int = Math.floor(pL);
		var borderR : Int = Math.floor(pR);
		var borderT : Int = Math.floor(pT);
		var borderB : Int = Math.floor(pB);
		var innerW : Int = Math.floor(pW);
		var innerH : Int = Math.floor(pH);
		var texMidW : Int = pWidth - borderL - borderR;
		var texMidH : Int = pHeight - borderT - borderB;
		var tTexL : Int = pTexX + borderL;
		var tTexT : Int = pTexY + borderT;
		var tTexR : Int = pTexX + pWidth - borderR;
		var tTexB : Int = pTexY + pHeight - borderB;
		var tRenderBottom : Int = borderT + innerH;
		var tRenderRight : Int = borderL + innerW;
		var tScaledW : Float = 0;
		var tScaledH : Float = 0;
		if ( texMidW > 0 ) {
			tScaledW = innerW / texMidW;
			// Draw the horizontally scaled pieces
			g.save();
			g.translate( borderL, 0 );
			g.scale( tScaledW, 1 );
			g.drawSubTexture( texture, 0, 0, tTexL, pTexY, texMidW, borderT ); // Center Top
			g.drawSubTexture( texture, 0, tRenderBottom, tTexL, tTexB, texMidW, borderB ); // Center Bottom
			g.restore();
		}
		if ( texMidH > 0 ) {
			tScaledH = innerH / texMidH;
			// Draw the veritcally scaled pieces
			g.save();
			g.translate( 0, borderT );
			g.scale( 1, tScaledH );
			g.drawSubTexture( texture, 0, 0, pTexX, tTexT, borderL, texMidH ); // Center Left
			g.drawSubTexture( texture, tRenderRight, 0, tTexR, tTexT, borderR, texMidH );
			g.restore();
		}
		if ( texMidH > 0 && texMidW > 0 ) {
			// Draw the center
			g.save();
			g.translate( borderL, borderT );
			g.scale( tScaledW, tScaledH );
			g.drawSubTexture( texture, 0, 0, tTexL, tTexT, texMidW, texMidH );
			g.restore();
		}
		// Draw the corners
		g.drawSubTexture( texture, 0, 0, pTexX, pTexY, borderL, borderT );
		g.drawSubTexture( texture, tRenderRight, 0, tTexR, pTexY, borderR, borderT );
		g.drawSubTexture( texture, 0, tRenderBottom, pTexX, tTexB, borderL, borderB );
		g.drawSubTexture( texture, tRenderRight, tRenderBottom, tTexR, tTexB, borderR, borderB );
	}

	private override function _draw( g:Graphics ) : Void {
		if ( _buffer == null ) {
			return;
		}
		g.ctx.drawSubTexture( _buffer, 0, 0, 0, 0, outerWidth, outerHeight );
	}
}
