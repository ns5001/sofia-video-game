package workinman.display;

import flambe.math.Matrix;
import flambe.math.FMath;
import flambe.math.Point;
import workinman.math.WMPoint;
import workinman.display.Camera;
import workinman.display.Graphics;

/**
* WMSprite - basic unit of rendering in the WM Engine
*/
@:keepSub class Sprite {

	/**
	* An array of all the children of this WMSprite
	*/
	public var children(default,null) : Array<Sprite>;

	/**
	* The parent of this WMSprite
	*/
	public var parent(default,null) : Sprite;

	/**
	* The local position of this WMSprite
	*/
	public var pos(default,null) : WMPoint;

	/**
	* The rendering offset of this WMSprite, added to pos before rendering
	*/
	public var offset(default,null) : WMPoint;
	private var _matrix(default,null) : Matrix;
	private var _viewMatrix(default,null) : Matrix;

	/**
	* Normalized Alpha value of this WMSprite, from 0-1
	*/
	public var alpha(default,default) : Float;

	/**
	* Normalized X Origin of this WMSprite, from 0-1
	*
	* 0 - Left edge
	* 1 - Right edge
	*/
	public var originX(default,set) : Float;

	/**
	* Normalized Y Origin of this WMSprite, from 0-1
	*
	* 0 - Top edge
	* 1 - Bottom edge
	*/
	public var originY(default,set) : Float;

	/**
	* Normalized X scale of this WMSprite. 1 is 100%
	*/
	public var scaleX(default,default) : Float;

	/**
	* Normalized Y scale of this WMSprite. 1 is 100%
	*/
	public var scaleY(default,default) : Float;

	/**
	* Rotation of this WMSprite, in clockwise degrees
	*/
	public var rotation(default,default) : Float;

	/**
	* A flag denoting whether or not this WMSprite is visible and should be rendered
	*/
	public var visible(default,default) : Bool;

	/**
	* A flag denoting whether or not this WMSprite should ignore the camera rendering completely, and just render in view space.
	*
	* All child WMSprites will always ignore camera positioning
	*/
	public var useCamera(default,default) : Bool;

	/**
	* A flag denoting whether or not this WMSprite should ignore perspective rendering, but still render according to the camera position
	*/
	public var usePerspective(default,default) : Bool;

	/**
	* A flag denoting when this WMSprite's lifecycle is complete and that it should be cleaned up
	*
	* Note - In most cases a WMSprite's cleanup will be handled automatically by parent sprites or ElementManagers
	*/
	public var doDelete(default,default) : Bool;

	/**
	* A flag denoting whether or not this WMSprite will return a hitTest result, or be ignored by that input check
	*/
	public var inputEnabled(default,default) : Bool;

	/**
	* Constructor for WMSprite
	*
	* prop - WMSpriteProp - And object containing optional intialization parameters for the WMSprite
	*/
	public function new( prop:SpriteProp ) : Void {
		children = [];
		parent = null;
		_matrix = new Matrix();
		_viewMatrix = new Matrix();
		pos = WMPoint.request(0,0,0);
		offset = WMPoint.request(0,0,0);
		rotation = 0;
		origin = .5;
		scale = alpha = 1;
		visible = useCamera = usePerspective = true;
		inputEnabled = true;
		doDelete = false;
		if ( prop != null ) {
			if ( prop.alpha != null ) 					{ alpha = prop.alpha; }
			if ( prop.x != null ) 							{ x = prop.x; }
			if ( prop.y != null ) 							{ y = prop.y; }
			if ( prop.z != null )								{ z = prop.z; }
			if ( prop.offsetX != null ) 				{ offsetX = prop.offsetX; }
			if ( prop.offsetY != null ) 				{ offsetY = prop.offsetY; }
			if ( prop.offsetZ != null )					{ offsetZ = prop.offsetZ; }
			if ( prop.origin != null )					{ origin = prop.origin; }
			if ( prop.originX != null )					{ originX = prop.originX; }
			if ( prop.originY != null ) 				{ originY = prop.originY; }
			if ( prop.scale != null )						{ scale = prop.scale; }
			if ( prop.scaleX != null ) 					{ scaleX = prop.scaleX; }
			if ( prop.scaleY != null )					{ scaleY = prop.scaleY; }
			if ( prop.rotation != null )				{ rotation = prop.rotation; }
			if ( prop.visible != null )					{ visible = prop.visible; }
			if ( prop.useCamera != null )				{ useCamera = prop.useCamera; }
			if ( prop.usePerspective != null ) 	{ usePerspective = prop.usePerspective; }
		}
	}

	/**
	* Dispose is called at the end of the WMSprite's lifecycle, usually as a response to setting the doDelete flag
	*
	* Note - this is almost always going to be called automatically by the parent WMSprite or an ElementManager
	*/
	public function dispose() : Void {
		if ( children != null ) {
			for ( c in children ) {
				c.dispose();
			}
			children = null;
		}
		parent = null;
		if ( pos != null ) {
			pos.dispose();
			pos = null;
		}
		if ( offset != null ) {
			offset.dispose();
			offset = null;
		}
		_matrix = null;
		_viewMatrix = null;
	}

	/**
	* Property that directly exposes the x value of the pos variable
	*/
	public var x(get,set) : Float;
	private function get_x() : Float { return pos.x; }
	private function set_x(val:Float) : Float { pos.x = val; return val; }

	/**
	* Property that directly exposes the y value of the pos variable
	*/
	public var y(get,set) : Float;
	private function get_y() : Float { return pos.y; }
	private function set_y(val:Float) : Float { pos.y = val; return val; }

	/**
	* Property that directly exposes the z value of the pos variable
	*/
	public var z(get,set) : Float;
	private function get_z() : Float { return pos.z; }
	private function set_z(val:Float) : Float { pos.z = val; return val; }

	/**
	* Property that directly exposes the X value of the offset variable
	*/
	public var offsetX(get,set) : Float;
	private function get_offsetX() : Float { return offset.x; }
	private function set_offsetX(val:Float) : Float { offset.x = val; return val; }

	/**
	* Property that directly exposes the Y value of the offset variable
	*/
	public var offsetY(get,set) : Float;
	private function get_offsetY() : Float { return offset.y; }
	private function set_offsetY(val:Float) : Float { offset.y = val; return val; }

	/**
	* Property that directly exposes the Z value of the offset variable
	*/
	public var offsetZ(get,set) : Float;
	private function get_offsetZ() : Float { return offset.z; }
	private function set_offsetZ(val:Float) : Float { offset.z = val; return val; }

	/**
	* Overrideable property that defines a depth for this WMSprite - to be used by the ElementManager for Z sorting
	*/
	public var depth(get,never) : Float;
	private function get_depth() : Float {
		// Override for custom sorting
		return pos.z;
	}

	private function set_originX(val:Float) : Float {
		originX = val;
		return val;
	}

	private function set_originY(val:Float) : Float {
		originY = val;
		return val;
	}

	/**
	* Property describing the width of this WMSprite
	*/
	public var width(get,never) : Float;
	private function get_width() : Float {
		// Override to return correct width
		return 0;
	}

	/**
	* Property describing the height of this WMSprite
	*/
	public var height(get,never) : Float;
	private function get_height() : Float {
		// Override to return correct height
		return 0;
	}

	/**
	* Convenience property for automatically setting the X and Y scales of this WMSprite simultaneously
	*/
	public var scale(default,set) : Float;
	private function set_scale(val:Float) : Float {
		scale = scaleX = scaleY = val;
		return val;
	}

	/**
	* Convenience property for automatically setting the X and Y origin of this WMSprite simultaneously
	*/
	public var origin(default,set) : Float;
	private function set_origin(val:Float) : Float {
		originX = originY = val;
		return val;
	}

	/**
	* Function for adding a child to this WMSprite, identical to addChild()
	*/
	public inline function addElement<T:Sprite>( pChild:T ) : T {
		return addChild(pChild);
	}

	/**
	* Function for adding a child to this WMSprite, identical to addElement()
	*/
	public function addChild<T:Sprite>( pChild:T ) : T {
		if ( pChild.parent != null ) {
			pChild.parent.removeChild(pChild);
		}
		pChild.parent = this;
		children.push(pChild);
		return pChild;
	}

	public function addChildToBottom<T:Sprite>( pChild:T ) : T {
		if ( pChild.parent != null ) {
			pChild.parent.removeChild(pChild);
		}
		pChild.parent = this;
		children.unshift(pChild);
		return pChild;
	}

	/**
	* Function for removing a child from this WMSprite, identical to removeChild()
	*/
	public inline function removeElement<T:Sprite>( pChild:T ) : T {
		return removeChild(pChild);
	}

	/**
	* Function for removing a child from this WMSprite, identical to removeElement()
	*/
	public function removeChild<T:Sprite>( pChild:T ) : T {
		if ( children.remove(pChild) ) {
			pChild.parent = null;
		}
		return pChild;
	}

	/**
	* A property exposing the current view transform matrix of this WMSprite
	*/
	public var viewMatrix(get,never) : Matrix;
	private function get_viewMatrix() : Matrix {
		if ( parent != null ) {
			return _viewMatrix;
		}
		return _matrix;
	}

	/**
	* A property which unwraps the view X position of this WMSprite
	*/
	public var viewX(get,never) : Float;
	private function get_viewX() : Float {
		var m : Matrix = viewMatrix;
		return m.m02 / m.m00;
	}

	/**
	* A property which unwraps the view Y position of this WMSprite
	*/
	public var viewY(get,never) : Float;
	private function get_viewY() : Float {
		var m : Matrix = viewMatrix;
		return m.m12 / m.m11;
	}

	public function accessibleInHierarchy() : Bool {
		return (visible && alpha > 0 && inputEnabled) && (parent == null ? true : parent.accessibleInHierarchy());
	}

	/**
	* A convenience function used by WMInput to find which object is clicked on
	*/
	public function hitTest( x:Float, y:Float, point:Point ) : Sprite {
		// Skip invisible
		if ( visible == false || inputEnabled == false ) {
			return null;
		}
		// Check all children
		var tI : Int = children.length;
		var tRes : Sprite = null;
		while ( tI-- > 0 ) {
			tRes = children[tI].hitTest(x,y,point);
			if ( tRes != null ) {
				return tRes;
			}
		}
		// Check this
		if ( inverseTransform(x,y,point) ) {
			return this;
		}
		// Nothing in this one
		return null;
	}

	/**
	* A convenience function which tests to see whether or not a pair of view coordinates are contained within this WMSprite's view matrix
	*/
	public function inverseTransform( x:Float, y:Float, point:Point, pW:Float = -1, pH:Float = -1 ) : Bool {
		if ( pW < 0 ) {
			pW = width;
		}
		if ( pH < 0 ) {
			pH = height;
		}
		var tOX : Float = -originX * pW;
		var tOY : Float = -originY * pH;
		return viewMatrix.inverseTransform(x,y,point) && point.x >= tOX && point.y >= tOY && point.x < tOX + pW && point.y < tOY + pH;
	}

	/**
	* Update function which both updates this WMSprite and the children of this WMSprite
	*
	* Override only if necessary, override update() instead
	*/
	public function runUpdate(dt:Float) : Void {
		update(dt);
		// Override with update
		var tI : Int = children.length;
		while ( tI-- > 0 ) {
			children[tI].runUpdate(dt);
			if ( children[tI].doDelete ) {
				children[tI].dispose();
				children.splice(tI,1);
			}
		}
	}

	/**
	* Update function for managing this WMSprite alone.
	*
	* Should be overriden with custom behavior
	*/
	public function update(dt:Float) : Void {
		// Override as necessary
	}

	/**
	* Function which sets up this WMSprite's view matrixes, draws content to the screen, and renders the children of this WMSprite
	*/
	public function render( g:Graphics, c:Camera ) : Void {
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
		g.ctx.save();
		g.ctx.translate(-width*originX+offsetX,-height*originY+offsetY);
		_draw(g);
		g.ctx.restore();
		for ( i in 0...children.length ) {
			children[i].render(g,null);
		}
		g.ctx.restore();
	}

	private function _draw( g:Graphics ) : Void {
		// Override to actually draw content
	}
}
