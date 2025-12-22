package workinman.display;

import flambe.Entity;
import flambe.swf.MovieSprite;
import flambe.swf.MovieSymbol;
import flambe.swf.Library;

class AnimatedElementFlump extends AnimatedElement {

	private var _entityContainer	: Entity;
	private var _movieSprite		: MovieSprite;
	private var _library			: String;
	private var _symbol				: String;

	public function new ( pData:AnimatedElementFlumpProp ) : Void {
		_entityContainer = new Entity();
		super( pData );
		// Try to grab library data from assets, if it exists
		if ( pData.library == null ) {
			pData.library = pData.asset;
		}
		// If we still don't have any library info, throw an error
		if ( pData.library != null ) {
			setLibraryAndSymbol( pData.library, pData.symbol, pData.doTrace!=null?pData.doTrace:false );
		} else {
			throw "[FlumpElement](new) Trying to create a Flump element with no library, or asset. Please define a library or asset.";
		}
	}

	public override function dispose() : Void {
		_entityContainer.dispose();
		_entityContainer = null;
		_movieSprite.dispose();
		_movieSprite = null;
		_library = null;
		_symbol = null;
		super.dispose();
	}

	public function setSymbol( pSymbol:String ) : AnimatedElementFlump {
		return setLibraryAndSymbol( _library, pSymbol, false );
	}

	public function setLibraryAndSymbol( pLibrary:String, ?pSymbol:String, ?pTraceBuild:Bool ) : AnimatedElementFlump {
		// Clear out old sprite, if it exists
		if ( _movieSprite != null ) {
			_entityContainer.remove(_movieSprite);
			_movieSprite.dispose();
			_movieSprite = null;
		}

		// Grab a reference to our library, and if we don't have it, return
		var tLibrary : Library = workinman.WMAssets.getLibrary( pLibrary );
		if ( tLibrary == null ) {
			return this;
		}

		// Search for first symbol in the library if none is defined
		// You still need to define the symbol if there are more than one in a library!
		if ( pSymbol == null ) {
			pSymbol = "";
		}

		// We didn't pass in a symbol, let's look for the first one
		if ( pSymbol == "" ) {
			for ( s in tLibrary ) {
				if ( Std.is(s,MovieSymbol) && cast(s,MovieSymbol).frames > 0 ) {
					pSymbol = s.name;
					if ( pTraceBuild ) {
						trace( "[AnimatedElement](setLibraryAndSymbol) Found symbol named '" + pSymbol + "' in library '" + pLibrary + "'" );
					}
				}
			}
		}

		if ( pLibrary == _library && pSymbol == _symbol ) {
			// No reason to re-set the same info
			return this;
		}

		_library = pLibrary;
		_symbol = pSymbol;

		var tSymbol : MovieSymbol = cast tLibrary.getSymbol( _symbol );
		_buildAnimationsFromLayers( tSymbol, pTraceBuild );
		_duration = tSymbol.duration;
		_frames = tSymbol.frames;
		_movieSprite = cast tSymbol.createSprite();
		_movieSprite.paused = true;
		_entityContainer.add(_movieSprite);
		tSymbol = null;
		return this;
	}

	private function _buildAnimationsFromLayers( pSymbol:MovieSymbol, pTrace:Bool ) : Void {
		while ( _animations.length > 0 ) {
			_animations.pop().dispose();
		}
		var labelLayer : MovieLayer = null;
		for( l in pSymbol.layers ) {
			if ( labelLayer != null ) {
				break;
			}
			for ( k in l.keyframes ) {
				if ( k.label != null ) {
					labelLayer = l;
					break;
				}
			}
		}
		if ( pTrace ) {
			trace("[AnimatedElement](_buildAnimationsFromLayers) Building animations for '" + _library + " - " + _symbol + "'" );
		}
		if ( labelLayer != null ) {
			for ( k in labelLayer.keyframes ) {
				addAnimation( k.label, Math.floor(k.index+1), Math.floor(k.index+k.duration) );
				if ( pTrace ) {
					trace("\tAdd: '" + k.label + "' Start: " + (k.index+1) + " End: " + (k.index+k.duration) );
				}
			}
		} else {
			trace("[AnimatedElement](_buildAnimationsFromLayers) Couldn't find any labels to base animations on in '" + _library + " - " + _symbol + "'" );
		}
	}

	public function addAnimation( pName:String, pStartFrame:Int, pEndFrame:Int ) : AnimatedElementFlump {
		removeAnimation( pName );
		_animations.push( AnimationDef.request(pName, pStartFrame-1, pEndFrame-1) );
		return this;
	}

	private override function _runAnimation( dt:Float ) : Void {
		if ( _movieSprite != null ) {
			_movieSprite.onUpdate(dt);
		}
		super._runAnimation(dt);
	}

	private override function _setFrame( pFrame:Float ) {
		if ( _movieSprite == null ) {
			return;
		}
		_movieSprite.position = ((pFrame/_frames) * _duration);
	}

	private override function _draw( g:Graphics ) : Void {
		if ( _movieSprite == null ) {
			return;
		}
		g.ctx.save();
		flambe.display.Sprite.render(_entityContainer,g.ctx);
		g.ctx.restore();
	}
}
