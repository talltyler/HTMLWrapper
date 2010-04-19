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
package framework.view.html.tags 
{
	import flash.external.ExternalInterface;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.display.Bitmap;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.engine.*;
	
	import framework.controller.Controller;
	import framework.controller.SWFAddress;
	import framework.debug.Log;
	import framework.net.Assets;
	import framework.net.Asset;
	import framework.view.html.Document;
	import framework.view.html.Element;
	import framework.view.html.Navigator;
	import framework.view.html.Parser;
	import framework.view.html.Window;
	
	
	public class BasicTags 
	{
		private const INLINE:String = "inline";
		private const BLOCK:String = "block";
		private const TABLE:String = "table";
		private const TABLE_CELL:String = "table-cell";
		private const TABLE_ROW:String = "table-row";
		
		private var _window:Window;
		private var _navigator:Navigator;
		private var _controller:Controller;
		private var _linksLoading:Array = [];
		private var _progressFunctions:Object = {};
		private var _completeFunctions:Object = {};
		
		public function BasicTags( controller:Controller )
		{
			super();
			
			_controller = controller;
		}
		
		public function element( document:Document, target:Element, xml:XML, display:String ):Object
		{
			if( _navigator == null )
				_navigator = document.window.navigator;
			if( _window == null )
				_window = document.window;
			var element:Element = _navigator.pools.retrieve( Element );
			var style:Object = _window.css.getElementStyles( xml, target ).style;
			element.create( { controller:_controller, document:document, element:target, xml:xml, styles:style } );
			if( element.style.display == null ) 
				element.style.display = display;
			return {element:element};
		}
		
		/**
		 *	Specifies any character data
		 */
		public function cdata( document:Document, target:Element, xml:XML ):void
		{
			target.addCData( xml.toXMLString() );
		}
		
		/**
		 *		
		 * &lt;a&gt;	Specifies a hyperlink
		 *	http://www.w3schools.com/tags/html5_a.asp
		 *	
		 *	Standard Attributes
		 *		class, id, ref, tabindex, title,  -- dir, draggable, irrelevant, , template, 
		 *	
		 *	Event Attributes
		 *		onabort, onbeforeunload, onblur, onchange, onclick, oncontextmenu, ondblclick, ondrag, ondragend, ondragenter, ondragleave, ondragover, ondragstart, ondrop, onerror, onfocus, onkeydown, onkeypress, onkeyup, onload, onmessage, onmousedown, onmousemove, onmouseover, onmouseout, onmouseup, onmousewheel, onresize, onscroll, onselect, onsubmit, onunload
		 *	
		 *	Attributes
		 *	href		URL	The target URL of the link	4/5
		 *	name		section_name	Deprecated. Names an anchor. Use this attribute to create a bookmark in a document. Not supported. Use id instead.	4	 
		 *	rel			[alternate,archives,author,bookmark,contact,external,feed,first,help,icon,index,last,license,next,nofollow,noreferrer,pingback,prefetch,prev,search,stylesheet,sidebar,tag,up]	Specifies the relationship between the current document and the target URL. Use only if the href attribute is present
		 *	target		[_blank (the target URL will open in a new window),_parent(the target URL will open in the parent document),_self(the target URL will open in the same document as it was clicked),_top(the target URL will open in the full body of the window)]	Where to open the target URL. Use only if the href attribute is present 4/5
		 */
		public function a( document:Document, target:Element, xml:XML ):Object
		{
			var obj:Object = element( document, target, xml, INLINE );
			if( xml.@href.toString() ){
				obj.element.addEventListener( MouseEvent.CLICK, 
					function( event:Event ):void {
						redirect( document, xml.@href.toString(), xml.@target.toString(), xml.@rel.toString() ) 
					}
				);
				// we need to have a way to delete these before they are saved
				// document.anchors.push( { name:xml.@name.toString()||obj.element.name, href:xml.@href.toString(), target:xml.@target.toString() } ); // offsetLeft:0, offsetParent:"parent", offsetTop:0, x:0, y:0
			}
			obj.element.buttonMode = true;
			return obj;
		}
		
		/**
		 * @private
		 * Called internally to load a new html page and load it into the page or if it's an external page navigate to that
		 * @param document Document 
		 * @param href String 
		 * @param target String 
		 * @param rel String 
		 */
		private function redirect( document:Document, href:String, target:String=null, rel:String=null ):void
		{
			target = (target||"").toLowerCase();
			rel = (rel||"").toLowerCase();

			if( ( rel == "internal" && target != "" ) 
			 || ( ( _controller.deeplinking == Controller.DEEPLINKING_OFF ) // || _controller.deeplinking == Controller.TEMP_DISABLE
			   && ( target != "_blank" || target != "_self" || target != "_parent" || target != "_top" ) ) ){
				
				var element:Element = document.getElementById( target );
				if( element == null ) {
					// element = document; // document isn't an element anymore
				}
				if( document.cache.assets[ href ] == null ){
					var asset:Asset = document.assets.add( href );
					asset.addEventListener(Event.COMPLETE, onRedirectLoad );
					asset.userData = element;
				}else{
					element.innerHTML = document.cache.assets[ href ];
				}
			}else if( target == "_blank" || target == "_self" || target == "_parent" || target == "_top" ){
				navigateToURL(new URLRequest(href), target);
			}else{
				SWFAddress.setValue(href.split("#")[1]);
			}
		}
		
		/**
		 *  @private
		 *  After a page is loaded from the redirect method it is told to render inside of the document here.
		 *  @param event Event 
		 */
		private function onRedirectLoad(event:Event):void
		{
			var asset:Asset = event.target as Asset;
			var element:Element = asset.userData as Element;
			element.innerHTML = asset.data;
		}

		/**
		 *	&lt;abbr&gt;	Specifies an abbreviation
		 *	http://www.w3schools.com/tags/html5_abbr.asp
		 *	
		 *	Standard Attributes
		 *		class, contenteditable, contextmenu, dir, draggable, id, irrelevant, lang, ref, registrationmark, tabindex, template, title
		 *	
		 *	Event Attributes
		 *		onabort, onbeforeunload, onblur, onchange, onclick, oncontextmenu, ondblclick, ondrag, ondragend, ondragenter, ondragleave, ondragover, ondragstart, ondrop, onerror, onfocus, onkeydown, onkeypress, onkeyup, onload, onmessage, onmousedown, onmousemove, onmouseover, onmouseout, onmouseup, onmousewheel, onresize, onscroll, onselect, onsubmit, onunload
		 */
		/*
		public function abbr( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, INLINE ); // Passed through to the span tag because they are rendered the same
		}*/
		
		/**
		 *	&lt;address&gt;	Specifies an address element
		 *	http://www.w3schools.com/tags/html5_address.asp
		 *	
		 *	The &lt;address&gt; tag should NOT be used to describe a postal address, unless it is a part of the contact information.
		 *	The address usually renders in italic. Most browsers will add a line break before and after the address element.
		 *	
		 *	Standard Attributes
		 *		class, contenteditable, contextmenu, dir, draggable, id, irrelevant, lang, ref, registrationmark, tabindex, template, title
		 *	
		 *	Event Attributes
		 *		onabort, onbeforeunload, onblur, onchange, onclick, oncontextmenu, ondblclick, ondrag, ondragend, ondragenter, ondragleave, ondragover, ondragstart, ondrop, onerror, onfocus, onkeydown, onkeypress, onkeyup, onload, onmessage, onmousedown, onmousemove, onmouseover, onmouseout, onmouseup, onmousewheel, onresize, onscroll, onselect, onsubmit, onunload
		 *//*
		public function address( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, INLINE ); // Passed through to the span tag because they are rendered the same
		}*/

		/**
		 *	&lt;area&gt;	Specifies an area inside an image map	 
		 *	http://www.w3schools.com/tags/html5_area.asp
		 *	This element is always nested inside a &lt;map&gt; tag.
		 *	
		 *	Standard Attributes
		 *		class, contenteditable, contextmenu, dir, draggable, id, irrelevant, lang, ref, registrationmark, tabindex, template, title
		 *	
		 *	Event Attributes
		 *		onabort, onbeforeunload, onblur, onchange, onclick, oncontextmenu, ondblclick, ondrag, ondragend, ondragenter, ondragleave, ondragover, ondragstart, ondrop, onerror, onfocus, onkeydown, onkeypress, onkeyup, onload, onmessage, onmousedown, onmousemove, onmouseover, onmouseout, onmouseup, onmousewheel, onresize, onscroll, onselect, onsubmit, onunload
		 *	
		 *	Attributes
		 *	alt			Specifies an alternate text for the area. Required if the alt attribute is present. Use ONLY if the alt attribute is present.	text	4/5
		 *	coords		Specifies the coordinates for the clickable area 4/5
		 *		if(shape="rect"){ coords="left,top,right,bottom" }
		 *		if(shape="circ"){ coords="centerx,centery,radius" }
		 *		if(shape="poly"){ coords="x1,y1,x2,y2,..,xn,yn" }
		 *	href		Specifies the target URL of the area	URL	4/5
		 *	hreflang	Specifies the base language of the target URL. Use only if the href attribute is present	language_code	4	5
		 *	nohref		true
		 *	false		Deprecated. Excludes an area from the image map	4	 
		 *	media		media query	Specifies the mediatype of the target URL. Default value: all. Use only if the href attribute is present	 	5
		 *	ping		Space separated list of URLs that get notified when a user follows the hyperlink. Use only if the href attribute is present	URL	 	5
		 *	rel			[alternate,archives,author,bookmark,contact,external,feed,first,help,icon,index,last,license,next,nofollow,noreferrer,pingback,prefetch,prev,search,stylesheet,sidebar,tag,up]	Specifies the relationship between the current document and the target URL. Use only if the href attribute is present	 	5
		 *	shape		Defines the shape of the area	 [rect,rectangle,circ,circle,poly,polygon]	4/5
		 *	target		Where to open the target URL.	4/5
		 *		_blank - the target URL will open in a new window
		 *		_self - the target URL will open in the same frame as it was clicked
		 *		_parent - the target URL will open in the parent frameset
		 *		_top - the target URL will open in the full body of the window
		 *	type		mime_type	Specifies the MIME (Multipurpose Internet Mail Extensions) type of the target URL. Use only if the href attribute is present	 	5
		 *	
		 *//*
		public function area( document:Document, target:Element, xml:XML ):void
		{
			// Log.info("area", xml.toXMLString())
		}*/

		/**
		 *	&lt;article&gt;	Specifies an article	NEW
		 *	http://www.w3schools.com/tags/html5_article.asp
		 *	The external content could be a news-article from an external provider, or a text from a web log (blog), or a text from a forum, or any other content from an external source.
		 *	
		 *	Standard Attributes
		 *		class, contenteditable, contextmenu, dir, draggable, id, irrelevant, lang, ref, registrationmark, tabindex, template, title
		 *	
		 *	Event Attributes
		 *		onabort, onbeforeunload, onblur, onchange, onclick, oncontextmenu, ondblclick, ondrag, ondragend, ondragenter, ondragleave, ondragover, ondragstart, ondrop, onerror, onfocus, onkeydown, onkeypress, onkeyup, onload, onmessage, onmousedown, onmousemove, onmouseover, onmouseout, onmouseup, onmousewheel, onresize, onscroll, onselect, onsubmit, onunload
		 */
		public function article( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, BLOCK );
		}
		
		/**
		 *	&lt;aside&gt;	The &lt;aside&gt; tag defines some content aside from the article it is placed in. The aside content should be related to the article's content.
		 *	http://www.w3schools.com/tags/html5_aside.asp
		 *	
		 *	Standard Attributes
		 *		class, contenteditable, contextmenu, dir, draggable, id, irrelevant, lang, ref, registrationmark, tabindex, template, title
		 *	
		 *	Event Attributes
		 *		onabort, onbeforeunload, onblur, onchange, onclick, oncontextmenu, ondblclick, ondrag, ondragend, ondragenter, ondragleave, ondragover, ondragstart, ondrop, onerror, onfocus, onkeydown, onkeypress, onkeyup, onload, onmessage, onmousedown, onmousemove, onmouseover, onmouseout, onmouseup, onmousewheel, onresize, onscroll, onselect, onsubmit, onunload
		 */
		public function aside( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, BLOCK );
		}

		/**
		 *	&lt;audio&gt;	Specifies sound content	NEW
		 *	http://www.w3schools.com/tags/html5_audio.asp
		 *	You can write text inside the start and end audio tags, to show older browser that they do not support this tag.
		 *	
		 *	Standard Attributes
		 *		class, contenteditable, contextmenu, dir, draggable, id, irrelevant, lang, ref, registrationmark, tabindex, template, title
		 *	
		 *	Event Attributes
		 *		onabort, onbeforeunload, onblur, onchange, onclick, oncontextmenu, ondblclick, ondrag, ondragend, ondragenter, ondragleave, ondragover, ondragstart, ondrop, onerror, onfocus, onkeydown, onkeypress, onkeyup, onload, onmessage, onmousedown, onmousemove, onmouseover, onmouseout, onmouseup, onmousewheel, onresize, onscroll, onselect, onsubmit, onunload
		 *	
		 *	Attributes
		 *	autoplay	true | false	If set to true, the audio will start playing as soon as it is ready.
		 *	controls	true | false	If set to true, the user is shown some controls, such as a play button.
		 *	end			numeric value	Defines where in the audio stream the player should stop playing. By default, it plays to the end.
		 *	loopend		numeric value	Defines where in the audio stream the loop should stop, before jumping to the start of the loop. Default is the end attribute's value.
		 *	loopstart	numeric value	Defines where in the audio stream the loop should start. Default is the start attribute's value.
		 *	playcount	numeric value	Defines how many times the audio should be played. Default is 1.
		 *	src			url	 Defines the URL of the audio to play
		 *	start		numeric value	Defines where in the audio stream the player should start playing. By default, it plays from the beginning.
		 */
		/*
		public function audio( document:Document, target:Element, xml:XML ):void
		{
			var audio:AudioTag = new AudioTag();
			audio.create( {document:document, element:target, xml:xml} );
			audio.style.display = BLOCK;
		}*/

		/**
		 *	&lt;b&gt;	Specifies bold text	 
		 *	http://www.w3schools.com/tags/html5_b.asp
		 *	
		 *	Standard Attributes
		 *		class, contenteditable, contextmenu, dir, draggable, id, irrelevant, lang, ref, registrationmark, tabindex, template, title
		 *	
		 *	Event Attributes
		 *		onabort, onbeforeunload, onblur, onchange, onclick, oncontextmenu, ondblclick, ondrag, ondragend, ondragenter, ondragleave, ondragover, ondragstart, ondrop, onerror, onfocus, onkeydown, onkeypress, onkeyup, onload, onmessage, onmousedown, onmousemove, onmouseover, onmouseout, onmouseup, onmousewheel, onresize, onscroll, onselect, onsubmit, onunload
		 */
		public function b( document:Document, target:Element, xml:XML ):Object
		{
			var obj:Object = element( document, target, xml, INLINE );
			obj.element.style.fontWeight = "bold";
			return obj;
		}
		
		/**
		 *	&lt;base&gt;	Specifies a base URL for all the links in a page	 
		 *	http://www.w3schools.com/tags/html5_base.asp
		 *	
		 *	The &lt;base&gt; tag must go inside the head element.
		 *	Maximum one &lt;base&gt; element in a document.
		 *	
		 *	Attributes
		 *	href	URL	Specifies the URL to use as the base URL for links in the page	4	5
		 *	target	
		 *		_top	Where to open all the links on the page. This attribute can be overridden by using the target attribute in each link.
		 *		_blank - all the links will open in new windows
		 *		_self - all the links will open in the same frame they where clicked
		 *		_parent - all the links will open in the parent frameset
		 *		_top - all the links will open in the full body of the window
		 *	
		 */
		public function base( document:Document, target:Element, xml:XML ):void
		{
			// Log.info("base", xml.toXMLString())
		}

		/**
		 *	&lt;bdo&gt;	Specifies the direction of text display	 
		 *	http://www.w3schools.com/tags/html5_bdo.asp
		 *	
		 *	Attributes
		 *	dir	[ltr,rtl]	Defines the text direction. This attribute is required	4/5
		 *	
		 *	Standard Attributes
		 *		class, contenteditable, contextmenu, dir, draggable, id, irrelevant, lang, ref, registrationmark, tabindex, template, title
		 *	
		 *	Event Attributes
		 *		onabort, onbeforeunload, onblur, onchange, onclick, oncontextmenu, ondblclick, ondrag, ondragend, ondragenter, ondragleave, ondragover, ondragstart, ondrop, onerror, onfocus, onkeydown, onkeypress, onkeyup, onload, onmessage, onmousedown, onmousemove, onmouseover, onmouseout, onmouseup, onmousewheel, onresize, onscroll, onselect, onsubmit, onunload
		 *//*
		public function bdo( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, INLINE ); // Passed through the span tag because they are rendered the same.
		}*/
		
		/**
		 *	&lt;blockquote&gt;	Specifies a long quotation	 
		 *	http://www.w3schools.com/tags/html5_blockquote.asp
		 *	The blockquote element should only be used for quotes from anothe source.
		 *	
		 *	Attributes
		 *	cite	URL	URL of the quote, if it is taken from the web	4	5
		 *	
		 *	Standard Attributes
		 *		class, contenteditable, contextmenu, dir, draggable, id, irrelevant, lang, ref, registrationmark, tabindex, template, title
		 *	
		 *	Event Attributes
		 *		onabort, onbeforeunload, onblur, onchange, onclick, oncontextmenu, ondblclick, ondrag, ondragend, ondragenter, ondragleave, ondragover, ondragstart, ondrop, onerror, onfocus, onkeydown, onkeypress, onkeyup, onload, onmessage, onmousedown, onmousemove, onmouseover, onmouseout, onmouseup, onmousewheel, onresize, onscroll, onselect, onsubmit, onunload
		 */
		public function blockquote( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, BLOCK );
		}

		/**
		 *	&lt;body&gt;	Specifies the body element	
		 *	http://www.w3schools.com/tags/html5_body.asp
		 *	
		 *	Standard Attributes
		 *		class, contenteditable, contextmenu, dir, draggable, id, irrelevant, lang, ref, registrationmark, tabindex, template, title
		 *	
		 *	Event Attributes
		 *		onabort, onbeforeunload, onblur, onchange, onclick, oncontextmenu, ondblclick, ondrag, ondragend, ondragenter, ondragleave, ondragover, ondragstart, ondrop, onerror, onfocus, onkeydown, onkeypress, onkeyup, onload, onmessage, onmousedown, onmousemove, onmouseover, onmouseout, onmouseup, onmousewheel, onresize, onscroll, onselect, onsubmit, onunload
		 */
		public function body( document:Document, target:Element, xml:XML ):Object
		{
			var obj:Object = element( document, target, xml, BLOCK );
			obj.element.style.width = obj.element.style.height = "100%";
			obj.element.style.background.alpha = 0;
			return obj;
		}

		/**
		 *	&lt;br&gt;	Inserts a single line break	 
		 *	http://www.w3schools.com/tags/html5_br.asp
		 *	Use the &lt;br&gt; tag to enter blank lines, not to separate paragraphs.
		 *	
		 *	Standard Attributes
		 *		class, contenteditable, contextmenu, dir, draggable, id, irrelevant, lang, ref, registrationmark, tabindex, template, title
		 *	
		 *	Event Attributes
		 *		onabort, onbeforeunload, onblur, onchange, onclick, oncontextmenu, ondblclick, ondrag, ondragend, ondragenter, ondragleave, ondragover, ondragstart, ondrop, onerror, onfocus, onkeydown, onkeypress, onkeyup, onload, onmessage, onmousedown, onmousemove, onmouseover, onmouseout, onmouseup, onmousewheel, onresize, onscroll, onselect, onsubmit, onunload
		 */
		public function br( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, BLOCK );
		}
		
		/**
		 *	&lt;canvas&gt;	The &lt;canvas&gt; tag defines graphic, such as graphs or other images. NEW
		 *	http://www.w3schools.com/tags/html5_canvas.asp
		 *	
		 *	You can write text between the start and end tags, to show older browser that they do not support this tag.
		 *	The &lt;canvas&gt; tag is only a container for graphics, you must use a script to actually paint graphics.
		 *	Some browsers already supports the &lt;canvas&gt; tag, like Firefox and Opera.
		 *		var context = canvas.getContext('2d');
		 *		context.fillRect(0,0,50,50);
		 *		canvas.setAttribute('width', '300'); // clears the canvas
		 *		context.fillRect(0,100,50,50);
		 *		canvas.width = canvas.width; // clears the canvas
		 *		context.fillRect(100,0,50,50); // only this square remains
		 *	
		 *	Attributes
		 *	height		pixels	Sets the height of the canvas
		 *	width		pixels	Sets the width of the canvas
		 */
		public function canvas( document:Document, target:Element, xml:XML ):Object
		{
			var obj:Object = element( document, target, xml, BLOCK );
			return obj;
		}
		//&lt;caption&gt;	Specifies a table caption	 
		//http://www.w3schools.com/tags/html5_caption.asp
		public function caption( document:Document, target:Element, xml:XML ):void
		{
			// Log.info("caption", xml.toXMLString())
		}
		//&lt;cite&gt;	Specifies a citation	 
		//http://www.w3schools.com/tags/html5_cite.asp
		public function cite( document:Document, target:Element, xml:XML ):void
		{
			// Log.info("cite", xml.toXMLString())
		}
		//&lt;code&gt;	Specifies computer code text	 
		//http://www.w3schools.com/tags/html5_code.asp
		public function code( document:Document, target:Element, xml:XML ):Object
		{
			var obj:Object = element( document, target, xml, INLINE );
			obj.style.fontFace = "_typewriter";
			obj.style.digitWidth = DigitWidth.TABULAR;
			return obj;
		}
		//&lt;col&gt;	Specifies attributes for table columns 	 
		//http://www.w3schools.com/tags/html5_col.asp
		public function col( document:Document, target:Element, xml:XML ):void
		{
			// Log.info("col", xml.toXMLString())
		}
		//&lt;colgroup&gt;	Specifies groups of table columns	 
		//http://www.w3schools.com/tags/html5_colgroup.asp
		public function colgroup( document:Document, target:Element, xml:XML ):void
		{
			// Log.info("colgroup", xml.toXMLString())
		}
		//&lt;command&gt;	Specifies a command	NEW
		//http://www.w3schools.com/tags/html5_command.asp
		public function command( document:Document, target:Element, xml:XML ):void
		{
			// Log.info("command", xml.toXMLString())
		}
		//&lt;datagrid&gt;	Specifies data in a tree-list	NEW
		//http://www.w3schools.com/tags/html5_datagrid.asp
		public function datagrid( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, TABLE );
		}
		//&lt;datalist&gt;	Specifies an "autocomplete" dropdown list	NEW
		//http://www.w3schools.com/tags/html5_datalist.asp
		public function datalist( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, TABLE );
		}
		//&lt;dd&gt;	Specifies a definition description	 
		//http://www.w3schools.com/tags/html5_dd.asp
		public function dd( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, TABLE_CELL );
		}
		//&lt;del&gt;	Specifies deleted text	 
		//http://www.w3schools.com/tags/html5_del.asp
		public function del( document:Document, target:Element, xml:XML ):void
		{
			// Log.info("del", xml.toXMLString())
		}
		//&lt;details&gt;	Specifies details of an element	NEW
		//http://www.w3schools.com/tags/html5_details.asp
		public function details( document:Document, target:Element, xml:XML ):void
		{
			// Log.info("details", xml.toXMLString())
		}
		//&lt;dialog&gt;	Specifies a dialog (conversation)	NEW
		//http://www.w3schools.com/tags/html5_dialog.asp
		public function dialog( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, BLOCK );
		}
		//&lt;dfn&gt;	Defines a definition term	 
		//http://www.w3schools.com/tags/html5_dfn.asp
		/*public function dfn( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, INLINE ); // Passed through the span tag because they are rendered the same.
		}*/
		//&lt;div&gt;	Specifies a section in a document	 
		//http://www.w3schools.com/tags/html5_div.asp
		public function div( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, BLOCK );
		}
		//&lt;dl&gt;	Specifies a definition list	 
		//http://www.w3schools.com/tags/html5_dl.asp
		public function dl( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, TABLE );
		}
		//&lt;dt&gt;	Specifies a definition term	 
		//http://www.w3schools.com/tags/html5_dt.asp
		public function dt( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, TABLE_CELL );
		}
		//&lt;em&gt;	Specifies emphasized text 	 
		//http://www.w3schools.com/tags/html5_em.asp
		public function em( document:Document, target:Element, xml:XML ):Object
		{
			var obj:Object = element( document, target, xml, INLINE );
			obj.element.style.fontStyle = "italic";
			return obj;
		}
		//&lt;embed&gt;	Specifies external application or interactive content	NEW
		//http://www.w3schools.com/tags/html5_embed.asp
		public function embed( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, BLOCK );
		}
		//&lt;eventsource&gt;	Specifies a target for events sent by a server	NEW
		//http://www.w3schools.com/tags/html5_eventsource.asp
		public function eventsource( document:Document, target:Element, xml:XML ):void
		{
			// Log.info("eventsource", xml.toXMLString())
		}
		//&lt;fieldset&gt;	Specifies a fieldset	 
		//http://www.w3schools.com/tags/html5_fieldset.asp
		public function fieldset( document:Document, target:Element, xml:XML ):void
		{
			// Log.info("fieldset", xml.toXMLString())
		}
		//&lt;figure&gt;	Specifies a group of media content, and their caption	NEW
		//http://www.w3schools.com/tags/html5_figure.asp
		public function figure( document:Document, target:Element, xml:XML ):void
		{
			// Log.info("figure", xml.toXMLString())
		}
		//&lt;footer&gt;	Specifies a footer for a section or page	NEW
		//http://www.w3schools.com/tags/html5_footer.asp
		public function footer( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, BLOCK );
		}
		// FORM TAG IS INSIDE OF FormTags.as
		
		//&lt;h1&gt;	 Specifies a heading level 1	 
		//http://www.w3schools.com/tags/html5_h1.asp
		public function h1( document:Document, target:Element, xml:XML ):Object
		{
			var obj:Object = element( document, target, xml, BLOCK );
			obj.element.style.fontSize = 22;
			obj.element.style.fontWeight = "bold";
			return obj;
		}
		//&lt;h2&gt;	 Specifies a heading level 2	 
		//http://www.w3schools.com/tags/html5_h2.asp
		public function h2( document:Document, target:Element, xml:XML ):Object
		{
			var obj:Object = element( document, target, xml, BLOCK );
			obj.element.style.fontSize = 20;
			obj.element.style.fontWeight = "bold";
			return obj;
		}
		//&lt;h3&gt;	 Specifies a heading level 3	 
		//http://www.w3schools.com/tags/html5_h3.asp
		public function h3( document:Document, target:Element, xml:XML ):Object
		{
			var obj:Object = element( document, target, xml, BLOCK );
			obj.element.style.fontSize = 18;
			obj.element.style.fontWeight = "bold";
			return obj;
		}
		//&lt;h4&gt;	 Specifies a heading level 4	 
		//http://www.w3schools.com/tags/html5_h4.asp
		public function h4( document:Document, target:Element, xml:XML ):Object
		{
			var obj:Object = element( document, target, xml, BLOCK );
			obj.element.style.fontSize = 16;
			obj.element.style.fontWeight = "bold";
			return obj;
		}
		//&lt;h5&gt;	 Specifies a heading level 5	 
		//http://www.w3schools.com/tags/html5_h5.asp
		public function h5( document:Document, target:Element, xml:XML ):Object
		{
			var obj:Object = element( document, target, xml, BLOCK );
			obj.element.style.fontSize = 14;
			obj.element.style.fontWeight = "bold";
			return obj;
		}
		//&lt;h6&gt;	 Specifies a heading level 6	 
		//http://www.w3schools.com/tags/html5_h6.asp
		public function h6( document:Document, target:Element, xml:XML ):Object
		{
			var obj:Object = element( document, target, xml, BLOCK );
			obj.element.style.fontSize = 12;
			obj.element.style.fontWeight = "bold";
			return obj;
		}
		//&lt;head&gt;	Specifies information about the document	 
		//http://www.w3schools.com/tags/html5_head.asp
		public function head( document:Document, target:Element, xml:XML ):Object
		{
			document.parser.paused = true;

			for each( var node:XML in xml.children()) {
				if( node.localName() == "link" ){
					link( document, target, node );
				}
				if( node.localName() == "title" ){
					title( document, target, node );
				}
			}
			
			if( _linksLoading.length > 0 )
				_controller.assets.load().addEventListener(Event.COMPLETE, onHeadLoaded);
			else
				document.parser.paused = false;
			
			return {}
		}
		private function onHeadLoaded(event:Event):void
		{
			var styles:String
			var document:Document
			for each( var link:Object in _linksLoading ) {
				if( styles == null ) {
					styles = link.document.window.styles;
					document = link.document;
				}
				if( link.rel.toLowerCase() == "stylesheet" ) {
					styles += _controller.assets.fetch( link.href );
					// var styleSheet:StyleSheet = new StyleSheet( link.document );
					// link.document.styleSheets.push( styleSheet );
				}else{
					// Log.info( "Unknown link tag type", link.rel );
				}
			}
			document.window.css.parseCSS( styles );
			document.parser.paused = false;
			document.dispatchEvent( new Event( Parser.RESTART_PARSER ) );
		}
		//&lt;header&gt;	Specifies a header for a section or page	NEW
		//http://www.w3schools.com/tags/html5_header.asp
		public function header( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, BLOCK );
		}
		//&lt;hr&gt;	 Specifies a horizontal rule	 
		//http://www.w3schools.com/tags/html5_hr.asp
		public function hr( document:Document, target:Element, xml:XML ):Object
		{
			var obj:Object = element( document, target, xml, BLOCK );
			return obj;
		}
		//&lt;html&gt;	Specifies an html document	 
		//http://www.w3schools.com/tags/html5_html.asp
		public function html( document:Document, target:Element, xml:XML ):Object
		{
			return {};
		}
		//&lt;i&gt;	Specifies italic text	 
		//http://www.w3schools.com/tags/html5_i.asp
		public function i( document:Document, target:Element, xml:XML ):Object
		{
			var obj:Object = element( document, target, xml, INLINE );
			obj.element.style.fontStyle = "italic";
			return obj;
		}
		//&lt;iframe&gt;	Specifies an inline sub window (frame)	 
		//http://www.w3schools.com/tags/html5_iframe.asp
		public function iframe( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, BLOCK );
		}
		//&lt;img&gt;	Specifies an image	 
		//http://www.w3schools.com/tags/html5_img.asp
		public function img( document:Document, target:Element, xml:XML ):Object
		{
			var obj:Object = element( document, target, xml, INLINE );
			if( xml.@width.toString() ) {
				obj.element.style.width = xml.@width.toString();
			}
			if( xml.@height.toString() ) {
				obj.element.style.height = xml.@height.toString();
			}
			var url:String = xml.@src.toString();
			var asset:Asset = _controller.assets.add( url );
			
			_progressFunctions[url] = function( event:ProgressEvent ):void{ onImgProgress( event, url, obj ); }
			asset.addEventListener(ProgressEvent.PROGRESS, _progressFunctions[url] );
			
			_completeFunctions[url] = function( event:Event ):void{ onImgComplete( event, url, obj ); }
			asset.addEventListener(Event.COMPLETE, _completeFunctions[url] );
			
			_controller.assets.load();
			return obj;
		}
		
		private function onImgProgress( event:ProgressEvent, url:String, obj:Object ):void
		{
			obj.element.dispatchEvent( event );
		}
		
		private function onImgComplete( event:Event, url:String, obj:Object ):void
		{
			if( event.target.hasEventListener(Event.COMPLETE ) && _completeFunctions[url] != null ) {
				event.target.removeEventListener(Event.COMPLETE, _completeFunctions[url] );	
			}
			
			if( event.target.hasEventListener( ProgressEvent.PROGRESS ) && _progressFunctions[url] != null ) {
				event.target.removeEventListener(ProgressEvent.PROGRESS, _progressFunctions[url] );
			}
			
			var img:Bitmap = _controller.assets.fetch( url );
			//img.width = obj.element.computedStyles.width;
			//img.scaleY = img.scaleX;
			obj.element.addChild( img );
			delete _progressFunctions[url];
			delete _completeFunctions[url];
		}
		
		// INPUT IS DEFINED WITHIN FormTags.as
		
		//&lt;ins&gt;	Specifies inserted text	 
		//http://www.w3schools.com/tags/html5_ins.asp
		/*public function ins( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, INLINE ); // Passed through the span tag because they are rendered the same.
		}*/
		//&lt;kbd&gt;	Specifies keyboard text	 
		//http://www.w3schools.com/tags/html5_kbd.asp
		public function kbd( document:Document, target:Element, xml:XML ):Object
		{
			var obj:Object = element( document, target, xml, INLINE );
			obj.style.fontFace = "_typewriter";
			obj.style.digitWidth = DigitWidth.TABULAR;
			return obj;
		}
		
		// LABEL TAG IS DEFINED INSIDE OF FormTags.as
		
		//&lt;legend&gt;	Specifies a title in a fieldset	 
		//http://www.w3schools.com/tags/html5_legend.asp
		public function legend( document:Document, target:Element, xml:XML ):void
		{
			// Log.info("legend", xml.toXMLString())
		}
		//&lt;li&gt;	Specifies a list item	 
		//http://www.w3schools.com/tags/html5_li.asp
		/*public function li( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, INLINE );// Passed through the span tag because they are rendered the same for now.
		}*/
		
		//&lt;link&gt;	Specifies a resource reference	 
		//http://www.w3schools.com/tags/html5_link.asp
		public function link( document:Document, target:Element, xml:XML ):void
		{
			_controller.assets.add(xml.@href.toString());
			_linksLoading.push({ href:xml.@href.toString(), rel:xml.@rel.toString(), type:xml.@type.toString(), document:document, target:target, xml:xml });
		}
		
		//&lt;mark&gt;	Specifies marked text	NEW
		//http://www.w3schools.com/tags/html5_mark.asp
		/*public function mark( document:Document, target:Element, xml:XML ):Object
		{
			// Log.info("mark", xml.toXMLString())
			return element( document, target, xml, INLINE );// Passed through the span tag because they are rendered the same.
		}*/
		//&lt;map&gt;	Specifies an image map 	 
		//http://www.w3schools.com/tags/html5_map.asp
		public function map( document:Document, target:Element, xml:XML ):void
		{
			// Log.info("map", xml.toXMLString())
		}
		//&lt;menu&gt;	Specifies a menu list	 
		//http://www.w3schools.com/tags/html5_menu.asp
		public function menu( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, BLOCK );
		}
		//&lt;meta&gt;	Specifies meta information	 
		//http://www.w3schools.com/tags/html5_meta.asp
		// all meta tags are currently ignored
		public function meta( document:Document, target:Element, xml:XML ):void {}
		
		//&lt;meter&gt;	Specifies measurement within a predefined range	NEW
		//http://www.w3schools.com/tags/html5_meter.asp
		public function meter( document:Document, target:Element, xml:XML ):void
		{
			// Log.info("meter", xml.toXMLString())
		}
		//&lt;nav&gt;	Specifies navigation links	NEW
		//http://www.w3schools.com/tags/html5_nav.asp
		public function nav( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, BLOCK );
		}
		//&lt;noscript&gt;	Specifies a noscript section	 
		//http://www.w3schools.com/tags/html5_noscript.asp
		public function noscript( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, BLOCK );
		}
		//&lt;object&gt;	Specifies an embedded object	 
		//http://www.w3schools.com/tags/html5_object.asp
		public function object( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, BLOCK );
		}
		//&lt;ol&gt;	Specifies an ordered list	 
		//http://www.w3schools.com/tags/html5_ol.asp
		/*
		public function ol( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, INLINE ); // Passed through the span tag because they are rendered the same.
		}*/
		
		// optgroup & option are defined inside of FormTags.as
		
		//&lt;output&gt;	Specifies some types of output	NEW
		//http://www.w3schools.com/tags/html5_output.asp
		public function output( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, BLOCK );
		}
		//&lt;p&gt;	Specifies a paragraph	 
		//http://www.w3schools.com/tags/html5_p.asp
		public function p( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, BLOCK );
		}
		//&lt;param&gt;	Specifies a parameter for an object	 
		//http://www.w3schools.com/tags/html5_param.asp
		public function param( document:Document, target:Element, xml:XML ):void
		{
			// Log.info("param not implemented", xml.toXMLString())
		}
		//&lt;pre&gt;	Specifies preformatted text	 
		//http://www.w3schools.com/tags/html5_pre.asp
		public function pre( document:Document, target:Element, xml:XML ):Object
		{
			var obj:Object = element( document, target, xml, INLINE );
			obj.style.fontFace = "_typewriter";
			obj.style.digitWidth = DigitWidth.TABULAR;
			return obj;
		}
		
		//&lt;q&gt;	Specifies a short quotation	 
		//http://www.w3schools.com/tags/html5_q.asp
		/*public function q( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, INLINE ); // Passed through the span tag because they are rendered the same.
		}*/
		//&lt;ruby&gt;	Specifies a ruby annotation (used in East Asian typography)	NEW
		//http://www.w3schools.com/tags/html5_ruby.asp
		public function ruby( document:Document, target:Element, xml:XML ):void
		{
			// Log.info("ruby not implemented", xml.toXMLString())
		}
		//&lt;rp&gt;	Used for the benefit of browsers that don't support ruby annotations	NEW
		//http://www.w3schools.com/tags/html5_rp.asp
		public function rp( document:Document, target:Element, xml:XML ):void
		{
			// Log.info("rp not implemented", xml.toXMLString())
		}
		//&lt;rt&gt;	Specifies the ruby text component of a ruby annotation.	NEW
		//http://www.w3schools.com/tags/html5_rt.asp
		public function rt( document:Document, target:Element, xml:XML ):void
		{
			// Log.info("rt not implemented", xml.toXMLString())
		}
		//&lt;samp&gt;	Specifies sample computer code	 
		//http://www.w3schools.com/tags/html5_samp.asp
		public function samp( document:Document, target:Element, xml:XML ):Object
		{
			var obj:Object = element( document, target, xml, INLINE );
			obj.style.fontFace = "_typewriter";
			obj.style.digitWidth = DigitWidth.TABULAR;
			return obj;
		}
		//&lt;script&gt;	Specifies a script	 
		//http://www.w3schools.com/tags/html5_script.asp
		public function script( document:Document, target:Element, xml:XML ):void
		{
			// TODO: eval, I've gotten this working with a few eval implimentations, all of them are beast (adding about 200K, sometimes crashing browsers)
			// I will wait until someone does this right before adding it to my code base, I would suggest you do the same.
			//document.window.eval( 'namespace framework="framework.core";\nuse namespace framework;' + xml.text(), scriptCallBack); //, null, scriptCallBack
		}
		private function scriptCallBack( event:Event ):void
		{
			// getDefinitionByName("Test").other();
		}
		//&lt;section&gt;	Specifies a section	NEW
		//http://www.w3schools.com/tags/html5_section.asp
		public function section( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, BLOCK ); // TODO: does this new tag do anything special?
		}

		// Select is defined in FormTags.as
		
		//&lt;small&gt;	Specifies small text	 
		//http://www.w3schools.com/tags/html5_small.asp
		public function small( document:Document, target:Element, xml:XML ):Object
		{
			var obj:Object = element( document, target, xml, INLINE );
			if( obj.element.style.fontSize == null ) obj.element.style.fontSize = 8;
			return obj;
		}
		//&lt;source&gt;	Specifies media resources	NEW
		//http://www.w3schools.com/tags/html5_source.asp
		/*public function source( document:Document, target:Element, xml:XML ):Object
		{
			// TODO: what is a source tag?
			// // Log.info("source", xml.toXMLString())
			return element( document, target, xml, INLINE ); // Passed through the span tag because they are rendered the same.
		}*/
		//&lt;span&gt;	Specifies a section in a document	 
		//http://www.w3schools.com/tags/html5_span.asp
		public function span( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, INLINE );
		}
		//&lt;strong&gt;	Specifies strong text	 
		//http://www.w3schools.com/tags/html5_strong.asp
		public function strong( document:Document, target:Element, xml:XML ):Object
		{
			var obj:Object = element( document, target, xml, INLINE );
			obj.element.style.fontWeight = FontWeight.BOLD;
			return obj;
		}
		//&lt;style&gt;	Specifies a style definition	 
		//http://www.w3schools.com/tags/html5_style.asp
		public function style( document:Document, target:Element, xml:XML ):void
		{
			document.window.css.parseCSS( xml.text().toString() );
		}
		//&lt;sub&gt;	Specifies subscripted text	 
		//http://www.w3schools.com/tags/html5_sub.asp
		public function sub( document:Document, target:Element, xml:XML ):Object
		{
			var obj:Object = element( document, target, xml, INLINE );
			// obj.element.style.textBaseline = TextBaseline.SUBSCRIPT;
			return obj;
		}
		//&lt;sup&gt;	Specifies superscripted text	 
		//http://www.w3schools.com/tags/html5_sup.asp
		public function sup( document:Document, target:Element, xml:XML ):Object
		{
			var obj:Object = element( document, target, xml, INLINE );
			// obj.element.style.textBaseline = TextBaseline.SUPERSCRIPT;
			return obj;
		}
		//&lt;table&gt;	Specifies a table	 
		//http://www.w3schools.com/tags/html5_table.asp
		public function table( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, TABLE );
		}
		//&lt;tbody&gt;	Specifies a table body	 
		//http://www.w3schools.com/tags/html5_tbody.asp
		public function tbody( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, TABLE_CELL );
		}
		//&lt;td&gt;	Specifies a table cell	 
		//http://www.w3schools.com/tags/html5_td.asp
		public function td( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, TABLE_CELL );
		}
		
		// textarea is defined in FormTags.as
		
		//&lt;tfoot&gt;	Specifies a table footer	 
		//http://www.w3schools.com/tags/html5_tfoot.asp
		public function tfoot( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, TABLE_CELL );
		}
		//&lt;th&gt;	Specifies a table header	 
		//http://www.w3schools.com/tags/html5_th.asp
		public function th( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, TABLE_CELL );
		}
		//&lt;thead&gt;	Specifies a table header	 
		//http://www.w3schools.com/tags/html5_thead.asp
		public function thead( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, TABLE_CELL );
		}
		//&lt;time&gt;	Specifies a date/time	NEW
		//http://www.w3schools.com/tags/html5_time.asp
		/*public function time( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, INLINE ); // Passed through the span tag because they are rendered the same.
		}*/
		//&lt;title&gt;	Specifies the document title	 
		//http://www.w3schools.com/tags/html5_title.asp
		public function title( document:Document, target:Element, xml:XML ):void
		{
			if( ExternalInterface.available )
				ExternalInterface.call( 'function(){document.title="'+xml.text()+'";}' );
		}
		//&lt;tr&gt;	Specifies a table row	 
		//http://www.w3schools.com/tags/html5_tr.asp
		public function tr( document:Document, target:Element, xml:XML ):Object
		{
			return element( document, target, xml, TABLE_ROW );
		}
		//&lt;ul&gt;	Specifies an unordered list	 
		//http://www.w3schools.com/tags/html5_ul.asp
		public function ul( document:Document, target:Element, xml:XML ):Object
		{
			var obj:Object = element( document, target, xml, INLINE );
			
			/*
			http://www.web-source.net/web_development/cascading_style_sheets.htm
				list-style-type: decimal; 
				list-style-position: outside;
				list-style-type:none;
				list-style-image: url(arrow.gif);
				list-style-type: square;
				
				&lt;OL&gt;
				   &lt;LI STYLE="list-style-type: decimal"&gt; List Item
				   &lt;LI STYLE="list-style-type: lower-alpha"&gt; List Item
				   &lt;LI STYLE="list-style-type: upper-alpha"&gt; List Item
				   &lt;LI STYLE="list-style-type: lower-roman"&gt; List Item
				   &lt;LI STYLE="list-style-type: upper-roman"&gt; List Item
				&lt;/OL&gt;
				
				1.
				b.
				C.
				iv.
				V.
				
			*/
			return obj;
		}
		
	}
}