package workinman.utils;

import haxe.xml.Fast;

class PropertyList {

	// Only supports 'yyyy-mm-dd' and 'yyyy-mm-ddThh:mm:ssZ'.
	private static var _dateRegex:EReg = ~/(\d{4}-\d{2}-\d{2})(?:T(\d{2}:\d{2}:\d{2})Z)?/;

	/**
	* Parse an Apple property list XML file into a dynamic object. If
	* the property list is empty, an empty object will be returned.
	* @param pText (String) - Text contents of the property list file.
	*/
	static public function parse( pText:String ) : Dynamic {
		var fast = new Fast(Xml.parse(pText).firstElement());
		var value : Dynamic = {};
		if (fast.hasNode.dict) {
			value = _parseDict(fast.node.dict);
		} else if (fast.hasNode.array) {
			value = _parseValue(fast.node.array);
		}
		return value;
	}

	static private function _parseDate( pText:String ) : Date {
		if (!_dateRegex.match(pText)) {
			throw 'Invalid date "' + pText + '" (only yyyy-mm-dd and yyyy-mm-ddThh:mm:ssZ supported)';
		}
		pText = _dateRegex.matched(1);
		if (_dateRegex.matched(2) != null) {
			pText += ' ' + _dateRegex.matched(2);
		}
		return Date.fromString(pText);
	}

	static private function _parseDict( pNode:Fast ) : Dynamic {
		var key : String = null;
		var result : Dynamic = {};
		for (childNode in pNode.elements) {
			if (childNode.name == 'key') {
				key = childNode.innerData;
			} else if (key != null) {
				Reflect.setField(result, key, _parseValue(childNode));
			}
		}
		return result;
	}

	static private function _parseValue( pNode:Fast ) : Dynamic {
		var value : Dynamic = null;
		switch (pNode.name) {
			case 'array':
				value = new Array<Dynamic>();
				for (childNode in pNode.elements) {
					value.push(_parseValue(childNode));
				}

			case 'dict':
				value = _parseDict(pNode);

			case 'date':
				value = _parseDate(pNode.innerData);

			case 'string':
				value = pNode.innerData;

			case 'data':
				value = pNode.innerData;

			case 'true':
				value = true;

			case 'false':
				value = false;

			case 'real':
				value = Std.parseFloat(pNode.innerData);

			case 'integer':
				value = Std.parseInt(pNode.innerData);
		}
		return value;
	}
}
