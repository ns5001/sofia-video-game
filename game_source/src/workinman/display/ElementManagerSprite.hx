package workinman.display;

import workinman.display.Camera;
import flambe.math.Point;
import flambe.math.FMath;
import flambe.math.Matrix;

class ElementManagerSprite extends Sprite {

	public var camera(default,null) : Camera;
	private var _layers : Map<String,Array<Sprite>>;
	private var _layerOrder : Array<String>;

	public function new( pWorldCenterX:Float, pWorldCenterY:Float, pLayers:Map<String,Array<Sprite>>, pLayerOrder:Array<String> ) : Void {
		super(null);
		camera = new Camera(this,pWorldCenterX,pWorldCenterY);
		_layers = pLayers;
		_layerOrder = pLayerOrder;
	}

	public override function dispose() : Void {
		super.dispose();
		if ( camera != null ) {
			camera.dispose();
			camera = null;
		}
		if ( _layers != null ) {
			for ( l in _layers ) {
				for ( c in l ) {
					c.dispose();
				}
			}
			_layers = null;
		}
		_layerOrder = null;
	}

	public override function hitTest( x:Float, y:Float, pPoint:Point ) : Sprite {
		// Skip invisible
		if ( visible == false || inputEnabled == false ) {
			return null;
		}
		// First check layers
		var tRes : Sprite = null;
		var tI : Int = _layerOrder.length;
		var tLayer : Array<Sprite>;
		while ( tI-- > 0 ) {
			tLayer = _layers[_layerOrder[tI]];
			var tC : Int = tLayer.length;
			while ( tC-- > 0 ) {
				tRes = tLayer[tC].hitTest(x,y,pPoint);
				if ( tRes != null ) {
					tLayer = null;
					return tRes;
				}
			}
		}
		tLayer = null;
		return super.hitTest(x,y,pPoint);
	}

	public function addElementLayer<T:Sprite>( pChild:T, pLayer:String ) : T {
		if ( _layers.exists(pLayer) == false ) {
			return pChild;
		}
		if ( pChild.parent != null ) {
			pChild.parent.removeChild(pChild);
		}
		pChild.parent = this;
		_layers[pLayer].push(pChild);
		return pChild;
	}

	public override function removeChild<T:Sprite>( pChild:T ) : T {
		for ( l in _layers ) {
			if ( l.remove(pChild) ) {
				pChild.parent = null;
				break;
			}
		}
		return pChild;
	}

	public override function render( g:Graphics, c:Camera ) : Void {
		g.ctx.save();
		_matrix.compose(x,y,scaleX,scaleY,FMath.toRadians(rotation));
		// Calculate view
		if ( parent != null ) {
			Matrix.multiply(parent.viewMatrix,_matrix,_viewMatrix);
		}
		g.ctx.transform(_matrix.m00, _matrix.m10, _matrix.m01, _matrix.m11, _matrix.m02, _matrix.m12);
		// Render children if they happen to be added (for clickwalls and the like)
		for ( i in 0...children.length ) {
			children[i].render(g,null);
		}
		// Render layers
		var tLayer : Array<Sprite>;
		for ( l in 0..._layerOrder.length ) {
			tLayer = _layers[_layerOrder[l]];
			for ( c in 0...tLayer.length ) {
				tLayer[c].render(g,camera);
			}
		}
		tLayer = null;
		g.ctx.restore();
	}
}
