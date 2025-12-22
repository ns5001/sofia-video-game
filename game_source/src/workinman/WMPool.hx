package workinman;

import workinman.pooling.IStrictPoolable;
import workinman.pooling.PoolTracker;
import workinman.pooling.LOG_LEVEL;
import flambe.math.FMath;
import haxe.CallStack;

class WMPool {

	private static var _pools : Map<String,PoolTracker> = new Map<String,PoolTracker>();

	private static function _initPool( pId:String, pClass:Class<IStrictPoolable>, pLog:LOG_LEVEL = null, pCap:Int = -1 ) : Void {
		if ( _pools.exists(pId) == true ) {
			return;
		}
		if ( pLog == null ) {
			pLog = NONE;
		}
		_pools.set(pId,new PoolTracker(pClass,pLog,pCap));
	}

	public static function requestObject<T:IStrictPoolable>( pId:Class<T>, pLog:LOG_LEVEL = null, pCap:Int = -1 ) : T {
		var pKey : String = Type.getClassName(pId);
		var tCurrentClass : Class<IStrictPoolable> = cast pId;
		_testPool(pKey,tCurrentClass,pLog,pCap);
		var tCurrentPool : PoolTracker = _pools.get(pKey);
		_logCreate(pKey,tCurrentPool);
		var tPooledObject : IStrictPoolable;
		if ( tCurrentPool.numPooled > 0 ) {
			tPooledObject = tCurrentPool.givePool();
			tPooledObject.poolActivate();
		} else {
			tCurrentPool.incrementCreated();
			if ( tCurrentPool.cap > 0 && tCurrentPool.created > tCurrentPool.cap ) {
				throw "Too many instances of " + pId + " allocated - currently at " + tCurrentPool.created;
			}
			tPooledObject = Type.createEmptyInstance(tCurrentClass).instance(pKey,_returnObject);
		}
		tCurrentClass = null;
		tCurrentPool = null;
		return cast tPooledObject;
	}

	private static function _logCreate( pId:String, pPool:PoolTracker ) : Void {
		var tString : String;
		switch ( pPool.log ) {
			case NONE:
				return;
			case NO_STACK:
				trace( _traceCreateString(pId, pPool) );
			case NEW_STACK:
				if ( pPool.numPooled < 1 ) {
					trace( _traceCreateString(pId, pPool) + _stackTrace(4) );
				}
			case ALL_STACK:
				trace( _traceCreateString(pId, pPool) + _stackTrace(4) );
		}
	}

	private static function _stackTrace( pStripLevels:Int ) : String {
		var tStack : Array<haxe.StackItem> = CallStack.callStack();
		tStack.splice( 0, pStripLevels );
		var tString : String = "\n\n******* STACK TRACE *******"+CallStack.toString(tStack)+"\n******** END STACK TRACE *******\n";
		tStack = null;
		return tString;
	}

	private static function _traceCreateString( pId:String, pPool:PoolTracker ) : String {
		var tString : String = "[PoolStore](requestObject) ";
		if ( pPool.numPooled > 0 ) {
			tString += "Reusing [" + pId + "] object";
		} else {
			tString += "Creating new instance of [" + pId + "] - " + (pPool.created+1) + " created total";
		}
		return tString;
	}

	public static function flushPool( pId:Class<IStrictPoolable> ) : Void {
		var tCurrentName : String = Type.getClassName(pId);
		if ( _pools.exists(tCurrentName) == false ) {
			return;
		}
		_pools.get(tCurrentName).flush();
	}

	private static function _returnObject( pObject:IStrictPoolable ) : Void {
		if ( _pools.exists(pObject.poolKey) == false ) {
			return;
		}
		var tPool : PoolTracker = _pools.get(pObject.poolKey);
		tPool.poolObject(pObject);
		_logReturn(pObject.poolKey,tPool);
		tPool = null;
	}

	private static function _logReturn( pId:String, pPool:PoolTracker ) : Void {
		switch ( pPool.log ) {
			case NONE,NEW_STACK:
				return;
			case ALL_STACK:
				trace( "[PoolStore](_returnObject) Returned object [" + pId + "]" + _stackTrace(5) );
			default:
				trace( "[PoolStore](_returnObject) Returned object [" + pId + "]" );
		}
	}

	private static function _testPool( pId:String, pClass:Class<IStrictPoolable>, pLog:LOG_LEVEL = null, pCap:Int = -1 ) : Void {
		if ( _pools.exists(pId) == false ) {
			 //throw "Using pool " + pId + " before it has been initialized is not allowed!";
			 _initPool(pId,pClass,pLog,pCap);
		}
	}

	public static function tracePoolReport() : Void {
		var tS : String = "\nPool Report:\n\n";
		var tLoose : Int = 0;
		for ( k in _pools.keys() ) {
			tS += "\t" + k + "\n";
			tLoose = (_pools.get(k).created - _pools.get(k).numPooled);
			tS += "\t\tTotal Created: " + _pools.get(k).created + " \t\tPool: " + _pools.get(k).numPooled + " \t\t\tLoose: " + tLoose + " \t\t\tChange: " + (tLoose-_pools.get(k).loose);
			_pools.get(k).loose = tLoose;
			tS += "\n";
		}
		tS += "\n";
		trace(tS);
	}
}
