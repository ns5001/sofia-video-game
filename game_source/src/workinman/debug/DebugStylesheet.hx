package workinman.debug;

import js.Browser;

class DebugStylesheet {
	
	/***************************************
	 * CSS for the debug environment
	 ***************************************/
	public static function createStyle():Void {
		DebugUtils.newElem("style", {innerHTML:"
			::-moz-selection, ::selection {
				background-color:Transparent;
				color:#000;
			}
			* {
				-webkit-touch-callout: none;
				-webkit-user-select: none;
				-khtml-user-select: none;
				-moz-user-select: none;
				-ms-user-select: none;
				user-select: none;
			}
			body {
				overflow		: hidden;
			}

			/*
			* Common Styling
			*/
			.wm-debug input[type=number], .wm-debug input[type=text] {
				box-sizing: border-box;
				padding: 2px 5px;
				border-radius: 4px;
			}
			.wm-debug input[type=number]:disabled, .wm-debug input[type=text]:disabled {
				background: #DDD;
			}
			.wm-debug kbd.key {
				box-shadow: 0.1em 0.2em 0.2em rgba(0, 0, 0, 0.2);
				font-family: Arial,Helvetica,sans-serif;
				font-size: 0.85em;
				border-radius: 3px;
				padding: 1px 6px;
				white-space: nowrap;
				border: 1px solid #D8D8D8;
				background: rgba(255,255,255,0.3);
			}
			.wm-debug input {
				vertical-align: middle;
			}
			.wm-debug label {
				font-weight: bold;
			}
			.wm-debug output {
				margin-left: 2px;
			}
			.wm-debug ul {
				margin: 4px 0;
			}
			.wm-debug .red {
				color: red;
			}

			"+_panesCSS()+"
			"+_windowCSS()+"
			"+_treeListCSS()+"
			"+_checkboxSwitchCSS()+"
			"+_sliderCSS()+"
		"}, Browser.document.head);
	}

	private static function _windowCSS() : String {
		return "
			.debugWindow {
				position		: absolute;
				padding			: 4px;
				/*color			: #FFF;*/
				background		: linear-gradient(135deg, #000000 0%,#45484d 100%);
				border			: 1px solid #EEE;
				border-radius	: 3px;
				box-shadow		: 0 0 5px #000;
			}
			.debugWindow a {
				/*color			: #FFF;*/
			}
			.debugWindow .titleBar {
				text-align		: left;
				position		: relative;
				padding			: 1px 120px 3px 3px;
			}
			.debugWindow .titleBar .title {
				text-transform	: capitalize;
				display			: inline-block;
				margin-top		: -2px;
				padding			: 0 3px;
				color			: #333;
				border-radius	: 5px;
				text-shadow		: 1px 1px 12px #FFF, -1px 1px 12px #FFF, 1px -1px 12px #FFF, -1px -1px 12px #FFF;
				user-select		: none;
				cursor			: default;
			}
			.debugWindow .titleBar .buttonContainer {
				position		: absolute;
				display			: inline-block;
				vertical-align	: top;
				top				: -5px;
				right			: 0px;
			}
			.debugWindow .titleBar .buttonContainer .button {
				line-height		: 21px;
				color			: #EEE;
				font-weight		: 900;
				cursor			: pointer;
				display			: inline-block;
				padding			: 0px 8px;
				background		: transparent;
				box-shadow		: 0 0 1px #EEE;
				user-select		: none;
			}
			.debugWindow .titleBar .buttonContainer .button+.button { border-left:0; }
			.debugWindow .titleBar .buttonContainer .button:first-of-type { border-bottom-left-radius:5px; }
			.debugWindow .titleBar .buttonContainer .button:last-of-type { border-bottom-right-radius:5px; }
			.debugWindow .titleBar .buttonContainer .button.exit {
				padding			: 0px 15px;
			}
			.debugWindow .titleBar .buttonContainer .button:hover {
				background		: linear-gradient(to bottom, #d0e4f7 0%,#73b1e7 24%,#0a77d5 50%,#539fe1 79%,#87bcea 100%);
				box-shadow		: 0 0 8px #d0e4f7;
			}
			.debugWindow .titleBar .buttonContainer .button.exit:hover {
				background		: linear-gradient(to bottom, #f0b7a1 0%,#8c3310 50%,#752201 51%,#bf6e4e 100%);
				box-shadow		: 0 0 8px #f0b7a1;
			}

			.debugWindow .controlContainer {
				padding			: 2px 3px;
				background		: #CEE;
				border			: 1px solid #EEE;
			}
			.debugWindow .control {
				vertical-align	: top;
				position		: relative;
				display			: inline-block;
				box-sizing		: border-box;
				width			: "+Debug.CONTROL_WIDTH+"px;
				min-height		: 50px;
				margin			: 2px "+Debug.CONTROL_MARGIN+"px;
				background		: #ECC;
				border			: 1px dotted #D79B9B;
				/*background		: #F7921F;
				border			: 1px dotted #d27c1a;*/
			}
			.debugWindow .control.full {
				width			: calc(100% - 4px);
				overflow		: auto;
			}
			.debugWindow .control .title {
				text-transform	: capitalize;
				padding			: 1px 3px 2px;
				margin-bottom	: 2px;
				border-bottom	: 1px dotted #D79B9B;
			}
			.debugWindow .control .detail {
				position		: absolute;
				top				: 1px;
				right			: 4px;
			}
			.debugWindow .control .inputContainer {
				text-align		: center;
				padding			: 1px 3px;
			}
			.debugWindow .control ul {
				text-align		: left;
			}

			.sprite-transform-table {
				width:100%;
			}
			.sprite-transform-table input {
				width: calc(100% - 8px);
			}
		";
	}

	private static function _panesCSS() : String {
		return "
			#debug-panes-sidebar-cont {
				position: fixed;
				box-sizing: border-box;
				overflow: auto;
				height: 100%;
				width: 350px;
				top: 0;
				right: 0;
				padding: 3px 5px;
				background: #a2a2a2;
				border-left: 2px solid #222;
			}
			#debug-panes-sidebar-cont .close-button {
				position: absolute;
				top: 5px;
				right: 8px;
				cursor: pointer;
			}
			#debug-panes-sidebar-cont .close-button:before {
				content:'✖';
			}
			#debug-panes-sidebar-cont .close-button:hover {
				-webkit-text-stroke: 2px white;
			}
			.debug-pane {
				box-sizing: border-box;
				width: 100%;
				height: calc(100% - 23px);
				color: black;
				overflow-y: auto;
				overflow-x: hidden;
				background: #c2c2c2;
				border: 1px solid #747474;
			}
			.pane-section {
				padding: 3px 4px;
			}
			.pane-section+.pane-section {
				border-top: 2px solid #747474;
			}
			.pane-section .title {
				display: block;
				width: 100%;
				margin-bottom: 2px;
				font-size: 115%;
				font-weight: bold;
				border-bottom: 1px solid #a2a2a2;
			}
			.pane-section-content {

			}
			.pane-section-content p {
				margin: 0.25em 0;
			}

			#debug-pane-tab-cont {
				overflow-y: hidden;
			}
			#debug-pane-tab-cont:after {
				content:'';
				clear: both;
			}
			#debug-pane-tab-cont .tab {
				box-sizing: border-box;
				display: block;
				float: left;
				max-width: 90px;
				width: 90px;
				font-weight: bold;
				padding: 2px 6px;
				overflow: hidden;
				border-top: 1px solid #858585;
				border-right: 1px solid #858585;
				cursor: pointer;
				border-radius: 5px 5px 0 0;
			}
			#debug-pane-tab-cont .tab:first-of-type {
				border-left: 1px solid #858585;
			}
			#debug-pane-tab-cont .tab:hover {
				background: #D4D4D4;
			}
			#debug-pane-tab-cont .tab.active {
				background: #E4E4E4;
			}

			#cloud-table {
				width: 100%;
				text-align: left;
				word-break: break-all;
			}
			#cloud-table th div {
				overflow: hidden;
				white-space: nowrap;
				width: 220px;
				text-overflow: ellipsis;
			}
			#cloud-table input {
				max-width: 90px;
			}

			/*#debug-panes-cont {
				display: flex;
				flex-direction: row;
			}
			#debug-panes-sidebar-cont {
				flex:0 0 300px;
				background: #444;
			}
			.debug-pane {
				width:100%;
				color: white;
			}*/
		";
	}

	private static function _treeListCSS() : String {
		var DOTTED_GIF = "data:image/gif;base64,R0lGODlhCQABAIAAAAAAAP///yH5BAEAAAEALAAAAAAJAAEAAAIDRIxXADs=";
		var DOTTED_ANGLE_GIF = "data:image/gif;base64,R0lGODlhCwALAIAAAAAAAP///yH5BAEAAAEALAAAAAALAAsAAAIQRI6pa+venjxxvmpZMHzvAgA7";
		// https://www.thecssninja.com/css/css-tree-menu
		// http://www.howtocreate.co.uk/tutorials/jsexamples/listCollapseExample.html
		return "
			ul.maketree, ul.maketree ul, ul.maketree li {
				margin: 0;
				padding: 0;
				list-style-type: none;
			}
			ul.maketree ul { padding-left: 0.3em; }
			ul.maketree li {
				border-left: 1px dotted #000;
				padding-left: 13px;
				background: url("+DOTTED_GIF+") scroll no-repeat 1px 0.8em;
			}
			ul.maketree li:last-child {
				border-left-width: 0px;
				padding-left: 14px;
				background: url("+DOTTED_ANGLE_GIF+") scroll no-repeat left top;
			}


			ul.maketree li input
			{
				position: absolute;
				left: 0;
				margin-left: 0;
				opacity: 0;
				z-index: 2;
				cursor: pointer;
				height: 1em;
				width: 1em;
				top: 0;
			}
			ul.maketree li input + ul > li { display: none; }
			ul.maketree li label
			{
				cursor: pointer;
				display: inline-block;
			}
			ul.maketree li input:checked + ul > li { display: block; margin: 0 0 0.125em;  /* 2px */}
			ul.maketree li input:checked + ul > li:last-child { margin: 0 0 0.063em; /* 1px */ }
		";
	}

	private static function _checkboxSwitchCSS() : String {
		return "
			/* https://proto.io/freebies/onoff/ */
			.onoffswitch {
				display			: inline-block;
				position: relative; width: 90px;
				-webkit-user-select:none; -moz-user-select:none; -ms-user-select: none;
				vertical-align: middle; /* [WORKINMAN] */
			}
			.onoffswitch-checkbox {
				display: none;
			}
			.onoffswitch-label {
				display: block; overflow: hidden; cursor: pointer;
				border: 2px solid #999999; border-radius: 20px;
				text-align: left;
			}
			.onoffswitch-inner {
				display: block; width: 200%; margin-left: -100%;
				-moz-transition: margin 0.3s ease-in 0s; -webkit-transition: margin 0.3s ease-in 0s;
				-o-transition: margin 0.3s ease-in 0s; transition: margin 0.3s ease-in 0s;
			}
			.onoffswitch-inner:before, .onoffswitch-inner:after {
				display: block; float: left; width: 50%; height: 21px; padding: 0; line-height: 21px;
				font-size: 14px; color: white; font-family: Trebuchet, Arial, sans-serif; font-weight: bold;
				-moz-box-sizing: border-box; -webkit-box-sizing: border-box; box-sizing: border-box;
			}
			.onoffswitch-inner:before {
				content: 'TRUE';
				padding-left: 15px;
				background-color: #34A7C1; color: #FFFFFF;
			}
			.onoffswitch-inner:after {
				content: 'FALSE';
				padding-right: 10px;
				background-color: #EEEEEE; color: #999999;
				text-align: right;
			}
			.onoffswitch-switch {
				display: block; width: 13px; margin: 4px;
				background: #FFFFFF;
				border: 2px solid #999999; border-radius: 20px;
				position: absolute; top: 0; bottom: 0; right: 65px;
				-moz-transition: all 0.3s ease-in 0s; -webkit-transition: all 0.3s ease-in 0s;
				-o-transition: all 0.3s ease-in 0s; transition: all 0.3s ease-in 0s;
			}
			.onoffswitch-checkbox:checked + .onoffswitch-inner {
				margin-left: 0;
			}
			.onoffswitch-checkbox:checked + * + .onoffswitch-switch {
				right: 0px;
			}
		";
	}

	private static function _sliderCSS() : String {
		return "
			input[type=range] {
				-webkit-appearance: none;
				background: none;
				border: 0;
				box-shadow: 0;
				padding: 8px 0;
			}
			input[type=range]:focus {
				/*box-shadow: inset 0 1px 1px rgba(0,0,0,.075), 0 0 8px rgba(102, 175, 233, .6);*/
				box-shadow: inset 0 1px 1px rgba(0,0,0,0);
			}
			/**********************
			* RANGE THUMB - https://css-tricks.com/styling-cross-browser-compatible-range-inputs-css/
			**********************/
			/* Special styling for WebKit/Blink */
			input[type=range]::-webkit-slider-thumb {
			  -webkit-appearance: none;
			  border: 1px solid #000000;
			  height: 24px;
			  width: 16px;
			  border-radius: 5px;
			  background: #ffa800;
			  cursor: pointer;
			  margin-top: -9px; /* You need to specify a margin in Chrome, but in Firefox and IE it is automatic */
			  box-shadow: 1px 1px 1px #000000, 0px 0px 1px #0d0d0d;
			}

			/* All the same stuff for Firefox */
			input[type=range]::-moz-range-thumb {
			  box-shadow: 1px 1px 1px #000000, 0px 0px 1px #0d0d0d;
			  border: 1px solid #000000;
			  height: 24px;
			  width: 16px;
			  border-radius: 5px;
			  background: #ffa800;
			  cursor: pointer;
			}

			/* All the same stuff for IE */
			input[type=range]::-ms-thumb {
			  box-shadow: 1px 1px 1px #000000, 0px 0px 1px #0d0d0d;
			  border: 1px solid #000000;
			  height: 24px;
			  width: 16px;
			  border-radius: 5px;
			  background: #ffa800;
			  cursor: pointer;
			}

			/* Special styling for WebKit/Blink */
			input[type=range]:disabled::-webkit-slider-thumb {
			  box-shadow: 1px 1px 1px rgba(0, 0, 0, .075), 0px 0px 1px rgba(0, 0, 0, .075);
			  border: 1px solid rgba(0, 0, 0, .15);
			  background: #ddd;
			}

			/* All the same stuff for Firefox */
			input[type=range]:disabled::-moz-range-thumb {
			  box-shadow: 1px 1px 1px rgba(0, 0, 0, .075), 0px 0px 1px rgba(0, 0, 0, .075);
			  border: 1px solid rgba(0, 0, 0, .15);
			  background: #ddd;
			}

			/* All the same stuff for IE */
			input[type=range]:disabled::-ms-thumb {
			  box-shadow: 1px 1px 1px rgba(0, 0, 0, .075), 0px 0px 1px rgba(0, 0, 0, .075);
			  border: 1px solid rgba(0, 0, 0, .15);
			  background: #ddd;
			}

			/**********************
			* RANGE TRACK - https://css-tricks.com/styling-cross-browser-compatible-range-inputs-css/
			**********************/
			input[type=range]::-webkit-slider-runnable-track {
			  width: 100%;
			  height: 7px;
			  cursor: pointer;
			  box-shadow: 1px 1px 1px rgba(0, 0, 0, .075), 0px 0px 1px rgba(0, 0, 0, .075);
			  background: #eeeeee;
			  border-radius: 1.3px;
			  border: 0.2px solid rgba(0, 0, 0, .15);
			}

			input[type=range]:focus::-webkit-slider-runnable-track {
			  background: #d9d9d9;
			}

			input[type=range]::-moz-range-track {
			  width: 100%;
			  height: 7px;
			  cursor: pointer;
			  box-shadow: 1px 1px 1px rgba(0, 0, 0, .075), 0px 0px 1px rgba(0, 0, 0, .075);
			  background: #eeeeee;
			  border-radius: 1.3px;
			  border: 0.2px solid rgba(0, 0, 0, .15);
			}

			input[type=range]::-ms-track {
			  width: 100%;
			  height: 7px;
			  cursor: pointer;
			  background: transparent;
			  border-color: transparent;
			  border-width: 16px 0;
			  color: transparent;
			}
			input[type=range]::-ms-fill-lower {
			  background: #2a6495;
			  border: 0.2px solid rgba(0, 0, 0, .15);
			  border-radius: 2.6px;
			  box-shadow: 1px 1px 1px rgba(0, 0, 0, .075), 0px 0px 1px rgba(0, 0, 0, .075);
			}
			input[type=range]:focus::-ms-fill-lower {
			  background: #eeeeee;
			}
			input[type=range]::-ms-fill-upper {
			  background: #eeeeee;
			  border: 0.2px solid rgba(0, 0, 0, .15);
			  border-radius: 2.6px;
			  box-shadow: 1px 1px 1px rgba(0, 0, 0, .075), 0px 0px 1px rgba(0, 0, 0, .075);
			}
			input[type=range]:focus::-ms-fill-upper {
			  background: #d9d9d9;
			}

			input[type=range]:disabled::-webkit-slider-runnable-track {
			  background: #eee;
			}
			input[type=range]:disabled::-moz-range-track {
			  background: #eee;
			}
			input[type=range]:disabled::-ms-fill-lower {
			  background: #eee;
			}
			input[type=range]:disabled::-ms-fill-upper {
			  background: #eee;
			}
		";
	}
}
