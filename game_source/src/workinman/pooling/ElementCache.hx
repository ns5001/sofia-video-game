package workinman.pooling;

class ElementCache {

	private var _cache : Array<ICacheableElement>;
	private var _type : Class<ICacheableElement>;
	private var _emptyParams : Array<Dynamic>;

	private var _initFill : Int;
	private var _maxFill : Int;
	private var _totalFill : Int;

	/**
	 * Instantiates a new ElementCache
	 *
	 * Managed by an intstance of CacheManager, should probably not be used alone
	 */
	public function new( pType:Class<ICacheableElement>, pEmptyParams:Array<Dynamic>, pCacheInit:Int, pCacheMax:Int ) {
		_cache = new Array<ICacheableElement>();
		_initFill = pCacheInit;
		_type = pType;
		_emptyParams = pEmptyParams;
		_totalFill = 0;
		_maxFill = pCacheMax;
	}

	/**
	 * Disposes the ElementCache
	 *
	 * Managed by an intstance of CacheManager, should probably not be used alone
	 */
	public function dispose() : Void {
		while ( _cache.length > 0 ) {
			_cache.pop().destroy();
		}
		_cache = null;
		_type = null;
		_emptyParams = null;
	}

	/**
	 * Pre-fills the ElementCache
	 *
	 * Managed by an intstance of CacheManager, should probably not be used alone
	 */
	public function fillCache( pAmt:Int ) : Bool {
		var tItem : ICacheableElement;
		while ( _cache.length < _initFill ) {
			_totalFill++;
			tItem = Type.createInstance( _type, _emptyParams );
			tItem.setReturnFunction( returnFunction );
			tItem.dispose();
			tItem = null;
			if ( pAmt > 0 && pAmt-- <= 0 ) {
				return false;
			}
		}
		return true;
	}

	/**
	 * Delegate return function for ICacheableElements to return themselves in their dispose() functions
	 *
	 * Managed by an intstance of CacheManager, should probably not be used alone
	 */
	public function returnFunction( pReturn:ICacheableElement ) : Void {
		if ( _cache == null ) {
			// Our timing is off, this has been disposed. Destroy the element.
			pReturn.destroy();
			return;
		}
		_cache.push( pReturn );
	}

	/**
	 * Asks this ElementCache to give an instance
	 *
	 * Managed by an intstance of CacheManager, should probably not be used alone
	 */
	public function requestElement<T:ICacheableElement>() : T {
		var tRes : T;
		if ( _cache.length > 0 ) {
			tRes = cast _cache.pop();
		} else if ( _maxFill < 1 || _totalFill < _maxFill ) {
			_totalFill++;
			tRes = cast Type.createInstance( _type, _emptyParams );
			tRes.setReturnFunction( returnFunction );
		} else {
			return null;
		}
		return tRes;
	}
}
