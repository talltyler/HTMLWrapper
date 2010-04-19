/*                                   ,----,                                 
 *                                 ,/   .`|                                 
 *      ,---,       .--.--.      ,`   .'  :,-.----.      ,---,    ,---,     
 *     '  .' \     /  /    '.  ;    ;     /\    /  \  ,`--.' |  .'  .' `\   
 *    /  ;    '.  |  :  /`. /.'___,/    ,' ;   :    \ |   :  :,---.'     \  
 *   :  :       \ ;  |  |--` |    :     |  |   | .\ : :   |  '|   |  .`\  | 
 *   :  |   /\   \|  :  ;_   ;    |.';  ;  .   : |: | |   :  |:   : |  '  | 
 *   |  :  ' ;.   :\  \    `.`----'  |  |  |   |  \ : '   '  ;|   ' '  ;  : 
 *   |  |  ;/  \   \`----.   \   '   :  ;  |   : .  / |   |  |'   | ;  .  | 
 *   '  :  | \  \ ,'__ \  \  |   |   |  '  ;   | |  \ '   :  ;|   | :  |  ' 
 *   |  |  '  '--' /  /`--'  /   '   :  |  |   | ;\  \|   |  ''   : | /  ;  
 *   |  :  :      '--'.     /    ;   |.'   :   ' | \.''   :  ||   | '` ,/   
 *   |  | ,'        `--'---'     '---'     :   : :-'  ;   |.' ;   :  .'     
 *   `--''                                 |   |.'    '---'   |   ,.' Tyler      
 * ActionScript tested rapid iterative dev `---' Copyright2010'---'  Larson
 * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 * http://www.gnu.org/licenses
 */
package framework.view.htmlwrapper 
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	
	import framework.debug.Log;
	import framework.display.Base;
	import framework.display.ElementBase;
	import framework.net.Asset;
	
	/*
	import com.hurlant.eval.ByteLoader;
	import com.hurlant.eval.CompiledESC;
	import com.hurlant.eval.dump.ABCDump;
	import com.hurlant.jsobject.JSObject;
	import com.hurlant.util.Hex;
*/
	
	public class Window extends Base
	{
		public var target:DisplayObjectContainer;
		public var navigator:Navigator;
		public var closed:Boolean;
		public var document:Document;
		public var history:History;
		public var frames:Array = [];
		public var length:int // how many frames
		public var location:Location;
		//public var statusBar:StatusBar;
		
		public var windowName:String;
		public var windowFeatures:Object;
		public var windowReplace:Boolean;
		
		public var styles:String = "body{\nwidth:100%;\nheight:100%;\n}";
		public var css:CSS
		
		private var _windowURL:String;
		private var _innerWidth:int;
		private var _innerHeight:int;
		private var _status:String = "Loading";
		
		//private var esc:CompiledESC = new CompiledESC;
		//private var queue:Array = [];
		
		// linkage hack, to make a few things accessible from scripts
		//private var jsobject:JSObject;
		//private var hex:Hex;
		//private var abcdump:ABCDump;
		
		public function Window( navigator:Navigator, width:int, height:int, url:String=null, name:String="_self", features:Object=null, replace:Boolean=false )
		{
			super();
			
			graphics.beginFill(0xDDDDDD, 0.01);
			graphics.drawRect(0,0,width,height);
			graphics.endFill();
			
			this.navigator = navigator;
			navigator.windows.push( this );
			
			_windowURL = url;
			
			document = new Document( this );
			addChild( document );
			location = new Location( document );
			history = new History( document );
			
			var frame:Frame = new Frame( document, url, name, features );
			frame.graphics.clear();
			frames.push( frame );
			
			css = new CSS( navigator.controller );
			css.parseCSS( styles );
		}

		public function render( value:String ):void
		{
			frames[0].getLayer(0).innerHTML = value;
		}
		
		/**
		*	taken out because the interface doesn't seem right
		 *	Window.open( url:String=null, name:String="_self", features:Object=null, replace:Boolean=false )
		 */
		public function open() : void
		{
			//_instance.windowName = name;
			//_instance.windowFeatures = features;
			//_instance.windowReplace = replace;
			
			/*
			if( !replace ){
				if(_instance.app.windows[ name ] is Array){
					_instance.app.windows[ name ].push( frame );
				}else{
					_instance.app.windows[ name ] = [ frame ];
				}
			}else{
				_instance.app.windows[ name ] = [ frame ];
			}
			
			if( features && features.status ){
				statusBar = new StatusBar( this )
			}
			*/
		}
		
		public function close():void
		{
			closed = true
		}

		public function alert( message:String ) : void
		{
			ExternalInterface.call( "alert", message )
		}
		
		public function confirm( message:String ) : Boolean
		{
			return ExternalInterface.call( "confirm", message ) as Boolean
		}
		
		public function prompt( message:String, value:String ):String
		{
			return ExternalInterface.call( "prompt", message, value ) as String
		}
		
		public function getComputedStyle( id:String, styleName:String ):void
		{
			
		}
		
		public function blur():void
		{
			
		}
		
		public function focus():void
		{
			
		}
		
		public function print():void
		{
			
		}
		
		public function moveBy( xOffset:int, yOffset:int ):void
		{
			
		}
		
		public function moveTo( xPos:int, yPos:int ):void
		{
			
		}
		
		public function resizeBy( xOffset:int, yOffset:int ):void
		{
			
		}
		
		public function resizeTo( width:int, height:int ):void
		{
			graphics.clear();
			graphics.beginFill(0xDDDDDD, 1);
			graphics.drawRect(0,0,width,height);

			for each(var frame:Frame in frames ) {
				frame.draw( frame.style );
				updateChildren( frame );
				/*
				//Log.debug(frame.width, frame.height, frame.style.width, frame.style.height, "child", frame.name)
				for each( var layer:Layer in frame.layers ) {
					layer.draw( layer, layer.style );
					//Log.debug(layer.width, layer.height, layer.style.width, layer.style.height, "child", layer.name)
					updateChildren( layer );
				}
				*/
			}
			
			// Log.debug(this.width, this.height, width, height)
		}
		
		private function updateChildren( parent:ElementBase ):void
		{
			for( var i:int = 0; i<parent.numChildren; i++ ) {
				var child:* = parent.getChildAt(i);
				if( child is Base && child.hasOwnProperty("draw") ) {
					child.draw( child, child.style );
					//Log.debug(child.width, child.height, child.style.width, child.style.height, "child", child.name)
					if( child.numChildren != 0 ) {
						updateChildren( child );
					}
				}
			}
		}
		
		public function scrollBy( xOffset:int, yOffset:int ):void
		{
			
		}
		
		public function scroll( xPos:int, yPos:int ):void
		{
			
		}
		
		public function isNaN( number:Number ):Boolean
		{
			return isNaN(number)
		}
		
		public function parseInt( number:String ):int
		{
			return parseInt(number)
		}
		
		public function parseFloat( number:String ):Number
		{
			return parseFloat(number)
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		public function get windowURL():String
		{ 
			return _windowURL; 
		}

		public function set windowURL(value:String):void
		{
			if (value !== _windowURL)
			{
				_windowURL = value;
				location.href = _windowURL;
			}
		}
		public function get defaultStatus():String
		{ 
			return _status; 
		}

		public function set defaultStatus(value:String):void
		{
			if (value !== _status)
			{
				_status = value;
				/*
				if( !statusBar.closed ) {
					statusBar.update()
				}
				*/
			}
		}
		
		public function get status():String
		{ 
			return _status; 
		}

		public function set status(value:String):void
		{
			if (value !== _status)
			{
				_status = value;
				/*
				if( !statusBar.closed ) {
					statusBar.update()
				}*/
			}
		}
		
		public function get innerWidth():int
		{ 
			return _innerWidth; 
		}

		public function set innerWidth(value:int):void
		{
			if (value !== _innerWidth)
			{
				_innerWidth = value;
				location.refresh();
			}
		}
		
		public function get innerHeight():int
		{ 
			return _innerHeight; 
		}

		public function set innerHeight(value:int):void
		{
			if (value !== _innerHeight)
			{
				_innerHeight = value;
				location.refresh()
			}
		}
		
		public function get outerHeight():int
		{ 
			return target.height
		}
		
		public function get outerWidth():int
		{ 
			return target.width
		}
		
		public function get pageXOffset():int
		{ 
			return target.x; 
		}
		
		public function get pageYOffset():int
		{ 
			return target.y; 
		}
		
		/*
		private function checkForEsc():void {
			try {
				var compile:Function = getDefinitionByName("ESC::compile") as Function;
			} catch(e:Error) {
				setTimeout(checkForEsc, 100);
				return;
			}
			// initialize a few things
			firstScript();
			// let the Js side know we're open for business
			//ExternalInterface.call("HURLANT_donkey_escReady");
		}
		
		private function firstScript():void {
			// I don't want to copy every obscure window members by default.
			// it starts java on firefox, and has god knows how many other weird side effects.
			// so limit ourselves to the basics. 
			// programs can always go fish for stuff on window if they need to.
			var globals:Array = ["document", "top", "parent", "self", "history", "navigator", "screen", "opener", "location", "frames", "alert", "confirm", "prompt", "XMLHttpRequest"]; // 
			var pre:String =  
				  "namespace DOM = 'com.hurlant.jsobject';\n" +
				  "use namespace DOM;\n" +
				  "ESC function eval_hook(){};\n" + // needed to allow later override by eval()..
				  "var window = JSObject.getWindow();\n" +
				  "var eval2 = ScreamingDonkey.eval2;\n";
				
			for each (var n:String in globals) {
				pre += "var "+n+" = window."+n+";\n";
			}
			enqueueScript(pre, 0, "scopeSetter"); // XXX we rely on 0 being unused (because there's at least <script src=donkey.js></script>)
		}
		*/
		/*
		private function pageScripts( script:String ):void
		{
			var pageName:String = app.controller.pageName();
			eval( "class "+pageName+"{\npublic function "+pageName+"(){\n"+script+"\n}\n}" );
		}
		
		private function elementScripts( script:String ):void
		{
			var pageName:String = app.controller.pageName();
			var klass:Class = getDefinitionByName(pageName) as Class;
			var instance:* = new klass();
			// Do we want to loop over the methods and call them or do we want to try and have eval manage it all.
			eval( "class "+pageName+"{\npublic function "+pageName+"(){\n"+script+"\n}\n}" );
		}
		*/
		
		/**
		 * Plain "eval"-like method, who doesn't try to hard:
		 * - no scopes, no callback. no worries
		 *  
		 * @param script
		 * 
		 */
		/*
		public function eval(script:String, callback:Function=null):void {
			try {
				var bytes:ByteArray = esc.compile(script);
				ByteLoader.loadBytes(bytes, true, callback);
			} catch (e:Error) {
				Log.error("Error in eval: "+e);
				throw e;
			}
		}
		*/
		/**
		 * More full-featured eval. Still not synchronous, but we make up
		 * for it with a user-defined scope array and a callback.
		 * Scopes are implemented with "with", because it's easy and I'm cheap.
		 * 
		 * @param script
		 * @param scopes
		 * @param callback
		 * @return 
		 * 
		 */
		/*
		public function eval2(script:String, scopes:Array = null, callback:Function = null):* {
    		return _instance.esc.evaluateInScopeArray(script, scopes, callback);
		}
		
		private function enqueueScript(script:String, index:int, name:String):void {
			try {
				// add flash.utils in scope, to get setTimeout and setInterval.
				script = "namespace _flash_utils = 'flash.utils';\n" +
			             "use namespace _flash_utils;\n" +
			             script;
			    // compile
				var bytes:ByteArray = esc.compile(script, name);
				// don't load yet.
				queue[index] = bytes;
			} catch (e:Error) {
				Log.error("Error in eval: "+e);
				throw e;
			}
		}
		
		private function runQueue():void {
			var q:Array = [];
			for (var i:int=0;i<queue.length;i++) {
				if (queue[i] is ByteArray) {
					q.push(queue[i]);
				}
			}
			queue =[]; // empty queue
			ByteLoader.loadBytes(q, true);
		}
		*/
		
		private function instalize():void
		{
			// target = app.main
			document = new Document( this )
			location = new Location( document )
			history = new History( document )
			/*
			if (ExternalInterface.available) {
				ExternalInterface.marshallExceptions=true;
				ExternalInterface.addCallback("eval", eval);
				ExternalInterface.addCallback("enqueueScript", enqueueScript);
				ExternalInterface.addCallback("runQueue", runQueue);
				ExternalInterface.addCallback("trace", trace); // for debugging purposes.
				// notify the js side as soon as ESC is up.
				checkForEsc();
			}
			*/
		}
		
		private function onLocationChange( event:Event ):void
		{
			var asset:Asset = navigator.controller.assets.add( location.href );
			asset.addEventListener(Event.COMPLETE, onLocationChanged);
			navigator.controller.assets.load();
		}
		
		private function onLocationChanged( event:Event ):void
		{	
			frames[0].innerHTML = navigator.controller.assets.fetch( location.href );
		}	
	}
}