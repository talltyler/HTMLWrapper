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
	import framework.display.Text;
	
	public class Element extends Node
	{		
		//public var scrollbar:ScrollBox;
		//public var textBox:TextBox;
		public var text:Text
		private var _cdata:String;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		/**
		 *	@constructor
		 *	@param	styles	 Object containing all styles for different states of this element
		 *	@param	events	 Object created by ObjectUtils to preclean method calls
		 */
		public function Element( document:Document=null, element:Node=null, xml:XML=null )
		{
			super( document, element, xml );
		}
		
		public function get cdata():String
		{ 
			return _cdata; 
		}

		public function set cdata(value:String):void
		{
			if (value !== _cdata)
			{
				_cdata = value;
				
				if( text == null ){
					text = new Text( _cdata, computedStyles, document.window.css.styleSheet );
					addEventListener(Event.ADDED_TO_STAGE, addText);
				}else
					updateText();
			}
		}
		
		public function setProperty( name:String, value:* ):void
		{
			this[name] = value;
		}
		
		// need to make this a system that can accept more than one block of text.
		public function addCData( text:String ):void
		{
			cdata = text;
		}
		
		private function addText( event:Event ):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addText);
			addChild( text );
			text.create( { style:style } );
		}
		
		private function updateText():void
		{
			// TODO: fix update text, currently there is no way to do this
			//text.rebreakLines();
		}
		
		private function updateScroll():void
		{
			// update scroll box based on _style
		}
	}
}