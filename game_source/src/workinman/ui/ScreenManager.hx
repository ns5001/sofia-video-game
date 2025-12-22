package workinman.ui;

import workinman.display.Sprite;
import workinman.event.Event2;

class ScreenManager {

	// Screens
	private var _screenOpen				: Array<ScreenBase>; // Open screen instances.
	private var _interfaceDelegate 		: CHANGE_TYPE->Class<ScreenBase>->Void;
	private var _root 					: Sprite;

	// Events
	public static var eventFlowDelegate : Event2<CHANGE_TYPE,Class<ScreenBase>> = new Event2<CHANGE_TYPE,Class<ScreenBase>>();

	/**********************************************************
	@construction
	**********************************************************/
	public function new( pRoot:Sprite, pInterface:CHANGE_TYPE->Class<ScreenBase>->Void ) : Void {
		_root = pRoot;
		_screenOpen	= [];
		_interfaceDelegate = pInterface;
		eventFlowDelegate.add( _dispatchEventChange );
	}

	/**********************************************************
	@description
	**********************************************************/
	public function dispose() : Void {
		if ( _screenOpen != null ) {
			for ( s in _screenOpen ) {
				s.dispose();
			}
			_screenOpen = null;
		}
		_interfaceDelegate = null;
		_root = null;
	}

	/**********************************************************
	@description
	// Close a specific screen if specified, otherwise close the top screen on the stack.
	// If Index is supplied, close the screen at that index (saves time on looping if we already have that info).
	// If the screen is not found, this will also dig into the queue and pop it out.
	**********************************************************/
	public function closeScreen( pId:Class<ScreenBase>, pPlayOutro:Bool = true ) : Void {
		// Check if the screen we're trying to close is open
		var tI : Int = _screenOpen.length;
		while ( tI-- > 0 ) {
			if ( _screenOpen[tI].classType == pId ) {
				_screenOpen[tI].close( pPlayOutro );
				_dispatchEventChange( CHANGE_TYPE.CLOSE_BEGIN, pId);
			}
		}
	}

	/**********************************************************
	@description
	// Close all screens not already closing.
	**********************************************************/
	public function closeAllScreens( pPlayOutro:Bool = false) : Void {
		for ( s in _screenOpen ) {
			s.close(pPlayOutro);
		}
	}

	/**********************************************************
	@description
	pWaitForClosingScreens - Set to FALSE and the screen will open immediately. Se to TRUE and the screen will wait until the following screen condition is met.
	**********************************************************/
	public function openScreen( pId:Class<ScreenBase> ) : Void {
		if ( isScreenOpen(pId) ) {
			trace("[ScreenManager](openScreen) Screen \"" + Type.getClassName( pId ) + "\" is already open, moving it to the top.");
			for ( s in _screenOpen ) {
				// TODO Sort this array?
				if ( s.classType == pId ) {
					_root.addChild( s.root );
					break;
				}
			}
			_dispatchEventChange( CHANGE_TYPE.OPEN_BEGIN, pId );
			_dispatchEventChange( CHANGE_TYPE.OPEN_COMPLETE, pId );
			return;
		}
		trace( "[ScreenManager](openScreen) \"" + Type.getClassName( pId ) + "\"" );
		var tNewScreen : ScreenBase = Type.createInstance( pId, [_root] );
		tNewScreen.open( true );
		_screenOpen.push( tNewScreen );
		tNewScreen = null;
		_dispatchEventChange( CHANGE_TYPE.OPEN_BEGIN, pId );
	}

	/**********************************************************
	@description
	A screen change entails the closing of ALL open screens and the opening of only the requested screen.
	If you want to open a screen on top of other screens, just use open.
	Screen changes wait for the previous screens to close by default.
	**********************************************************/
	public function changeScreenTo( pId:Class<ScreenBase>, pPlayOutroAnimations:Bool = false ) : Void {
        trace( "[ScreenManager](changeTo) \"" + Type.getClassName( pId ) + "\"" );
        app.ConstantsEvent.removeLoader.dispatch();
		// Close any screen other than the one we're changing to
		var tI : Int = _screenOpen.length;
		while ( tI-- > 0 ) {
			if ( _screenOpen[tI].classType == pId ) {
				continue;
			}
			_screenOpen[tI].close(pPlayOutroAnimations);
		}
		// Open the new screen
		openScreen(pId);
	}

	/**********************************************************
	@description
	**********************************************************/
	public function update( dt:Float ) : Void {
		var tI : Int = _screenOpen.length;
		while ( tI-- > 0 ) {
			var s = _screenOpen[tI];
			s.update(dt);
			if ( s.doDelete ) {
				s.dispose();
				_screenOpen.splice(tI,1);
			}
		}
	}

	/**********************************************************
	@description
	// test if a specific screen is open.
	**********************************************************/
	public function isScreenOpen( pId:Class<ScreenBase> ) : Bool {
		for ( s in _screenOpen ) {
			if ( s.classType == pId ) {
				return true;
			}
		}
		return false;
	}

	/**********************************************************
	@description
	**********************************************************/
	private function _dispatchEventChange( pChangeId:CHANGE_TYPE, pScreenId:Class<ScreenBase> ) : Void {
		_interfaceDelegate( pChangeId, pScreenId );
	}
}
