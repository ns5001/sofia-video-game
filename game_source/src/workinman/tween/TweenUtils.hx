package workinman.tween;

import workinman.display.Sprite;
import workinman.tween.data.TweenStep;

class TweenUtils {

	// Reusable storage variables
	// private static var __workPoint : WMPoint;
	// private static var _def : TweenStep;

	// Follow a pattern like this for your tween functions -
	//  -- The following are required
	// someTween( 	pTarget:Dynamic, // this is what you will be tweening, usually a renderable or a WMPoint
	// 				pTweener:Tweener, // The tweener to do the work
	//  -- Put things here which may change depending on what you're tweening eg.
	//				pDoInit:Bool = true, // Allow you to manually set the source or have the function set it yourself, generally TRUE for Ins, and FALSE for outs
	//				pTime:Float, // How long the tween will take
	// 				pTargetX:Float, // The x to tween to
	//				pTargetScale:Float, // The scale to tween to
	//	-- Make sure you include a delay too!
	//				pDelay : Float = 0 // How long to wait before starting
	//			) : TweenStep // Return this so you can have onComplete handlers!

	// Simple fade in tween
	public static function easeFadeIn( pTarget:Sprite, pTweener:Tweener, pDoInit:Bool = true, pDelay:Float = 0 ) : TweenStep {
		// Set the initial state, if required
		if ( pDoInit ) {
			pTarget.visible = true;
			pTarget.alpha = 0;
		}
		// Begin the tween
		return pTweener.tween( { target:pTarget, duration:.3, overwrite:true, ease:Ease.inQuad, delay:pDelay }, { alpha:1 } );
	}

	// Simple fade out tween
	public static function easeFadeOut( pTarget:Sprite, pTweener:Tweener, pDoInit:Bool = true, pDelay:Float = 0 ) : TweenStep {
		// Set the initial state, if required
		if ( pDoInit ) {
			pTarget.visible = true;
			pTarget.alpha = 1;
		}
		// Begin the tween
		return pTweener.tween( { target:pTarget, duration:.3, overwrite:true, ease:Ease.outQuad, delay:pDelay }, { alpha:0 } );
	}

	// Simple bounce in tween
	public static function easeBounceIn( pTarget:Sprite, pTweener:Tweener, pDoInit:Bool = true, pDelay:Float = 0 ) : TweenStep {
		// Set the initial state, if required
		if ( pDoInit ) {
			pTarget.visible = true;
			pTarget.scale = .1;
			pTarget.alpha = 0;
		}
		// Begin the tween
		pTweener.tween( { target:pTarget, duration:.15, overwrite:true, ease:Ease.outQuad, delay:pDelay }, { scale:1.1, alpha:1 } );
		return pTweener.tween( { target:pTarget, duration:.15, ease:Ease.inQuad }, { scale:1 } );
	}

	// Simple bounce out tween
	public static function easeBounceOut( pTarget:Sprite, pTweener:Tweener, pDoInit:Bool = false, pDelay:Float = 0 ) : TweenStep {
		// Set the initial state, if required
		if ( pDoInit ) {
			pTarget.visible = true;
			pTarget.scale = 1;
			pTarget.alpha = 1;
		}
		// Begin the tween
		pTweener.tween( { target:pTarget, duration:.15, overwrite:true, ease:Ease.outQuad, delay:pDelay }, { scale:1.1 } );
		return pTweener.tween( { target:pTarget, duration:.15, ease:Ease.inQuad }, { scale:.1, alpha:0 } );
	}

	// Simple elastic bounce in
	public static function easeElasticBounceIn( pTarget:Sprite, pTweener:Tweener, pDoInit:Bool = true, pDelay:Float = 0 ) : TweenStep {
		// Set the initial state, if required
		if ( pDoInit ) {
			pTarget.visible = true;
			pTarget.scale = .1;
			pTarget.alpha = 0;
		}
		// Begin the tween
		pTweener.tween( { target:pTarget, duration:.15, overwrite:true, ease:Ease.outQuad, delay:pDelay }, { scale:1.1, alpha:1 } );
		return pTweener.tween( { target:pTarget, duration:.5, ease:Ease.outElastic }, { scale:1 } );
	}

	// Simple bounce in, rocks to an angle before settling back to 0 rotation
	public static function easeRockBounceIn( pTarget:Sprite, pTweener:Tweener, pRockAngle:Float, pDoInit:Bool = true, pDelay:Float = 0 ) : TweenStep {
		// Set the initial state, if required
		if ( pDoInit ) {
			pTarget.visible = true;
			pTarget.scale = .1;
			pTarget.alpha = 0;
			pTarget.rotation = 0;
		}
		// Begin the tween
		pTweener.tween( { target:pTarget, duration:.15, overwrite:true, ease:Ease.outQuad, delay:pDelay }, { scale:1.1, alpha:1, rotation:pRockAngle } );
		return pTweener.tween( { target:pTarget, duration:.15, ease:Ease.inQuad }, { scale:1, rotation:0 } );
	}

	// Simple bounce out, rocks to an angle before disappearing
	public static function easeRockBounceOut( pTarget:Sprite, pTweener:Tweener, pRockAngle:Float, pDelay:Float = 0 ) : TweenStep {
		// Begin the tween
		pTweener.tween( { target:pTarget, duration:.15, overwrite:true, ease:Ease.outQuad, delay:pDelay }, { scale:1.1, rotation:pRockAngle } );
		return pTweener.tween( { target:pTarget, duration:.15, ease:Ease.inQuad }, { scale:.1, rotation:0, alpha:0 } );
	}
}
