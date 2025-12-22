package workinman.display;

import workinman.display.Camera;
import workinman.display.Sprite;
import workinman.ui.Button;
import flambe.math.Point;
import haxe.ds.ArraySort;
import flambe.math.FMath;
import flambe.math.Matrix;

class ElementManager {

	private var _layers : Map<String, Array<Sprite>>;
	private var _layerOrder : Array<String>;
	private var _defaultLayer : String;
	private var _enablePointer : Bool;

	public function new( pRoot:Sprite, pCameraX:Float, pCameraY:Float, pEnableInput:Bool = false ) : Void {
		_layerOrder = [];
		_layers = new Map<String,Array<Sprite>>();
		root = pRoot.addChild( new ElementManagerSprite(pCameraX,pCameraY,_layers,_layerOrder) );
		camera = root.camera;
		_defaultLayer = "";
		_enablePointer = pEnableInput;
	}

	public function dispose() : Void {
		if ( root != null ) {
			root.doDelete = true;
			root = null;
		}
		_layers = null;
		_layerOrder = null;
		_defaultLayer = null;
	}

	public var root(default,null) : ElementManagerSprite;

	public var camera(default,null) : Camera;

	public function addLayer( pLayerName:String, pSetAsDefaultLayer : Bool = false ) : Void {
		// If it's already added, move the layer to the top
		if ( _layers.exists(pLayerName) ) {
			_layerOrder.remove(pLayerName);
			_layerOrder.push(pLayerName);
			return;
		}
		if ( pSetAsDefaultLayer || _defaultLayer.length < 1 ) {
			_defaultLayer = pLayerName;
		}
		_layers.set(pLayerName,[]);
		_layerOrder.push(pLayerName);
	}

	public function setMainLayer( pLayerName:String ) {
		if ( _layers.exists( pLayerName ) == false ) {
			trace( "[ElementManager](setMainLayer) Layer \"" + pLayerName + "\" doesn't exist in ElementManager. Do you need to addLayer?" );
			return;
		}
		_defaultLayer = pLayerName;
	}

	public function removeLayer( pLayerName:String ) : Void {
		if ( _layers.exists(pLayerName) == false ) {
			trace("[ElementManager](removeLayer) Can't remove layer '" + pLayerName + "' it doesn't exist!" );
			return;
		}
		_layerOrder.remove(pLayerName);
		// Dispose all the sprites that are left floating by this process
		for ( c in _layers[pLayerName] ) {
			c.dispose();
		}
		_layers.remove(pLayerName);
	}

	public inline function addChild<T:Sprite> ( pSprite:T, ?pLayer:String ) : T {
		return addElement(pSprite,pLayer);
	}

	public function addElement<T:Sprite> ( pElement:T, ?pLayer:String ) : T {
		if ( _enablePointer == false ) {
			// TODO DISABLE POINTER
			// pElement.disablePointerInput();
		}

		// Look for default layer
		if ( pLayer == null && _defaultLayer != null ) {
			pLayer = _defaultLayer;
		}

		// If we can't add it to the layer, return
		if ( pLayer == null || _layers.exists(pLayer)	== false ) {
			trace("[ElementManager](addElement) Trying to add element to non-existant layer '" + pLayer + "'!" );
			return pElement;
		}

		// If we're already added to something, remove it
		if ( pElement.parent != null ) {
			pElement.parent.removeChild(pElement);
		}
		root.addElementLayer(pElement,pLayer);
		return pElement;
	}

	public function removeElement<T:Sprite>( pElement:T ) : T {
		return root.removeChild(pElement);
	}

	public function update(dt:Float) : Void {
		var c : Sprite;
		for ( l in _layers ) {
			var tI : Int = l.length;
			while ( tI-- > 0 ) {
				c = l[tI];
				c.runUpdate(dt);
				if ( c.doDelete ) {
					c.dispose();
					l.splice(tI,1);
				}
			}
		}
		c = null;
	}

	public function updateZSort( pLayerName:String, pSort:Sprite->Sprite->Int = null ) : Void {
		ArraySort.sort(_layers[pLayerName], pSort==null?_zSort:pSort );
	}

	public function getAllButtons() : Array<Button> {
		var buttons = new Array<Button>();

		for (l in _layers) {
			for (e in l) {
				buttons = buttons.concat(_getButtons(e));
			}
		}

		return buttons;
	}

	private function _getButtons(e : Sprite) : Array<Button> {
		var buttons = new Array<Button>();

		if (Std.is(e, Button)) {
			buttons.push(cast e);
		}

		for (c in e.children) {
			buttons = buttons.concat(_getButtons(c));
		}

		return buttons;
	}

	private function _zSort( a:Sprite, b:Sprite ) : Int {
		if ( a.depth > b.depth ) {
			return -1;
		} else if ( a.depth < b.depth ) {
			return 1;
		}
		return 0;
	}
}
