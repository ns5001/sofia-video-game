package workinman.display;

class FillSprite extends Sprite {

	public var color(default,default) : Int;
	public var sizeX(default,default) : Float;
	public var sizeY(default,default) : Float;

	public function new( prop:FillSpriteProp ) : Void {
		super(prop);
		color = 0xFF0000;
		sizeX = sizeY = 10;
		if ( prop != null ) {
			color = prop.color;
			sizeX = prop.sizeX;
			sizeY = prop.sizeY;
		}
	}

	public override function get_width() : Int { return Math.floor(sizeX); }
	public override function get_height() : Int { return Math.floor(sizeY); }

	private override function _draw( g:Graphics ) : Void {
		g.ctx.fillRect(color,0,0,sizeX,sizeY);
	}
}
