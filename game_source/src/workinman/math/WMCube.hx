package com.workinman.utils;

import com.workinman.math.WMPoint;
import com.workinman.math.WMMath;
import flambe.math.Rectangle;
class WMCube{
	
	private var _dimensions		: WMPoint;
	private var _position		: WMPoint;
	private var _offset			: WMPoint;

	public function new(pDimensions:WMPoint, pPosition:WMPoint, pOffset:WMPoint = null):Void
	{
		_dimensions = pDimensions;
		_position = pPosition;	
		_offset = pOffset;
	}
	
	public function intersectsWith(cube:WMCube):Bool
	{	
		//trace(x + " : " + cube.x + " : " + Math.abs(x-cube.x));
		
		if(Math.abs(x - cube.x) > (width * .5) + (cube.width * .5)){
			//trace("x test");
			return false;
		}
		if(Math.abs(y - cube.y) > (height * .5) + (cube.height * .5)){
			//trace("y test");
			return false;
		}
		if(Math.abs(z - cube.z) > (depth * .5) + (cube.depth * .5)){
			//trace(z + " : " + cube.z);
			//trace("z test");
			return false;
		}
		
		//trace(WMMath.testRectangleIntersection(new Rectangle(x-width/2, y-width/2,width,height), new Rectangle(cube.x-cube.width/2, cube.y-cube.width/2,cube.width,cube.height)));
		
		return true;// WMMath.testRectangleIntersection(new Rectangle(x-width/2, y-height/2,width,height), new Rectangle(cube.x-cube.width/2, cube.y-cube.height/2,cube.width,cube.height));
	}
	
	public function intersectsZPlane(cube:WMCube)
	{
		if(Math.abs(x - cube.x) > (width * .5) + (cube.width * .5)){
			//trace("x test");
			return false;
		}
		if(Math.abs(y - cube.y) > (height * .5) + (cube.height * .5)){
			//trace("y test");
			return false;
		}
		if(Math.abs(z - cube.z) > (depth * 5)){
			//trace(z + " : " + cube.z);
			//trace("z test");
			return false;
		}
		
		return true;
	}
	
	public function copy():WMCube{
		return new WMCube(_dimensions.copy(), _position.copy());
	}
	
	public function set(pDimensions:WMPoint, pPosition:WMPoint){
		_dimensions = pDimensions;
		_position = pPosition;
	}
	
	public var dimensions(get, set):WMPoint;
	public var width(get, set):Float;
	public var height(get, set):Float;
	public var depth(get, set):Float;
	public var position(get, set):WMPoint;
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var z(get, set):Float;
	public var offset(get, set):WMPoint;
	public var offsetX(get, set):Float;
	public var offsetY(get, set):Float;
	public var offsetZ(get, set):Float;
	
	private function get_dimensions():WMPoint{return _dimensions;}
	private function get_width():Float{return _dimensions.x;}
	private function get_height():Float{return _dimensions.y;}
	private function get_depth():Float{return _dimensions.z;}
	private function get_position():WMPoint{return _position;}
	private function get_x():Float{return _position.x;}
	private function get_y():Float{return _position.y;}
	private function get_z():Float{return _position.z;}
	private function get_offset():WMPoint{return _offset;}
	private function get_offsetX():Float{return _offset.x;}
	private function get_offsetY():Float{return _offset.y;}
	private function get_offsetZ():Float{return _offset.z;}
	

	private function set_dimensions(pDimensions:WMPoint):WMPoint{return _dimensions = pDimensions.copy();}
	private function set_width(pWidth:Float):Float{return _dimensions.x = pWidth; }
	private function set_height(pHeight:Float):Float{return _dimensions.y = pHeight;}
	private function set_depth(pDepth:Float):Float{return _dimensions.z = pDepth;} 
	private function set_position(pPosition:WMPoint):WMPoint{return _position = pPosition.copy();}
	private function set_x(pX:Float):Float{return _position.x = pX;}
	private function set_y(pY:Float):Float{return _position.y = pY;}
	private function set_z(pZ:Float):Float{return _position.z = pZ;}
	private function set_offset(pOffset:WMPoint):WMPoint{return _offset = pOffset;}
	private function set_offsetX(pX:Float):Float{return _offset.x = pX;}
	private function set_offsetY(pY:Float):Float{return _offset.y = pY;}
	private function set_offsetZ(pZ:Float):Float{return _offset.z = pZ;}
}
