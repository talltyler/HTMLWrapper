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
	import framework.debug.Log;
	
	public class Location
	{
		public static const LOCATION_CHANGE:String = "locationChange";
		
		private var _hash:String;
		private var _host:String;
		private var _hostname:String;
		private var _href:String;
		private var _pathname:String;
		private var _port:String;
		private var _protocol:String;
		private var _search:String;
		private var _document:Document
		
		public function Location( document:Document )
		{
			super();
			
			_document = document;
			_document.window.addEventListener( Location.LOCATION_CHANGE, refresh );
		}
		
		public function assign( url:String ) : void
		{
			
		}
		
		public function reload() : void
		{
			refresh();
		}
		
		public function refresh( event:Event=null ) : void
		{			
			/*
			AssetCache.instance
			_app.loader.add( href );
			_app.loader.addEventListener( BulkLoader.COMPLETE, onCompleteHandler );
			_app.loader.start();
			*/
			// Log.info("refresh location")
		}
		
		public function replace( url:String ) : void
		{
			/*
			AssetCache.instance
			_app.loader.add( url );
			_app.loader.addEventListener( BulkLoader.COMPLETE, onCompleteHandler );
			_app.loader.start();
			*/
			// Log.info("replace location")
		}
		
		public function toString() : String
		{
			return href
		}
		
		public function get hash():String
		{ 
			return _hash; 
		}

		public function set hash(value:String):void
		{
			if (value !== _hash)
			{
				_hash = value;
				_document.window.dispatchEvent( new Event( Location.LOCATION_CHANGE ) )
			}
		}
		
		public function get host():String
		{ 
			return _host; 
		}

		public function set host(value:String):void
		{
			if (value !== _host)
			{
				_host = value;
				_document.window.dispatchEvent( new Event( Location.LOCATION_CHANGE ) )
			}
		}
		
		public function get hostname():String
		{ 
			return _hostname; 
		}

		public function set hostname(value:String):void
		{
			if (value !== _hostname)
			{
				_hostname = value;
				_document.window.dispatchEvent( new Event( Location.LOCATION_CHANGE ) )
			}
		}
		
		public function get href():String
		{ 
			return _href; 
		}

		public function set href(value:String):void
		{
			if (value !== _href)
			{
				_href = value;
				_document.window.dispatchEvent( new Event( Location.LOCATION_CHANGE ) )
			}
		}
		
		public function get pathname():String
		{ 
			return _pathname; 
		}

		public function set pathname(value:String):void
		{
			if (value !== _pathname)
			{
				_pathname = value;
				_document.window.dispatchEvent( new Event( Location.LOCATION_CHANGE ) )
			}
		}
		
		public function get port():String
		{ 
			return _port; 
		}

		public function set port(value:String):void
		{
			if (value !== _port)
			{
				_port = value;
				_document.window.dispatchEvent( new Event( Location.LOCATION_CHANGE ) )
			}
		}
		
		public function get protocol():String
		{ 
			return _protocol;
		}

		public function set protocol(value:String):void
		{
			if (value !== _protocol)
			{
				_protocol = value;
				_document.window.dispatchEvent( new Event( Location.LOCATION_CHANGE ) )
			}
		}
		
		public function get search():String
		{ 
			return _search; 
		}

		public function set search(value:String):void
		{
			if (value !== _search)
			{
				_search = value;
				_document.window.dispatchEvent( new Event( Location.LOCATION_CHANGE ) )
			}
		}
		
		private function onCompleteHandler( event:Event ):void
		{
			//AssetCache.instance.removeEventListener( Event.COMPLETE, onCompleteHandler );
			//_document.innerHTML = _app.loader.getText( href );
			// Log.info("onComplete")
		}
	}
}