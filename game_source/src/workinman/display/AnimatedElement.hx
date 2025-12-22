package workinman.display;

import workinman.event.Event0;

class AnimatedElement extends Element {

	private var _currentAnimDef 			: AnimationDef;
	private var _animations 				: Array<AnimationDef>;
	private var _queuedAnimations			: Array<AnimationQueue>;
	public var eventAnimationComplete 		: Event0;
	public var currentAnimation				: String;

	public var reverse						: Bool;
	public var fps							: Float;
	private var _currentFrame 				: Float;
	private var _currentLoop 				: Int;
	private var _lastFrame 					: Int;
	private var _flagLoop 					: Bool;
	private var _duration 					: Float;
	private var _frames 					: Float;
	private var _animationStopped 			: Bool;
	private var _loopComplete				: Bool;
	private var _newFrame					: Int;
	private var _realFrame 					: Float;

	public function new ( pData:ImageSpriteProp ) : Void {
		_animations = new Array<AnimationDef>();
		_queuedAnimations = new Array<AnimationQueue>();
		eventAnimationComplete = new Event0();
		_currentAnimDef = null;
		_lastFrame = -1;
		_currentFrame = 0;
		currentAnimation = "";
		fps = 24;
		_animationStopped = true;
		_loopComplete = false;
		_realFrame = 0;
		super( pData );
	}

	public override function dispose() : Void {
		for ( a in _animations ) {
			a.dispose();
		}
		_animations = null;
		_currentAnimDef = null;
		clearQueue();
		for ( q in _queuedAnimations ) {
			q.dispose();
		}
		_queuedAnimations = null;
		eventAnimationComplete.dispose();
		eventAnimationComplete = null;
		currentAnimation = null;
		super.dispose();
	}

	public function setFps( pFPS:Float ) : AnimatedElement {
		fps = pFPS;
		return this;
	}

	public var animationRatio( get_animationRatio, set_animationRatio ) : Float;
	private function get_animationRatio() : Float {
		return (_currentFrame-_currentAnimDef.startFrame)/(_currentAnimDef.endFrame-_currentAnimDef.endFrame);
	}
	private function set_animationRatio(ratio:Float) : Float {
		_newFrame = Math.floor(ratio * (_currentAnimDef.endFrame - _currentAnimDef.startFrame) + _currentAnimDef.startFrame);
		if(_newFrame != _currentFrame) {
			animationFrame = _newFrame;
		}
		return get_animationRatio();
	}

	public var animationFrame( get_animationFrame, set_animationFrame ) : Int;
	private function get_animationFrame() : Int { return Std.int(_currentFrame); }
	private function set_animationFrame( pFrame:Int ) : Int {
		_currentFrame = _realFrame = pFrame;
		_setFrame(_realFrame);
		stopAnimation();
		return Std.int(_currentFrame);
	}

	public var isPlaying( get,never ) : Bool;
	private function get_isPlaying() : Bool { return currentAnimation != "" && _doLoop() == true && _animationStopped == false; }

	public var animationFrameRelative( get_animationFrameRelative, set_animationFrameRelative ) : Int;
 	private function get_animationFrameRelative() : Int { return Std.int(_currentFrame - _currentAnimDef.startFrame); }
	private function set_animationFrameRelative( pFrame:Int ) : Int { _currentFrame = _currentAnimDef.startFrame + pFrame; return get_animationFrameRelative(); }

	public var frames( get,never ) : Int;
	private function get_frames() : Int {
		return Math.floor(_frames);
	}

	public function removeAnimation( pName:String ) : Void {
		var tI : Int = _animations.length;
		while ( tI-- > 0 ) {
			if ( _animations[tI].id == pName ) {
				_animations[tI].dispose();
				_animations.splice(tI,1);
			}
		}
	}

	public function animate( pName:String, pNumLoops:Int = 0, pForceRestart:Bool = false ) : AnimatedElement {
		clearQueue();
		_doAnimate( pName,pNumLoops,pForceRestart );
		return this;
	}

	private function _doAnimate( pName:String, pNumLoops:Int = 0, pForceRestart:Bool = false ) : Void {
		if ( currentAnimation == pName && pForceRestart == false ) {
			return;
		}

		if( _animations != null && hasAnimation(pName) ) {
			_currentAnimDef = null;
			_currentAnimDef = _getAnimation(pName);
			if ( _currentAnimDef.reverse ) {
				reverse = true;
				_currentFrame = _currentAnimDef.endFrame;
			} else {
				reverse = false;
				_currentFrame = _currentAnimDef.startFrame;
			}
			currentAnimation = pName;
			setLoop(pNumLoops);
			_animationStopped = false;
			_setFrame(_currentFrame);
		} else {
			trace( "[AnimatedElement](_doAnimate) Animation not found: " + pName );
		}
	}

	public function setLoop( pLoop:Int ) : AnimatedElement {
		_currentLoop = pLoop;
		_flagLoop = (pLoop == 0);
		return this;
	}

	public function stopAnimation() : Void {
		_animationStopped = true;
	}

	public function startAnimation() : Void {
		_animationStopped = false;
	}

	private function _getAnimation( pId:String ) : AnimationDef {
		for ( a in _animations ) {
			if ( a.id == pId ) {
				return a;
			}
		}
		return null;
	}

	public function hasAnimation( pName:String ) : Bool {
		for ( a in _animations ) {
			if ( a.id == pName ) {
				return true;
			}
		}
		return false;
	}

	public function queueAnimation( pName:String, pNumLoops:Int = 0, pForceRestart:Bool = false ) : AnimatedElement {
		_queuedAnimations.push(AnimationQueue.request(pName,pNumLoops,pForceRestart));
		return this;
	}

	public function clearQueue() : Void {
		while ( _queuedAnimations.length > 0 ) {
			_queuedAnimations.pop().dispose();
		}
	}

	public override function update(dt:Float):Void {
		super.update(dt);
		_runAnimation(dt);
	}

	private function _doLoop() : Bool {
		return (_currentLoop > 0 || _flagLoop);
	}

	private function _runAnimation( dt:Float ) : Void {
		if ( isPlaying ) {
			_currentFrame += fps * dt;
			if ( Math.floor(_currentFrame) > _currentAnimDef.endFrame ) {
				_currentFrame = _currentAnimDef.startFrame + (_currentFrame-Math.floor(_currentFrame));
				_loopComplete = true;
			}

			if ( _loopComplete == true ) {
				_loopComplete = false;
				_currentLoop--;
				if ( _doLoop() == false ) {
					_animationStopped = true;
					_currentFrame = _currentAnimDef.endFrame;
					if ( _queuedAnimations.length > 0 ) {
						_doAnimate(_queuedAnimations[0].name,_queuedAnimations[0].loops,_queuedAnimations[0].force);
						_queuedAnimations[0].dispose();
						_queuedAnimations.splice(0,1);
					} else {
						_onAnimationComplete();
						eventAnimationComplete.dispatch();
					}
				}
			}

			if ( reverse ) {
				_realFrame = _currentAnimDef.endFrame - ( _currentFrame - _currentAnimDef.startFrame ) + 1;
			} else {
				_realFrame = _currentFrame;
			}

			if ( _realFrame != _lastFrame ) {
				_setFrame(_realFrame);
			}
		}
	}

	private function _setFrame( pFrame:Float ) {
		setAsset(_currentAnimDef.frameIds[Math.floor(pFrame-1)]);
	}

	private function _onAnimationComplete() : Void {
		// Override
		// You should be able to tell what animation you were coming from
		// based on state, but if not you can switch ( _currentAnimation ) here before
		// animating again
	}
}
