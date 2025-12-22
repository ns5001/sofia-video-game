// package screen.button;

// import flambe.display.BlendMode;
// import flambe.display.Texture;
// import workinman.ui.ButtonProp;
// import workinman.ui.Button;
// import workinman.WMSound;
// import app.ConstantsEvent;
// import app.STICKER;
// import flambe.System;
// import app.PAINTING;

// class ButtonSticker extends Button {

//     var _type               : STICKER;
//     var _size               : Int;
//     var _stickerTexture     : Texture;

//     public var type( get, never ) : STICKER;
//     private function get_type() : STICKER { return _type; }

//     public var stickerTexture( get, never ) : Texture;
//     private function get_stickerTexture() : Texture { return _stickerTexture; }

//     public function new( pData:ButtonProp, pType:STICKER, ?pSize:Int = 50, ?pCallback:Void->Void = null) : Void {
//         super( pData );

//         _type = pType;

//         var _baseMask = workinman.WMAssets.getTexture( getStickerAssets(pType).texture );
//         _stickerTexture = System.renderer.createTexture(_baseMask.width, _baseMask.height);
//         _stickerTexture.graphics.drawTexture(_baseMask, 0, 0);
//         // _stickerTexture.graphics.scale(.8, .8);

//         eventDown.add( _pickup );
//         if (pCallback != null) {
//             eventDown.add( pCallback );
//         }
//     }

//     public function getType() : STICKER {
//         return _type;
//     }

//     public function updateType(pType:STICKER) : Void {
//         var tDetails = getStickerAssets(pType);

//         _type = pType;
//         asset = tDetails.texture;
//     }

//     // public function getStickerTexture () : Texture {
//     //     var _baseMask = workinman.WMAssets.getTexture( getStickerAssets(_type).texture );
//     //     _stickerTexture = System.renderer.createTexture(_baseMask.width, _baseMask.height);
//     //     _stickerTexture.graphics.drawTexture(_baseMask, 0, 0);
//     //     return _stickerTexture;
//     // }
//     public function getStickerTexture () : Texture {
//         trace("calling new GETSTICKERTEXTURE");
//         var _baseTexture = workinman.WMAssets.getTexture( getStickerAssets(_type).texture );
//         var _baseRect = workinman.WMAssets.getSpriteRect( getStickerAssets(_type).texture );

//         var _texture = System.renderer.createTexture(Std.int(_baseRect.sizeX), Std.int(_baseRect.sizeY));

//         if ( _baseTexture == null ) {
// 			return null;
// 		}
// 		if ( _baseRect != null ) {
// 			if ( _baseRect.rotate ) {
// 				_texture.graphics.save();
// 				_texture.graphics.rotate(90);
// 				_texture.graphics.drawSubTexture( _baseTexture, 0 + _baseRect.origY - _baseRect.sizeY - _baseRect.offsetY, -0 -_baseRect.offsetX-_baseRect.sizeX, _baseRect.x, _baseRect.y, _baseRect.sizeY, _baseRect.sizeX );
// 				_texture.graphics.restore();
// 			} else {
// 				_texture.graphics.drawSubTexture( _baseTexture, 0 + _baseRect.offsetX, 0 + _baseRect.origY - _baseRect.sizeY - _baseRect.offsetY, _baseRect.x, _baseRect.y, _baseRect.sizeX, _baseRect.sizeY );
// 			}
// 		}
// 		return _texture;
//     }

//     public static function getStickerAssets(pType:STICKER) : Dynamic {
//         switch(pType) {
//             default:
//                 return { texture: manifest.Texture.cezanne_sticker_1, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_cezanne_sticker_1, stickerSize: {x: 115, y: 91}, gain: 1 };
//             case STICKER.CEZANNE_SUNFLOWER: 
//                 return { texture: manifest.Texture.cezanne_sticker_1, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_cezanne_sticker_1, stickerSize: {x: 115, y: 91}, gain: 1 };
//             case STICKER.CEZANNE_APPLE: 
//                 return { texture: manifest.Texture.cezanne_sticker_2, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_cezanne_sticker_2, stickerSize: {x: 68, y: 68}, gain: 1 };
//             case STICKER.CEZANNE_BANANNA: 
//                 return { texture: manifest.Texture.cezanne_sticker_3, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_cezanne_sticker_3, stickerSize: {x: 137, y: 97}, gain: .7 };
//             case STICKER.CEZANNE_GRAPES: 
//                 return { texture: manifest.Texture.cezanne_sticker_4, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_cezanne_sticker_4, stickerSize: {x: 168, y: 73}, gain: 1 };
//             case STICKER.CEZANNE_FLOWERS: 
//                 return { texture: manifest.Texture.cezanne_sticker_5, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_cezanne_sticker_5, stickerSize: {x: 84, y: 84}, gain: 1 };
//             case STICKER.HOKUSAI_WAVE: 
//                 return { texture: manifest.Texture.hokusai_sticker_1, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_hokusai_sticker_1, stickerSize: {x: 142, y: 133}, gain: 1 };
//             case STICKER.HOKUSAI_CRANE: 
//                 return { texture: manifest.Texture.hokusai_sticker_2, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_hokusai_sticker_2, stickerSize: {x: 183, y: 95}, gain: 1 };
//             case STICKER.HOKUSAI_BOAT: 
//                 return { texture: manifest.Texture.hokusai_sticker_3, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_hokusai_sticker_3, stickerSize: {x: 296, y: 81}, gain: .7 };
//             case STICKER.HOKUSAI_FISH_BLUE: 
//                 return { texture: manifest.Texture.hokusai_sticker_4, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_hokusai_sticker_4, stickerSize: {x: 69, y: 77}, gain: 1 };
//             case STICKER.HOKUSAI_FISH_RED: 
//                 return { texture: manifest.Texture.hokusai_sticker_5, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_hokusai_sticker_5, stickerSize: {x: 78, y: 42}, gain: 1 };
//             case STICKER.HOMER_FLOWERS: 
//                 return { texture: manifest.Texture.homer_sticker_1, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_homer_sticker_1, stickerSize: {x: 134, y: 118}, gain: 1 };
//             case STICKER.HOMER_BIRDS: 
//                 return { texture: manifest.Texture.homer_sticker_2, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_homer_sticker_2, stickerSize: {x: 115, y: 47}, gain: 1 };
//             case STICKER.HOMER_GIRL: 
//                 return { texture: manifest.Texture.homer_sticker_3, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_homer_sticker_3, stickerSize: {x: 167, y: 263}, gain: .7 };
//             case STICKER.HOMER_CLOUDS: 
//                 return { texture: manifest.Texture.homer_sticker_4, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_homer_sticker_4, stickerSize: {x: 195, y: 47}, gain: 1 };
//             case STICKER.HOMER_BOY: 
//                 return { texture: manifest.Texture.homer_sticker_5, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_homer_sticker_5, stickerSize: {x: 212, y: 313}, gain: 1 };
//             case STICKER.MONDRIAN_RECTANGLE_HORIZONTAL: 
//                 return { texture: manifest.Texture.mondrian_sticker_1, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_mondrian_sticker_1, stickerSize: {x: 157, y: 19}, gain: 1 };
//             case STICKER.MONDRIAN_RECTANGLE_VERTICAL: 
//                 return { texture: manifest.Texture.mondrian_sticker_2, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_mondrian_sticker_2, stickerSize: {x: 19, y: 157}, gain: 1 };
//             case STICKER.MONDRIAN_CIRCLE: 
//                 return { texture: manifest.Texture.mondrian_sticker_3, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_mondrian_sticker_3, stickerSize: {x: 129, y: 129}, gain: .7 };
//             case STICKER.MONDRIAN_TRIANGLE: 
//                 return { texture: manifest.Texture.mondrian_sticker_4, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_mondrian_sticker_4, stickerSize: {x: 136, y: 118}, gain: 1 };
//             case STICKER.MONDRIAN_SQUARE: 
//                 return { texture: manifest.Texture.mondrian_sticker_5, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_mondrian_sticker_5, stickerSize: {x: 110, y: 111}, gain: 1 };
//             case STICKER.VANGOGH_GLASSES: 
//                 return { texture: manifest.Texture.vangogh_sticker_1, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_vangogh_sticker_1, stickerSize: {x: 80, y: 38}, gain: 1 };
//             case STICKER.VANGOGH_BOW: 
//                 return { texture: manifest.Texture.vangogh_sticker_2, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_vangogh_sticker_2, stickerSize: {x: 84, y: 67}, gain: 1 };
//             case STICKER.VANGOGH_PEARL: 
//                 return { texture: manifest.Texture.vangogh_sticker_3, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_vangogh_sticker_3, stickerSize: {x: 35, y: 35}, gain: .7 };
//             case STICKER.VANGOGH_FLOWER: 
//                 return { texture: manifest.Texture.vangogh_sticker_4, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_vangogh_sticker_4, stickerSize: {x: 79, y: 79}, gain: 1 };
//             case STICKER.VANGOGH_BIRD: 
//                 return { texture: manifest.Texture.vangogh_sticker_5, sound: manifest.Sound.silent, uiTexture: manifest.Texture.ui_vangogh_sticker_5, stickerSize: {x: 95, y: 73}, gain: 1 };
//         }

//         return null;
//     }

//     public function getStickerPlacementOffset() : Dynamic
//     {
//         var isBlank : Bool = app.PlayerData.selectedPainting == PAINTING.BLANK;

//         switch(_type) {
//             default: 
//                 return {x: 0, y: 0 };
//             case STICKER.CEZANNE_SUNFLOWER:
//                 if (isBlank)
//                     return {x: -5, y: -5  };
//                 else
//                     return {x: 70, y: 70  };
//             case STICKER.CEZANNE_APPLE:
//                 if (isBlank)
//                     return {x: -6, y: -6  };
//                 else
//                     return {x: 75, y: 75  };
//             case STICKER.CEZANNE_BANANNA:
//                 if (isBlank)
//                     return {x: -4, y: -4  };
//                 else
//                     return {x: 75, y: 75  };
//             case STICKER.CEZANNE_GRAPES:
//                 if (isBlank)
//                     return {x: -2, y: -5.25  };
//                 else
//                     return {x: 75, y: 75  };
//             case STICKER.CEZANNE_FLOWERS:
//                 if (isBlank)
//                     return { x: -5.25, y: -5.25}
//                 else
//                     return {x: 75, y: 75  };
//             case STICKER.HOKUSAI_WAVE: 
//                 return {x: 50, y: 50 };
//             case STICKER.HOKUSAI_CRANE:
//                 return {x: 50, y: 50 };
//             case STICKER.HOKUSAI_BOAT: 
//                 return {x: 50, y: 50 };
//             case STICKER.HOKUSAI_FISH_BLUE: 
//                 return {x: 60, y: 60 };
//             case STICKER.HOKUSAI_FISH_RED: 
//                 return {x: 60, y: 60 };
//             case STICKER.HOMER_FLOWERS: 
//                 return {x: 40, y: 40 };
//             case STICKER.HOMER_BIRDS: 
//                 return {x: 40, y: 40 };
//             case STICKER.HOMER_GIRL: 
//                 return {x: 40, y: 40 };
//             case STICKER.HOMER_CLOUDS: 
//                 return {x: 40, y: 40 };
//             case STICKER.HOMER_BOY: 
//                 return {x: -20, y: -20 };
//             case STICKER.MONDRIAN_RECTANGLE_HORIZONTAL: 
//                 return {x: 20, y: 20 };
//             case STICKER.MONDRIAN_RECTANGLE_VERTICAL: 
//                 return {x: 20, y: 20 };
//             case STICKER.MONDRIAN_CIRCLE: 
//                 return {x: 20, y: 20 };
//             case STICKER.MONDRIAN_TRIANGLE: 
//                 return {x: 20, y: 20 };
//             case STICKER.MONDRIAN_SQUARE: 
//                 return {x: 20, y: 20 };
//             case STICKER.VANGOGH_GLASSES: 
//                 return {x: 25, y: 25 };
//             case STICKER.VANGOGH_BOW: 
//                 return {x: 25, y: 25 };
//             case STICKER.VANGOGH_PEARL: 
//                 return {x: 25, y: 25 };
//             case STICKER.VANGOGH_FLOWER:
//                 return {x: 25, y: 25 };
//             case STICKER.VANGOGH_BIRD: 
//                 return {x: 25, y: 25 };
        
//         }

//         return {x: 0, y: 0};
//     }

//     private function _pickup() {
//         WMSound.playSound( manifest.Sound.pick_up, .75 );
//         ConstantsEvent.pickupSticker.dispatch(this);
//     }
// }

// typedef StickerAssets = {
//     texture:String,
//     sound:String,
//     environmentTexture:String,
//     gain:Float,
// }   