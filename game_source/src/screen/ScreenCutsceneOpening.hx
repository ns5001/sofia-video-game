package screen;

import workinman.display.ImageSprite;
import workinman.display.Sprite;
import workinman.tween.Ease;
import world.elements.MenuOptions;
import workinman.ui.ScreenBase;
import workinman.ui.Button;
import workinman.WMSound;
import app.ConstantsApp;
import workinman.WMInput;
import app.INPUT_TYPE;

class ScreenCutsceneOpening extends ScreenBase {

  private var _tray                    : ImageSprite;
  private var _clickTray			         : Button;

  private var _clickableTextContainer1 : Button;
  private var _clickableTextContainer2 : Button;

  private var _menuOptions             : MenuOptions;
  private var _storyPage               : ImageSprite;
  private var _storyPageColor          : ImageSprite;
  private var _nextButton              : ImageSprite;
  private var _nextButtonHitbox        : Button;
  private var _previousButton          : ImageSprite;
  private var _previousButtonHitbox    : Button;
  private var _pageIndex               : Int = 0;

  private var _definitionBar           : ImageSprite;
  private var _instructionIn           : Bool = false;
  private var _definitionVO            : String = "";
  private var _definitionWord          : String = "";

  public function new( pRoot:Sprite ) : Void {
		trace("CUTSCENE OPENING building");
    super( pRoot );
  }
  
  private override function _buildScreen() : Void {
      super._buildScreen();
      _closing = false;

      _tray = _elementManager.addElement ( new ImageSprite({}));

      _storyPage = _tray.addElement ( new ImageSprite( { asset: manifest.Texture.story_1, scale: 1 } ));
      _storyPageColor = _tray.addElement ( new ImageSprite( { asset: manifest.Texture.story_5_color, scale: 1, alpha: 0 } ));

      _definitionBar = _tray.addElement ( new ImageSprite( { asset: manifest.Texture.story_popup_lungs, y:ConstantsApp.STAGE_CENTER_Y + 87, scale: 1 } ));

      _clickTray = _tray.addElement( new Button( { tween:_tween, clear: _clearButtonInput } ));
      _clickTray.setCustomHitBox(ConstantsApp.STAGE_WIDTH, ConstantsApp.STAGE_HEIGHT);
      _clickTray.eventClick.add( _clearDefinition );

      _nextButton = _tray.addElement(new ImageSprite({asset: manifest.Texture.btn_next_side, x:ConstantsApp.STAGE_CENTER_X - 44, y:0, scale:.5}));
      _nextButtonHitbox = _nextButton.addElement(new Button({asset: manifest.Texture.btn_next_side_arrow, tween:_tween, clear:_clearButtonInput }));
      _nextButtonHitbox.setCustomHitBox(200, 1440);
      _nextButtonHitbox.eventClick.add( _clickNextButton );

      _previousButton = _tray.addElement(new ImageSprite({asset: manifest.Texture.btn_next_side, x:-ConstantsApp.STAGE_CENTER_X + 44, y:0, scale:.5, scaleX:-.5, alpha:0}));
      _previousButtonHitbox = _previousButton.addElement(new Button({asset: manifest.Texture.btn_next_side_arrow, tween:_tween, clear:_clearButtonInput }));
      _previousButtonHitbox.setCustomHitBox(200, 1440);
      _previousButtonHitbox.eventClick.add( _clickPreviousButton );

      _clickableTextContainer1 = _tray.addElement(new Button({x:300, y:-185, tween:_tween, clear:_clearButtonInput}));
      _clickableTextContainer1.setCustomHitBox(140, 55);
      _clickableTextContainer1.eventDown.add(function() {
        if (!_instructionIn)
          _clickDefinition();
        else
          _clearDefinition();
      });

      _menuOptions = _tray.addElement( new MenuOptions( { }, "", manifest.Texture.popup_panel_short, "", _tween, _clearButtonInput, true ));

      WMInput.eventInput.add(_generalInput);

      _definitionWord = "lungs";
      _definitionVO = manifest.Sound.sofia_lungs_definition;
      WMSound.playVO(manifest.Sound.sofia_intro_01, "");

      app.GoogleAnalytics.LogEvent("Progress_web", { 'event_label': "1: Cutscene #1"});
      // app.GoogleAnalytics.LogEvent("Progress", { 'event_label': "Progress", "screen":"1: Cutscene #1"});
  }

  public override function update(dt:Float) : Void {
      super.update(dt);
  }
  
  public override function dispose() : Void {
    _tray = null;
    _clickTray = null;
  
    _clickableTextContainer1 = null;
    _clickableTextContainer2 = null;
  
    _menuOptions = null;
    _storyPage = null;
    _storyPageColor = null;
    _nextButton = null;
    _nextButtonHitbox = null;
    _previousButton = null;
    _previousButtonHitbox = null;
    _definitionBar = null;

        WMInput.eventInput.remove(_generalInput);

    super.dispose();
  }
    
  private function _generalInput(pType:INPUT_TYPE , pDown:Bool) : Void {
    switch ( pType ) {
      case INPUT_TYPE.POINTER:
        if ( pDown )
          _menuOptions.resetCountdown();
      default:
    }
  }

  private function _onEventAdvanceScreen() {
    if ( _closing == false ) {

      WMSound.stopVO();
      
      _closing = true;
      app.ConstantsEvent.addLoader.dispatch();
      app.ConstantsEvent.flow.dispatch( app.FLOW.QUIZ1 );
    }
  }

  public function _clickNextButton() : Void {

    WMSound.stopVO();

    _pageIndex++;
    _clearDefinition();

    switch(_pageIndex) {
      case 1:
        WMSound.playSound(manifest.Sound.sofia_page_turn, .5);

        _definitionWord = "treatment";
        _definitionVO = manifest.Sound.sofia_treatment_definition;
        _storyPage.asset = manifest.Texture.story_2;
        _previousButton.alpha = 1;

        // set up clickable word
        _definitionBar.setAsset(manifest.Texture.story_popup_treatment);
        _clickableTextContainer1.inputEnabled = true;
        _clickableTextContainer1.x = -365;
        _clickableTextContainer1.y = 65;
        _clickableTextContainer1.setCustomHitBox(250, 55);

        WMSound.playVO(manifest.Sound.sofia_intro_02, "");

      case 2:
        WMSound.playSound(manifest.Sound.sofia_page_turn, .5);

        _definitionWord = "scientist";
        _definitionVO = manifest.Sound.sofia_scientist_definition;
        _storyPage.asset = manifest.Texture.story_3;

        // set up clickable word
        _definitionBar.scale = .5;
        _definitionBar.setAsset(manifest.Texture.story_popup_scientist);
        _clickableTextContainer1.x = -160;
        _clickableTextContainer1.y = -120;
        _clickableTextContainer1.setCustomHitBox(210, 55);

        WMSound.playVO(manifest.Sound.sofia_intro_03, "");
      case 3:
        _onEventAdvanceScreen();
    }
  }

  public function _clickPreviousButton() : Void {

    if (_pageIndex <= 0) return;

    WMSound.stopVO();
    
    _pageIndex--;
    _clearDefinition();
    switch(_pageIndex) {
      case 0:
        WMSound.playSound(manifest.Sound.sofia_page_turn, .5);

        _definitionWord = "lungs";
        _definitionVO = manifest.Sound.sofia_lungs_definition;
        _storyPage.asset = manifest.Texture.story_1;
        _previousButton.alpha = 0;

        // set up clickable word
        _definitionBar.scale = 1;
        _definitionBar.setAsset(manifest.Texture.story_popup_lungs);
        _clickableTextContainer1.inputEnabled = true;
        _clickableTextContainer1.x = 300;
        _clickableTextContainer1.y = -185;
        _clickableTextContainer1.setCustomHitBox(140, 55);

        WMSound.playVO(manifest.Sound.sofia_intro_01, "");

      case 1:
        WMSound.playSound(manifest.Sound.sofia_page_turn, .5);

        _definitionWord = "treatment";
        _definitionVO = manifest.Sound.sofia_treatment_definition;
        _storyPage.asset = manifest.Texture.story_2;

        // set up clickable word
        _definitionBar.scale = 1;
        _definitionBar.setAsset(manifest.Texture.story_popup_treatment);
        _clickableTextContainer1.inputEnabled = true;
        _clickableTextContainer1.x = -365;
        _clickableTextContainer1.y = 65;
        _clickableTextContainer1.setCustomHitBox(250, 55);

        WMSound.playVO(manifest.Sound.sofia_intro_02, "");
    }
  }

  public function _clickDefinition () : Void {

    WMSound.stopVO();
    WMSound.playSound(manifest.Sound.sofia_click);

    _menuOptions.hideInstructions();

    _instructionIn = true;
    _tween.tween( { target: _definitionBar, duration: .4, delay: 0, ease: Ease.outQuad }, { y: ConstantsApp.STAGE_CENTER_Y - 87 } );

    WMSound.playVO(_definitionVO, "");

    app.GoogleAnalytics.LogEvent("Clicked Definition_web", { 'event_label':_definitionWord});
  }
  public function _clearDefinition () : Void {
    if (!_instructionIn) return;

    WMSound.stopVO();

    _instructionIn = false;
    _tween.tween( { target: _definitionBar, duration: .2, delay: 0, ease: Ease.outQuad }, { y: ConstantsApp.STAGE_CENTER_Y + 87 } );
  }
}