package workinman;

import workinman.assets.SpriteSheetDef;
import workinman.assets.LoadQueue;
import workinman.assets.WMAssetPack;
import workinman.display.SpriteRect;
import workinman.display.FontColor;
import workinman.event.Event0;
import flambe.asset.Manifest;
import flambe.asset.AssetEntry;
import flambe.asset.AssetPack;
import flambe.asset.File;
import flambe.display.Font;
import flambe.display.Texture;
import flambe.swf.Library;
import flambe.util.Disposable;
import flambe.util.Promise;
import flambe.System;
import flambe.math.FMath;
import flambe.sound.Sound;
import haxe.xml.Fast;

/**
 * WMAssets handles loading, unloading, parsing and delivering assets
 */
class WMAssets {

	public static var eventLoadError : Event0 = new Event0();

	private static var _assets : Map<String, String> = new Map<String, String>();
	private static var _packs : Map<String, WMAssetPack> = new Map<String, WMAssetPack>();
	private static var _spritesheets : Map<String,SpriteSheetDef> = new Map<String, SpriteSheetDef>();
	private static var _flump : Map<String, Library> = new Map<String, Library>();
	private static var _customManifests : Map<String, Manifest> = new Map<String, Manifest>();
	private static var _fontCache : Map<String,Font> = new Map<String, Font>();
	private static var _requests : Array<Disposable> = new Array<Disposable>();
	private static var _loadingCallback : Void->Void = null;
	private static var _loadQueue : Array<LoadQueue> = [];

	private static var _manifestsLoaded : Int = 0;
	private static var _manifestsMax : Int = 0;
	private static var _flagBaseIsCrossdomain : Bool = false;
	private static var _loadingProgress : Float = 0;
	private static var _loadingTotal : Float = 0;

	public static function update( dt:Float ) : Void {
		if ( isLoading || _loadQueue.length < 1 ) {
			return;
		}
		_loadQueue[0].delay -= dt;
		if ( _loadQueue[0].delay < 0 ) {
			_beginLoad( _loadQueue.shift() );
		}
	}

	/**
	 * Whether or not the WMAssets is currently loading
	 */
	public static var isLoading(get,never) : Bool;
	private static function get_isLoading() : Bool {
		return _manifestsLoaded < _manifestsMax;
	}

	/**
	 * Sets the Base URL path
	 */
	public static var baseUrl( default,set ) : String;
	private static function set_baseUrl( pBaseUrl:String ) {
		baseUrl = pBaseUrl;
		trace("[WMAssets](setBaseUrl) Base Url set to '" + pBaseUrl + "'" );
		return baseUrl;
	}

	/**
	 * Sets the Base URL path, and flags the Base URL as Cross-Domain
	 */
	public static function setCrossdomainBaseUrl( pBaseUrl:String ) {
		_flagBaseIsCrossdomain = true;
		baseUrl = pBaseUrl;
	}

	/**
	 * Call this to set up file requests for custom loaded manifests
	 *
	 * pType - AssetFormat - Import flambe.asset.AssetEntry to get access to this
	 */
	public static function addFile( pUrl:String, pManifestId:String, pType:AssetFormat, pId:String = "" ) : Void {
		// Add an individual file to be loaded.
		if ( _customManifests.exists(pManifestId) == false ) {
			_customManifests[pManifestId] = new Manifest();
		}
		// Sometimes the URL doesn't have a file extension, so the type must be specified
		// Also note that the name can be any unique text, it's only used to lookup the asset by name
  		// manifest.add("facebookPhoto", "https://graph.facebook.com/bruno.e.garcia/picture", Image);
		_customManifests[pManifestId].add( pId == "" ? pUrl : pId, pUrl, 0, pType );
	}

	/**
	 * Call this to begin loading a list of packs
	 */
	public static function load( pCallback:Void->Void, pPacks:Array<String>, pDelay:Float = 0  ) : Void {
		if ( pCallback == null ) {
			throw( "[WMAssets](load) Callback is null." );
		}
		var tQueue = new LoadQueue( pCallback, pPacks, pDelay );
		if ( isLoading || pDelay > 0 ) {
			_loadQueue.push( tQueue );
			return;
		}
		_beginLoad( tQueue );
	}

	private static function _beginLoad( pQueue:LoadQueue ) {
		var tPacksToLoad : Array<String> = [];
		var tFilesToLoad : Array<String> = [];

		// Find out what we can load
		for ( p in pQueue.packs ) {
			if ( _packs.exists( p ) ) {
				// Already loaded
				continue;
			}
			if ( Manifest.exists( p ) ) {
				tPacksToLoad.push(p);
			} else if ( _customManifests.exists(p) ) {
				tFilesToLoad.push(p);
			} else {
				trace( "[WMAssets](load) Unable to load pack \"" + p + "\", it's either missing or needs to be built with (addFile)." );
			}
		}

		// No need to load, do the callback immediately
		if ( tPacksToLoad.length < 1 && tFilesToLoad.length < 1 ) {
			tFilesToLoad = null;
			tPacksToLoad = null;
			pQueue.complete();
			return;
		}

		// Reset Data
		WMCloud.setFloat( app.CLOUD.FLOAT_LOADING_PROGRESS, 0 );
		_loadingProgress = 0;
		_loadingCallback = pQueue.complete;
		_manifestsMax += ( tFilesToLoad.length + tPacksToLoad.length );

		// Do the actual loading
		for ( f in tPacksToLoad ) {
			_loadPack( f );
		}
		for ( f in tFilesToLoad ) {
			_loadManifest( _customManifests[f], f );
		}

		pQueue.dispose();
		tFilesToLoad = null;
		tPacksToLoad = null;
	}

	private static function _loadPack( pId:String ) : Void {
		trace( "[WMAssets](loadPack) Loading pack " + pId );
		var tManifest : Manifest = Manifest.fromAssets( pId );
		if ( baseUrl != "" ) {
			if ( _flagBaseIsCrossdomain ) {
				tManifest.remoteBase = baseUrl;
			} else {
				tManifest.localBase = baseUrl;
			}
		}
		_loadManifest( tManifest, pId );
	}

	private static function _loadManifest( pManifest:Manifest, pId:String ) : Void {
		var loader : Promise<AssetPack> = System.loadAssetPack( pManifest );
		_loadingTotal += loader.total;
		var tLoadingProgress : Float = 0;
		loader.error.connect( _loadingError );
		loader.progressChanged.connect( function() {
			var tChange : Float = loader.progress - tLoadingProgress;
			tLoadingProgress = loader.progress;
			_loadingProgress += tChange;
			WMCloud.setFloat( app.CLOUD.FLOAT_LOADING_PROGRESS, FMath.clamp( _loadingProgress/_loadingTotal, 0, 1 ) );
		});
		_requests.push( loader.get( function( pack ) {
			_addPack( pId, new WMAssetPack( pack ) );
			if ( ++_manifestsLoaded >= _manifestsMax ) {
				_onAllLoadComplete();
			}
		}) );
	}

	private static function _loadingError( pError:String ) : Void {
		trace( "[WMAssets](_loadingError) Loading failed with error: " + pError );
		eventLoadError.dispatch();
		_manifestsLoaded++;
	}

	private static function _onAllLoadComplete() : Void {
		trace( "[WMAssets](_onAllLoadComplete) All packs loaded" );
		if ( _loadingCallback != null ) {
			var tCallback : Void->Void = _loadingCallback;
			_loadingCallback = null;
			tCallback();
			tCallback = null;
		}
		while ( _requests.length > 0 ) {
			_requests.pop();
		}
	}

	private static function _addPack( pId:String, pPack:WMAssetPack ) : Void {
		_packs[pId] = pPack;
		for ( a in pPack.pack.manifest ) {
			// Look for certain things that don't go in the larger asset library
			// TODO New renderer doesn't currently support Flump renderer
			if ( a.name.indexOf( "library.json" ) > -1 ) {
				// Flump file!
				var tPath = a.name;
				tPath = StringTools.replace( tPath, "/library.json", "" );
				trace( "[WMAssets](_addPack) Found Flump named \"" + tPath + "\"" );
				_flump[tPath] = new Library( pPack.pack, tPath );
				// Save the flump for later cleanup
				pPack.flump.push(tPath);
				tPath = null;
				continue;
			}

			// Look for parsing formats
			var tExtension : String = WMUtils.getExtension( a.name );
			switch ( tExtension ) {
				case "atlas", "txt":
					var tPath : String = "";
					var tSplit : Array<String> = a.name.split("/");
					for ( tI in 0...tSplit.length-1 ) {
						tPath += tSplit[tI] + "/";
					}
					_parseSpriteAtlas( tPath, pPack.pack.getFile( a.name ).toString(), pPack );
			}

			// If it's not a parsed asset, add it to the normal asset list
			_assets[a.name] = pId;
			// Save the asset name to the pack for cleanup
			pPack.assets.push(a.name);
		}
	}

	private static function _parseSpriteAtlas( pPath:String, pContentString:String, pPack:WMAssetPack ) : Void {
		// Get the file contents, and split it apart into a list
		var tLines : Array<String> = pContentString.split( "\n" );
		while ( tLines.length > 1 ) {
			// Shift away any initial white space
			while ( tLines[0].length <= 1 ) {
				tLines.shift();
			}
			// Find the file atlas name
			var tAtlasName : String = pPath + WMUtils.removeExtension( StringTools.rtrim(tLines.shift()) );
			// Move the "playhead" down to the first image
			while ( true ) {
				if ( tLines.shift().indexOf("repeat:") > -1 ) {
					break;
				}
			}
			// And now parse each sprite my moving the "playhead"
			while ( tLines.length > 1 && tLines[0].length > 1 ) {
				_parsePackedSpriteAndMovePlayhead( tAtlasName, tLines, pPack );
			}
		}
	}

	private static function _parsePackedSpriteAndMovePlayhead( pAtlas:String, pArray:Array<String>, pPack:WMAssetPack ) : Void {
		// Move playhead forward until we hit "index" and decide we have all the data for this image
		var tArray : Array<String> = [];
		var tItem : String;
		while ( true ) {
			tItem = pArray.shift();
			tArray.push( StringTools.rtrim(tItem) );
			if ( tItem.indexOf( "index:") > -1 ) {
				tItem = null;
				break;
			}
		}
		// Finally, build the new packed sprite based on this data
		// More parsing done within new WMSpriteRect
		_addPackedSprite( tArray[0], pAtlas, new SpriteRect( tArray ), pPack );
		tArray = null;
	}

	private static function _addPackedSprite( pId:String, pAtlas:String, pRect:SpriteRect, pPack:WMAssetPack ) : Void {
		if ( _spritesheets.exists(pId) ) {
			trace("[WMAssets](_addPackedSprite) Duplicate definition of sprite named \'" + pId + "\'");
			_spritesheets[pId].dispose();
		}
		_spritesheets.set( pId, new SpriteSheetDef( pAtlas, pRect ) );
		// Keep a reference to this spritesheet for cleanup
		pPack.spritesheets.push( pId );
	}

	public static function unload( pPacks:Array<String> ) : Void {
		for ( p in pPacks ) {
			if ( _packs.exists( p ) == false ) {
				continue;
			}
			var tPack : WMAssetPack = _packs[p];
			// Clean up assets referenced by this pack
			while ( tPack.assets.length > 0 ) {
				_assets.remove(tPack.assets.pop());
			}
			// Clean up spritesheets referenced by this pack
			while ( tPack.spritesheets.length > 0 ) {
				_spritesheets.remove(tPack.spritesheets.pop());
			}
			// Clean up Flump
			while ( tPack.flump.length > 0 ) {
				var tId : String = tPack.flump.pop();
				_flump[tId].disposeFiles();
				_flump.remove(tId);
			}
			tPack.dispose();
			_packs.remove( p );
			trace("[WMAssets](unload) Pack \"" + p + "\" disposed.");
		}
	}

	/**************************************************
	 * ASSET RETURNING
	 *************************************************/
	public static function hasTexture( pTexture:String = "" ) : Bool {
		if ( pTexture == null || pTexture == "" ) {
			return false;
		}
		return _hasAsset(pTexture);
	}

	public static function hasSound( pSound:String = "" ) : Bool {
		if ( pSound == null || pSound == "" ) {
			return false;
		}
		return _hasAsset( pSound );
	}

	public static function hasXML( pXML:String = "" ) : Bool {
		if ( pXML == null || pXML == "" ) {
			return false;
		}
		return _hasAsset(pXML);
	}

	private static function _hasAsset( pId:String ) : Bool {
		if ( _spritesheets.exists(pId) ) {
			return true;
		}
		return _assets.exists(pId);
	}

	public static function getPackForAsset( pAsset:String ) : AssetPack {
		if ( _assets.exists( pAsset ) == false ) {
			return null;
		}
		return _packs[_assets[pAsset]].pack;
	}

	public static function getTexture( pAsset:String ) : Texture {
		if ( hasTexture(pAsset) == false ) {
			return null;
		}
		if ( _spritesheets.exists( pAsset ) ) {
			pAsset = _spritesheets[pAsset].atlas;
		}
		if ( _assets.exists( pAsset ) == false ) {
			trace("[WMAssets](getTexture) No asset named \'" + pAsset + "\' exists! Returning null.");
			return null;
		}
		return _packs[_assets[pAsset]].pack.getTexture( pAsset );
	}

	public static function getSpriteRect( pAsset:String ) : SpriteRect {
		if ( pAsset == null || pAsset == "" ) {
			return null;
		}
		if ( _spritesheets.exists(pAsset) == false ) {
			return null;
		}
		return _spritesheets[pAsset].rect;
	}

	public static function getSound( pSound:String ) : Sound {
		if ( hasSound(pSound) == false ) {
			trace('[WMAssets](getSound) No sound named \'${pSound}\' exists! Returning null.');
			return null;
		}
		return _packs[_assets[pSound]].pack.getSound( pSound );
	}

	public static function getFile( pId:String ) : File {
		if ( _hasAsset( pId ) == false ) {
			trace('[WMAssets](getFile) No file named \'${pId}\' exists! Returning null.');
			return null;
		}
		return _packs[_assets[pId]].pack.getFile( pId );
	}

	public static function getXML( pXML:String ) : Fast {
		if ( hasXML( pXML ) == false ) {
			trace('[WMAssets](getXML) No xml named \'${pXML}\' exists! Returning null.');
			return null;
		}
		var tXML : Xml = Xml.parse( getFile(pXML).toString() );
		var tFast : Fast = new Fast( tXML.firstElement() );
		tXML = null;
		return tFast;
	}

	public static function allConfig() : Array<Fast> {
		var tXML : Array<Fast> = [];
		for ( config in manifest.Xml.allConfig ) {
			tXML.push( getXML(config) );
		}
		return tXML;
	}

	public static function getPList( pId:String ) : Dynamic {
		// Check if the pList exisits
		if ( _assets.exists(pId) == false ) {
			trace("[WMAssets](getPList) No asset named " + pId + " exists! Returning null.");
			return null;
		}
		// Get the pList in an XML format
		return WMUtils.parsePropertyList(getFile(pId).toString());
	}

	public static function getFont( pId:String, pCache:Bool = true, pColor : Int = -1 ) : Font {
		if ( pId == null || pId == "" || _assets.exists(pId) == false ) {
			trace("WARNING: Font name " + pId + " DOES NOT EXIST, returning default font instead");
			return getFont( WMLocalize.defaultFont );
		}

		if (pColor == -1) {
			if ( pCache == false ) {
				return new Font( _packs[_assets[pId]].pack, pId );
			}
			if ( _fontCache.exists(pId) == false ) {
				_fontCache[pId] = new Font( _packs[_assets[pId]].pack, pId );
			}
			return _fontCache[pId];
		} else {
			var appendedId = pId + pColor;

			if ( pCache == false ) {
				return new FontColor(_packs[_assets[pId]].pack, pId, pColor);
			}

			if ( _fontCache.exists(appendedId) == false ) {
				_fontCache[appendedId] = new FontColor(_packs[_assets[pId]].pack, pId, pColor);
			}
			return _fontCache[appendedId];
		}
	}

	public static function getLibrary( pId:String ) : Library {
		if ( _flump.exists( pId ) == false ) {
			trace("[WMAssets](getLibrary) no library named " + pId + " exists!");
			return null;
		}
		return _flump[pId];
	}
}
