package workinman.display;

import workinman.pooling.PoolStrictBase;
import workinman.pooling.IStrictPoolable;

class AnimationDef extends PoolStrictBase implements IStrictPoolable {

	public static function request( pId:String, pStartFrame:Int = -1, pEndFrame:Int = -1, pFrameIds:Array<String> = null ) : AnimationDef {
		return WMPool.requestObject(AnimationDef).init(pId,pStartFrame,pEndFrame,pFrameIds);
	}

	public var frameIds(default,null) : Array<String>;
	public var id(default,null) : String;
	public var startFrame(default,null) : Int;
	public var endFrame(default,null) : Int;
	public var reverse(default,null) : Bool;

	public override function create() : Void {
		frameIds = [];
	}

	public function init( pId:String, pStartFrame:Int = -1, pEndFrame:Int = -1, pFrameIds:Array<String> = null ) : AnimationDef {
		id = pId;
		reverse = false;
		if ( pFrameIds != null ) {
			for ( i in pFrameIds ) {
				frameIds.push(i);
			}
			startFrame = 1;
			endFrame = frameIds.length;
		} else {
			startFrame = pStartFrame;
			endFrame = pEndFrame;
			if ( pStartFrame > pEndFrame ) {
				reverse = true;
				startFrame = pEndFrame;
				endFrame = pStartFrame;
			}
		}
		return this;
	}

	public override function dispose() : Void {
		while ( frameIds.length > 0 ) {
			frameIds.pop();
		}
		super.dispose();
	}

	public override function destroy() : Void {
		frameIds = null;
		id = null;
		super.destroy();
	}
}
