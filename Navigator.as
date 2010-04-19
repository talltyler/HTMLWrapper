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
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	
	import framework.cache.Pool;
	import framework.controller.Controller;
	import framework.display.Base;
	
	public class Navigator extends EventDispatcher
	{
		public static const NAVIGATOR_MAIN:String = "NAVIGATOR_MAIN";
		public static const NAVIGATOR_TOP:String = "NAVIGATOR_TOP";
		
		public var controller:Controller;
		public var target:Sprite;
		public var main:Base;
		public var top:Base;
		
		public var tags:TagsBase;
		public var windows:Array = [];
		public var pools:Pool;
		
		public function Navigator( controller:Controller )
		{
			super();
			
			this.controller = controller;
			pools = new Pool();
			tags = new TagsBase( controller );
		}
		
		public function start( target:Sprite ):void
		{
			this.target = target;
			this.target.name = "NAVIGATOR";
			/* // Any object that will be added and deleted many times must go through the pool
			pools.Element = new Pool(true);
			*/
			
			main = new Base();
			main.name = NAVIGATOR_MAIN;
			main.graphics.clear();
			target.addChild( main );
			
			top = new Base();
			top.name = NAVIGATOR_TOP;
			top.graphics.clear();
			target.addChild(top);
		}
	}
}