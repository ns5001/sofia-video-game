package workinman.ui;

import workinman.display.Element;
import workinman.tween.Tweener;

class Display extends Element {

	private var _flagLocked : Bool;
	private var _tween : Tweener;

	public function new( pData:DisplayProp ) {
		_flagLocked = false;
		_tween = pData.tween;
		super( pData );
	}

	private override function _addEventListeners() : Void {
		super._addEventListeners();
		app.ConstantsEvent.updateDisplay.add( _onUpdateDisplay );
	}

	private override function _removeEventListeners() : Void  {
		super._removeEventListeners();
		app.ConstantsEvent.updateDisplay.remove( _onUpdateDisplay );
	}

	private function _onUpdateDisplay( pVal:String ):Void {
		if ( _flagLocked ) {
			return;
		}
		if ( pVal == _updateValue() ) {
			_refresh();
		}
	}

	private function _refresh():Void {
		//override
	}

	private function _updateValue() : String { return null; }

	public override function dispose() : Void {
		_tween = null;
		super.dispose();
	}

	public function lock() : Void	{
		_flagLocked = true;
	}

	public function unlock() : Void	{
		_flagLocked = false;
	}
}
