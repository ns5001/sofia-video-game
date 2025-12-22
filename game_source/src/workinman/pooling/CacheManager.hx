package workinman.pooling;

class CacheManager {

	private var _caches : Map<String,ElementCache>;
	private var _emptyParams : Array<Dynamic>;

	/**
	 * Allocates a new instance of a CacheManager
	 *
	 * The CacheManager maintains any number of individual ElementCaches
	 */
	public function new() : Void {
		_caches = new Map<String,ElementCache>();
		_emptyParams = [];
	}

	/**
	 * Disposes the CacheManager
	 *
	 * Call when you're done using it (i.e. World dispose) to dispose the CacheManager and all of it's managed ElementCaches
	 */
	public function dispose() : Void {
		for ( e in _caches ) {
			e.dispose();
		}
		_caches = null;
		_emptyParams = null;
	}

	/**
	 * Adds a new ElementCache to the list of managed ElementCaches
	 *
	 * pId - A unique string constant used to identify the new ElementCache
	 *
	 * pType - The class type of the object to cache. Must implement ICacheableElement
	 *
	 * pCacheInit - The number of objects to pre-allocate during the processFill() step
	 *
	 * pCacheMax - The maximum number of objects to allow the cache to allocate.
	 *
	 * 		If the pCacheMax limit is hit, you will recieve null instead of an instance of the object you requested
	 * 		If pCacheMax is 0 or less, there will be no limit, and whenever you request an object you will recieve a new instance, regardless of whether there are any available in the pool
	 */
	public function addCache( pId:String, pType:Class<ICacheableElement>, pCacheInit:Int, pCacheMax:Int = 0 ) : Void {
		_caches[pId] = new ElementCache( pType, _emptyParams, pCacheInit, pCacheMax );
	}

	/**
	 * Processes the allocation of objects in the managed ElementCaches
	 *
	 * pAmt - The number of objects to allocate per update. This allows a large number of objects to be allocated per update, without requiring the app to halt while the allocation is taking place
	 *
	 * 		If pAmt is 0 or less, there will be no limit, and an entire ElementCache will be filled each update
	 */
	public function processFill( pAmt:Int ) : Bool {
		for ( c in _caches ) {
			if ( c.fillCache( pAmt ) == false ) {
				return false;
			}
		}
		return true;
	}

	/**
	 * Requests an instance of an object from an ElementCache
	 *
	 * pId - The unique string constant used to identify the cache in addCache()
	 *
	 * 		It will always return an instance of the object you request, unless you have defined a Max cache size. If you have, and this limit has been hit, null will be returned instead.
	 */
	public function requestElement<T:ICacheableElement>( pId:String ) : T {
		return _caches[pId].requestElement();
	}
}
