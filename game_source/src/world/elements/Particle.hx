package world.elements;

import app.PARTICLE_TYPE;
import workinman.display.Element;
import workinman.pooling.ICacheableElement;
import workinman.math.WMPoint;
import app.EFFECT_TYPE;
import workinman.WMRandom;

class Particle extends Element implements ICacheableElement
{
    private var _type:PARTICLE_TYPE;
    private var _lifetime:Float = 0;
    private var _fadeout:Float = 0;
    private var _fadein:Float = 0;
    private var _fadein_full: Float = 0;
    private var _gravity:Float = 0;

    public function new() : Void {
		super( {} );
	}

    public function init(pData:Dynamic) : Void {
        setAsset(pData.asset);
        pos.x = pData.x;
        pos.y = pData.y;

        velocity.to(0, 0);

        doDelete = false;
        alpha = 1;

        _type = pData.type;
        _lifetime = 1;
        _gravity = 0;

        rotation = Math.random() * 360;

        switch(_type) {
            case NONE:
                
        }

        _fadein_full = _fadein;
    }

    public override function update(dt:Float) : Void {
        super.update(dt);

        pos.x += velocity.x * dt;
        pos.y += velocity.y * dt;

        velocity.y += _gravity * dt;

        if(_fadein >= 0)
        {
            _fadein -= dt;
            alpha = 1 - (_fadein / _fadein_full);
        }
        else
        {
            if(_fadeout > 0 && _lifetime < _fadeout) {
                alpha = 1 - ((_fadeout - _lifetime) / _fadeout);
            }

            _lifetime -= dt;
            if(_lifetime < 0) {
                doDelete = true;
            }
        }

    }

    // Saves the return delegate
	private var _returnFunction : ICacheableElement->Void;
	public function setReturnFunction( pReturn:ICacheableElement->Void ) : Void {
		_returnFunction = pReturn;
	}

	// Override the root dispose. Notice it does NOT call super.dispose() - that is reserved for the final destroy() function
	public override function dispose() : Void {
		_returnFunction(this);
	}

	// Final destroy for when the CacheManager is done. Call super.dispose, and do your proper cleanup here
	// Remember to null your _returnFunction delegate
	public function destroy() : Void {
		super.dispose();
		_returnFunction = null;
	}
}