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
	
	public class History 
	{
		public static var HISTORY_UPDATED:String = "historyUpdated";
		
		private var _document:Document
		private var _history:Array = [];
		private var _currentIndex:uint = 0;
		private var _current:String;
		private var _next:String;
		private var _previous:String;
		
		public function History( document:Document )
		{
			super();
			_document = document;
			_document.window.addEventListener( Location.LOCATION_CHANGE, locationChange )
		}
		
		public function back():void
		{
			go( -1 );
		}
		
		public function forward():void
		{
			go( 1 );
		}
		
		public function go( location:* ):void
		{
			if( location is String ) 
			{	
				_history.push( new HistoryItem( location ) );
				_currentIndex = _currentIndex + 1;	
				_current = location;
			}else{
				_currentIndex = _currentIndex + int( location );
				_current = _history[ _currentIndex ].href;
			}
			
			if( length >= _currentIndex )
				_history.splice( _currentIndex + 1, length-_currentIndex+1);
				
			if( _currentIndex > 1 )
				_previous = _history[ _currentIndex - 1 ].href;
			else
				_previous = null;

			if( _currentIndex <= length )
				_next = _history[ _currentIndex + 1 ].href;
			else
				_next = null;
			
			_document.window.dispatchEvent( new Event( History.HISTORY_UPDATED ) )
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		public function get current():String
		{ 
			return _current; 
		}
		
		public function get next():String
		{ 
			return _next; 
		}
		
		public function get previous():String
		{ 
			return _previous; 
		}
		
		public function get length():uint
		{ 
			return _history.length; 
		}
		
		private function locationChange( event:Event ):void
		{
			var location:String = _document.window.location.href;
			
			_history.push( new HistoryItem( location ) );
			
			_currentIndex = _history.length - 1;
			
			if(_currentIndex > 1 )
				_previous = _history[ _currentIndex - 1 ].href;
			else
				_previous = null;
				
			_current = location;
		}
	}
}
class HistoryItem 
{
	public var href:String;
	
	public function HistoryItem( _href:String )
	{
		super();
		href = _href
	}
}

