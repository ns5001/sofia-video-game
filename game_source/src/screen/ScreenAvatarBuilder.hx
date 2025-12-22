package screen;

import workinman.display.spine.SpineElement;
import workinman.display.ImageSprite;
import workinman.display.Sprite;
import workinman.ui.ScreenBase;
import workinman.ui.Button;
import world.elements.MenuOptions;
import screen.button.ButtonMenu;
import screen.data.AvatarSlotData;
import workinman.WMTimer;
import workinman.WMSound;
import workinman.WMInput;
import app.ConstantsApp;
import app.PlayerData;
import app.INPUT_TYPE;

class ScreenAvatarBuilder extends ScreenBase {

    private var _tray                     : ImageSprite;
    private var _acceptButton			        : Button;

    private var _avatar                    : SpineElement;

    private var _menuOptions              : MenuOptions;

    // Selection tabs
    private var _customizationBacking     : ImageSprite;
    private var _customizationTabButtons  : Array<ButtonMenu> = [null, null, null, null];
    private var _customizationBodies      : Array<ImageSprite> = [null, null, null, null];

    // Body options
    private var _bodyTray                 : ImageSprite;
    private var _skinColorButtons         : Array<ButtonMenu> = [null, null, null, null, null, null, null, null];
    private var _bodyTypeButtons          : Array<ButtonMenu> = [null, null, null, null, null];

    // Hair options
    private var _hairTray                 : ImageSprite;
    private var _arrowButtons             : Array<Button> = [null, null];
    private var _hairStyleContainers      : Array<ImageSprite> = [null, null];
    private var _hairColorButtons         : Array<ButtonMenu> = [null, null, null, null, null, null, null, null, null, null];
    private var _hairStyleButtons         : Array<ButtonMenu> = [null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null];

    // Eye options
    private var _eyesTray                 : ImageSprite;
    private var _eyeColorButtons         : Array<ButtonMenu> = [null, null, null, null, null, null, null, null, null, null, null, null];
    private var _eyeStyleButtons         : Array<ButtonMenu> = [null, null, null];

    // Outfit options
    private var _glassesTray              : ImageSprite;
    private var _outfitButtons            : Array<ButtonMenu> = [null, null];
    private var _outfitColorButtons       : Array<ButtonMenu> = [null, null, null, null, null, null, null, null];
    private var _accesoryButtons          : Array<ButtonMenu> = [null, null, null, null];

    // Selection variables
    private var _selectedSkinColor        : Int = 0;
    private var _selectedBodyType         : Int = 0;

    private var _selectedHairColor        : Int = 0;
    private var _selectedHairStyle        : Int = 0;
    private var _wasAltColor              : Bool = false;

    private var _selectedEyeColor         : Int = 0;
    private var _selectedEyeShape         : Int = 0;

    private var _selectedOutfitType       : Int = 0;
    private var _selectedOutfitColor      : Int = 0;
    private var _selectedFacewear         : Int = 0;

    private var _clickVolume              : Float = .5;

    public function new( pRoot:Sprite ) : Void {
      trace("AVATAR BUILDER building");
      super( pRoot );
    }
    
    private override function _buildScreen() : Void {
        super._buildScreen();

        WMSound.stopMusic();
        WMSound.playMusic(manifest.Sound.sofia_park_lab_track, ConstantsApp.DEFAULT_GAME_MUSIC_VOLUME);
        
		    _closing = false;

        _tray = _elementManager.addElement ( new ImageSprite({}));
        _tray.addElement ( new ImageSprite( { asset: manifest.Texture.avatar_bg, scale: 1, alpha: 1 } ));

        _acceptButton = _tray.addElement( new Button( { asset: manifest.Texture.btn_check, x: ConstantsApp.STAGE_WIDTH/2 - 75, y: ConstantsApp.STAGE_HEIGHT/2 - 75, tween:_tween, clear: _clearButtonInput, scale: 1, alpha: 1 } ));
        _acceptButton.eventClick.add( _onEventClickPlay );

        _createHeaderTabs();

        // Tray for body options
        _createBodyButtons();

        // Tray for body options
        _createHairButtons();

        //Tray for eye options
        _createEyeButtons();

        //Tray for glasses options
        _createOutfitButtons();

        // var tAvatar = manifest.spine.avatar_tall_thin.Info.name;
        //  _avatar.setSkin("outfit_pants_1");
        _initializeAvatar();

        // _addInstruction();
        _menuOptions = _tray.addElement( new MenuOptions( { }, "4: Avatar Builder", manifest.Texture.avatar_popup, manifest.Sound.sofia_avatar_builder, _tween, _clearButtonInput ));

        app.GoogleAnalytics.LogEvent("Progress_web", { 'event_label': "4: Avatar Builder"});
        // app.GoogleAnalytics.LogEvent("Progress", { 'event_label': "Progress", "screen":"4: Avatar Builder"});

        WMInput.eventInput.add(_generalInput);
    }

    public override function update(dt:Float) : Void {
        super.update(dt);
    }
    
    public override function dispose() : Void {
        WMTimer.stop("hide_timer");

        _menuOptions = null;
        _tray = null;
        _acceptButton = null;
        _avatar = null;
        _customizationBacking = null;
        _bodyTray = null;
        _hairTray = null;
        _eyesTray = null;
        _glassesTray = null;

        // Selection tabs
        _customizationTabButtons = [];
        _customizationBodies = [];
    
        // Body options
        _skinColorButtons = [];
        _bodyTypeButtons = [];
    
        // Hair options
        _arrowButtons = [];
        _hairStyleContainers = [];
        _hairColorButtons = [];
        _hairStyleButtons = [];
    
        // Eye options
        _eyeColorButtons = [];
        _eyeStyleButtons = [];
    
        // Outfit options
        _outfitButtons = [];
        _outfitColorButtons = [];
        _accesoryButtons = [];

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

    private function _onEventClickPlay() : Void {
      if ( _closing == false ) {

        WMSound.stopVO();
        WMSound.stopMusic();

        WMSound.playSound(manifest.Sound.sofia_click_confirm);
        WMSound.playMusic(manifest.Sound.sofia_bg_music, ConstantsApp.DEFAULT_GAME_MUSIC_VOLUME);

        PlayerData.avatarSettings = {
          skinColor : _selectedSkinColor, bodyType : _selectedBodyType,
          hairColor : _selectedHairColor, hairStyle : _selectedHairStyle,
          eyeColor : _selectedEyeColor, eyeShape : _selectedEyeShape,
          outfitType : _selectedOutfitType, outfitColor : _selectedOutfitColor, facewear : _selectedFacewear,
        };

        _closing = true;
        app.ConstantsEvent.addLoader.dispatch();

        // app.ConstantsEvent.flow.dispatch( app.FLOW.CUTSCENE_DOCTOR_START );
        app.ConstantsEvent.flow.dispatch( app.FLOW.CUTSCENE_OPENING );
      }
    }

    /** SETTING UP MENU TABS **/
    private function _createHeaderTabs() : Void {
      _customizationBacking = _tray.addElement ( new ImageSprite( { asset: manifest.Texture.top_panel, x: 216, y: -224}));
      
      _customizationTabButtons[0] = _customizationBacking.addElement (
        new ButtonMenu( { asset: manifest.Texture.btn_body, alt: manifest.Texture.btn_body_highlight, x: -261, y: -16, tween:_tween, clear: _clearButtonInput},
          function() {_selectHeaderTab(0);}));
      _customizationTabButtons[1] = _customizationBacking.addElement (
        new ButtonMenu( { asset: manifest.Texture.btn_hair, alt: manifest.Texture.btn_hair_highlight, x: -91, y: 0, tween:_tween, clear: _clearButtonInput},
          function() {_selectHeaderTab(1);}));
      _customizationTabButtons[2] = _customizationBacking.addElement (
        new ButtonMenu( { asset: manifest.Texture.btn_eyes, alt: manifest.Texture.btn_eyes_highlight, x: 64, y: 1, tween:_tween, clear: _clearButtonInput},
          function() {_selectHeaderTab(2);}));
      _customizationTabButtons[3] = _customizationBacking.addElement (
        new ButtonMenu( { asset: manifest.Texture.btn_accessories, alt: manifest.Texture.btn_accessories_highlight,
          x: 240, y: 1, tween:_tween, clear: _clearButtonInput},
          function() {_selectHeaderTab(3);}));

      _bodyTray = _customizationBodies[0] = _tray.addElement ( new ImageSprite({x: 215, y: 0, alpha: 0}));
      _hairTray = _customizationBodies[1] = _tray.addElement ( new ImageSprite({x: 215, y: 0, alpha: 0}));
      _eyesTray = _customizationBodies[2] = _tray.addElement ( new ImageSprite({x: 215, y: 0, alpha: 0}));
      _glassesTray = _customizationBodies[3] = _tray.addElement ( new ImageSprite({x: 215, y: 0, alpha: 0}));

      // for(i in 0..._customizationBodies.length) _customizationBodies[i].inputEnabled = false;
          
      _selectHeaderTab(0, false);
    }
    private function _selectHeaderTab(pIndex:Int, pPlaySFX : Bool = true ) : Void {

      if (pPlaySFX) WMSound.playSound(manifest.Sound.sofia_click, _clickVolume);

      for(i in 0..._customizationTabButtons.length){
        if (i != pIndex) {
          _customizationTabButtons[i].deselect();
          _customizationBodies[i].alpha = 0;
          _customizationBodies[i].inputEnabled = false;
        }
      }

      _customizationTabButtons[pIndex].select();
      _customizationBodies[pIndex].alpha = 1;
      _customizationBodies[pIndex].inputEnabled = true;
    }

    // ******************************
    // BODY SELECTION FUNCTIONALITY

    // -- adding buttons and functionality
    private function _createBodyButtons() : Void {
      _skinColorButtons[0] = _bodyTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_body_color_1, highlight:manifest.Texture.btn_body_color_highlight, x: -151, y: -38, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(0, _skinColorButtons); _selectSkinColor(0); }));
      _skinColorButtons[1] = _bodyTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_body_color_2, highlight:manifest.Texture.btn_body_color_highlight, x: -46, y: -38, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(1, _skinColorButtons); _selectSkinColor(1); }));
      _skinColorButtons[2] = _bodyTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_body_color_3, highlight:manifest.Texture.btn_body_color_highlight, x: 63, y: -38, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(2, _skinColorButtons); _selectSkinColor(2); }));
      _skinColorButtons[3] = _bodyTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_body_color_4, highlight:manifest.Texture.btn_body_color_highlight, x: 167, y: -38, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(3, _skinColorButtons); _selectSkinColor(3); }));
      _skinColorButtons[4] = _bodyTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_body_color_5, highlight:manifest.Texture.btn_body_color_highlight, x: -197, y: 72, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(4, _skinColorButtons); _selectSkinColor(4); }));
      _skinColorButtons[5] = _bodyTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_body_color_6, highlight:manifest.Texture.btn_body_color_highlight, x: -90, y: 72, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(5, _skinColorButtons); _selectSkinColor(5); }));
      _skinColorButtons[6] = _bodyTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_body_color_7, highlight:manifest.Texture.btn_body_color_highlight, x: 19, y: 72, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(6, _skinColorButtons); _selectSkinColor(6); }));
      _skinColorButtons[7] = _bodyTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_body_color_8, highlight:manifest.Texture.btn_body_color_highlight, x: 126, y: 72, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(7, _skinColorButtons); _selectSkinColor(7); }));

      _bodyTypeButtons[0] = _bodyTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_body_shape_1, highlight:manifest.Texture.btn_body_shape_1_highlight, x: -282, y: 234, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(0, _bodyTypeButtons); _selectBodyType(0); }));
      _bodyTypeButtons[1] = _bodyTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_body_shape_2, highlight:manifest.Texture.btn_body_shape_2_highlight, x: -156, y: 234, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(1, _bodyTypeButtons); _selectBodyType(1); }));
      _bodyTypeButtons[2] = _bodyTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_body_shape_3, highlight:manifest.Texture.btn_body_shape_1_highlight, x: -30, y: 234, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(2, _bodyTypeButtons); _selectBodyType(2); }));
      _bodyTypeButtons[3] = _bodyTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_body_shape_4, highlight:manifest.Texture.btn_body_shape_2_highlight, x: 96, y: 234, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(3, _bodyTypeButtons); _selectBodyType(3); }));
      _bodyTypeButtons[4] = _bodyTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_body_shape_5, highlight:manifest.Texture.btn_body_shape_1_highlight, x: 224, y: 234, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(4, _bodyTypeButtons); _selectBodyType(4); }));

      _selectButtonFromGroup(0, _skinColorButtons);
      _selectButtonFromGroup(0, _bodyTypeButtons);
    }
    // -- select skin color
    private function _selectSkinColor (pIndex : Int, pPlaySFX : Bool = true ) : Void {
      _selectedSkinColor = pIndex;

      if (pPlaySFX) WMSound.playSound(manifest.Sound.sofia_click, _clickVolume);

      _avatar.setAttachment("face_color", AvatarSlotData.getSlotAttachment("face_color", _selectedSkinColor));
      _avatar.setAttachment("neck", AvatarSlotData.getSlotAttachment("neck", _selectedSkinColor));
    }
    // -- select body shape
    private function _selectBodyType (pIndex : Int, pPlaySFX : Bool = true ) : Void {
      _selectedBodyType = pIndex;

      if (pPlaySFX) WMSound.playSound(manifest.Sound.sofia_click, _clickVolume);

      //delete old avatar if it exists
      if (_avatar != null) {
        _tray.removeElement (_avatar);
        _avatar.dispose();
        _avatar = null;
      }

      // create new body
      switch(pIndex) {
        case 0:
          _avatar = _tray.addElement ( new SpineElement({ library: manifest.spine.avatar_tall_thin.Info.name, scale: .5, x: -400, y: 300, alpha: 1}, "spine/avatar_texture_packed"));
        case 1:
          _avatar = _tray.addElement ( new SpineElement({ library: manifest.spine.avatar_short_thin.Info.name, scale: .5, x: -400, y: 300, alpha: 1}, "spine/avatar_texture_packed"));
        case 2:
          _avatar = _tray.addElement ( new SpineElement({ library: manifest.spine.avatar_tall_thick.Info.name, scale: .5, x: -400, y: 300, alpha: 1}, "spine/avatar_texture_packed"));
        case 3:
          _avatar = _tray.addElement ( new SpineElement({ library: manifest.spine.avatar_short_thick.Info.name, scale: .5, x: -400, y: 300, alpha: 1}, "spine/avatar_texture_packed"));
        case 4:
          _avatar = _tray.addElement ( new SpineElement({ library: manifest.spine.avatar_wheelchair.Info.name, scale: .5, x: -400, y: 300, alpha: 1}, "spine/avatar_texture_packed"));
        default:
          _avatar = _tray.addElement ( new SpineElement({ library: manifest.spine.avatar_tall_thin.Info.name, scale: .5, x: -400, y: 300, alpha: 1}, "spine/avatar_texture_packed"));
      }

      // now reset all pieces to target assets
      _selectSkinColor(_selectedSkinColor, false);
      _selectHairColor(_selectedHairColor, false);
      _selectEyeColor(_selectedEyeColor, false);
      _selectEyeShape(_selectedEyeShape, false);
      _selectOutfitType(_selectedOutfitType, false);

      _avatar.animate("idle");
    }

    // ******************************
    // HAIR SELECTION FUNCTIONALITY

    // -- adding buttons and functionality
    private function _createHairButtons() : Void {
      _hairStyleContainers[0] = _hairTray.addElement ( new ImageSprite({x: 0, y: 0, alpha: 1}) );
      _hairStyleContainers[1] = _hairTray.addElement ( new ImageSprite({x: 0, y: 0, alpha: 0}) );
      _hairStyleContainers[1].inputEnabled = false;

      _hairColorButtons[0] = _hairTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_color_1, highlight:manifest.Texture.btn_hair_color_hjighlight, x: -335, y: -47, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(0, _hairColorButtons); _selectHairColor(0); }));
      _hairColorButtons[1] = _hairTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_color_2, highlight:manifest.Texture.btn_hair_color_hjighlight, x: -261, y: -47, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(1, _hairColorButtons); _selectHairColor(1); }));
      _hairColorButtons[2] = _hairTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_color_3, highlight:manifest.Texture.btn_hair_color_hjighlight, x: -188, y: -47, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(2, _hairColorButtons); _selectHairColor(2); }));
      _hairColorButtons[3] = _hairTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_color_4, highlight:manifest.Texture.btn_hair_color_hjighlight, x: -113, y: -47, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(3, _hairColorButtons); _selectHairColor(3); }));
      _hairColorButtons[4] = _hairTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_color_5, highlight:manifest.Texture.btn_hair_color_hjighlight, x: -38, y: -47, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(4, _hairColorButtons); _selectHairColor(4); }));
      _hairColorButtons[5] = _hairTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_color_6, highlight:manifest.Texture.btn_hair_color_hjighlight, x: 37, y: -47, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(5, _hairColorButtons); _selectHairColor(5); }));
      _hairColorButtons[6] = _hairTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_color_7, highlight:manifest.Texture.btn_hair_color_hjighlight, x: 112, y: -47, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(6, _hairColorButtons); _selectHairColor(6); }));
      _hairColorButtons[7] = _hairTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_color_8, highlight:manifest.Texture.btn_hair_color_hjighlight, x: 187, y: -47, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(7, _hairColorButtons); _selectHairColor(7); }));
      _hairColorButtons[8] = _hairTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_color_9, highlight:manifest.Texture.btn_hair_color_hjighlight, x: 262, y: -47, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(8, _hairColorButtons); _selectHairColor(8); }));
      _hairColorButtons[9] = _hairTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_color_10, highlight:manifest.Texture.btn_hair_color_hjighlight, x: 337, y: -47, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(9, _hairColorButtons); _selectHairColor(9); }));

      _arrowButtons[0] = _hairTray.addElement( new Button( {asset: manifest.Texture.btn_arrow_left, x: -350, y: 143, tween:_tween, clear: _clearButtonInput}));
      _arrowButtons[0].eventDown.add( _arrowClick );
      _arrowButtons[1] = _hairTray.addElement( new Button( {asset: manifest.Texture.btn_arrow_right, x: 335, y: 143, tween:_tween, clear: _clearButtonInput}));
      _arrowButtons[1].eventDown.add( _arrowClick );
      
      _hairStyleButtons[0] = _hairStyleContainers[0].addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_style_1, highlight:manifest.Texture.btn_hair_style_highlight, x: -251, y: 80, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(0, _hairStyleButtons); _selectHairStyle(0); }));
      _hairStyleButtons[1] = _hairStyleContainers[0].addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_style_2, highlight:manifest.Texture.btn_hair_style_highlight, x: -129, y: 80, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(1, _hairStyleButtons); _selectHairStyle(1); }));
      _hairStyleButtons[2] = _hairStyleContainers[0].addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_style_3, highlight:manifest.Texture.btn_hair_style_highlight, x: -7, y: 80, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(2, _hairStyleButtons); _selectHairStyle(2); }));
      _hairStyleButtons[3] = _hairStyleContainers[0].addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_style_4, highlight:manifest.Texture.btn_hair_style_highlight, x: 115, y: 80, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(3, _hairStyleButtons); _selectHairStyle(3); }));
      _hairStyleButtons[4] = _hairStyleContainers[0].addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_style_5, highlight:manifest.Texture.btn_hair_style_highlight, x: 237, y: 80, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(4, _hairStyleButtons); _selectHairStyle(4); }));
      _hairStyleButtons[5] = _hairStyleContainers[0].addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_style_6, highlight:manifest.Texture.btn_hair_style_highlight, x: -251, y: 206, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(5, _hairStyleButtons); _selectHairStyle(5); }));
      _hairStyleButtons[6] = _hairStyleContainers[0].addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_style_7, highlight:manifest.Texture.btn_hair_style_highlight, x: -129, y: 206, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(6, _hairStyleButtons); _selectHairStyle(6); }));
      _hairStyleButtons[7] = _hairStyleContainers[0].addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_style_8, highlight:manifest.Texture.btn_hair_style_highlight, x: -7, y: 206, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(7, _hairStyleButtons); _selectHairStyle(7); }));
      _hairStyleButtons[8] = _hairStyleContainers[0].addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_style_9, highlight:manifest.Texture.btn_hair_style_highlight, x: 115, y: 206, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(8, _hairStyleButtons); _selectHairStyle(8); }));
      _hairStyleButtons[9] = _hairStyleContainers[0].addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_style_10, highlight:manifest.Texture.btn_hair_style_highlight, x: 237, y: 206, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(9, _hairStyleButtons); _selectHairStyle(9); }));

      _hairStyleButtons[10] = _hairStyleContainers[1].addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_style_11, highlight:manifest.Texture.btn_hair_style_highlight, x: -251, y: 80, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(10, _hairStyleButtons); _selectHairStyle(10); }));
      _hairStyleButtons[11] = _hairStyleContainers[1].addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_style_12, highlight:manifest.Texture.btn_hair_style_highlight, x: -129, y: 80, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(11, _hairStyleButtons); _selectHairStyle(11); }));
      _hairStyleButtons[12] = _hairStyleContainers[1].addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_style_13, highlight:manifest.Texture.btn_hair_style_highlight, x: -7, y: 80, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(12, _hairStyleButtons); _selectHairStyle(12); }));
      _hairStyleButtons[13] = _hairStyleContainers[1].addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_style_14, highlight:manifest.Texture.btn_hair_style_highlight, x: 115, y: 80, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(13, _hairStyleButtons); _selectHairStyle(13); }));
      _hairStyleButtons[14] = _hairStyleContainers[1].addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_style_15, highlight:manifest.Texture.btn_hair_style_highlight, x: 237, y: 80, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(14, _hairStyleButtons); _selectHairStyle(14); }));
      _hairStyleButtons[15] = _hairStyleContainers[1].addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_style_16, highlight:manifest.Texture.btn_hair_style_highlight, x: -251, y: 206, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(15, _hairStyleButtons); _selectHairStyle(15); }));
      _hairStyleButtons[16] = _hairStyleContainers[1].addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_style_17, highlight:manifest.Texture.btn_hair_style_highlight, x: -129, y: 206, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(16, _hairStyleButtons); _selectHairStyle(16); }));
      _hairStyleButtons[17] = _hairStyleContainers[1].addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_style_18, highlight:manifest.Texture.btn_hair_style_highlight, x: -7, y: 206, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(17, _hairStyleButtons); _selectHairStyle(17); }));
      _hairStyleButtons[18] = _hairStyleContainers[1].addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_style_19, highlight:manifest.Texture.btn_hair_style_highlight, x: 115, y: 206, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(18, _hairStyleButtons); _selectHairStyle(18); }));
      _hairStyleButtons[19] = _hairStyleContainers[1].addElement ( new ButtonMenu( { asset: manifest.Texture.btn_hair_style_20, highlight:manifest.Texture.btn_hair_style_highlight, x: 237, y: 206, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(19, _hairStyleButtons); _selectHairStyle(19); }));

      _selectButtonFromGroup(0, _hairColorButtons);
      _selectButtonFromGroup(0, _hairStyleButtons);
    }
    // -- select the hair color
    private function _selectHairColor(pIndex : Int, pPlaySFX : Bool = true ) : Void {
      _selectedHairColor = pIndex;
      
      if (pPlaySFX) WMSound.playSound(manifest.Sound.sofia_click, _clickVolume);

      _selectHairStyle(_selectedHairStyle, false);
    }
    // -- select the hair style
    private function _selectHairStyle(pIndex : Int, pPlaySFX : Bool = true ) : Void {
      _selectedHairStyle = pIndex;
      
      if (pPlaySFX) WMSound.playSound(manifest.Sound.sofia_click, _clickVolume);

      _avatar.setAttachment("hair", AvatarSlotData.getHairAttachment(_selectedHairStyle, _selectedHairColor));
      _avatar.setAttachment("hair_back", null);

      if (_selectedHairStyle == 9 || _selectedHairStyle == 13 || _selectedHairStyle == 14)
        _avatar.setAttachment("hair_back", AvatarSlotData.getHairBackAttachment(_selectedHairStyle, _selectedHairColor));

      if ((_wasAltColor && (_selectedHairStyle != 10 && _selectedHairStyle != 15)) || (!_wasAltColor && (_selectedHairStyle == 10 || _selectedHairStyle == 15)))
        _setCustomHairColorOptions (_selectedHairStyle == 10 || _selectedHairStyle == 15);
    }
    private function _arrowClick() : Void {
      
      WMSound.playSound(manifest.Sound.sofia_click, _clickVolume);

      if (_hairStyleContainers[0].alpha == 1) {
        _hairStyleContainers[0].alpha = 0;
        _hairStyleContainers[0].inputEnabled = false;
        _hairStyleContainers[1].alpha = 1;
        _hairStyleContainers[1].inputEnabled = true;
      } else {
        _hairStyleContainers[0].alpha = 1;
        _hairStyleContainers[0].inputEnabled = true;
        _hairStyleContainers[1].alpha = 0;
        _hairStyleContainers[1].inputEnabled = false;
      }
    }
    private function _setCustomHairColorOptions (pIsAltColorStyle:Bool) : Void {
      trace("SETTING HAIR STYLE COLORS - " + pIsAltColorStyle);
      _hairColorButtons[0].setButtonAsset(pIsAltColorStyle ? manifest.Texture.btn_hair_color_11 : manifest.Texture.btn_hair_color_1);
      _hairColorButtons[1].setButtonAsset(pIsAltColorStyle ? manifest.Texture.btn_hair_color_12 : manifest.Texture.btn_hair_color_2);
      _hairColorButtons[2].setButtonAsset(pIsAltColorStyle ? manifest.Texture.btn_hair_color_13 : manifest.Texture.btn_hair_color_3);
      _hairColorButtons[3].setButtonAsset(pIsAltColorStyle ? manifest.Texture.btn_hair_color_14 : manifest.Texture.btn_hair_color_4);
      _hairColorButtons[4].setButtonAsset(pIsAltColorStyle ? manifest.Texture.btn_hair_color_15 : manifest.Texture.btn_hair_color_5);
      _hairColorButtons[5].setButtonAsset(pIsAltColorStyle ? manifest.Texture.btn_hair_color_16 : manifest.Texture.btn_hair_color_6);
      _hairColorButtons[6].setButtonAsset(pIsAltColorStyle ? manifest.Texture.btn_hair_color_17 : manifest.Texture.btn_hair_color_7);
      _hairColorButtons[7].setButtonAsset(pIsAltColorStyle ? manifest.Texture.btn_hair_color_18 : manifest.Texture.btn_hair_color_8);
      _hairColorButtons[8].setButtonAsset(pIsAltColorStyle ? manifest.Texture.btn_hair_color_19 : manifest.Texture.btn_hair_color_9);
      _hairColorButtons[9].setButtonAsset(pIsAltColorStyle ? manifest.Texture.btn_hair_color_20 : manifest.Texture.btn_hair_color_10);

      _wasAltColor = pIsAltColorStyle;
    }

    // ******************************
    // EYE SELECTION FUNCTIONALITY

    // -- adding buttons and functionality
    private function _createEyeButtons() : Void {
      _eyeColorButtons[0] = _eyesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_eye_color_1, highlight:manifest.Texture.btn_eye_color_highlight, x: -257, y: -37, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(0, _eyeColorButtons); _selectEyeColor(0); }));
      _eyeColorButtons[1] = _eyesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_eye_color_2, highlight:manifest.Texture.btn_eye_color_highlight, x: -150, y: -37, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(1, _eyeColorButtons); _selectEyeColor(1); }));
      _eyeColorButtons[2] = _eyesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_eye_color_3, highlight:manifest.Texture.btn_eye_color_highlight, x: -43, y: -37, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(2, _eyeColorButtons); _selectEyeColor(2); }));
      _eyeColorButtons[3] = _eyesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_eye_color_4, highlight:manifest.Texture.btn_eye_color_highlight, x: 64, y: -37, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(3, _eyeColorButtons); _selectEyeColor(3); }));
      _eyeColorButtons[4] = _eyesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_eye_color_5, highlight:manifest.Texture.btn_eye_color_highlight, x: 171, y: -37, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(4, _eyeColorButtons); _selectEyeColor(4); }));
      _eyeColorButtons[5] = _eyesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_eye_color_6, highlight:manifest.Texture.btn_eye_color_highlight, x: 278, y: -37, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(5, _eyeColorButtons); _selectEyeColor(5); }));
      _eyeColorButtons[6] = _eyesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_eye_color_7, highlight:manifest.Texture.btn_eye_color_highlight, x: -303, y: 72, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(6, _eyeColorButtons); _selectEyeColor(6); }));
      _eyeColorButtons[7] = _eyesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_eye_color_8, highlight:manifest.Texture.btn_eye_color_highlight, x: -196, y: 72, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(7, _eyeColorButtons); _selectEyeColor(7); }));
      _eyeColorButtons[8] = _eyesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_eye_color_9, highlight:manifest.Texture.btn_eye_color_highlight, x: -80, y: 72, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(8, _eyeColorButtons); _selectEyeColor(8); }));
      _eyeColorButtons[9] = _eyesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_eye_color_10, highlight:manifest.Texture.btn_eye_color_highlight, x: 18, y: 72, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(9, _eyeColorButtons); _selectEyeColor(9); }));
      _eyeColorButtons[10] = _eyesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_eye_color_11, highlight:manifest.Texture.btn_eye_color_highlight, x: 125, y: 72, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(10, _eyeColorButtons); _selectEyeColor(10); }));
      _eyeColorButtons[11] = _eyesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_eye_color_12, highlight:manifest.Texture.btn_eye_color_highlight, x: 232, y: 72, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(11, _eyeColorButtons); _selectEyeColor(11); }));

      _eyeStyleButtons[0] = _eyesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_eye_shape_1, highlight:manifest.Texture.btn_eye_shape_highlight, x: -170, y: 236, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(0, _eyeStyleButtons); _selectEyeShape(0); }));
      _eyeStyleButtons[1] = _eyesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_eye_shape_2, highlight:manifest.Texture.btn_eye_shape_highlight, x: -5, y: 236, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(1, _eyeStyleButtons); _selectEyeShape(1); }));
      _eyeStyleButtons[2] = _eyesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_eye_shape_3, highlight:manifest.Texture.btn_eye_shape_highlight, x: 160, y: 236, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(2, _eyeStyleButtons); _selectEyeShape(2); }));

      _selectButtonFromGroup(0, _eyeColorButtons);
      _selectButtonFromGroup(0, _eyeStyleButtons);
    }
    // -- select the eye color
    private function _selectEyeColor(pIndex : Int, pPlaySFX : Bool = true ) : Void {
      _selectedEyeColor = pIndex;
      
      if (pPlaySFX) WMSound.playSound(manifest.Sound.sofia_click, _clickVolume);

      _avatar.setAttachment("eye_color_left", AvatarSlotData.getSlotAttachment("eye_color", _selectedEyeColor));
      _avatar.setAttachment("eye_color_right", AvatarSlotData.getSlotAttachment("eye_color", _selectedEyeColor));
    }
    // select the eye shape
    private function _selectEyeShape(pIndex : Int, pPlaySFX : Bool = true ) : Void {
      _selectedEyeShape = pIndex;
      
      if (pPlaySFX) WMSound.playSound(manifest.Sound.sofia_click, _clickVolume);

      _avatar.setAttachment("eyes_shape", AvatarSlotData.getSlotAttachment("eyes_shape", _selectedEyeShape));
    }

    // ******************************
    // OUTFIT SELECTION FUNCTIONALITY

    // -- adding buttons and functionality
    private function _createOutfitButtons() : Void {
      _outfitButtons[0] = _glassesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_outfit_skirt, highlight:manifest.Texture.btn_outfit_skirt_highlight, x: -73, y: -25, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(0, _outfitButtons); _selectOutfitType(0); }));
      _outfitButtons[1] = _glassesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_outfit_pants, highlight:manifest.Texture.btn_outfit_pants_highlight, x: 40, y: -25, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(1, _outfitButtons); _selectOutfitType(1); }));

      _outfitColorButtons[0] = _glassesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_outfit_color_blue, highlight:manifest.Texture.btn_outfit_color_highlight, x: -313, y: 114, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(0, _outfitColorButtons); _selectOutfitColor(0); }));
      _outfitColorButtons[1] = _glassesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_outfit_color_purple, highlight:manifest.Texture.btn_outfit_color_highlight, x: -225, y: 114, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(1, _outfitColorButtons); _selectOutfitColor(1); }));
      _outfitColorButtons[2] = _glassesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_outfit_color_red, highlight:manifest.Texture.btn_outfit_color_highlight, x: -137, y: 114, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(2, _outfitColorButtons); _selectOutfitColor(2); }));
      _outfitColorButtons[3] = _glassesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_outfit_color_orange, highlight:manifest.Texture.btn_outfit_color_highlight, x: -53, y: 114, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(3, _outfitColorButtons); _selectOutfitColor(3); }));
      _outfitColorButtons[4] = _glassesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_outfit_color_yellow, highlight:manifest.Texture.btn_outfit_color_highlight, x: 31, y: 114, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(4, _outfitColorButtons); _selectOutfitColor(4); }));
      _outfitColorButtons[5] = _glassesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_outfit_color_green, highlight:manifest.Texture.btn_outfit_color_highlight, x: 115, y: 114, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(5, _outfitColorButtons); _selectOutfitColor(5); }));
      _outfitColorButtons[6] = _glassesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_outfit_color_pink, highlight:manifest.Texture.btn_outfit_color_highlight, x: 202, y: 114, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(6, _outfitColorButtons); _selectOutfitColor(6); }));
      _outfitColorButtons[7] = _glassesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_outfit_color_black, highlight:manifest.Texture.btn_outfit_color_highlight, x: 286, y: 114, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(7, _outfitColorButtons); _selectOutfitColor(7); }));

      _accesoryButtons[0] = _glassesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_accessory_1, highlight:manifest.Texture.btn_accessory_highlight, x: -258, y: 260, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(0, _accesoryButtons); _selectFacewear(0); }));
      _accesoryButtons[1] = _glassesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_accessory_3, highlight:manifest.Texture.btn_accessory_highlight, x: -100, y: 260, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(1, _accesoryButtons); _selectFacewear(1); }));
      _accesoryButtons[2] = _glassesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_accessory_2, highlight:manifest.Texture.btn_accessory_highlight, x: 58, y: 260, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(2, _accesoryButtons); _selectFacewear(2); }));
      _accesoryButtons[3] = _glassesTray.addElement ( new ButtonMenu( { asset: manifest.Texture.btn_accessory_4, highlight:manifest.Texture.btn_accessory_highlight, x: 216, y: 260, tween:_tween, clear: _clearButtonInput}, function() {_selectButtonFromGroup(3, _accesoryButtons); _selectFacewear(3); }));
      
      _selectButtonFromGroup(0, _outfitButtons);
      _selectButtonFromGroup(0, _outfitColorButtons);
      _selectButtonFromGroup(0, _accesoryButtons);
    }
    // -- select the type (pants/skirt)
    private function _selectOutfitType(pIndex : Int, pPlaySFX : Bool = true ) : Void {
      _selectedOutfitType = pIndex;
      
      if (pPlaySFX) WMSound.playSound(manifest.Sound.sofia_click, _clickVolume);

      _selectOutfitColor(_selectedOutfitColor, false);
      _selectFacewear(_selectedFacewear, false);
    }
    // -- select the color of outfit (pants/skirt)
    private function _selectOutfitColor(pIndex : Int, pPlaySFX : Bool = true) : Void {
      _selectedOutfitColor = pIndex;
      
      if (pPlaySFX) WMSound.playSound(manifest.Sound.sofia_click, _clickVolume);

      // if selected skirt
      if (_selectedOutfitType == 0) {
        switch(pIndex) {
          case 0:
            _avatar.setSkin("outfit_skirt_1");
          case 1:
            _avatar.setSkin("outfit_skirt_2");
          case 2:
            _avatar.setSkin("outfit_skirt_3");
          case 3:
            _avatar.setSkin("outfit_skirt_4");
          case 4:
            _avatar.setSkin("outfit_skirt_5");
          case 5:
            _avatar.setSkin("outfit_skirt_6");
          case 6:
            _avatar.setSkin("outfit_skirt_7");
          case 7:
            _avatar.setSkin("outfit_skirt_8");
        }
      } else { // else selected pants
        switch(pIndex) {
          case 0:
            _avatar.setSkin("outfit_pants_1");
          case 1:
            _avatar.setSkin("outfit_pants_2");
          case 2:
            _avatar.setSkin("outfit_pants_3");
          case 3:
            _avatar.setSkin("outfit_pants_4");
          case 4:
            _avatar.setSkin("outfit_pants_5");
          case 5:
            _avatar.setSkin("outfit_pants_6");
          case 6:
            _avatar.setSkin("outfit_pants_7");
          case 7:
            _avatar.setSkin("outfit_pants_8");
        }
      }

      _selectFacewear(_selectedFacewear, false);
    }
    // -- select glasses or mask
    private function _selectFacewear(pIndex : Int, pPlaySFX : Bool = true) : Void {
      _selectedFacewear = pIndex;
      
      if (pPlaySFX) WMSound.playSound(manifest.Sound.sofia_click, _clickVolume);

      _avatar.setAttachment("mask", null);
      _avatar.setAttachment("hearingaid", null);
      _avatar.setAttachment("glasses_circle", null);
      _avatar.setAttachment("glasses_square", null);

      switch(_selectedFacewear) {
        case 0: // Mask
          _avatar.setAttachment("mask", AvatarSlotData.getSlotAttachment("mask", _selectedOutfitColor));
        case 1: // Square Glasses
          _avatar.setAttachment("glasses_circle", AvatarSlotData.getSlotAttachment("glasses_circle", _selectedOutfitColor));
        case 2: // Circle Glasses
          _avatar.setAttachment("glasses_square", AvatarSlotData.getSlotAttachment("glasses_square", _selectedOutfitColor));
        case 3: // Hearing Aid
          _avatar.setAttachment("hearingaid", AvatarSlotData.getSlotAttachment("hearingaid", _selectedOutfitColor));
      }
    }

    // ******************************
    // GENERAL FUNCTIONALITY
    private function _selectButtonFromGroup(pIndex:Int, groupArray:Array<ButtonMenu>) : Void {
      for(i in 0...groupArray.length){
        if (i != pIndex) {
          groupArray[i].deselect();
        }
      }
      groupArray[pIndex].select();
    }
    // PRESET AVATAR SETUP
    private function _initializeAvatar() : Void {
      _selectBodyType(0, false);

      // _avatar.setAttachment("cape", null);
      _avatar.setAttachment("hair_back", null);
      _avatar.setAttachment("glasses_circle", null);
      _avatar.setAttachment("glasses_square", null);
      _avatar.setAttachment("hearingaid", null);
      _avatar.setAttachment("mask", null);

      // _avatar.setSkin("outfit_pants_1");
      // _avatar.setAttachment("face_color", AvatarSlotData.getSlotAttachment("face_color", 0));
      // _avatar.setAttachment("neck", AvatarSlotData.getSlotAttachment("neck", 0));
      // _avatar.setAttachment("eyes_shape", AvatarSlotData.getSlotAttachment("eyes_shape", 0));
      // _avatar.setAttachment("eye_color_left", AvatarSlotData.getSlotAttachment("eye_color", 0));
      // _avatar.setAttachment("eye_color_right", AvatarSlotData.getSlotAttachment("eye_color", 0));
      // _avatar.setAttachment("hair", AvatarSlotData.getSlotAttachment("hair", 0));
    }
}