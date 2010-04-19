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
	import framework.controller.Controller;
	import framework.debug.Log;
	import framework.utils.StringUtils;
	import framework.utils.TypeUtils;
	
	public class CSS 
	{
		public static const SEPARATOR:String = "|";
		
		private var _styleSheet:StylesBase;
		private var _controller:Controller;
		private var _currentStyles:String = "";
		private var _background:Object;
		private var _border:Object;
		private var _margin:Object;
		private var _padding:Object;
		
		private const DEFAULT_CSS:String = "div{display:block;width:100%;height:0}body{display:block;width:100%;height:100%;}";
		
		private const mapping:Object = 
		{
			background : { method:cleanBackground, 
				props:[ "background", "backgroundColor", "backgroundImage", "backgroundOpacity", "backgroundRepeat", 
						"backgroundPosition", "backgroundRotation", "backgroundScale", "backgroundSmooth", 
						"backgroundScaleX", "backgroundScaleY","backgroundSize" ] },
						
			border : { method:cleanBorder, 
				props:[ "border", "borderColor", "borderRadius", "borderTopLeftRadius", "borderTopRightRadius", 
						"borderBottomLeftRadius", "borderBottomRightRadius" ] },
						
			margin			: { method:cleanMargin, 
				props:[ "margin", "marginLeft", "marginRight", "marginTop", "marginBottom" ] },
				
			padding			: { method:cleanPadding, 
				props:[ "padding", "paddingLeft", "paddingRight", "paddingTop", "paddingBottom" ] }
		}
		
		// object constants
		private static const INHERITED_STYLES:Array = [ 
			"color",
			"cursor",
			"direction",
			"fontFamily",
			"fontSize",
			"fontStyle",
			"fontVariant",
			"fontWeight",
			"font",
			"letter",
			"spacing",
			"lineHeight",
			"listStyleImage",
			"listStylePosition",
			"listStyleType",
			"listStyle",
			"textAlign",
			"textIndent",
			"textTransform",
			"visibility",
			"whiteSpace",
			"wordSpacing"
		];
		
		// string constants
		private const DEFAULT:String = "default";
		private const CLASS:String = "class";
		
		
		public function get styleSheet() : StylesBase
		{
			return _styleSheet;
		}
		
		public function CSS( controller:Controller )
		{
			super();
			
			_controller = controller;
			_styleSheet = new StylesBase();
		}
		
		public function parseCSS( css:String ):StylesBase
		{
			css = _currentStyles + css;
			css = preparse( css );
			
			try {
				_styleSheet.parseCSS( DEFAULT_CSS + css );
			} catch(er:Error) {
				//Debug.log( "CSS Parse error", er );
			}
			return parse( _styleSheet );
		}
		
		/* TODO: selectors http://www.w3.org/TR/css3-selectors/#selectors
		
			*  
			E[foo] 
			E[foo="bar"] 
			E[foo~="bar"] 
			E[foo^="bar"] 
			E[foo$="bar"] 
			E[foo*="bar"]  
			E[hreflang|="en"]
			E:first-child
			E:last-child
			E:nth-child(n)
			E:nth-last-child(n)
			E:nth-of-type(n)
			E:nth-last-of-type(n)
			E:first-of-type
			E:last-of-type
			E:root 
			E:only-child 
			E:only-of-type 
			E:empty
			E:not(s)
			E > F 
			E + F 
			E ~ F
			
			Working:
			E
			E F
			E.warning 
			E#myid 
			
		*/
		
		public function getElementStyles( node:XML, parent:Element=null ):Object
		{
			var parentStyle:Object = {};
			var prop:String;
			var states:Object;
			var classArray:Array = [];
			var matchingStyles:Array = [];
			var currentParentWithinLoop:Element = parent;
			var currentParentDepth:int = 0;
			var candidates:Array = [];
			var lastClass:String
			var tailCandidates:Array;
			var scrap:String = node.@[CLASS].toString();
			var tag:String = node.localName();
			
			// Not all properties are inherited.
			if( parent ){
				for( prop in parent.style[DEFAULT] ){
					var saveProp:Boolean = false;
					if( INHERITED_STYLES.indexOf( prop ) ){
						parentStyle[ prop ] = parent.style[ prop ];
					}
				}
			}
			
			states = { "default":parentStyle };

			if (scrap.length) {
				classArray = scrap.split(" ");
				tailCandidates = scrap.split(" ");
				tailCandidates.unshift("");
				tailCandidates = tailCandidates.join(" .").split(" ");
				tailCandidates.shift();
				tailCandidates.reverse();
			} else {
				tailCandidates = [];
			}
			
			for (var i:int = 0; i < tailCandidates.length; i++) {
				lastClass = tailCandidates[i];
				if (_styleSheet.tailSortedStyles[lastClass]) {
					candidates.push.apply(null, _styleSheet.tailSortedStyles[lastClass]);
				}
			}
			
			scrap = node.@id.toString();
			if (scrap.length) {
				var id:String = "#" + scrap;
				if (_styleSheet.tailSortedStyles[id]) {
					candidates.push.apply(null, _styleSheet.tailSortedStyles[id]);
				}			
			}

			if (_styleSheet.tailSortedStyles[tag]) {
				candidates.push.apply(null, _styleSheet.tailSortedStyles[tag]); 
			}
			
			// this matches styles in the stylesheet to the node xml
			//styleLoop : for each( var styleName:String in _styleSheetstyleNames ) {
			styleLoop : for each( var styleName:String in candidates ) {

				var styleNameArray:Array = styleName.split( SEPARATOR );
				var styleMatch:Boolean = false;
				var score:int = 0;
				var currentNode:XML = node;
				var currentParentElement:Element = parent;
				var hasState:Boolean = false;
				var matchingSections:int = 0;
				var firstNodeMatch:Boolean = false;
				
				styleSectionLoop : for( i = styleNameArray.length - 1; i >= 0; i-- )
				{
					
					var sectionMatch:Boolean = false;
					var styleNameSection:String = styleNameArray[i];
					
					if( styleNameSection.charAt(0) == ":" && i == styleNameArray.length - 1 ){

						hasState = true;
						matchingSections++
						continue;
					}else{
						if( ( hasState && i == styleNameArray.length - 2) || i == styleNameArray.length - 1 ) {

							var isMatch:Object = nodeHasStyles( currentParentElement, styleNameSection, currentNode, foundMatch, breakNoMatch );
							
							currentParentWithinLoop = isMatch.parentElement
							currentParentDepth = isMatch.parentDepth
							
							if( isMatch.matching ) {
								var styleNameSectionArray:Array = styleNameSection.split(".").join(" .").split("#").join(" #").split(" ");
								var lastStylePart:String = styleNameSectionArray[styleNameSectionArray.length-1];
								var bonusPoints:uint = styleName.split(" ").join(".").split("#").join(".").split(".").length;
								if( lastStylePart.charAt(0) == "#" ){
									score += 3 + bonusPoints;
								}else if( lastStylePart.charAt(0) == "."){
									score += 2 + bonusPoints;
								}else{ // node style
									score += 1 + bonusPoints;
								}
								matchingSections++
								sectionMatch = true;
								firstNodeMatch = true;
							}else {
								if (currentParentWithinLoop && !(currentParentWithinLoop.parent is Element) )
									break styleSectionLoop;
							}
						}	
					}
					
					if(firstNodeMatch){
						if( score != 0 && matchingSections == styleNameArray.length ){
							styleMatch = true 
							matchingStyles.push( { score:score, styleName:styleName } )
							break styleSectionLoop
						}else if(currentParentWithinLoop && currentParentWithinLoop.parent && currentParentElement 
									&& currentParentElement.parent is Element){ 
							if( sectionMatch == true ){
								matchingSections++
								continue
							}else{
							
								var doesParentsHaveThisStyle:Object = nodeHasStyles( currentParentWithinLoop, styleNameSection, 
									currentParentWithinLoop.nodeXML, foundMatch, loopThroughParentsForMatch );
								currentParentElement = currentParentWithinLoop.parent as Element;
								currentNode = currentParentWithinLoop.nodeXML;
							
								if( doesParentsHaveThisStyle.matching ){
									if(i == 0){
										matchingStyles.push( { score:score, styleName:styleName } )
									}else{
										matchingSections++
										continue
									}
								}else{  // not a match
									break styleSectionLoop
								}
							}
						}else{ // not a match
							break styleSectionLoop
						}
					}
				}
			}
			/*
			var r:String = ""
			for each ( var s:* in matchingStyles){
				r += s.styleName + " " + s.score + ",   " 
			}
			if(r) // Log.debug(r, "\n", node.toXMLString(), "\n", "\n")
			*/
			
			// sort matched styles by there score
			var sorted:Array = matchingStyles.sortOn("score") //Array.DESCENDING

			// add inline styles to stylesheet after cleaning them
			if(node.@style.toString()){
				_styleSheet.setStyle("inline", cleanCSS( node.@style ) )
				sorted.push( { depth:1, score:100, styleName:"inline" } )
			}
			
			// condense into one style and apply as default style
			for each( var defaultItems:Object in sorted ) {
				var defaultStateName:Array = defaultItems.styleName.split(":").join(SEPARATOR+":").split(":");
				if( defaultStateName.length < 2 ) {
					var defaultObj:Object = _styleSheet.getStyle( defaultItems.styleName )
					for( var defaultProps:String in defaultObj ) {
						if( typeof(defaultObj[ defaultProps ]) == "object" ) {
							if( states[ DEFAULT ][ defaultProps ] == null ){ states[ DEFAULT ][ defaultProps ] = {}; }
							for( var objOrgProp:String in defaultObj[ defaultProps ] ) { 
								states[ DEFAULT ][ defaultProps ][ objOrgProp ] = defaultObj[ defaultProps ][ objOrgProp ]; 
							}
						}else { //  if( defaultObj[ defaultProps ] is String && defaultObj[ defaultProps ] != "[object Object]" )
							if( defaultObj[ defaultProps ] is String )
								states[ DEFAULT ][ defaultProps ] = 
								defaultObj[ defaultProps ].split( (SEPARATOR + "#") ).join("#").split( ( SEPARATOR + "." ) ).join(".");
							else
								states[ DEFAULT ][ defaultProps ] = defaultObj[ defaultProps ];
						}
					}
				}else{
					// create other states
					states[ defaultStateName[1] ] = {}
				}
			}
			
			// default styles
			var objs:Object = { 
				left:0, top:0, width:"100%", height:0, position:"auto", 
				background:{ type:"none", alpha:1 }, 
				border:{ type:"none", shape:"box", left:0, right:0, top:0, bottom:0 }, 
				margin:{ left:0, right:0, top:0, bottom:0 }, 
				padding:{ left:0, right:0, top:0, bottom:0 } };
				
			for( prop in objs ) {
				if( states[ DEFAULT ][ prop ] == null ){
					states[ DEFAULT ][ prop ] = objs[ prop ];
					continue;
				}
				if( typeof(objs[prop]) == "object" ){
					for( var baseObjProp:String in objs[prop] ) {
						if( !states[ DEFAULT ][ prop ] ){
							states[ DEFAULT ][ prop ] = objs[prop];
							continue;
						}
						if( !states[ DEFAULT ][ prop ][ baseObjProp ] )
							states[ DEFAULT ][ prop ][ baseObjProp ] = objs[ prop ][ baseObjProp ];
					}
				}
			}
				
			for each( var sortedItems1:Object in sorted ) {
				var orgStateName1:Array = sortedItems1.styleName.split(SEPARATOR+":").join(":").split(":");
				if( orgStateName1[1] ) states[ orgStateName1[1] ] = duplicateStyle( states[ DEFAULT ] );	
			}
			
			// Create other states objects based on defaults
			for each( var sortedItems:Object in sorted ) {
				var orgStateName:Array = sortedItems.styleName.split(SEPARATOR+":").join(":").split(":");
				if( orgStateName.length > 1 ) {
					var baseObj:Object = _styleSheet.getStyle( sortedItems.styleName )
					for( var sortedProp:String in baseObj){
						if( typeof( baseObj[ sortedProp ] ) == "object" ) {
							if( !states[ orgStateName[1] ][ sortedProp ] ){ states[ orgStateName[1] ][ sortedProp ] = {}; }
							for( var objProp:String in baseObj[ sortedProp ] ) { 
								states[ orgStateName[1] ][ sortedProp ][ objProp ] = baseObj[ sortedProp ][ objProp ]; 
							}
						}else{
							states[ orgStateName[1] ][ sortedProp ] = baseObj[ sortedProp ].split(SEPARATOR+"#").join("#").split(SEPARATOR+".").join(".")
						}
					}
				}
			}
			
			//// Log.debug("----------------------------------------------------------------------------")
			//// Log.debug(node.toXMLString())
			//toStyleString(states[DEFAULT]);
			//// Log.debug("----------------------------------------------------------------------------")
			return { style:states, appliedStyles:sorted };
		}
		
		private function doNodesClassStylesMatch(styleNameSection:String, classes:String=null):Boolean{ 
			if( classes ){ 
				for each( var className:String in classes.split(" ") ){ 
					if( styleNameSection == "." + className ){ 
						return true 
					} 
				} 
			} 
			return false 
		}

		private function nodeHasStyles( parentElement:Element, styleNameSection:String, node:XML, onMatch:Function, onNoMatch:Function, parentDepth:int=0 ) : Object 
		{	
			var nodeId:String = node.@id.toString();
			var nodeClass:String = node.@[CLASS].toString();
			var nodeName:String = node.localName();

			var styleNameArray:Array = styleNameSection.split(".").join(" .").split("#").join(" #").split(" ");
			
			var matchedParts:int = 0;
			var matchType:String = "none";
			
			if(styleNameArray[0] == "") 
				styleNameArray.shift()
			
			/*
			if(parentElement.nodeXML.children()[0] == node){
				// Log.debug(parentElement.nodeXML.children()[0].toXMLString(), "firstchild")
			}
			*/
			
			for each( var stylePart:String in styleNameArray ){
				
				if( stylePart != null && stylePart != "" ){
					if( node.@id.toString() && stylePart.charAt(0) == "#" && stylePart == "#" + nodeId){
						matchType = "id"
						matchedParts++
					}else if( node.@[CLASS].toString() && stylePart.charAt(0) == "." && doNodesClassStylesMatch( stylePart, nodeClass ) ){ 
						matchType = CLASS
						matchedParts++
					}else if( stylePart == node.localName() ){ 
						matchType = "node"
						matchedParts++
					}
				}
			}

			if( matchedParts > 0 && matchedParts >= styleNameArray.length ) {
				return onMatch( parentElement, styleNameSection, parentDepth )
			}else{
				return onNoMatch( parentElement, styleNameSection, parentDepth )
			}
			
			return { matching:false, parentElement:parentElement, parentDepth:parentDepth }
		}
		
		private function loopThroughParentsForMatch( parentElement:Element, stylePart:String, parentDepth:int ) : Object
		{
			if( parentElement.parent is Element ){
				parentElement = parentElement.parent as Element
				parentDepth++
				var result:Object = nodeHasStyles(parentElement, stylePart, parentElement.nodeXML, foundMatch, loopThroughParentsForMatch, parentDepth );
				return { matching:result.matching, parentElement:result.parentElement, parentDepth:result.parentDepth }
			}
			return { matching:false, parentElement:parentElement, parentDepth:parentDepth }
		}
		
		private function breakNoMatch( parentElement:Element, stylePart:String, parentDepth:int ) : Object
		{
			return { matching:false, parentElement:parentElement, parentDepth:parentDepth }
		}
		
		private function foundMatch( parentElement:Element, stylePart:String, parentDepth:int ) : Object
		{
			return { matching:true, parentElement:parentElement, parentDepth:parentDepth }
		}
		
		private function cleanCSS( style:String ):Object 
		{	
			var css:CSS = new CSS( _controller );
			css.parseCSS("inline{" + style + "}");
			return css.styleSheet.getStyle("inline");
		}
		
		// take out any references to things we can't parse or are defined differently than we would like them
		private function preparse( css:String ):String
		{
			// .split("OBJ(").join("obj(").split("style(").join("obj(")
			css = css.split("  ").join(" ").split("\t").join("").split(" :").join(SEPARATOR+":").split(": ").join(":") + "\n";

			// The standard CSS parser in ActionScript dosn't accept spaces in your style names. 
			css = cleanSpacesOutOfStyleNames( css );

			// the standard CSS parser in ActionScript doesn't accept currly braces but we use objects in some styles that need these, 
			// so we parse them out and replace them after the CSS is parsed
			//css = parseJSON( css );
			
			return css
		}
		
		private function cleanSpacesOutOfStyleNames(css:String):String
		{
			var cssChars:Array = css.split("}")
			for each( var part:String in cssChars){
				if( part.charAt(0) == ")" || part.charAt(1) == ")" ){
					continue; // these are objects not styles
				}else{
					var styleName:String = part.substring( 0, part.indexOf("{") + 2 );
					css = css.split(styleName).join( StringUtils.trim( styleName ).split(" ").join(SEPARATOR).split(":").join(SEPARATOR+":") );
				}
			}
			return css.split("}"+SEPARATOR).join("}").split(SEPARATOR+"{").join("{");
		}
		
		private function parse( css:StylesBase ) :StylesBase 
		{
			for each( var styleName:String in css.styleNames ) {
				var styleObject:Object = css.getStyle( styleName );
				_background = {};
				_border = {};
				_margin = {};
				_padding = {};
				for ( var propName:String in styleObject ) {
					parseProp( css, styleObject, propName, styleObject[propName], styleName )
				}
			}
			// loadFonts();
			return css; //traceStyleSheet(style)
		}
		
		private function parseProp( css:StylesBase, styleObject:Object, propName:String, value:*, styleName:String=null ) : Object
		{
			var populated:Boolean = false;
			var s:Object = {};
			mapLoop: for ( var mapProp:String in mapping ) {
				var props:Array = mapping[mapProp].props
				mapPropLoop: for each( var prop:String in props ) {
					if( propName == prop ) {

						if( styleName ) 
							s = css.getStyle(styleName);
							
						s[mapProp] = mapping[mapProp].method(mapProp, value, propName);

						if(styleName) 
							css.setStyle(styleName, s);

						populated = true;
						break mapLoop;
					}
				}
			}
			/*
			if( propName == "src" ){ 
				fonts.push( value.split('url(').join("").split(')').join("").split('"').join("").split(";").join("").split("'").join("") );
				populated = true;
			}
			*/
			if( !populated && styleName ){ // everything else
				s = css.getStyle(styleName);
				s[propName] = TypeUtils.cleanString( value );
				css.setStyle(styleName, s );
			}
			return s;
		}
		// _computedStyles.background.type
		private function cleanBackground( name:String, value:String, prop:String ) : Object
		{
			var loc_fill:Object;
			if( prop == "background" || prop == "backgroundColor" ){ 
				if( value.substr( 0, 2 ) == "url" ) { 
					_background.type = "image"; _background.url = value.substr( 4, (value.length-1) );
				}else if( value.indexOf( "gradient(") != -1 ){
					_background.gradient = gradient( value );
					_background.type = "gradient";
				}else if( value.indexOf( "random" ) != -1 ){
					_background.type = "solid"; // This will give it a random solid color
				}else{ 
					_background.color = TypeUtils.cleanString( value );
					_background.type = "solid"; 
				}
				loc_fill = _background;
			}else if( prop == "backgroundOpacity" ){
				_background.alpha = parseFloat( value ); 
				loc_fill = _background;
			}else if( prop == "backgroundPosition" ){
				var position:Array = value.split(" ")
				_background.x = parseFloat( position[0] ); 
				_background.y = parseFloat( position[1] ); 
				loc_fill = _background;
			}else if( prop == "backgroundRepeat" ){
				_background.repeat = value; 
				loc_fill = _background;
			}else if( prop == "backgroundRotation" ){
				_background.rotation = parseFloat( value ); 
				loc_fill = _background;
			}else if( prop == "backgroundScaleX" ){
				_background.scaleX = parseFloat( value ); 
				loc_fill = _background;
			}else if( prop == "backgroundScaleY" ){
				_background.scaleY = parseFloat( value ); 
				loc_fill = _background;
			}else if( prop == "backgroundSmooth" ){
				_background.smooth = TypeUtils.cleanString( value ); 
				loc_fill = _background;
			}else if( prop == "backgroundSize" ){
				var pos:Array = value.split(" ")
				_background.width = parseFloat( pos[0] ); 
				_background.height = parseFloat( pos[1] ); 
				loc_fill = _background;
			}else if( prop == "backgroundImage" ){
				_background.type = "image"; 
				if( value.toLowerCase() == "no-repeat" ){ _background.repeat = false; } else { _background.repeat = true; } 
				if( value.toLowerCase() == "smooth" ){ _background.smooth = true; } else { _background.smooth = false; } 
				if( value.indexOf( "url(") != -1 ) {
					_background.url = value.substr( value.indexOf( "url(") + 4, value.lastIndexOf( ")") - 1 ).split('"').join("").split(")").join("");
				}else if( value.indexOf( "gradient(") != -1 ){
					_background.gradient = gradient( value );
					_background.type = "gradient";
				}
				
				loc_fill = _background;
			}
			return loc_fill;
		}
		
		// Everyone likes to define gradients differently. We will try to simplify the adobe method
		// I would be fine with going with something else but webkits version is questionable
		// this is what we use gradient(linear,[#123456,#123456,#123456],[1,1,1],[0,200,255],[x,y,r],pad,rgb,0)
		// webkit: gradient(<type>, <point> [, <radius>]?, <point> [, <radius>]? [, <stop>]*)
		// mask-image: gradient(linear, left top, left bottom, from(rgba(0,0,0,1)), to(rgba(0,0,0,0)));
		// gradient(linear,[#123456,#123456,#123456],[1,1,1],[0,200,255],[x,y,r],pad,rgb,0)
		// beginGradientFill(type:String, colors:Array, alphas:Array, ratios:Array, matrix:Matrix = null, 
		// spreadMethod:String = "pad", interpolationMethod:String = "rgb", focalPointRatio:Number = 0)
		public function gradient( value:String ):Object
		{
			var result:Object = {};
			var array:Array = value.substr( value.indexOf( "gradient(") + 9, value.lastIndexOf( ")") - 1 ).split(
											'"').join("").split(")").join("").split(" ").join("").split(",");
			var props:Array = ["kind","colors","alphas","ratios","matrix","spreadMethod","interpolationMethod","focalPointRatio"];
			var inArray:Boolean = false;
			var count:int = 0;
			var args:Array = [];
			var argArray:Array;
			var item:String;

			for each( item in array){
				if( inArray && item.indexOf("]") == item.length - 1 ) {
					inArray = false;
					argArray.push( item.split("]").join("") );
					args.push( argArray );
				}else if( !inArray && item.charAt(0) == "[" ) {
					inArray = true;
					argArray = [ item.split("[").join("") ];
				}else if( inArray ){
					argArray.push(item);
				}else{
					args.push(item);
				}
				count++;
			}
			
			count = 0;
			
			for each( var arg:Object in args ) {
				result[props[count]] = arg;
				count++;
			}
			
			return result;
		}
		
		private function cleanBorder( name:String, value:String, prop:String ) : Object
		{
			var __border:Object = {};
			if( prop == "border" ){
				var parts:Array = value.split(" ");
				_border.weight = parseFloat( parts[0] ); 
				_border.type = parts[1]||"solid"; 
				_border.color = TypeUtils.cleanString( parts[2] );
			}else if( prop == "borderColor" ){
				_border.weight = 1; 
				_border.type = "solid"; 
				_border.color = TypeUtils.cleanString( value ); 
			}else if( prop == "borderRadius" ){
				_border.shape = "RoundRect";
				_border.radius = parseFloat( value );
			}else if( prop == "borderTopLeftRadius" ){
				_border.shape = "RoundRectComplex";
				_border.topLeftRadius = parseFloat( value );
			}else if( prop == "borderTopRightRadius" ){
				_border.shape = "RoundRectComplex";
				_border.topRightRadius = parseFloat( value );
			}else if( prop == "borderBottomLeftRadius" ){
				_border.shape = "RoundRectComplex";
				_border.bottomLeftRadius = parseFloat( value );
			}else if( prop == "borderBottomRightRadius" ){
				_border.shape = "RoundRectComplex";
				_border.bottomRightRadius = parseFloat( value );
			}else{
				_border[prop] = value;
			}
			return _border;
		}
		
		private function cleanMargin( name:String, value:String, prop:String ) : Object
		{
			if( prop == "margin" ){ 
				var p:Array = value.split(" ");
				if( p.length == 1 ) { 
					_margin.top = _margin.right = _margin.bottom = _margin.left = TypeUtils.cleanString( value );
				}else if( p.length == 2 ){
					_margin.top = _margin.bottom = TypeUtils.cleanString( p[0] );
					_margin.right = _margin.left = TypeUtils.cleanString( p[1] );
				}else{
					_margin.top = TypeUtils.cleanString( p[0] );
					_margin.right = TypeUtils.cleanString( p[1] );
					_margin.bottom = TypeUtils.cleanString( p[2] );
					_margin.left = TypeUtils.cleanString( p[3] );
				}	
			}
			else if( prop == "marginLeft" ){ _margin.left = TypeUtils.cleanString( value ); }
			else if( prop == "marginRight" ){ _margin.right = TypeUtils.cleanString( value );  }
			else if( prop == "marginTop" ){ _margin.top = TypeUtils.cleanString( value ); }
			else if( prop == "marginBottom" ){ _margin.bottom = TypeUtils.cleanString( value ); }
			return _margin;
		}
		private function cleanPadding( name:String, value:String, prop:String ) : Object
		{
			if( prop == "padding" ){ 
				var p:Array = value.split(" ");
				if( p.length == 1 ) {
					_padding.top = _padding.right = _padding.bottom = _padding.left = TypeUtils.cleanString( value );
				}else{
					_padding.top = parseFloat( p[0] );
					_padding.right = parseFloat( p[1] );
					_padding.bottom = parseFloat( p[2] );
					_padding.left = parseFloat( p[3] );
				}	
			}
			else if( prop == "paddingLeft" ) _padding.left = TypeUtils.cleanString( value );
			else if( prop == "paddingRight" ) _padding.right = TypeUtils.cleanString( value );
			else if( prop == "paddingTop" ) _padding.top = TypeUtils.cleanString( value );
			else if( prop == "paddingBottom" ) _padding.bottom = TypeUtils.cleanString( value );
			return _padding;
		}
		
		public function duplicateStyle( style:Object ) : Object
		{ // duplicate style to save clean values. This loop only goes two layers deep ( might be important later but fine now )
			var clean:Object = new Object();
			for( var prop:String in style ){
				if( typeof(style[ prop ]) == "object" ) {
					if( style[ prop ] is Array ) {
						clean[ prop ] = style[ prop ];
					}else{
						clean[ prop ] = new Object();
						for( var objProp:String in style[ prop ] ) {
							clean[ prop ][ objProp ] = style[ prop ][ objProp ];
						}
					}
				}else{
					clean[ prop ] = style[ prop ];
				}
			}
			return clean;
		}
		
		/**
		 *	Styles are parsed down to a nested styles object called states, you can trace this out with this.
		 */
		//ENVIRONMENT::DEBUG {
			public function toStyleString( states:Object ) : String 
			{
				var result:String = new String();
				for( var p:String in states ){
					if( typeof(states[ p ]) == "object" ) {
						var style:Object = states[ p ]
						result += p + " {" + "\n";
						for ( var propName:String in style ) {
							if(typeof(style[ propName ]) == "object"){
								result += "\t"+ propName +": {";
								for ( var prop:String in style[ propName ] )
									result += " " + prop + ": " + style[ propName ][ prop ] + ",";
								result = result.substr(0, -1)
								result += " };\n";
							}else
								result += "\t" + propName + ": " + style[ propName ] + ";\n";
						}
						result += "}\n";
					}else{
						result += p + " : " + states[ p ] + ";\n";
					}
				}
				// Log.debug(result)
				return result
			}
		//}
	}
}

import flash.text.*;
import framework.view.html.*;
/**
 *  StylesBase is just an extenstion of StyleSheet, it transforms any needed html elements into the actionscript equivalents 
 *	and saves the cleaned, processed and raw versions of itself.
 */
class StylesBase extends StyleSheet
{
	private var tempSheet:StyleSheet = new StyleSheet();
	public var tailSortedStyles:Object = {};

	public function StylesBase()
	{
		super()
	}
	
	/**
	 *	This method is overridden so that we can extend css's functionality
	 *	@inheritDoc
	 */
	override public function transform( s:Object ) : TextFormat 
	{ 
		var f:TextFormat = super.transform( s );
      	
		for ( var p:String in s ) {
			switch ( p ) {
				case "lineHeight": 
					f.leading = parseFloat( s[ p ] ); 
					break;
            	case "blockIndent": 
					f.blockIndent = parseFloat( s[ p ] ); 
					break;
           		case "indent": 
					f.indent = parseFloat( s[ p ] ); 
					break;
				case "leftMargin": 
					f.leftMargin = parseFloat( s[ p ] ); 
					break;
				case "rightMargin": 
					f.rightMargin = parseFloat( s[ p ] ); 
					break;
				case "tabStops": // tab-stops: 0,15,30,45;
					f.tabStops = String( s[ p ] ).split( "," ); 
					break;
            	case "bullet": 
					f.bullet = ( s[ p ] == "true" ); 
					break;
				case "letterSpacing": 
					f.letterSpacing = parseFloat( s[ p ] );
					break;
				case "target": 
					f.target = s[ p ]; 
					break;
				case "url": 
					f.url = s[ p ]; 
					break;
         	}
     	}
     	return f;
 	}
 	
 	override public function clear():void {
 		super.clear();
 		
		for(var index:String in tailSortedStyles) {
 			tailSortedStyles[index] = undefined;
 		}
 	}
 	
 	override public function setStyle(styleName:String, styleObject:Object):void 
	{
 		super.setStyle(styleName, styleObject);

	 	var suffix:String = hashSuffixOf(styleName);
 		if (styleObject) { // add in the style name to the hash
 			if (tailSortedStyles[suffix] == undefined) {
				tailSortedStyles[suffix] = [styleName];
			} else if (tailSortedStyles[suffix].indexOf(styleName) == -1) {
				tailSortedStyles[suffix].push(styleName);
			}
 		} else if (tailSortedStyles[suffix] != undefined) { // remove the style name from the hash
			if (tailSortedStyles[suffix].length == 1) {
				tailSortedStyles[suffix].pop();
				tailSortedStyles[suffix] = undefined;	 					
				} else {
 				var index2:int = tailSortedStyles[suffix].indexOf(styleName);
				if (index2 > -1) {
					tailSortedStyles[suffix].splice(index2, 1);
				}
			}
 		}
 	}
 	
 	/**
	 *	This method is overridden so that we can append new styles to the tailIndexedStyle object.
	 *	@inheritDoc
	 */
	override public function parseCSS( cssText:String ) : void 
	{ 
		
		super.parseCSS(cssText);
		
		// if (TAIL_SEARCH_ENABLED ) { //  && cssText.indexOf("inline{")
		// grab the style names from cssText
		tempSheet.parseCSS(cssText);
		var names:Array = tempSheet.styleNames;
		var styleName:String, suffix:String;
		
		for (var i:int = 0; i < names.length; i++) {
			
			styleName = names[i];
			
			// add each new style to the tail-sorted style list
			
			suffix = hashSuffixOf(styleName);
			
			if (tailSortedStyles[suffix] == undefined) {
				tailSortedStyles[suffix] = [styleName];
			} else if (tailSortedStyles[suffix].indexOf(styleName) == -1) {
				tailSortedStyles[suffix].push(styleName);
			}
		}
		
		// wipe clean the temp style sheet
		tempSheet.clear();
	}
	
	private static function hashSuffixOf(styleName:String):String {
		
		if (styleName.lastIndexOf(CSS.SEPARATOR+":") != -1) styleName = styleName.substr(0, styleName.lastIndexOf(CSS.SEPARATOR+":"));
		if (styleName.lastIndexOf(":") != -1) styleName = styleName.substr(0, styleName.lastIndexOf(":"));
		
		styleName = styleName.substr(styleName.lastIndexOf(CSS.SEPARATOR) + 1);
		
		var lastPound:int = styleName.lastIndexOf("#");
		var lastDot:int = styleName.lastIndexOf(".");
		
		if (lastPound > -1 && lastPound > lastDot)
			styleName = styleName.substr(lastPound);
		else if (lastDot > -1 && lastDot > lastPound)
			styleName = styleName.substr(lastDot);
		
		return styleName;
	}
}