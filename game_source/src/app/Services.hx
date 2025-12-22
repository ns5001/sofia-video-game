package app;
import flambe.System;

class Services {
	private static var _flagCanadaTrackingEnabled : Bool = false;
	private static var _canadaShowGameTitle	: String = "";
	public static function initMain() : Void {
		//Initialize SDK
		// System.root.add(new SDKComponent());
		//Add AutoScale
		// TODO Not necessary
		//System.root.add(new AutoScale());
		// Hook up system volume control
		// GameEventListener.onAudioToggle = function(enabled : Bool) : Void {
		// 	System.volume._ = enabled ? 1 : 0;
		// }

		// Send load start event
		// GameEventEmitter.sendGameEvent(GameEventEmitter.ON_LOADING_START);
	}
	public static function initServices() : Void {

	}
	public static function setPlaybackToggle( pFunction:Bool->Void ) : Void {
		// GameEventListener.onPlaybackToggle = pFunction;
	}
	public static function onBootstrapFinished() : Void {
		//GameEventEmitter.sendGameEvent(GameEventEmitter.GET_LOADING_PROGRESS, 1/3);
	}
	public static function onPreloadFinished() : Void {
		//GameEventEmitter.sendGameEvent(GameEventEmitter.GET_LOADING_PROGRESS, 2/3);
	}
	public static function onInitialFinished() : Void {
		// GameEventEmitter.sendGameEvent(GameEventEmitter.ON_LOADING_END);
	}
	public static function onTitleStart() : Void {
		// GameEventEmitter.sendGameEvent(GameEventEmitter.ON_TITLE_SCREEN_START);
	}
	public static function onSplashPlay() : Void {
	}
	public static function onTitleEnd() : Void {
		// GameEventEmitter.sendGameEvent(GameEventEmitter.ON_TITLE_SCREEN_END);
	}
	public static function onGameStart() : Void {
		//GameEventEmitter.sendGameEvent(GameEventEmitter.ON_LEVEL_START);
	}
	public static function onPlayAgain() : Void {
		//GameEventEmitter.sendGameEvent(GameEventEmitter.ON_PLAY_AGAIN);
	}
	public static function onGameEnd() : Void {
		//GameEventEmitter.sendGameEvent(GameEventEmitter.ON_GAME_OVER);
	}
	public static function onPauseEvent() : Void {
		//GameEventEmitter.sendGameEvent(GameEventEmitter.ON_PAUSE);
	}
	public static function onResumeEvent() : Void {
		//GameEventEmitter.sendGameEvent(GameEventEmitter.ON_RESUME);
	}
	public static function update(dt:Float) : Void {
	}
}