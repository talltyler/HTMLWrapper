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
	public class TextNode extends Element
	{
		private var _cdata:String;
		
		override public function get cdata():String
		{ 
			return _cdata; 
		}

		override public function set cdata(value:String):void
		{
			if (value !== _cdata)
			{
				_cdata = value;
				//updateText();
			}
		}
		
		public function TextNode( document:Document, element:Node, xml:XML=null )
		{
			super( document, element, xml);
		}
		
		
		/*
			//myFontDescription = new FontDescription();
			//myFontDescription.fontName="Geneva";// hopefully you have it
			//myFontDescription.fontWeight=FontWeight.BOLD; //we make it bold
			//myFontDescription = new FontDescription();
			//myFontDescription.fontName="Webdings";// hopefully you have it
			//myFontDescription.fontWeight=FontWeight.BOLD; //we make it bold
			// textFormat.breakOpportunity
			// textFormat.trackingRight
			// textFormat.trackingLeft
			// textFormat.ligatureLevel=LigatureLevel.EXOTIC;
			// textFormat.digitCase=DigitCase.LINING;
			// textFormat.textRotation = TextRotation.ROTATE_180; 
			// textFormat.typographicCase=TypographicCase.TITLE;
			// textFormat.ligatureLevel=LigatureLevel.NONE;
		*/
		/*
			var css:String = "h1{font-family:Times Roman; font-size:30; color:#FF3300; } p{font-family:Times Roman; font-size:10; color:#000000; }"
			var styleSheet:StyleSheet = new StyleSheet()
			styleSheet.parseCSS(css)

			function init():void{
				var txt:Sprite = textBox("<h1>Headline</h1><p>Body</p><p>Body</p><p>Body</p><h1>Headline</h1><p>Body</p>")
				txt.x=125;
				txt.y=135;
				addChild(txt)
			}
			function textBox( text:String, width:int=500 ):Sprite{

				var result:Sprite = new Sprite
				var content:XML = XML("<xml>"+text+"</xml>")
				var textBlock:TextBlock = new TextBlock();
				var textFormat:ElementFormat
				var textElement:TextElement

				for each( var part:XML in content.children()){
					var style:Object = styleSheet.getStyle(part.localName())
					var fontDescription:FontDescription = new FontDescription();
					fontDescription.fontName = style.fontFamily || "Times Roman";
					textFormat = new ElementFormat(fontDescription, int(style.fontSize)||12, uint(String(style.color||"#000000").split("#").join("0x")), 1 );
					textElement = new TextElement(part.text(),textFormat);
					textBlock.content=textElement;
					var textLine:TextLine = textBlock.createTextLine(null,width);
					textLine.y = result.height + textBlock.lastLine.ascent
					if(textLine) result.addChild(textLine)
				}

				return result
			}
		*/
	
	}

}

