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
	import flash.display.DisplayObject;
	
	import framework.debug.Log;
	import framework.display.Base;

	/**
	 * This class is a combination of two things, a html cleaner that 
	 * takes html strings and convertes it into xml and my html parser.
	 * The html parser takes that xml and creates / renders the html document.
	 * 
	 * The cleaner part is based on the stuff below, but modified in many ways for wrapper
	 * http://www.buzzware.com.au/_blog/Coffee_into_Code/post/Pure_Actionscript_HTML_Parser_(with_thanks_to_John_Resig)/
	 * 14th May 2009: The following was adapted to ActionScript 3.0 by Gary McGhee of Buzzware Solutions (email gary at buzzware . com . au)
	 *
	 * Which is based on this below
	 * HTML Parser By John Resig (ejohn.org) (of JQuery fame)
	 * Original code by Erik Arvidsson, Mozilla Public License
	 * http://erik.eae.net/simplehtmlparser/simplehtmlparser.js
	 * http://ejohn.org/files/htmlparser.js
	 */
	public class Parser
	{	
		public static const PARSED:String = "parsed";
		public static const RESTART_PARSER:String = "restartParser";
		public static const ELEMENT:String = "element";
		
		private var _tags:Object
		private var _result:Object;
		private var _target:Base;
		private var _nodeName:String;
		private var _pausedData:Object;
		private var _paused:Boolean = false;
		
		// Regular Expressions for parsing tags and attributes
		private const startTag:RegExp = /^<(\w+)((?:\s+\w+(?:\s*=\s*(?:(?:"[^"]*")|(?:'[^']*')|[^>\s]+))?)*)\s*(\/?)>/;
		private const endTag:RegExp = /^<\/(\w+)[^>]*>/;
		private const attr:RegExp = /(\w+)(?:\s*=\s*(?:(?:"((?:\\.|[^"])*)")|(?:'((?:\\.|[^'])*)')|([^>\s]+)))?/g;
		
		private const empty:Array = // Empty Elements - HTML 4.01 + new 5 tags
		[ "area","base","basefont","br","col","frame","hr","img","input","isindex","link","meta","param","embed","video" ];

		private const block:Array = // Block Elements - HTML 4.01 + new 5 tags
		[ "address","applet","blockquote","button","center","dd","del","dir","div","dl","dt","fieldset","form",
		"frameset","hr","iframe","ins","isindex","li","map","menu","noframes","noscript","object","ol","p",
		"pre","script","table","tbody","td","tfoot","th","thead","tr","ul","section" ];
	
		private const inline:Array = // Inline Elements - HTML 4.01 + new 5 tags
		[ "a","abbr","acronym","applet","b","basefont","bdo","big","br","button","cite","code","del","dfn","em",
		"font","i","iframe","img","input","ins","kbd","label","map","object","q","s","samp","script","select",
		"small","span","strike","strong","sub","sup","textarea","time","tt","u","var","source","progress" ];
	
		// Elements that you can, intentionally, leave open (and which close themselves)
		private const closeSelf:Array = [ "colgroup","dd","dt","li","options","p","td","tfoot","th","thead","tr" ];
	
		private const fillAttrs:Array = // Attributes that have their values filled in disabled="disabled"
		[ "checked","compact","declare","defer","disabled","ismap","multiple","nohref","noresize","noshade",
		"nowrap","readonly","selected" ];
	
		private const special:Array = [ "script","style" ]; // Special Elements (can contain anything)

		public function get paused():Boolean
		{ 
			return _paused; 
		}

		public function set paused(value:Boolean):void
		{
			if (value !== _paused){
				_paused = value;
				
				if( _paused == false && _pausedData != null ) {
					parseHTML( _pausedData.document, _pausedData.target, _pausedData.node );
					_pausedData = null;
				}
			}
		}	
				
		/**
		 *	@constructor
		 */
		public function Parser( tags:TagsBase )
		{ 
			super();
			_tags = tags.tags;
		}
		
		/*
		this method still has problems with some things,
		known quarks:
			CData and other comments inside of script tags thrown it off in some cases
			Doctype is striped out, all documents are rendered the same way currently
		*/
		public function cleanHTML( html:String ) : XML 
		{
			var str:String = "";
			try {
				
				// remove space before doc
				//html = html.replace(/\s+/g," ").replace(/^\s*([\s\S]*\S+)\s*$|^\s*$/,"$1");
				html = html.split(html.substr(0,html.indexOf("<"))).join("")
				
				// Take out the doctype
				if( html.substring(0,2) == "<!" )
					html = html.substr( html.indexOf(">") + 1, html.length ) 

				// take out any xmlns and xml:lang rendering information, this throws off the xml parser
				if( html.indexOf("<html") != -1)
					html = html.split( html.substring( 0, html.indexOf(">") ) ).join("<html")
				
				if( html.indexOf("<html>\n<html>") != -1)
					html = html.split( "<html>\n<html>" ).join("<html>")
					
				html = html.replace(/<html([^>]*)\s*>/gi,'<html>')
				
				html = html.replace(/<!DOCTYPE([^>]*)\s*>/gi,'')
				
				html = html.replace(/<meta([^>]*)\s*>/gi,'')
				
				
				//html = html.split( "<SCRIPT" ).join("<script");
				//html = html.split( "</SCRIPT>" ).join("</script>");
				
				//html = html.split( "<STYLE" ).join("<style");
				//html = html.split( "</STYLE>" ).join("</style>");
				
				//html = html.replace(/<script([^>]*)\si*>/gi,'<script>')
				//html = html.replace(/<style([^>]*)\si*>/gi,'<style>')
				
				// html = html.replace(/<script([^>]*)\s*>/gi,'<script>')
				
				// take out attributes that have dashes in them
				//html = html.split( "http-equiv" ).join( "httpequiv" );
				html = html.split( "accept-charset" ).join( "charset" );
				
				// strip out all comments
				//html = html.replace(/\/\*(.|[\r\n])*?\*\//g, "");
				//html = html.split( '//-->' ).join( "" );
				
				// No need for empty id or class attributes
				html = html.split( 'class="" ' ).join( "" );
				html = html.split( 'id="" ' ).join( "" );
				
				// strip out all html comments
				//html = html.replace(/<!(?:--[\s\S]*?--\s*)?>\s*/g,'');
				
				// <script>
				//html = html.split( '<script language="javascript" type="text/javascript"><!--' ).join( "<script>" ).split( '--><script>' ).join( "</script>" );
				//html = html.split( '<script language="JavaScript"><!--' ).join( "<script>" ).split( '--><script>' ).join( "</script>" );
				// <script language="javascript" type="text/javascript"><!--
				
				//// Log.debug( html )
				/*
				var scriptTags:int = html.split("<script").length;
				var pointer:int = 0
				for(var i:int=0;i<scriptTags-1;i++){
					var begin:int = html.indexOf("<script", pointer);
					var end:int = html.indexOf(">", begin) + 1;
					if( begin != -1 && end != -1 ) {
						var s:String = html.substring(begin, end)
						html = html.split( s ).join( s + "<![CDATA[" );
					}
					pointer = end;
				}
				html = html.split( "<![CDATA[<![CDATA[" ).join( "<![CDATA[" );
				//html = html.replace(/<script([^>]*)\s*>/gim,"<script $1 ><![CDATA[")
				//html = html.replace(/<style([^>]*)\s*>/gi,"<style><![CDATA[")
				html = html.split("</script>").join("\n]]></script>");
				*/
				parse( html, {
					start: function( tag:String, attrs:Array, unary:Boolean ) :void {
						str += "<" + tag.toLowerCase();

						for ( var i:int = 0; i < attrs.length; i++ )
							str += " " + attrs[i].name + '="' + attrs[i].escaped + '"';

						str += (unary ? "/" : "") + ">";
					},
					end: function( tag:String ) : void {
						str += "</" + tag.toLowerCase() + ">";
					},
					chars: function( text:String ) : void {
						str += text;
					},
					comment: function( text:String ) : void {
						str += "<!--" + text + "-->";
					}
				});
				
				str = str.split("<!--").join("").split("-->").join("");
				
				//html = html.replace("</style>","]]></style>");
				
				// // Log.debug(str)
				
				return new XML( "<html>"+str+"</html>" );
			} 
			catch(error:Error) 
			{
				return XML("<html><body><h1>Error:</h1><p>"+error+"</p></body></html>");
			}
			return null;
		}
		
		public function parseHTML( document:Document, target:Base, node:XML ) : void 
		{
			if( !_paused ){
				var index:uint = 0;
				for each ( var xml:XML in node.children() ) {
					var nodeName:String = xml.name();
					if( xml.nodeKind() == ELEMENT ) {
						var tagMethod:Function = _tags[ nodeName ];
						if( tagMethod != null ) {
							var result:Object = tagMethod( document, target, xml );
							if( result != null ) { 
								//// Log.debug(nodeName, "nodeName")
								parseHTML( document, result.element||target, xml );	
								if( result.element && result.element != target && result.element is DisplayObject ){
									index++
									if( result.element.hasOwnProperty("index") ) {
										result.element.index = index;
									}
									target.addChild( result.element );
									// // Log.debug(result.element.name, target.name, target.getChildIndex(result.element))
								}
							}
						}else{
							_tags.span( document, target, xml );
						}
					}else{ // The node is ether a text node or it's unknown and will be rendered inside of a text box
						_tags.cdata( document, target, xml );
					}
				}

				//target.updateDisplayList(); // Dont think I need to do this now because everything is added after all of the siblings are parsed

				// This event is fired when all objects have been created from the base xml node that was sent in, this does not include anything that was loaded
				target.dispatchEvent( new Event( PARSED, false ) );
			}
			else
			{
				_pausedData = { document:document, target:target, node:node };
				document.addEventListener( RESTART_PARSER, restart );
			}
		}
		
		private function restart( event:Event ):void
		{
			event.target.removeEventListener( RESTART_PARSER, restart );
			paused = false;
			if( _pausedData )
				parseHTML( _pausedData.document, _pausedData.target, _pausedData.node );
		}
		
		private function parse( html:String=null, handler:Object=null ) : void
		{
			var index:int;
			var chars:Boolean;
			var match:Array;
			var stack:Stack = new Stack();
			var last:String = html;
			
	
			while ( html ) {
				chars = true;
	
				// Make sure we're not in a script or style element
				if ( !stack.last() || !special.indexOf( stack.last() ) > -1 ) {
	
					// Comment
					if ( html.indexOf("<!--") == 0 ) {
						index = html.indexOf("-->");
		
						if ( index >= 0 ) {
							// if ( handler.comment ) handler.comment( html.substring( 4, index ) );
							html = html.substring( index + 3 );
							chars = false;
						}
		
					// end tag
					} else if ( html.indexOf("</") == 0 ) {
						match = html.match( endTag );
		
						if ( match ) {
							html = html.substring( match[0].length );
							match[0].replace( endTag, parseEndTag );
							chars = false;
						}
		
					// start tag
					} else if ( html.indexOf("<") == 0 ) {
						match = html.match( startTag );
		
						if ( match ) {
							html = html.substring( match[0].length );
							match[0].replace( startTag, parseStartTag );
							chars = false;
						}
					}
	
					if ( chars ) {
						index = html.indexOf("<");
						
						var text:String = index < 0 ? html : html.substring( 0, index );
						html = index < 0 ? "" : html.substring( index );
						
						if ( handler.chars )
							handler.chars( text );
					}
	
				} else {
					html = html.replace(/\/\*(.|[\r\n])*?\*\//g, "");
					var sub:String = html.substring( 0, html.indexOf("</"+stack.last() ) )
					html = html.split( sub ).join(sub.split("\n").join("").split("\r").join(""));
					html = html.replace(new RegExp("(.*)<\/" + stack.last() + "[^>]*>", "im"), function(all:String, text:String, ...rest) : String
					{	
						text = text.replace(/<!--(.*?)-->/gim, "$1").replace(/<!\[CDATA\[(.*?)]]>/gim, "$1");
						
						if ( handler.chars )
							handler.chars( text );
	
						return "";
					});
					
					parseEndTag( "", stack.last() );
				}
	
				if ( html == last )
					throw "Parse Error: " + html;
					
				last = html;
			}
			
			// Clean up any remaining tags
			parseEndTag();
	
			function parseStartTag( tag:String, tagName:String, rest:String, unary:Boolean, ...parseStartTagArgs ) : void {
				if ( block.indexOf( tagName ) > -1 ) {
					while ( stack.last() && inline.indexOf( stack.last() ) > -1) {
						parseEndTag( "", stack.last() );
					}
				}
	
				if ( closeSelf.indexOf( tagName ) > -1 && stack.last() == tagName ) {
					parseEndTag( "", tagName );
				}
	
				unary = empty.indexOf( tagName ) > -1 || !!unary;
	
				if ( !unary )
					stack.push( tagName );
				
				if ( handler.start ) {
					var attrs:Array = [];
		
					rest.replace(attr, function(match:String, name:String, arg3:*=null, arg4:*=null) :void {
						var value:String = arguments[2] ? arguments[2] :
							arguments[3] ? arguments[3] :
							arguments[4] ? arguments[4] :
							fillAttrs.indexOf(name) > -1 ? name : "";
						
						attrs.push({
							name: name,
							value: value,
							escaped: value.replace(/(^|[^\\])"/g, '$1\\\"')
						});
					});
		
					if ( handler.start )
						handler.start( tagName, attrs, unary );
				}
			}
	
			function parseEndTag( tag:String=null, tagName:String=null, ...parseEndTagArgs ) : void 
			{
				var pos:int
				// If no tag name is provided, clean shop
				if ( !tagName )		
					pos = 0;
					
				// Find the closest opened tag of the same type
				else
					for (pos = stack.length - 1; pos >= 0; pos-- )
						if ( stack[ pos ] == tagName )
							break;
				
				if ( pos >= 0 ) {
					// Close all the open elements, up the stack
					for ( var i:int = stack.length - 1; i >= pos; i-- )
						if ( handler.end )
							handler.end( stack[ i ] );
					
					// Remove the open elements from the stack
					stack.length = pos;
				}
			}
		}
	}
}
dynamic class Stack extends Array  {
	
	public function Stack(){ super(); }
	
	public function last() : String 
	{
		return this[ this.length - 1 ]; 
	}
}