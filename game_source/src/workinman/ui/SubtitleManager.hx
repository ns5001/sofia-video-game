package workinman.ui;

import workinman.display.Element;
import workinman.display.Text;
import workinman.display.ElementManager;
import workinman.display.Sprite;
import workinman.tween.*;
import workinman.localization.LocalizationData;
import app.ConstantsApp;
import flambe.display.Font;

private enum SUB_STATE {
	OFF;
	CHANGE_ON;
	CHANGE_OFF;
	ON;
}

class SubtitleManager {

	private var _image : Element;
	private var _text : Text;
	private var _currentText : String;
	private var _elementManager : ElementManager;
	private var _tween : Tweener;
	private var _subState : SUB_STATE;

	private var _timer : Float;

	private static inline var _DEFAULT_LAYER : String = "subtitle_default";
	private static inline var _TWEEN_TIME : Float = .2;

	public function new( pSprite:Sprite ) {
		// TODO SET THE IMAGE SOMEWHERE
		_elementManager = new ElementManager(pSprite,0,0,false);
		_elementManager.addLayer( _DEFAULT_LAYER );
		_image = _elementManager.addElement(new Element({asset:"",y:ConstantsApp.STAGE_CENTER_Y,originY:1}));
		_text = _elementManager.addElement(new Text({text:"",y:ConstantsApp.STAGE_CENTER_Y-20,originY:1,align:TextAlign.Center,wrapWidth:ConstantsApp.STAGE_WIDTH-100}));
		_tween = new Tweener();
		_setSubState(ON);
	}

	public function update( dt:Float ) : Void {
		_elementManager.update(dt);
		_tween.update(dt);

		switch ( _subState ) {
			case OFF:
			case CHANGE_ON:
			case ON:
				if ( _timer > 0 ) {
					_timer -= dt;
				}
			case CHANGE_OFF:
		}

		if ( WMSound.subtitleQueue.length > 0 ) {
			var tSub : String = WMSound.subtitleQueue[0];
			if ( tSub != _currentText && WMLocalize.subtitlesEnabled ) {
				// A different subtitle is now queued - end the current one.
				_currentText = tSub;
				_setSubtitle(_currentText);
			}
			tSub = null;
		} else if ( _timer <= 0 ) {
			// Turn off the subs - there's nothing else in the queue and the timer is out
			switch ( _subState ) {
				case ON,CHANGE_ON:
					_setSubState(CHANGE_OFF);
				default:
					// Nothing to do, already off or turning off
			}
		}
	}

	private function _setSubState(pState:SUB_STATE) : Void {
		_subState = pState;
		switch ( _subState ) {
			case OFF:
				_currentText = "";
				_image.visible = false;
				_image.alpha = 0;
				_text.visible = false;
				_text.alpha = 0;
			case CHANGE_ON:
				_image.visible = true;
				_text.visible = true;
				_tween.tween( { target: _image, duration: _TWEEN_TIME, overwrite: true, ease: Ease.linear }, { alpha:1 } ).onComplete( function() { _setSubState(ON); } );
				_tween.tween( { target: _text, duration: _TWEEN_TIME, overwrite: true, ease: Ease.linear }, { alpha:1 } );
			case CHANGE_OFF:
				_tween.tween( { target: _image, duration: _TWEEN_TIME, overwrite: true, ease: Ease.linear }, { alpha:0 } ).onComplete( function() { _setSubState(OFF); } );
				_tween.tween( { target: _text, duration: _TWEEN_TIME, overwrite: true, ease: Ease.linear }, { alpha:0 } );
			case ON:
		}
	}

	private function _setSubtitle( pVal:String ) : Void {
		var tData : LocalizationData = WMLocalize.getLocalizeData(pVal);
		_timer = tData.subtitleTime;
		tData = null;
		_text.setText(pVal);
		switch ( _subState ) {
			case OFF,CHANGE_OFF:
				_setSubState(CHANGE_ON);
			default:
				// We're already visible
		}
	}
}
