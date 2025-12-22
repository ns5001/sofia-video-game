package workinman;

import workinman.saving.*;
import haxe.Unserializer;

class WMSaving {

	public static function dataLoad<T:SharedObjectSaveDef>( pId:String ) : T {
		var tShared : WMSharedObject = _getLocal( pId );
		var tData : SharedObjectSaveDef = tShared.data;
		tShared.dispose();
		tShared = null;
		return cast tData;
	}

	public static function dataSave( pId:String, pData:SharedObjectSaveDef ) : Void {
		var tShared : WMSharedObject = _getLocal( pId );
		tShared.data = pData;
		tShared.flush();
		tShared.dispose();
		tShared = null;
	}

	public static function dataDelete( pId:String ) : Void {
		var tShared : WMSharedObject = _getLocal( pId );
		tShared.clear();
		tShared.dispose();
		tShared = null;
	}

	private static function _getLocal( pId:String ) : WMSharedObject {
		var tSO : WMSharedObject = new WMSharedObject( pId );
		try {
			var tRawData : String = js.Browser.window.localStorage.getItem( pId );
			if ( tRawData != null && tRawData != "" ) {
				tSO.data = Unserializer.run( tRawData );
			}
			tRawData = null;
		} catch ( err:Dynamic ) {
			trace("[WMSharedObject] Shared Objects not allowed for some reason on this device, may be due to Incognito mode. Make sure your app gracefully handles this and does not store session data in shared objects.");
		}
		return tSO;
	}
}
