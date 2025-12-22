package workinman.display.spine;

import workinman.display.spine.platform.flambe.SkeletonAnimation;
import workinman.display.spine.platform.flambe.SkeletonRegions;
import workinman.display.spine.platform.flambe.FlambeTextureLoader;
import workinman.display.spine.animation.AnimationState;
import workinman.display.spine.animation.AnimationStateData;
import workinman.display.spine.animation.Animation;
import workinman.display.spine.animation.TrackEntry;
import workinman.display.spine.atlas.Atlas;
import workinman.display.spine.attachments.AtlasAttachmentLoader;
import workinman.display.spine.attachments.BoundingBoxAttachment;
import workinman.display.spine.attachments.RegionAttachment;
import workinman.math.WMMath;
import workinman.event.Event0;

class SpineElement extends Element {

	public static inline var VERSION : String = "3.2.00";
	public static inline var ATLAS_FILE_TYPE : String = ".atlas";

	private var _renderer			: SkeletonAnimation;
	public var state(default,null)	: AnimationState;
	private var _skeleton			: Skeleton;
	private var _animationsSpine	: Map<String, Animation>;
	private var _bounds 			: SkeletonBounds;
	private var _boundsRegion		: SkeletonRegions;
	private var _hitName			: String;
	private var _currentAnimation	: String;
	public var eventAnimationComplete : Event0;

	public static var FPS			: Int = 30;

	public function new( pData:SpineElementProp, pSharedAtlas:String = "", pSharedAtlasJSON = "", pShell:Bool = false ) : Void {
		super(pData);

		var tAtlasName : String = pData.library;
		var tJSON : String = pSharedAtlasJSON;
		if(pSharedAtlas != "") {
			tAtlasName = pSharedAtlas;
		}

		var atlas:Atlas = pShell ? null : new Atlas(
			workinman.WMAssets.getFile( tAtlasName + ATLAS_FILE_TYPE ).toString(),
			new FlambeTextureLoader( tAtlasName.substring(0, tAtlasName.lastIndexOf("/") + 1), workinman.WMAssets.getPackForAsset( tAtlasName ) )
		);
		var json = new SkeletonJson( new AtlasAttachmentLoader(atlas) );
		
		var tLibraryName = (tJSON == "" ? pData.library : tJSON);
		var skeletonData:SkeletonData = json.readSkeletonData(workinman.WMAssets.getFile(tLibraryName + ".json").toString(), tLibraryName);

		var stateData = new AnimationStateData(skeletonData);
		state = new AnimationState(stateData);

		_renderer = new SkeletonAnimation(skeletonData, pData.debug);
		_skeleton = _renderer.skeleton;
		_skeleton.updateWorldTransform();
		eventAnimationComplete = new Event0();

		_animationsSpine = new Map<String, Animation>();
		for(animation in skeletonData.animations) {
			if(pData.trace) {
				trace("[SpineElement] Building animations for " + tAtlasName + " named " + animation.name);
			}
			_animationsSpine.set(animation.name, animation);
		}

		state.onStart.add(_onAnimationStart);
		state.onComplete.add(_onAnimationCompleted);
		state.onEvent.add(_onAnimationEvent);

		addChild(_renderer);

		_bounds = new SkeletonBounds();
		_boundsRegion = new SkeletonRegions(_renderer);

		atlas = null;
		json = null;
		skeletonData = null;
	}

	public override function dispose():Void {
		state.onStart.remove(_onAnimationStart);
		state.onComplete.remove(_onAnimationCompleted);
		state.onEvent.remove(_onAnimationEvent);

		_bounds.dispose();
		_bounds = null;
		_boundsRegion.dispose();
		_boundsRegion = null;
		state.dispose();
		state = null;
		eventAnimationComplete.dispose();
		eventAnimationComplete = null;
		// Other variables are disposed elsewhere
		_skeleton = null;
		_animationsSpine = null;
		_renderer = null;

		super.dispose();
	}

	public var currentAnimation(get, never) : String;
	private function get_currentAnimation() : String { return _currentAnimation; }

	public var animationsSpine(get, never) : Map<String, Animation>;
	private function get_animationsSpine() : Map<String, Animation> { return _animationsSpine; }

	public var hitName(get, never) : String;
	private function get_hitName() : String { return _hitName; }

	public override function runUpdate( dt:Float ) : Void {
        super.runUpdate(dt);
		state.update(dt);
		state.apply(_skeleton);
		_skeleton.updateWorldTransform();
	}

	/**
	 * Total number of frames
	 */
	public function getFrames(pTrackIndex = 0) : Int {
		var track:TrackEntry = state.getCurrent(pTrackIndex);
		if(track != null) {
			return Math.floor(track.animation.duration * FPS);
		}
		return 0;
	}

	/**
	 * Get current frame
	 */
	public function getFrame(pTrackIndex = 0) : Int {
		var track:TrackEntry = state.getCurrent(pTrackIndex);
		if(track != null) {
			return Math.floor(track.animation.currentTime * FPS);
		}
		return 0;
	}

	/**
	 * Set current frame
	 */
	public function setFrame(pValue:Int, pTrackIndex = 0) : Void {
		var track:TrackEntry = state.getCurrent(pTrackIndex);
		if(track != null) {
			track.timeScale = 0;
			track.time = WMMath.clamp(pValue / FPS, 0, track.animation.duration);
		}
	}

	/**
	 * Set time scale of animation
	 * @param pTmeScale The rate at which animations progress over time. 1 means 100%. 0.5 means 50%.
	 */
	public function setTimeScale(pTimeScale:Float, pTrackIndex:Int = 0) : Void
	{
		var track:TrackEntry = state.getCurrent(pTrackIndex);
		if(track != null) {
			track.timeScale = pTimeScale;
		}
	}

	/**
	 * Continue animation if there was one playing
	 */
	public function startAnimation(pTrackIndex:Int = 0) : Void
	{
		var track:TrackEntry = state.getCurrent(pTrackIndex);
		if(track != null) {
			track.timeScale = 1;
		}
	}

	/**
	 * Pause animation if playing
	 */
	public function stopAnimation(pTrackIndex:Int = 0) : Void
	{
		var track:TrackEntry = state.getCurrent(pTrackIndex);
		if(track != null) {
			track.timeScale = 0;
		}
	}

	/**
	* Mix between animations
	* @param pFrom the first animation
	* @param pTo the second animation
	* @param pDuration the duration the mix should last
	*/
	public function mixAnimation(pFrom:String, pTo:String, pDuration:Float) : Void {
		state.data.setMixByName(pFrom, pTo, pDuration);
	}

	public function hasAnimation( pName:String ) : Bool {
		return _animationsSpine.exists(pName);
	}

	/**
	* Set the current animation. Any queued animations are cleared.
	* @param pName the name of the animation
	* @param pNumLoops the number of times to play the animation. pNumLoops = 0 will loop the animation
	* @param pFlagReset if slots and bones should reset before playing the animation
	* @param pTrackIndex used to combine animations. Give each animation it's own unique index to use
	*/
	public function animate(pName:String, pNumLoops:Int = 0, pTimeScale:Float = 1, pTrackIndex:Int = 0, pFlagReset:Bool = false) : SpineElement {
		_doAnimate(pName, pNumLoops, false, 0, pTimeScale, pTrackIndex, pFlagReset);
		return this;
	}

	/**
	* Queue an animation
	* @param pDelay the number of seconds to delay the animation
	*/
	public function queueAnimation(pName:String, pNumLoops:Int = 0, pTimeScale:Float = 1, pTrackIndex:Int = 0, pFlagReset:Bool = false, pDelay:Float = 0) : SpineElement {
		_doAnimate(pName, pNumLoops, true, pDelay, pTimeScale, pTrackIndex, pFlagReset);
		return this;
	}

	private function _doAnimate(pName:String, pNumLoops:Int, pQueue:Bool, pDelay:Float, pTimeScale:Float = 1, pTrackIndex:Int = 0, pFlagReset:Bool = false): Void {
		if(pFlagReset){
			_skeleton.setToSetupPose();
		}

		if(hasAnimation(pName)) {
			var entry:TrackEntry;
			if(pQueue) {
				entry = state.addAnimationByName(pTrackIndex, pName, pNumLoops == 0, pDelay);
			} else {
				entry = state.setAnimationByName(pTrackIndex, pName, pNumLoops == 0);
			}
			entry.timeScale = pTimeScale;

			if(pNumLoops > 0) {
				for(i in 1...pNumLoops) {
					entry = state.addAnimationByName(pTrackIndex, pName, false, 0);
					entry.timeScale = pTimeScale;
				}
			}
			entry = null;
		} else {
			trace("[SpineElement](animate) Animation not found: " + pName);
		}
	}

	public function clearQueue() : Void {
		if(state != null) { state.clearTracks(); }
	}

	/**
	 * Change skin
	 * @param pSkinName name of skin
	 */
	public function setSkin( pSkinName:String, pFlagReset:Bool = false) : Void {
        _skeleton.set_skinName( pSkinName );
        if(pFlagReset) {
        	_skeleton.setSlotsToSetupPose();
        }
    }

	/**
	 * Change attachment
	 * @param pSlotName name of slot
	 * @param pAttachmentName name of attachment
	 */
    public function setAttachment(pSlotName:String, pAttachmentName) : Void
    {
    	_skeleton.setAttachment(pSlotName, pAttachmentName);
    }

    public function getAttachment(pSlotName:String):String {
    	var slot:Slot = _skeleton.findSlot(pSlotName);
    	if(slot == null || slot.attachment == null) { return ""; }
    	return slot.attachment.name;
	}

	/**
	 * Check if hit a bounding box
	 * @param pName check if hit a specific region
	 */
    public function hit(pX:Float, pY:Float, pName:String = "") : Bool
    {
		_hitName = "";

    	// Update SkeletonBounds with current skeleton bounding box positions.
    	_bounds.update(_skeleton, true);
    	// Check if inside AABB first. This check is fast.
    	if(_bounds.aabbContainsPoint(pX, pY)) {
    		// Check if inside a bounding box.
    		var hit:BoundingBoxAttachment = _bounds.containsPoint(pX, pY);
    		if (hit != null && (pName == "" || pName == hit.name)) {
				_hitName = hit.name;
				return true;
			}
			hit = null;
    	}
    	return false;
    }

	/**
	 * Check if hit an image region
	 * @param pName check if hit a specific region
	 */
    public function hitRegion(pX:Float, pY:Float, pName:String = "") : Bool
    {
		_hitName = "";

    	// Update SkeletonBounds with current skeleton bounding box positions.
		_boundsRegion.update(_skeleton, true, scaleX, scaleY);
    	// Check if inside AABB first. This check is fast.
    	if(_boundsRegion.aabbContainsPoint(pX, pY)) {
    		// Check if inside a region
    		var hit:RegionAttachment = _boundsRegion.containsPoint(pX, pY);
    		if (hit != null && (pName == "" || pName == hit.name)) {
				_hitName = hit.name;
				return true;
			}
			hit = null;
    	}
    	return false;
	}

	public function addElementToSlot<T:Sprite>(slotName:String, element:T) : Void
	{
		if(_skeleton.findSlot(slotName) == null || _renderer.sprites.get(_skeleton.findSlot(slotName).attachment) == null) {
			return;
		}

		_renderer.sprites.get(_skeleton.findSlot(slotName).attachment).addChild(element);
	}

	private function _onAnimationStart(trackIndex:Int, event:Event) : Void {
		_currentAnimation = state.getCurrent(trackIndex).animation.name;
	}

	private function _onAnimationCompleted(trackIndex:Int, event:Event) : Void {
		// Override
		// You should be able to tell what animation you were coming from
		// based on state, but if not you can switch ( _currentAnimation ) here before
		// animating again

		eventAnimationComplete.dispatch();
	}

	private function _onAnimationEvent(trackIndex:Int, event:Event) : Void
	{
		// An event is a trigger for something to happen during an animation
		switch(event.data.name) {
			default:
		}
	}
}
