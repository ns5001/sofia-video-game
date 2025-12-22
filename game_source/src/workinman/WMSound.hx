package workinman;

import workinman.event.Event1;
import workinman.sound.*;
import workinman.tween.*;
import flambe.sound.Sound;
import flambe.sound.Mixer;

class WMSound {

	// Events
	public static var eventVOStatus : Event1<VO_STATUS> = new Event1<VO_STATUS>();

	// Members
	public static var subtitleQueue(default,null) : Array<String> = [];
	private static var _sound : Array<PlaybackDef> = new Array<PlaybackDef>();
	private static var _voQueue : Array<VOQueue> = new Array<VOQueue>();
	private static var _tween : Tweener = new Tweener();
	private static var _music : PlaybackDef = null;
	private static var _vo : PlaybackDef = null;
	private static var _lastVO : VOQueue = null;
	private static var _musicId : String = "";
	private static var _stateVo : VO_STATUS = VO_STATUS.STOPPED;

	public static var duckMusic : Bool = true; //toggle for music ducking in/out durring vo
	private static var _musicGain : Float = 1;
	public static var muteAll(default,set) : Bool;
	public static var muteSystem(default,set) : Bool;
	public static var muteMusic(default,set) : Bool;
	public static var muteSfx(default,set) : Bool;
	public static var muteVo(default,set) : Bool;

	private static function set_muteAll( pVal:Bool ) : Bool { muteAll = pVal; _toggleMute(); return pVal; }
	private static function set_muteSystem( pVal:Bool ) : Bool { muteSystem = pVal; _toggleMute(); return pVal; }
	private static function set_muteMusic( pVal:Bool ) : Bool { muteMusic = pVal; _toggleMute(); return pVal; }
	private static function set_muteSfx( pVal:Bool ) : Bool { muteSfx = pVal; _toggleMute(); return pVal; }
	private static function set_muteVo( pVal:Bool ) : Bool { muteVo = pVal; _toggleMute(); return pVal; }

	private static function _toggleMute() : Void {
		if ( _getMuteState( muteMusic ) ) {
			stopMusic();
		} else {
			playMusic( _musicId, _musicGain );
		}
		if ( _getMuteState( muteSfx ) ) {
			stopAllSound();
		}
		if ( _getMuteState( muteVo ) ) {
			stopVO();
		}
	}

	private static function _setVOState( pState:VO_STATUS ) : Void {
		if ( pState == _stateVo ) {
			return;
		}
		_stateVo = pState;
		switch ( _stateVo ) {
			case VO_STATUS.STOPPED:
				if ( _music != null && duckMusic) {
					_tween.tween( { target:_music, duration:.15, overwrite:true, ease:Ease.inOutQuad }, { volume:app.ConstantsApp.DEFAULT_GAME_MUSIC_VOLUME } ); // Return ducking volume to normal
				}
			case VO_STATUS.PLAYING:
				if ( _music != null && duckMusic) {
					_tween.tween( { target:_music, duration:.15, overwrite:true, ease:Ease.inOutQuad }, { volume:app.ConstantsApp.DUCKING_GAME_MUSIC_VOLUME } ); // Start ducking the volume
				}
			case VO_STATUS.PAUSED:
		}
		eventVOStatus.dispatch( pState );
	}

	private static function _getMuteState( pMute : Bool ) : Bool {
		return muteAll || muteSystem || pMute;
	}

	public static function playMusic( pId:String, pGain:Float = 1, pFadeOutTime:Float = -1 ) : Void {
		if ( pId == null || pId == "" || _musicId == pId && _music != null ) {
			return;
		}
		_musicId = pId;
		_musicGain = pGain;
		stopMusic( pFadeOutTime, _finishPlayingMusic );
	}

	private static function _finishPlayingMusic() : Void {
		_music = _playAudio( _musicId, _musicGain, null, true, muteMusic );
	}

	public static function stopMusic( pFadeOutTime:Float = -1, pStopComplete:Void->Void = null ) : Void {
		if ( pFadeOutTime > 0 && _music != null ) {
			_tween.tween( { target:_music, duration:pFadeOutTime, overwrite:true, ease:Ease.linear, complete:function () {
				_disposeMusic();
				if ( pStopComplete != null ) {
					pStopComplete();
				}
			} }, { volume:0 } );
			return;
		}
		_disposeMusic();
		if ( pStopComplete != null ) {
			pStopComplete();
		}
	}

	private static function _disposeMusic() : Void {
		if ( _music == null ) {
			return;
		}
		_music.dispose();
		_music = null;
	}

	public static function playSound( pId:String, pGain:Float = 1, pComplete:Void->Void = null, pLoop:Bool = false ) : PlaybackDef {
		var tSound : PlaybackDef = _playAudio( pId, pGain, pComplete, pLoop, muteSfx );
		if ( tSound == null ) {
			return null;
		}
		_sound.push( tSound );
		return tSound;
	}

	public static function stopAllSound() : Void {
		while ( _sound.length > 0 ) {
			_sound.pop().dispose();
		}
	}

	public static function stopSound( pId:String ) : Void {
		var tI : Int = _sound.length;
		while ( tI-- > 0 ) {
			if ( _sound[tI].id == pId ) {
				_sound[tI].dispose();
				_sound.splice(tI,1);
			}
		}
	}

	public static function playVO( pId:String, pLocalization:String, pOverride:Bool = false, pCallback:Void->Void = null, pGain:Float = 1, pDelay:Float = -1 ) : Void {
		if ( pOverride ) {
			stopVO();
		}
		_voQueue.push( new VOQueue( pId, pGain, pCallback, pDelay, pLocalization ) );
	}

	public static function stopVO() : Void {
		while ( _voQueue.length > 0 ) {
			_voQueue.pop().dispose();
		}
		if ( _vo == null ) {
			return;
		}
		_vo.dispose();
		_vo = null;
	}

	public static function isVoPlaying() : Bool {
		return _stateVo != VO_STATUS.STOPPED;
	}

	private static function _playAudio( pId:String, pGain:Float, pComplete:Void->Void, pLoop:Bool, pMuteState:Bool ) : PlaybackDef {
		if ( pId == null || pId == "" || _getMuteState( pMuteState )  ) {
			if ( pComplete != null ) {
				pComplete();
			}
			return null;
		}
		var tSoundAsset : Sound = WMAssets.getSound( pId );
		if ( tSoundAsset == null ) {
			trace('[WMSound](_playAudio) Sound \'${pId}\' not found.');
			if ( pComplete != null ) {
				pComplete();
			}
			return null;
		}
		if ( pLoop ) {
			return new PlaybackDef( pId, tSoundAsset.loop( pGain ), pComplete );
		}
		return new PlaybackDef( pId, tSoundAsset.play( pGain ), pComplete );
	}

	public static function update( dt:Float ) : Void {
		_tween.update(dt);

		// Sound
		var tI : Int = _sound.length;
		while ( tI-- > 0 ) {
			var tSound = _sound[tI];
			if ( tSound.isComplete || tSound.disposed ) {
				tSound.dispose();
				_sound.splice(tI,1);
			}
		}

		// Music
		if ( _music != null && ( _music.isComplete || _music.disposed ) ) {
			_music.dispose();
			_music = null;
		}

		// Vo
		switch ( _stateVo ) {
			case VO_STATUS.STOPPED,VO_STATUS.PAUSED:
				_checkVOQueue( dt );
			case VO_STATUS.PLAYING:
				if ( _vo != null && ( _vo.isComplete || _vo.disposed ) ) {
					_vo.dispose();
					_vo = null;
				}
				if ( _vo == null ) {
					_checkVOQueue( dt );
				}
		}
	}

	private static function _checkVOQueue( dt:Float ) : Void {
		if ( _voQueue.length > 0 ) {
			_voQueue[0].delay -= dt;
			if ( _voQueue[0].delay < 0 ) {
				var tVOQueue : VOQueue = _voQueue.shift();
				subtitleQueue.push(tVOQueue.localization);
				if (_lastVO == null) {
					_lastVO = new VOQueue(tVOQueue.id, tVOQueue.gain, tVOQueue.call, tVOQueue.delay, tVOQueue.localization);
				}
				_lastVO.copy(tVOQueue);
				_vo = _playAudio( tVOQueue.id, 1, function() {
					if (_lastVO.call != null) {
						_lastVO.call();
					}
					subtitleQueue.shift();
				}, false, muteVo );
				tVOQueue.dispose();
				_setVOState( VO_STATUS.PLAYING );
				return;
			}
			_setVOState( VO_STATUS.PAUSED );
			return;
		}
		_setVOState( VO_STATUS.STOPPED );
	}
}
