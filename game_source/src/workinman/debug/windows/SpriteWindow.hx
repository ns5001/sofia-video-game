package workinman.debug.windows;

import workinman.display.Sprite;
import workinman.display.ElementManagerSprite;
import workinman.debug.inputs.NumericInput;
import workinman.debug.inputs.PercentSliderInput;
import workinman.debug.inputs.SwitchInput;
import js.Browser;
import js.html.Element;
import js.html.MouseEvent;

class SpriteWindow extends ControlWindow {

	// Storage
	private var _scaleIsLinked	: Bool;
	private var _scaleXYDiff	: Float;
	private var _scaleLinkElem	: Element;
	private var _scaleXInput	: NumericInput;
	private var _scaleYInput	: NumericInput;

	// Properties
	private var _wmElement(get, never): Sprite;
	private function get__wmElement() : Sprite	{ return cast(_object, Sprite); }

	// Constructor
	public function new(pData:ControlWindowProp) {
		super(pData);
	}

	private override function _buildWindow() : Void {
		_scaleIsLinked = false;
		_scaleXYDiff = 1;
		_addTransformDetail();
		addInputDetail(new PercentSliderInput({ keyObj:{ key:"alpha", obj:_wmElement } }), "alpha");
		addInputDetail(new SwitchInput({ keyObj:{ key:"visible", obj:_wmElement } }), "visible");
		if(_wmElement.parent != null) {
			addDetail(_createLinkToSpriteWindow(_wmElement.parent, DebugUtils.getClassName(_wmElement.parent)), "Parent");
		}
		_addChildrenDetail();
	}

	public override function dispose() : Void {
		super.dispose();
		_scaleLinkElem = null;
		_scaleXInput = null;
		_scaleYInput = null;
	}

	public override function update() : Void {
		super.update();
		if(elementStillExists() == false) {
			notifyUserElementIsGone();
		}
		for(tInput in _inputs) {
			tInput.refreshIfUpdated();
		}
	}

	public override function refresh() : Window {
		super.refresh();
		// relist children
		var tOldUL = _root.querySelector("ul");
		if(tOldUL != null) {
			tOldUL.parentNode.appendChild(_listElementChildren(_wmElement));
			DebugUtils.removeElem(tOldUL);
		}
		return this;
	}

	public function _addTransformDetail() : SpriteWindow {
		var tTable = DebugUtils.newElem("table", { className:"sprite-transform-table", innerHTML:"<col style='width:22%;' />" });
		var tRow, tCell;

		tRow = DebugUtils.newElem("tr", null, tTable);
		DebugUtils.newElem("th", { innerHTML:"Position: ", style:"text-align:left;" }, tRow);
		DebugUtils.newElem("td", { innerHTML:"X" }, tRow);
		tCell = DebugUtils.newElem("td", null, tRow);
		_inputs.push(new NumericInput({ keyObj:{ key:"x", obj:_wmElement.pos }, parent:tCell }));
		DebugUtils.newElem("td", null, tRow);
		DebugUtils.newElem("td", { innerHTML:"Y" }, tRow);
		tCell = DebugUtils.newElem("td", null, tRow);
		_inputs.push(new NumericInput({ keyObj:{ key:"y", obj:_wmElement.pos }, parent:tCell }));

		tRow = DebugUtils.newElem("tr", null, tTable);
		DebugUtils.newElem("th", { innerHTML:"Scale: ", style:"text-align:left;" }, tRow);
		DebugUtils.newElem("td", { innerHTML:"X" }, tRow);
		tCell = DebugUtils.newElem("td", null, tRow);
		_inputs.push(_scaleXInput = new NumericInput({ keyObj:{ key:"scaleX", obj:_wmElement }, parent:tCell, step:0.01, onChange:_onScaleXChanged }));
		_scaleLinkElem = DebugUtils.newElem("span", { innerHTML:"🔗 ", style:"font-size:80%;" }, DebugUtils.newElem("td", null, tRow));
		DebugUtils.newElem("td", { innerHTML:"Y" }, tRow);
		tCell = DebugUtils.newElem("td", null, tRow);
		_inputs.push(_scaleYInput = new NumericInput({ keyObj:{ key:"scaleY", obj:_wmElement }, parent:tCell, step:0.01, onChange:_onScaleYChanged }));
		toggleScaleLink(_wmElement.scaleX == _wmElement.scaleY);
		_scaleLinkElem.addEventListener("click", _onScaleLinkElemClicked);

		tRow = DebugUtils.newElem("tr", null, tTable);
		DebugUtils.newElem("th", { innerHTML:"Rotation: ", style:"text-align:left;" }, tRow);
		tCell = DebugUtils.newElem("td", { colSpan:"100" }, tRow);
		_inputs.push(new NumericInput({ keyObj:{ key:"rotation", obj:_wmElement }, parent:tCell, style:"width:calc(100% - 8px);" }));

		var tCont = this.addDetail(tTable, "Transform");
		var tMoveBtn = DebugUtils.newElem("button", { innerHTML:"✥", style:"float:right;" }, tCont.querySelector(".title"));
		tMoveBtn.addEventListener("click", _onSpriteMoveClick);
		return this;
	}

	private function _addChildrenDetail() : SpriteWindow {
		this.addDetail(_listElementChildren(_wmElement), "Children");
		return this;
	}

	private function _onSpriteMoveClick(pEvent:MouseEvent) : Void {
		Debug.spriteSelector.startItemDrag(_wmElement);
	}

	private function _onScaleXChanged() : Void {
		if(_scaleIsLinked) {
			_scaleYInput.setObjValue(_scaleXInput.getObjValue() * _scaleXYDiff);
		}
	}

	private function _onScaleYChanged() : Void {
		if(_scaleIsLinked) {
			_scaleXInput.setObjValue(_scaleYInput.getObjValue() * (1 / _scaleXYDiff));
		}
	}

	private function _onScaleLinkElemClicked(pEvent:MouseEvent) { toggleScaleLink(); }
	private function toggleScaleLink(?pVal:Bool) : Void {
		_scaleIsLinked = pVal != null ? pVal : !_scaleIsLinked;
		_scaleLinkElem.style.opacity = Std.string(_scaleIsLinked ? 1 : 0.5);
		_scaleXYDiff = _wmElement.scaleY / _wmElement.scaleX;
	}

	public function elementStillExists() : Bool {
		return _object != null && _wmElement.pos != null;
	}

	public function notifyUserElementIsGone() : Void {
		var i = _inputs.length;
		while (--i >= 0) {
			_inputs[i].dispose();
			_inputs[i] = null;
			_inputs.splice(i, 1);
		}
		_contentDiv.innerHTML = "Element has been disposed.";
	}

	private function _listElementChildren(pElem:Sprite) : Element {
		var tListElem : Element = DebugUtils.newElem("ul", { className:"maketree" }), tNumChildren:Int = pElem.children.length;

		_addElementChildrenToList(pElem.children, tListElem);
		if(Std.is(pElem, ElementManagerSprite)) {
			_listLayerChildren(cast pElem, tListElem);
			tNumChildren++;
		}
		return tNumChildren > 0 ? tListElem : null;
	}

	private function _listLayerChildren(pElem:ElementManagerSprite, pListElem:Element) : Void {
		var tLayers:Map<String, Array<Sprite>> = Reflect.field(pElem, "_layers");
		var tLayerOrder:Array<String> = Reflect.field(pElem, "_layerOrder");
		for(tLayerKey in tLayerOrder) {
			if(tLayers[tLayerKey].length > 0) {
				var tLi:Element = DebugUtils.newElem("li", null, pListElem);
				_createSubtreeDropdown(tLi, tLayerKey);
				var tChildsChildrenList = DebugUtils.newElem("ul", { className:"maketree" }, tLi);
				_addElementChildrenToList(tLayers[tLayerKey], tChildsChildrenList);
			}
		}
	}

	private function _addElementChildrenToList(pChildren:Array<Sprite>, pListElem:Element) : Void {
		for(tElemChild in pChildren) {
			var tLi:Element = DebugUtils.newElem("li", null, pListElem);
			var tLink = _createLinkToSpriteWindow(tElemChild, DebugUtils.getClassName(tElemChild), tLi);

			var tChildsChildrenList = _listElementChildren(tElemChild);
			if(tChildsChildrenList != null) {
				var tLabel = _createSubtreeDropdown(tLi);
				tLabel.parentNode.insertBefore(tLink, tLabel.nextSibling);
				tLi.appendChild(tChildsChildrenList);
			}
		}
	}

	private function _createSubtreeDropdown(pParent:Element, pText:String="") : Element {
		var tID = "lst"+DebugUtils.uniqID();
		var tLabel = DebugUtils.newElem("label", { innerHTML:"±&nbsp;"+pText }, pParent); tLabel.setAttribute("for", tID);
		DebugUtils.newElem("input", { type:"checkbox", id:tID }, pParent);
		return tLabel;
	}

	private function _createLinkToSpriteWindow(pSprite:Sprite, pText:String, ?pParent:Element) : Element {
		var tLink = DebugUtils.newElem("a", {innerHTML:pText, href:"#"}, pParent);
		tLink.addEventListener("click", function(pEvent:MouseEvent){
			Debug.debugSprite(pSprite);
			pEvent.preventDefault();
		});
		return tLink;
	}
}
