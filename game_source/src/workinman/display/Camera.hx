package workinman.display;

import app.ConstantsApp;
import workinman.math.WMPoint;
import flambe.math.Point;

class Camera {

	private var _worldRoot : Sprite;
	private var _scratchPoint : Point;

	public var focalLength : Float;

	public function new( pWorldRoot:Sprite, pWorldCenterX:Float, pWorldCenterY:Float ) {
		_worldRoot = pWorldRoot;
		worldCenterX = pWorldCenterX;
		worldCenterY = pWorldCenterY;
		focalLength = 300;
		rotation = 0;
		pos = WMPoint.request();
		_scratchPoint = new Point();
	}

	public function dispose() : Void {
		pos.dispose();
		pos = null;
		_scratchPoint = null;
	}

	public var pos( default,null ) : WMPoint;

	public var worldCenterX( default,null ) : Float;

	public var worldCenterY( default,null ) : Float;

	public var rotation( default,set ) : Float;
	private function set_rotation( pVal:Float ) : Float {
		rotation = pVal;
		_worldRoot.rotation = pVal;
		return rotation;
	}

	public function setWorldCenter( pX:Float, pY:Float ) : Void {
		worldCenterX = pX;
		worldCenterY = pY;
	}

	public function getUIPositionOfScreenPoint( pX:Float, pY:Float, pZ:Float, pResult:WMPoint ) : WMPoint {
		_worldRoot.viewMatrix.inverseTransform( pX, pY, _scratchPoint );
		pResult.x = _scratchPoint.x;
		pResult.y = _scratchPoint.y;
		return pResult;
	}

	public function getWorldPositionOfScreenPoint( pX:Float, pY:Float, pZ:Float, pResult:WMPoint ) : WMPoint {
		_worldRoot.viewMatrix.inverseTransform( pX, pY, _scratchPoint );
		var tScale : Float = 1/_getZScale(pZ);
		pResult.x = pos.x + (worldCenterX + (_scratchPoint.x - worldCenterX) * tScale);
		pResult.y = pos.y + (worldCenterY + (_scratchPoint.y - worldCenterY) * tScale);
		return pResult;
	}

	public function getScreenPositionOfWorldPoint( pX:Float, pY:Float, pZ:Float, pResult:WMPoint ) : WMPoint {
		_worldRoot.viewMatrix.inverseTransform( pX, pY, _scratchPoint );
		var tScale : Float = _getZScale(pZ);
		pResult.x = worldCenterX + ((pX - pos.x) - worldCenterX) * tScale;
		pResult.y = worldCenterY + ((pY - pos.y) - worldCenterY) * tScale;
		return pResult;
	}

	private inline function _getZScale( pZ:Float ) : Float {
		return focalLength/(focalLength - (pos.z - pZ));
	}
}
