package workinman.pooling;

interface ICacheableElement {

	public function dispose() : Void; // Re-used dispose
	public function destroy() : Void; // Final destruction and memory freeing
	public function setReturnFunction( pReturnFunction:ICacheableElement->Void ) : Void;
}
