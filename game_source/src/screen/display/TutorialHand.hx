package screen.display;

import workinman.display.ImageSprite;
import workinman.display.ImageSpriteProp;
import app.ConstantsEvent;
import workinman.tween.Tweener;
import workinman.tween.Ease;
import workinman.WMTimer;

class TutorialHand extends ImageSprite {

    private var _flagIsHidden           : Bool = true;
    private var _flagIsReadyToLoop      : Bool = false;

    private var _speedMultiplier        : Float = 150.0;
    private var _fadeDuration           : Float = 0.75;
    private var _tapDuration            : Float = 0.35;
    private var _positionQueue          : Array<Dynamic>;

    private var _fingerOrigin           : Dynamic = { x: 0.25, y: 0.25 };
    private var _baseScale              : Float;
    private var _tappingScale           : Float = 0.8;

    private var _tween                  : Tweener;

    private var _moving : Bool;

    public function new( pData:ImageSpriteProp, pTweener:Tweener ) {
        super( pData );

        _tween = pTweener;
        _baseScale = scale;
        _positionQueue = [];

        originX = _fingerOrigin.x;
        originY = _fingerOrigin.y;

        inputEnabled = false;
        _moving = false;

        // Add listeners
        ConstantsEvent.tapTutorialHand.add( _onEventTapTutorialHand );
        ConstantsEvent.hideTutorialHand.add( _onEventHideTutorialHand );
        ConstantsEvent.moveTutorialHand.add( _onEventMoveTutorialHand );
        ConstantsEvent.moveTutorialHand.add( _enableMoving );
        ConstantsEvent.tapTutorialHand.add( _disableMoving );
    }

    public override function dispose() : Void {
        _positionQueue = [];

        // Remove listeners
        ConstantsEvent.tapTutorialHand.remove( _onEventTapTutorialHand );
        ConstantsEvent.hideTutorialHand.remove( _onEventHideTutorialHand );
        ConstantsEvent.moveTutorialHand.remove( _onEventMoveTutorialHand );
        ConstantsEvent.moveTutorialHand.remove( _enableMoving );
        ConstantsEvent.tapTutorialHand.remove( _disableMoving );

        super.dispose();
    }

    public override function update(dt:Float) : Void {
        super.update(dt);

        // If ready to loop, set up the tween queue.
        if(_flagIsReadyToLoop && !_flagIsHidden) {
            _flagIsReadyToLoop = false;

            // If we have elements in the position queue, we're moving.
            if( _positionQueue.length > 0 && _moving) {

                // Set up the position tweens to loop.
                for(p in 1..._positionQueue.length) {
                    // Determine duration of movement. Longer movements take more time.
                    var tDuration = Math.sqrt( Math.pow(_positionQueue[p].x - _positionQueue[p - 1].x, 2) + Math.pow(_positionQueue[p].y - _positionQueue[p - 1].y, 2) ) / _speedMultiplier;

                    // Tween to the next position. Delay the tweens by the running total of preceding tweens' durations.
                    if(p == _positionQueue.length - 1) {
                        _tween.tween( { target: pos, duration: tDuration, ease: Ease.linear }, { x: _positionQueue[p].x, y: _positionQueue[p].y } ).onComplete( function() {
                            _fadeHandAndReset();
                        } );
                    } else {
                        _tween.tween( { target: pos, duration: tDuration, ease: Ease.linear }, { x: _positionQueue[p].x, y: _positionQueue[p].y } );
                    }
                }

            } else {
                // If there are no elements in the position queue, we're tapping.
                _tween.tween( { target: this, duration: _tapDuration, ease: Ease.outExpo }, { scale: _baseScale * _tappingScale } ).onComplete(function() {
                    // Tween back to original size, then loop.
                    _tween.tween( { target: this, duration: _tapDuration, ease: Ease.inExpo }, { scale: _baseScale } ).onComplete(function() {
                        _flagIsReadyToLoop = true;
                    });
                });
            }
        }
    }

    private function _enableMoving(pUseless : Dynamic) : Void { _moving = true; }
    private function _disableMoving(pUseless : Dynamic) : Void { _moving = false; }

    private function _fadeHandAndReset() : Void {
        _flagIsHidden = true;

        _tween.tween( { target: this, duration: _fadeDuration, ease: Ease.outQuad, overwrite: true }, { alpha: 0 } ).onComplete(function() {
            //_flagIsReadyToLoop = true;
            // _onEventMoveTutorialHand( _positionQueue );
        } );
    }

    private function _onEventTapTutorialHand( pPosition:Dynamic ) : Void {
        _tween.stop(this);
        _tween.stop(pos);
        
        pos.x = pPosition.x;
        pos.y = pPosition.y;

        _positionQueue = [];

        // If the hand is hidden, show it and try again.
        if(_flagIsHidden) {

            _tween.tween( { target: this, duration: _fadeDuration, ease: Ease.outQuad }, { alpha: 1 } ).onComplete(function() {
                _flagIsHidden = false;
                _onEventTapTutorialHand( pPosition );
            });
        
            return;
        } else {
            // If we're tweening, interrupt.
            if(_positionQueue.length > 0) {
                _positionQueue = [];

                _tween.stop(this);
                _tween.stop(pos);
            }

            _flagIsReadyToLoop = true;
        }
    }

    private function _onEventMoveTutorialHand( pPositions:Array<Dynamic> ) : Void {
        if(pPositions.length < 2) {
            trace("[TutorialHand] Not enough positions! Needs at least two points.");
            return;
        }

        // If the hand is hidden, show it and try again.
        if(_flagIsHidden) {
            pos.x = pPositions[0].x;
            pos.y = pPositions[0].y;

            _tween.tween( { target: this, duration: _fadeDuration, ease: Ease.outQuad }, { alpha: 1 } ).onComplete(function() {
                _flagIsHidden = false;
                _onEventMoveTutorialHand( pPositions );
            });
        
            return;
        } else {
            // If we're tweening, interrupt.
            _tween.stop(this);
            _tween.stop(pos);

            pos.x = pPositions[0].x;
            pos.y = pPositions[0].y;

            // Set the position queue and indicate that we're ready to tween.
            _positionQueue = pPositions;
            _flagIsReadyToLoop = true;
        }
    }

    private function _onEventHideTutorialHand() : Void {
        // If the hand is already hidden, return.
        if( _flagIsHidden ) return;

        _flagIsHidden = true;
        _moving = false;

        // Stop current tweens, reset position queue.
        _tween.stop(this);
        _tween.stop(pos);

        _positionQueue = [];
        _flagIsReadyToLoop = false;
    
        _tween.tween( { target: this, duration: _fadeDuration, ease: Ease.outQuad, overwrite: true }, { alpha: 0 } );
    }

    public function immediateHideTutorialHand() : Void
    {
        // If the hand is already hidden, return.
        if( _flagIsHidden ) return;

        _flagIsHidden = true;
        _moving = false;

        this.alpha = 0;

        // Stop current tweens, reset position queue.
        _tween.stop(this);
        _tween.stop(pos);

        _positionQueue = [];
        _flagIsReadyToLoop = false;
    }
}