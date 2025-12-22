package workinman.ui;

import workinman.display.FillSprite;
import workinman.display.Sprite;
import workinman.display.ElementManager;
import workinman.display.ImageSprite;
import workinman.tween.Tweener;
import workinman.input.INPUT_SWIPE;
import flambe.display.Texture;
import flambe.input.Key;
import flambe.System;
import app.INPUT_TYPE;
import app.ConstantsApp;
import screen.display.DisplayLoadingProgress;

@:keepSub class ScreenBase {

    private var _clickWall          			    	: FillSprite;
    private var _elementManager	     				   	: ElementManager;
    private var _tween             				     	: Tweener;
    private var _state   								: STATE_SCREEN;
    public var doDelete	                				: Bool;
	public var classType( default,null )				: Class<ScreenBase>;

    private var _border                                 : ImageSprite;
    private var _closing : Bool;
    private var _loadWidget		                       	: DisplayLoadingProgress;

	private var _highlightedButton : Button;
	private var _highlightIndex : Int = -1;

	private static inline var _DEFAULT_LAYER 			: String = "ui_default";
	private static inline var _LOADER_LAYER 			: String = "ui_loader";
	private static inline var _BORDER_LAYER 			: String = "ui_border";
    private static inline var _DEBUG_SHOW_CLICKWALL 	: Bool = false;

    public function new( pRoot:Sprite ) : Void {
		classType = Type.getClass(this);
        _elementManager = new ElementManager( pRoot, ConstantsApp.STAGE_CENTER_X, ConstantsApp.STAGE_CENTER_Y, true );
        if ( _useClickWall() ) {
            // Add the clickwall to the very root of the ElementManager
            _clickWall = _elementManager.root.addElement( new FillSprite( {color:0xFF0000, sizeX:ConstantsApp.STAGE_WIDTH, sizeY:ConstantsApp.STAGE_HEIGHT, alpha:_DEBUG_SHOW_CLICKWALL?.5:0 } ) );
        }
        _elementManager.addLayer( _DEFAULT_LAYER, true );
        _elementManager.addLayer( _LOADER_LAYER );
        _elementManager.addLayer( _BORDER_LAYER );
        _tween = new Tweener();
        _buildScreen();
        _onEventResizeCanvas();
        doDelete = false;
		//_setState( STATE_SCREEN.IN );
        _addEventListeners();
    }

    public function dispose() : Void {
        _removeEventListeners();
        _clickWall = null;
        if ( _elementManager != null ) {
            _elementManager.dispose();
            _elementManager = null;
        }
        if ( _tween != null ) {
            _tween.dispose();
            _tween = null;
        }
        _state = null;
		classType = null;
    }

    /**********************************************************
    @description
    **********************************************************/
    private function _buildScreen() : Void {
        // Override
        _border = _elementManager.addElement( new ImageSprite( { asset: manifest.Texture.border, scaleY: 0.5, scaleX: 0.5135, alpha:0 } ), _BORDER_LAYER);
        _border.inputEnabled = false;

        _addLoader();
    }

    /**********************************************************
    @description
    **********************************************************/
    private function _addEventListeners() : Void {
        app.ConstantsEvent.resizeCanvas.add( _handleResizeCanvas );
        app.ConstantsEvent.addLoader.add( _addLoader );
        app.ConstantsEvent.removeLoader.add( _removeLoader );

        WMInput.eventInput.add( _handleInput );
    }

    /**********************************************************
    @description
    **********************************************************/
    private function _removeEventListeners() : Void {
        app.ConstantsEvent.resizeCanvas.remove( _handleResizeCanvas );
        app.ConstantsEvent.addLoader.remove( _addLoader );
        app.ConstantsEvent.removeLoader.remove( _removeLoader );

        WMInput.eventInput.remove( _handleInput );
    }

    public var root( get,never ) : Sprite;
    public function get_root() : Sprite {
        return _elementManager.root;
    }

    /**********************************************************
    @description Add a bubble-wipe loading screen.
    **********************************************************/
    private function _addLoader() : Void {
		if ( _loadWidget == null ) {
			_loadWidget = _elementManager.addElement( new DisplayLoadingProgress( { tween:_tween, y:0 } ), "ui_loader" );
		}
		if ( _loadWidget.active == false ) {
			_loadWidget.tweenIn(true);
        }
        
        _loadWidget.inputEnabled = false;
	}

    /**********************************************************
    @description Remove a bubble-wipe loading screen.
    **********************************************************/
	private function _removeLoader() : Void {
		if ( _loadWidget == null || _loadWidget.active == false ) {
			return;
		}
		_loadWidget.tweenOut();
	}

    /*********************************************************************************************
    METHODS TO OVERRIDE
    *********************************************************************************************/
    private function _useClickWall() : Bool 	{ return true; }

    /*********************************************************
    @description
    **********************************************************/
	private function _setState( pState:STATE_SCREEN ) {
		if ( _state == pState ) {
			return;
		}
		_state = pState;
		switch ( _state ) {
			case STATE_SCREEN.IN:
				_setInState();
			case STATE_SCREEN.OPENED:
	        	_setOpenedState();
			case STATE_SCREEN.OUT:
		}
	}


    private function _setInState() : Void {
        // Override...
        _finishInState();
    }

    private function _finishInState() : Void {
		_setState( STATE_SCREEN.OPENED );
        ScreenManager.eventFlowDelegate.dispatch( CHANGE_TYPE.OPEN_COMPLETE, classType );

        app.ConstantsEvent.removeLoader.dispatch();
    }

    /*********************************************************
    @description
    **********************************************************/
    private function _setCloseState() : Void {
        // Override...
        _finishCloseState();
    }

    private function _finishCloseState() : Void {
        doDelete = true;
		ScreenManager.eventFlowDelegate.dispatch( CHANGE_TYPE.CLOSE_COMPLETE, classType );
    }

    /*********************************************************
    @description
    **********************************************************/
    private function _setOpenedState() : Void {
        // Override...
    }

    /*********************************************************************************************
    INTERFACE METHODS - OVERRIDE FRIENDLY, BUT NOT NORMALLY NECESSARY
    *********************************************************************************************/

    /**********************************************************
    @description
    **********************************************************/
    public function update( dt:Float ) : Void {
        _tween.update(dt);
        _elementManager.update(dt);
    }

    private function _handleInput( pType:INPUT_TYPE, pDown:Bool ) : Void {
        if ( _clearInput() == false ) {
            return;
        }
        _onInput( pType, pDown );

        _checkButtonHighlight(pType, pDown);
    }

    

	private function _checkButtonHighlight( pType:INPUT_TYPE, pDown:Bool ) : Void {
		switch ( pType ) {
        case INPUT_TYPE.UI_TAB:
          	if ( pDown ) {
				if (_highlightedButton != null) {
					_highlightedButton.setHighlight(false);
				}
				var buttonList = _elementManager.getAllButtons();
				if (buttonList.length == 0) {
					return;
				}

                var reverse = System.keyboard.isDown(Key.Shift);    

				var start = _highlightIndex;

                do {
                    _highlightIndex += (reverse ? -1 : 1);
                    if (_highlightIndex >= buttonList.length) _highlightIndex = 0;
                    if (_highlightIndex < 0) _highlightIndex = buttonList.length - 1;
				} while (_highlightIndex != start && !buttonList[_highlightIndex].isSelectable());
					
				

				_highlightedButton = buttonList[_highlightIndex];
				_highlightedButton.setHighlight(true);
		  	}
        case INPUT_TYPE.MOVE_LEFT:
            if ( pDown ) {
				if (_highlightedButton != null) {
					_highlightedButton.setHighlight(false);
				}
				var buttonList = _elementManager.getAllButtons();
				if (buttonList.length == 0) {
					return;
				}

                var reverse = true;    

				var start = _highlightIndex;

                do {
                    _highlightIndex += (reverse ? -1 : 1);
                    if (_highlightIndex >= buttonList.length) _highlightIndex = 0;
                    if (_highlightIndex < 0) _highlightIndex = buttonList.length - 1;
				} while (_highlightIndex != start && !buttonList[_highlightIndex].isSelectable());
					
				

				_highlightedButton = buttonList[_highlightIndex];
				_highlightedButton.setHighlight(true);
		  	}
        case INPUT_TYPE.MOVE_RIGHT:
            if ( pDown ) {
				if (_highlightedButton != null) {
					_highlightedButton.setHighlight(false);
				}
				var buttonList = _elementManager.getAllButtons();
				if (buttonList.length == 0) {
					return;
				}

                var reverse = false;    

				var start = _highlightIndex;

                do {
                    _highlightIndex += (reverse ? -1 : 1);
                    if (_highlightIndex >= buttonList.length) _highlightIndex = 0;
                    if (_highlightIndex < 0) _highlightIndex = buttonList.length - 1;
				} while (_highlightIndex != start && !buttonList[_highlightIndex].isSelectable());
					
				

				_highlightedButton = buttonList[_highlightIndex];
				_highlightedButton.setHighlight(true);
		  	}
		case INPUT_TYPE.POINTER:
			if (pDown) {
				if (_highlightedButton != null) {
					_highlightedButton.setHighlight(false);
				}
			}
		case INPUT_TYPE.UI_OK:
			if (pDown) {
				if (_highlightedButton != null) {
					_highlightedButton.forceClick();
				}
			}
        default:
      }
	}

    /**********************************************************
    @description
    **********************************************************/
    private function _onInput( pType:INPUT_TYPE, pDown:Bool ) : Void {
        // Override
    }

    /**********************************************************
    @description
    **********************************************************/
    public function open( pPlayIntro:Bool = true ) : Void {
        if ( pPlayIntro ) {
			_setState( STATE_SCREEN.IN );
			return;
        }
		_finishInState();
    }

    /**********************************************************
    @description
    **********************************************************/
    public function close( pPlayOutro:Bool = true ) : Void {
        if ( _state == STATE_SCREEN.OUT ) {
            return;
        }
		_setState( STATE_SCREEN.OUT );
        if ( pPlayOutro ) {
            _setCloseState();
			return;
        }
		_finishCloseState();
    }

    private function _handleResizeCanvas( pScale:Float ) : Void {
        if ( _clickWall != null ) {
            _clickWall.sizeX = Math.floor(ConstantsApp.STAGE_WIDTH);
            _clickWall.sizeY = Math.floor(ConstantsApp.STAGE_HEIGHT);
        }
        _onEventResizeCanvas();
    }

    /**********************************************************
    @description
    **********************************************************/
    private function _onEventResizeCanvas() : Void {
        // Override
        var tBorderTexture : Texture = workinman.WMAssets.getTexture(_border.asset);

        _border.scaleX = ConstantsApp.STAGE_WIDTH / tBorderTexture.width;
        _border.scaleY = ConstantsApp.STAGE_HEIGHT / tBorderTexture.height;
    }

    private function _clearInput() : Bool {
        // Override this with further criteria
        if ( _state != STATE_SCREEN.OPENED ) {
            return false;
        }
        return true;
    }

    private function _clearButtonInput() : Bool {
        // Override this with further criteria
        if ( _state != STATE_SCREEN.OPENED ) {
            return false;
        }
        return true;
    }
}
