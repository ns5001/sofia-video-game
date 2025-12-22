package workinman.debug.windows;

import workinman.debug.inputs.NumericInput;
import js.html.Element;
import js.html.MouseEvent;

class ObjWindow extends ControlWindow {

	public function new(pData:ControlWindowProp) {
		super(pData);
	}

	private override function _buildWindow() : Void {
		for(fld in Type.getInstanceFields(Type.getClass(_object))) {
			trace(fld, Type.getClass(Reflect.getProperty(_object, fld)));
			if(!Reflect.isObject(Reflect.getProperty(_object, fld))) {
				addInputDetail(new NumericInput({ keyObj:{ key:fld, obj:_object } }), fld);
			}
		}
	}

	public override function dispose() : Void {
		super.dispose();
	}
}
