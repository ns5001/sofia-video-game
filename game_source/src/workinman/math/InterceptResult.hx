package workinman.math;

class InterceptResult {

	private var _success	: Bool;
	private var _result		: WMPoint;
	private var _line1		: WMLine;
	private var _line2		: WMLine;

	/**********************************************************
	@constructor
	**********************************************************/
	public function new( pSuccess:Bool, pInterceptPoint:WMPoint = null ) : Void {
		_success = pSuccess;
		_result	= WMPoint.request();
		_line1 = WMLine.request();
		_line2 = WMLine.request();
		if ( pInterceptPoint != null ) {
			_result.toPoint(pInterceptPoint);
		}
	}

	public function dispose() : Void {
		_result.dispose();
		_result = null;
		_line1.dispose();
		_line1 = null;
		_line2.dispose();
		_line2 = null;
	}

	public var success(get_success,set_success) : Bool;
	private function get_success() : Bool { return _success; }
	private function set_success( pSuccess:Bool ) : Bool { _success = pSuccess; return _success; }

	public var result(get_result,set_result) : WMPoint;
	private function get_result() : WMPoint { return _result; }
	private function set_result( pResult:WMPoint ) : WMPoint {
		if ( pResult == null ) {
			_result.to(0,0);
		} else {
			_result.toPoint(pResult);
		}
		return _result;
	}

	public var line1(get_line1,set_line1) : WMLine;
	private function get_line1() : WMLine { return _line1; }
	private function set_line1( pLine1:WMLine ) : WMLine { _line1.toLine(pLine1); return _line1; }

	public var line2(get_line2,set_line2) : WMLine;
	private function get_line2() : WMLine { return _line2; }
	private function set_line2( pLine2:WMLine ) : WMLine { _line2.toLine(pLine2); return _line2; }

	public function toString() : String { return "[Intercept Result] " + (_success?"Collided! -> " + _result : "Failed."); }
}
