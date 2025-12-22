package world.elements;

import workinman.display.spine.SpineElement;
import workinman.display.Element;
import workinman.tween.Tweener;
import screen.data.AvatarSlotData;

class AvatarObj extends Element 
{
	private var _tween      : Tweener;
  private var _avatar     : SpineElement;
  
	public var animating  : Bool = false;

	//Constructor
	public function new(pData : Dynamic, pAvatarData : AvatarProp, pTween : Tweener, ?pReversed = false) : Void 
	{
        super(pData);
        
		_tween = pTween;

        setAvatarType(pAvatarData.bodyType);
        
        _avatar.setAttachment("face_color", AvatarSlotData.getSlotAttachment("face_color", pAvatarData.skinColor));
        _avatar.setAttachment("neck", AvatarSlotData.getSlotAttachment("neck", pAvatarData.skinColor));

        _avatar.setAttachment("hair", AvatarSlotData.getHairAttachment(pAvatarData.hairStyle, pAvatarData.hairColor));
        _avatar.setAttachment("hair_back", null);
        if (pAvatarData.hairStyle == 9 || pAvatarData.hairStyle == 13 || pAvatarData.hairStyle == 14)
            _avatar.setAttachment("hair_back", AvatarSlotData.getHairBackAttachment(pAvatarData.hairStyle, pAvatarData.hairColor));

        _avatar.setAttachment("eye_color_left", AvatarSlotData.getSlotAttachment("eye_color", pAvatarData.eyeColor));
        _avatar.setAttachment("eye_color_right", AvatarSlotData.getSlotAttachment("eye_color", pAvatarData.eyeColor));
        _avatar.setAttachment("eyes_shape", AvatarSlotData.getSlotAttachment("eyes_shape", pAvatarData.eyeShape));

        setOutfit(pAvatarData.outfitColor, pAvatarData.outfitType);
        setFacewear(pAvatarData.facewear, pAvatarData.outfitColor);

        if (pReversed) setReversedBuckle(pAvatarData.outfitColor, pAvatarData.outfitType);

        // at end of animation, set boolean
        _avatar.eventAnimationComplete.add(function() {
          animating = false;
        });
	}

	// UPDATE AND DISPOSE ----------------------------------------------
	public override function update(dt:Float) : Void 
	{
		super.update(dt); 
	}

	public override function dispose() : Void
	{
		// _tween = null;
		// _avatar = null;

		super.dispose();
  }
    
    public function setAvatarType ( pBodyType : Int ) : Void {

        // create new body
        switch(pBodyType) {
          case 0:
            _avatar = addElement ( new SpineElement({ library: manifest.spine.avatar_tall_thin.Info.name }, "spine/avatar_texture_packed"));
          case 1:
            _avatar = addElement ( new SpineElement({ library: manifest.spine.avatar_short_thin.Info.name }, "spine/avatar_texture_packed"));
          case 2:
            _avatar = addElement ( new SpineElement({ library: manifest.spine.avatar_tall_thick.Info.name }, "spine/avatar_texture_packed"));
          case 3:
            _avatar = addElement ( new SpineElement({ library: manifest.spine.avatar_short_thick.Info.name }, "spine/avatar_texture_packed"));
          case 4:
            _avatar = addElement ( new SpineElement({ library: manifest.spine.avatar_wheelchair.Info.name }, "spine/avatar_texture_packed"));
          default:
            _avatar = addElement ( new SpineElement({ library: manifest.spine.avatar_tall_thin.Info.name }, "spine/avatar_texture_packed"));
        }
    }
    public function setOutfit( pOutfitColor : Int, pOutfitType : Int ) {
        if (pOutfitType == 0) {
          switch(pOutfitColor) {
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
        } else {
          switch(pOutfitColor) {
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
    }
    public function setReversedBuckle( pOutfitColor : Int, pOutfitType : Int ) {
        if (pOutfitType == 0) {
          switch(pOutfitColor) {
            case 0:
              _avatar.setAttachment("logo_flip", "logo_skirt_1");
            case 1:
              _avatar.setAttachment("logo_flip", "logo_skirt_2");
            case 2:
              _avatar.setAttachment("logo_flip", "logo_skirt_3");
            case 3:
              _avatar.setAttachment("logo_flip", "logo_skirt_4");
            case 4:
              _avatar.setAttachment("logo_flip", "logo_skirt_5");
            case 5:
              _avatar.setAttachment("logo_flip", "logo_skirt_6");
            case 6:
              _avatar.setAttachment("logo_flip", "logo_skirt_7");
            case 7:
              _avatar.setAttachment("logo_flip", "logo_skirt_8");
          }
        } else {
          switch(pOutfitColor) {
            case 0:
              _avatar.setAttachment("logo_flip", "logo_pants_1");
            case 1:
              _avatar.setAttachment("logo_flip", "logo_pants_2");
            case 2:
              _avatar.setAttachment("logo_flip", "logo_pants_3");
            case 3:
              _avatar.setAttachment("logo_flip", "logo_pants_4");
            case 4:
              _avatar.setAttachment("logo_flip", "logo_pants_5");
            case 5:
              _avatar.setAttachment("logo_flip", "logo_pants_6");
            case 6:
              _avatar.setAttachment("logo_flip", "logo_pants_7");
            case 7:
              _avatar.setAttachment("logo_flip", "logo_pants_8");
          }
        }
    }
    private function setFacewear(pFacewear : Int, pOutfitColor : Int) : Void {
        _avatar.setAttachment("mask", null);
        _avatar.setAttachment("hearingaid", null);
        _avatar.setAttachment("glasses_circle", null);
        _avatar.setAttachment("glasses_square", null);

        switch(pFacewear) {
            case 0:
            _avatar.setAttachment("mask", AvatarSlotData.getSlotAttachment("mask", pOutfitColor));
            case 1:
            _avatar.setAttachment("glasses_circle", AvatarSlotData.getSlotAttachment("glasses_circle", pOutfitColor));
            case 2:
            _avatar.setAttachment("glasses_square", AvatarSlotData.getSlotAttachment("glasses_square", pOutfitColor));
            case 3:
            _avatar.setAttachment("hearingaid", AvatarSlotData.getSlotAttachment("hearingaid", pOutfitColor));
        }
    }

    public function animate(pAnimation : String, ?pLoops : Int = 0, ?pPreventAnims = false) : Void {
      animating = pPreventAnims;
      _avatar.animate(pAnimation, pLoops);
    }
    public function queueAnimation(pAnimation : String, ?pLoops : Int = 0, ?pPreventAnims = false) : Void {
      _avatar.queueAnimation(pAnimation, pLoops);
    }
}
