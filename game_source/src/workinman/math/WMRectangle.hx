package workinman.math;

import workinman.pooling.IStrictPoolable;
import workinman.pooling.PoolStrictBase;
import flambe.math.Rectangle;

enum Side {
	TOP;
	RIGHT;
	BOTTOM;
	LEFT;
}

/*
 * Author: Justin R. Smith
 */
class WMRectangle extends PoolStrictBase implements IStrictPoolable {

	public static function request( pX:Float = 0, pY:Float = 0, pW:Float = 0, pH:Float = 0 ) : WMRectangle {
		return WMPool.requestObject(WMRectangle).init(pX,pY,pW,pH);
	}

	// Static functions
	public static function fromRectangle( pRectangle:Rectangle ) : WMRectangle {
		return request(pRectangle.x,pRectangle.y,pRectangle.width,pRectangle.height);
	}

	// Instance variables
	private var _x : Float;
	private var _y : Float;
	private var _width : Float;
	private var _height : Float;
	private var _workLine : WMLine;

	public override function create() : Void {
		_workLine = null;
	}

	public function init( pX:Float, pY:Float, pW:Float, pH:Float ) : WMRectangle {
		_x = pX;
		_y = pY;
		_width = pW;
		_height = pH;
		return this;
	}

	public override function dispose() : Void {
		if ( _workLine != null ) {
			_workLine.dispose();
		}
		_workLine = null;
		super.dispose();
	}

	private function _getWorkLine() : WMLine {
		if ( _workLine == null ) {
			_workLine = WMLine.request();
		}
		return _workLine;
	}

	public var x(get_x,set_x) : Float;
	private function get_x() : Float { return _x; }
	private function set_x( pX:Float ) : Float { _x = pX; return _x; }

	public var y(get_y,set_y) : Float;
	private function get_y() : Float { return _y; }
	private function set_y( pY:Float ) : Float { _y = pY; return _y; }

	public var top(get_top,set_top) : Float;
	private function get_top() : Float { return _y; }
	private function set_top( pTop:Float ) : Float { _y = pTop; return _y; }

	public var left(get_left,set_left) : Float;
	private function get_left() : Float { return _x; }
	private function set_left( pLeft:Float ) : Float { _x = pLeft; return _x; }

	public var width(get_width,set_width) : Float;
	private function get_width() : Float { return _width; }
	private function set_width( pWidth:Float ) : Float { _width = pWidth; return _width; }

	public var height(get_height,set_height) : Float;
	private function get_height() : Float { return _height; }
	private function set_height( pHeight:Float ) : Float { _height = pHeight; return _height; }

	public var bottom(get_bottom,set_bottom) : Float;
	private function get_bottom() : Float { return _y + _height; }
	private function set_bottom( pBottom:Float )  : Float {
		_y = pBottom - _height;
		return get_bottom();
	}

	public var right(get_right,set_right) : Float;
	private function get_right() : Float { return _x + _width; }
	private function set_right( pRight:Float ) : Float {
		_x = pRight - _width;
		return get_right();
	}

	public var centerX( get_centerX, set_centerX ) : Float;
	private function get_centerX() : Float { return _x + (_width/2); }
	private function set_centerX( pCX:Float ) : Float {
		_x = pCX - (_width/2);
		return get_centerX();
	}

	public var centerY( get_centerY, set_centerY ) : Float;
	private function get_centerY() : Float { return _y + (_height/2); }
	private function set_centerY( pCY:Float ) : Float {
		_y = pCY - (_height/2);
		return get_centerY();
	}

	public function copy(): WMRectangle {
		return request(_x,_y,_width,_height);
	}

	public function contains( pX:Float, pY:Float ) : Bool {
		if ( pX < left || pX > right ) {
			return false;
		}
		if ( pY > bottom || pY < top ) {
			return false;
		}
		return true;
	}

	public function toXY( pX:Float, pY:Float ) : Void {
        x = pX;
        y = pY;
    }

    public function toWH( pW:Float, pH:Float ) : Void {
        width = pW;
        height = pH;
    }

    public function toXYWH( pX:Float, pY:Float, pW:Float, pH:Float ) : Void {
        toXY(pX,pY);
        toWH(pW,pH);
    }

	public function containsPoint( pPos:WMPoint ) : Bool {
		return contains(pPos.x,pPos.y);
	}

	public function intersects( pRect:WMRectangle ) : Bool {
		return ( left < pRect.right && right > pRect.left && top < pRect.bottom && bottom > pRect.top );
	}

	public function intersection( pRect:WMRectangle ) : WMRectangle {
		var tRect : WMRectangle = request();
		if ( this.intersects(pRect) ) {
			tRect.x = left>pRect.left?left:pRect.left;
			tRect.y = top>pRect.top?top:pRect.top;

			var tRight : Float = right<pRect.right?right:pRect.right;
			var tBottom : Float = bottom<pRect.bottom?bottom:pRect.bottom;

			tRect.width = tRight - tRect.x;
			tRect.height = tBottom - tRect.y;
		}
		return tRect;
	}

	private function _setSideLine( pSide:Side ) : Void {
		_getWorkLine();
		switch ( pSide ) {
			case TOP:
				_workLine.toFloats( left,top,right,top );
			case RIGHT:
				_workLine.toFloats( right,top,right,bottom );
			case BOTTOM:
				_workLine.toFloats( left,bottom,right,bottom );
			case LEFT:
				_workLine.toFloats( left,top,left,bottom );
		}
	}

	public function sideLineIntercept( pLine:WMLine, pSide:Side, pResult:InterceptResult=null ) : InterceptResult {
		if ( _workLine == null ) {
			_setSideLine(pSide);
			trace(_workLine.toString());
		} else {
			_setSideLine(pSide);
		}
		return _workLine.testLineSegmentIntercept(pLine, false, pResult);
	}

	public function toString() : String {
		return "{ WMRectangle x: " + _x + " y: " + _y + " width: " + _width + " height: " + _height + " }";
	}
}
