package workinman.display;

/**
 * SpriteRect contains information for the texture coordinates of a sprite within a TexturePacker sprite sheet
 *
 * As of 5/2/16, requires a Spine texturepacked asset
 */
class SpriteRect {

	private var _parseRes : PointRes;

	/**
	 * Constructor for SpriteRect
	 */
	public function new( pData:Array<String> ) : Void {
		_parseRes = {x:0,y:0};

		// Line 1 - Rotation
		rotate = pData[1].indexOf("true") > -1;
		// Line 2 - x/y
		_setXY( _getLineData( pData[2] ) );
		// Line 3 - size x/y
		_setSizeXY( _getLineData( pData[3] ) );
		// Line 4 - original size x/y
		_setOrig( _getLineData( pData[4] ) );
		// Line 5 - offset x/y
		_setOffset( _getLineData( pData[5] ) );
		// Line 6 - index (skipped / actual Spine stuff?)

		_parseRes = null;
	}

	private function _getLineData( pString:String ) : PointRes {
		var tSplit : Array<String> = pString.split( ": " );
		tSplit = tSplit[1].split( ", " );
		_parseRes.x = Std.parseInt( tSplit[0] );
		_parseRes.y = Std.parseInt( tSplit[1] );
		tSplit = null;
		return _parseRes;
	}

	private function _setXY( pRes:PointRes ) : Void {
		x = pRes.x;
		y = pRes.y;
	}

	private function _setSizeXY( pRes:PointRes ) : Void {
		sizeX = pRes.x;
		sizeY = pRes.y;
	}

	private function _setOrig( pRes:PointRes ) : Void {
		origX = pRes.x;
		origY = pRes.y;
	}

	private function _setOffset( pRes:PointRes ) : Void {
		offsetX = pRes.x;
		offsetY = pRes.y;
	}

	/**
	 * Whether or not the packed image is rotated
	 */
	public var rotate( default,null ) : Bool;

	/**
	 * The x position in the atlas the image is located at
	 */
	public var x( default,null ) : Int;

	/**
	 * The y position in the atlas the image is located at
	 */
	public var y( default,null ) : Int;

	/**
	 * The width of the image to draw, in the atlas
	 */
	public var sizeX( default,null ) : Int;

	/**
	 * The height of the image to draw, in the atlas
	 */
	public var sizeY( default,null ) : Int;

	/**
	 * The original width of the image, if the image is trimmed
	 */
	public var origX( default,null ) : Int;

	/**
	 * The original height of the image, if the image is trimmed
	 */
	public var origY( default,null ) : Int;

	/**
	 * The x offset into the original image size, if the image is trimmed
	 */
	public var offsetX( default,null ) : Int;

	/**
	 * The y offset into the original image size, if the image is trimmed
	 */
	public var offsetY( default,null ) : Int;

	/**
	 * String rendition of SpriteRect
	 */
	public function toString() : String {
		return '[SpriteRect] { x:$x y:$y sizeX:$sizeX sizeY:$sizeY origX:$origX origY:$origY offsetX:$offsetX offsetY:$offsetY }';
	}
}

typedef PointRes = {
	x : Int,
	y : Int,
}
