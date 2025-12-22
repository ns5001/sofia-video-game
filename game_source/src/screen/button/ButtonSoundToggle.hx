package screen.button;

import workinman.ui.Button;

class ButtonSoundToggle extends Button {

	private var _assetUpOn : String;
	private var _assetOverOn : String;
	private var _assetDownOn : String;
	private var _assetDisabledOn : String;
	private var _assetUpOff : String;
	private var _assetOverOff : String;
	private var _assetDownOff : String;
	private var _assetDisabledOff : String;

	public function new( pData:ButtonSoundToggleProp ) {
		super( pData );

		_assetUpOn = pData.assetUp;
		_assetOverOn = pData.assetOver;
		_assetDownOn = pData.assetDown;
		_assetDisabledOn = pData.assetDisabled;
		_assetUpOff = pData.assetUpOff;
		_assetOverOff = pData.assetOverOff;
		_assetDownOff = pData.assetDownOff;
		_assetDisabledOff = pData.assetDisabledOff;

		_refreshMuteState();
		_renderUp();
	}

	public override function dispose() : Void {
		_assetUpOn = null;
		_assetOverOn = null;
		_assetDownOn = null;
		_assetDisabledOn = null;
		_assetUpOff = null;
		_assetOverOff = null;
		_assetDownOff = null;
		_assetDisabledOff = null;
		super.dispose();
	}

	private override function _doClick() : Void {
		if ( !_flagEnabled ) {
			return;
		}
		workinman.WMSound.muteAll = !workinman.WMSound.muteAll;
		_refreshMuteState();
		_renderUp();
	}

	private function _refreshMuteState() : Void {
		if ( workinman.WMSound.muteAll ) {
			_assetUp = _assetUpOff;
			_assetOver = _assetOverOff;
			_assetDown = _assetDownOff;
			_assetDisabled = _assetDisabledOff;
		} else {
			_assetUp = _assetUpOn;
			_assetOver = _assetOverOn;
			_assetDown = _assetDownOn;
			_assetDisabled = _assetDisabledOn;
		}
	}
}
