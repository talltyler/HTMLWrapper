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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import framework.display.ElementBase;
	import framework.utils.ClassUtils;
	import framework.utils.StringUtils;
	import framework.debug.Log;
	
	public class Node extends ElementBase
	{
		public var appliedStyles:Array;
		public var document:Document
		private var _element:Node
		private var _innerXML:XML;
		private var _innerHTML:String;
		
		public function Node( document:Document=null, element:Node=null, xml:XML=null )
		{
			this.document = document;
			_element = element;
			_innerXML = xml
			
			if( document || element || xml ){
				create( { document:document, element:element, xml:xml } );
			}
			super();
		}
		
		override public function create( params:Object=null ) : ElementBase
		{
			if( params ){
				document = params.document;
				_element = params.element;
				_innerXML = params.xml;
				if( _element && _innerXML ) {
					if( _innerXML.@name.toString() ) name = _innerXML.@name.toString();
					else if( _innerXML.@id.toString() ) name = _innerXML.@id.toString();
					else{
						name = _innerXML.name() + name.split("instance").join("");
						_innerXML.@id = name; // set the name back on in the id of the xml
					}
					
					//var events:Object = document.scripts.applyEvent( _innerXML );
					
					if( params.styles["default"].beforeTasks != null ) {
						beforeTasks.push.apply( null, cleanTasks( params.styles["default"].beforeTasks ) );
					}
					if( params.styles["default"].afterTasks != null ) {
						afterTasks.push.apply( null, cleanTasks( params.styles["default"].afterTasks ) );
					}
					
					super.create( { styles:params.styles, events:null} )
				}		
			}
			return this
		}
		
		private function cleanTasks( str:String ):Array
		{
			var parts:Array = str.split(")");
			var result:Array = [];
			for each(var item:String in parts ) {
				var methodParts:Array = item.split("(");
				if( methodParts[0] != " " ) {
					var clazz:Class = document.window.navigator.controller.assets.cache.tasks[ StringUtils.trim(methodParts[0]) ];
					if( clazz != null ) {
						var args:Array = methodParts[1].split(",");
						if( args.length == 1 && args[0] == "" ){ args = []; }
						var task:* = ClassUtils.instantiateWithArgs( clazz, args.map(cleanTask) );
						if( task != null && task is EventDispatcher && task.hasOwnProperty("start") ) {
							result.push( task );
						}
					}
				}
			}
			return result;
		}
		
		private function cleanTask(element:String, index:int, array:Array):* // Could be a string or a number
		{
			if( ( element.charAt(0) == "'" && element.charAt(element.length-1) == "'" ) || 
				( element.charAt(0) == '"' && element.charAt(element.length-1) == '"' ))
				return element.substring(1,element.length-2);
			
			else if( element.search( /\d+/ ) != -1 )
				return parseFloat( element );
				
			return null;
		}
				
		public function get innerHTML():String
		{ 
			return _innerHTML; 
		}

		public function set innerHTML(value:String):void
		{
			if (value !== _innerHTML)
			{
				_innerHTML = value;
				innerXML = document.parser.cleanHTML( _innerHTML );
			}
		}

		public function get innerXML():XML
		{ 
			return _innerXML; 
		}

		public function set innerXML(value:XML):void
		{
			if (value !== _innerXML)
			{
				_innerXML = value;

				//try{
					document.parser.parseHTML( document, this, _innerXML );
				/*}catch( error:Error ){
					// Log.error("Parse error.", error)
					document.parser.parseHTML( document, this, XML("<xml><h1>Your document was not well formed.</h1><p>"+error+"</p></xml>") )
				}
				*/
			}
		}
		
		public function get nodeXML():XML
		{ 
			return _innerXML; 
		}
		
		public function renderError(path:String):void
		{
			
		}
		
		private function onLoadError(event:Event=null):void
		{
			
		}
	}
}