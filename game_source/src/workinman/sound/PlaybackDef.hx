package workinman.sound;

import flambe.sound.Playback;
import flambe.util.Disposable;

class PlaybackDef {

	public var id(default,null) : String;
	private var _playback : Playback;
	private var _complete : Void->Void;
	private var _completeListener : Disposable;
	public var isComplete(default,null) : Bool;
	public var disposed(default,null) : Bool;
	public var playback(get_playback, null) : Playback;
	public function get_playback():Playback {return _playback;}

	public var volume(get_volume, set_volume) : Float;
	public function get_volume() : Float 
	{ 
		if(_playback == null) { return 0; }
		return _playback.volume._; 
	}
	public function set_volume(pValue : Float) : Float
	{ 
		//clean the input
		if(_playback == null) { return 0; }
		if(pValue > 1) { pValue = 1; }
		else if (pValue < 0) { pValue = 0; }

		//save the value to value and return
		_playback.volume._ = pValue;
		return pValue;
	}

	public function new( pId:String, pPlayback:Playback, pComplete:Void->Void ) : Void {
		id = pId;
		_playback = pPlayback;
		_completeListener = _playback.complete.watch( _onCompleteEvent );
		_complete = pComplete;
		isComplete = false;
		disposed = false;
		volume = _playback.volume._;
	}

	private function _onCompleteEvent( pComplete:Bool, p1:Bool ) : Void {
		if ( pComplete == false ) {
			return;
		}
		isComplete = true;
	}

	public function dispose() : Void {
		if ( disposed == true ) {
			return;
		}
		disposed = true;
		_completeListener.dispose();
		_completeListener = null;
		_playback.dispose();
		_playback = null;
		id = null;
		if ( _complete != null ) {
			var tComplete = _complete;
			_complete = null;
			tComplete();
		}
	}
}
