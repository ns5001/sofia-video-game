package workinman.ui;

class ChangeActionData {

	public var screenId( default,null ) : Class<ScreenBase>;
	public var changeEvent( default,null ) : CHANGE_TYPE;
	public var action( default,null ) : Void -> Void;

	public function new( pScreenId:Class<ScreenBase>, pChangeEvent:CHANGE_TYPE, pAction:Void->Void ) {
		screenId 		= pScreenId;
		changeEvent	= pChangeEvent;
		action		 	= pAction;
	}
}
