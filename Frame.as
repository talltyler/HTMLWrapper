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
	import framework.net.Asset;
	
	/*
	features
		left=pixels	The left position of the window
		top=pixels	The top position of the window
		width=pixels	The width of the window. Min. value is 100
		height=pixels	The height of the window. Min. value is 100
		scrollbars=yes|no|1|0	Whether or not to display scroll bars. Default is yes
	*/
	
	public class Frame extends Element
	{
		private var _layers:Array = [];
		private var _url:String;
		private var _features:Object;
		
		public function Frame( document:Document, url:String=null, name:String=null, features:Object=null )
		{
			super( document );
			style.width = "100%";
			style.height = "100%";
			if( name ) this.name = "_layer"+name;
			else this.name = "_layer";
			if( url ) this.url = url;
			_features = features;
			document.window.addChild(this);
			addLayer(0);
		}

		public function get url():String
		{ 
			return _url; 
		}

		public function set url(value:String):void
		{
			if (value !== _url) {
				_url = value;
				
				var asset:Asset = document.assets.add( _url );
				asset.addEventListener(Event.COMPLETE, onLocationChanged);
				document.assets.load()
			}
		}
		
		public function get features():Object
		{ 
			return _features; 
		}

		public function get layers():Array
		{ 
			return _layers; 
		}

		public function set layers( value:Array ):void
		{
			if (value !== _layers)
			{
				_layers = value;
			}
		}
		
		public function getLayer( zIndex:uint ):Layer
		{
			var result:Layer
			for each(var layer:Layer in layers){
				if( layer.zIndex == zIndex ) {
					result = layer;
					break;
				}
			}
			return result
		}
		
		public function addLayer( zIndex:uint ):Layer
		{
			var result:Layer = getLayer( zIndex );
			
			if( !result )
				result = new Layer( document, zIndex );
			
			_layers.push( result );
			
			addChild( result );
			
			return result
		}
		
		private function onLocationChanged( event:Event ):void
		{
			// // Log.info("onLocationChanged", _url)
			event.target.removeEventListener(Event.COMPLETE, onLocationChanged);
			getLayer(0).innerHTML = document.window.navigator.controller.assets.fetch(_url);
		}
	}
}