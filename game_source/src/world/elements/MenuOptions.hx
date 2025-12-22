package world.elements;

import workinman.display.ImageSprite;
import workinman.display.FillSprite;
import workinman.display.Element;
import workinman.display.Text;
import workinman.event.Event0;
import workinman.tween.Tweener;
import workinman.tween.Ease;
import workinman.ui.Button;
import workinman.WMSound;
import workinman.WMTimer;
import app.ConstantsApp;

class MenuOptions extends Element 
{
  private var _closing = false;
  private var _instructionsShown = false;

  private var _tween : Tweener;
  private var _clear : Void->Bool;
  
	private var _homeButton : Button;
  private var _helpButton : Button;
  private var _canvasCover : FillSprite;
  private var _canvasCoverClick : Button;
  private var _homeConfirm : ImageSprite;
  private var _popup : ImageSprite;

  private var _clickVolume              : Float = .5;
  private var _popupAudio               : String = "";
  private var _isAlt                    : Bool = false;
  private var _hideDefinition           : Bool = false;

  private var _curTimeout               : Float = 0.0;
  private var _maxTimeout               : Float = 60.0;
  private var _timeoutReached           : Bool = false;

  private var _screen : String;

  public var eventTimeout : Event0 = new Event0();

  private function _showAnyPopup() : Bool {
      return _isAlt && !_hideDefinition;
  }

	//Constructor
	public function new(pData : Dynamic, pScreen : String, pPopupAsset : String, pPopupAudio : String, pTween : Tweener, pClear : Void->Bool, pIsAlt : Bool = false, pHideDefinitionPopup : Bool = false) : Void 
	{
    super(pData);
    _screen = pScreen;
    _tween = pTween;
    _clear = pClear;
    _popupAudio = pPopupAudio;
    _isAlt = pIsAlt;
    _hideDefinition = pHideDefinitionPopup;

    _homeButton = addElement( new Button( { asset: manifest.Texture.btn_home, x: -ConstantsApp.STAGE_CENTER_X + 50, y: -ConstantsApp.STAGE_CENTER_Y + 50, tween:pTween, clear: pClear, scale: .5 } ));
    _homeButton.eventClick.add( _openExitMenu );

    if (!pIsAlt) {
      _helpButton = addElement( new Button( { asset: manifest.Texture.btn_help, x: ConstantsApp.STAGE_CENTER_X - 50, y: -ConstantsApp.STAGE_CENTER_Y + 50, tween:pTween, clear: pClear, scale: .5 } ));
      _helpButton.eventClick.add( function() {
        WMSound.playSound(manifest.Sound.sofia_click, _clickVolume);
        app.GoogleAnalytics.LogEvent("Clicked Help_web", { 'event_label':"survey"});
        
        if(!_instructionsShown)
          _introInstructions();
        else
          hideInstructions();
      });
    }
    
    if (!pHideDefinitionPopup)
      _addInstruction(pPopupAsset);

    _canvasCover = addElement(new FillSprite( { color:0x000000, sizeX:ConstantsApp.STAGE_WIDTH,  sizeY:ConstantsApp.STAGE_HEIGHT, alpha:0 } ) );
    _canvasCover.inputEnabled = false;
    _canvasCover.addElement( new Button( { tween:pTween, clear: pClear } )).setCustomHitBox(ConstantsApp.STAGE_WIDTH, ConstantsApp.STAGE_HEIGHT)
      .eventClick.add( _closeExitMenu );
    
    // if (!pIsAlt) {
      _homeConfirm = addElement( new ImageSprite({ asset: manifest.Texture.quit_popup, y: -600 /*-60*/ }));
      _homeConfirm.addElement( new Button( { asset: manifest.Texture.btn_check, x: -100, y: 160, tween:pTween, clear: pClear } ))
        .eventClick.add( _returnToSplash );
      _homeConfirm.addElement( new Button( { asset: manifest.Texture.btn_x, x: 100, y: 160, tween:pTween, clear: pClear } ))
        .eventClick.add( function () {
          WMSound.playSound(manifest.Sound.sofia_click, _clickVolume);
          _closeExitMenu();
        });
      _homeConfirm.inputEnabled = false;
    // }
	}

	// UPDATE AND DISPOSE ----------------------------------------------
	public override function update(dt:Float) : Void 
	{
    // disable timeout for now
    //_curTimeout += dt;
    
    if (_curTimeout >= _maxTimeout && !_timeoutReached) {
      _timeoutReached = true;
      _returnToSplash();
    }

		super.update(dt); 
	}

  public function resetCountdown() : Void {
    _curTimeout = 0;
  }

	public override function dispose() : Void
	{
    _tween = null;
    _clear = null;

    WMTimer.stop("hide_timer"+_screen);

		_homeButton = null;
		_helpButton = null;
		_canvasCover = null;
		_canvasCoverClick = null;
		_homeConfirm = null;
		_popup = null;

		super.dispose();
  }

  private function _returnToSplash () : Void {
    if ( _closing == false ) {
      _closing = true;

      WMSound.playSound(manifest.Sound.sofia_click, _clickVolume);

      app.GoogleAnalytics.LogEvent("Completion_web", { 'event_label':"reset"});

      app.ConstantsEvent.addLoader.dispatch();
      app.ConstantsEvent.flow.dispatch( app.FLOW.ATTRACT_PLAY );
    }
  }
  private function _openExitMenu () : Void {
    WMSound.playSound(manifest.Sound.sofia_click, _clickVolume);

    _tween.tween( { target: _homeConfirm, duration: .4, ease: Ease.outQuad, complete:function() {
      _homeConfirm.inputEnabled = true;
    }  }, { y: -60 } );
    _tween.tween( { target: _canvasCover, duration: .4, ease: Ease.outQuad, complete:function() {
      _canvasCover.inputEnabled = true;
    } }, { alpha: .75 } );
  }
  private function _closeExitMenu () : Void {
    _canvasCover.inputEnabled = false;
    _homeConfirm.inputEnabled = false;
    _tween.tween( { target: _homeConfirm, duration: .4, ease: Ease.outQuad }, { y: -600 } );
    _tween.tween( { target: _canvasCover, duration: .4, ease: Ease.outQuad }, { alpha: 0 } );
  }

  private function _addInstruction (pPopupAsset : String) : Void {
    _popup = addElement ( new ImageSprite({ asset: pPopupAsset, x: 0,
      y: _showAnyPopup() ? ConstantsApp.STAGE_HEIGHT/2 + 80 : - ConstantsApp.STAGE_HEIGHT/2 - 80
    }));
    if (_showAnyPopup())
      _popup.addElement ( new Text ( { text:manifest.localization.cutscene.Ids.instruction, x: 0, y: 0 } ));

    _popup.addElement ( new Button ({ tween:_tween, clear: _clear })).setCustomHitBox(500, 150).eventDown.add(function () {
      hideInstructions();
    });

    _introInstructions();
  }
  private function _introInstructions () : Void {
    if (_instructionsShown) return;

    WMSound.playVO(_popupAudio, "");
    
    _instructionsShown = true;

    _tween.tween( { target: _popup, duration: .4, ease: Ease.outQuad }, {
      y: _showAnyPopup() ? ConstantsApp.STAGE_HEIGHT/2 - 80 : - ConstantsApp.STAGE_HEIGHT/2 + 80
    } );

    WMTimer.start(function () {
      _tween.tween( { target: _popup, duration: .4, ease: Ease.outQuad }, {
        y: _showAnyPopup() ? ConstantsApp.STAGE_HEIGHT/2 + 80 : - ConstantsApp.STAGE_HEIGHT/2 - 80
      } );
      _instructionsShown = false;
    }, 6, "hide_timer"+_screen);
  }
  public function hideInstructions () : Void {
    WMSound.stopVO();
    WMTimer.stop("hide_timer"+_screen);
    _instructionsShown = false;
    _tween.tween( { target: _popup, duration: .4, ease: Ease.outQuad }, {
      y: _showAnyPopup() ? ConstantsApp.STAGE_HEIGHT/2 + 80 : - ConstantsApp.STAGE_HEIGHT/2 - 80
    } );
  }

  public function updateInstructions() : Void {
    _popup.setAsset(manifest.Texture.popup_panel_short);
    _popup.addElement ( new Text ( { text:manifest.localization.park.Ids.instruction, x: 0, y: 0 } ));

    _instructionsShown = true;

    _tween.tween( { target: _popup, duration: .4, ease: Ease.outQuad }, {
      y: _showAnyPopup() ? ConstantsApp.STAGE_HEIGHT/2 - 80 : - ConstantsApp.STAGE_HEIGHT/2 + 80
    } );
    WMTimer.stop("hide_timer"+_screen);
    WMTimer.start(function () {
      _tween.tween( { target: _popup, duration: .4, ease: Ease.outQuad }, {
        y: _showAnyPopup() ? ConstantsApp.STAGE_HEIGHT/2 + 80 : - ConstantsApp.STAGE_HEIGHT/2 - 80
      } );
      _instructionsShown = false;
    }, 6, "hide_timer"+_screen);
  }

  // Reset Timer on Input
  public function inputRegistered() {
    
  }
}
