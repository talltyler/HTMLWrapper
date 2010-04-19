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
	import framework.view.htmlwrapper.tags.BasicTags;
	import framework.view.htmlwrapper.tags.FormTags;
	import framework.view.htmlwrapper.tags.VideoTag;
	
	public class TagsBase 
	{
		public var tags:Object = {};
		public var basic:BasicTags;
		public var forms:FormTags;
		
		public function TagsBase( controller:Controller )
		{
			super();
			
			basic = new BasicTags( controller );
			forms = new FormTags( controller );
			
			tags.cdata 		= basic.cdata;
			tags.a 			= basic.a;
			// tags.abbr 		= basic.abbr;
			// tags.address 	= basic.address;
			//tags.area 		= basic.area;
			tags.article 	= basic.article;
			tags.aside 		= basic.aside;
			// tags.audio 		= basic.audio;
			tags.c 			= basic.b;
			tags.base 		= basic.base;
			// tags.bdo 		= basic.bdo;
			tags.blockquote = basic.blockquote;
			tags.body 		= basic.body;
			tags.br 		= basic.br;
			tags.button		= forms.button;
			tags.canvas 	= basic.canvas;
			tags.caption 	= basic.caption;
			tags.cite 		= basic.cite;
			tags.code 		= basic.code;
			tags.col 		= basic.col;
			tags.colgroup 	= basic.colgroup;
			tags.command 	= basic.command;
			tags.datagrid 	= basic.datagrid;
			tags.datalist 	= basic.datalist;
			tags.dd 		= basic.dd;
			tags.del 		= basic.del;
			tags.details 	= basic.details;
			tags.dialog 	= basic.dialog;
			// tags.dfn 		= basic.dfn;
			tags.div 		= basic.div;
			tags.dl 		= basic.dl;
			tags.dt 		= basic.dt;
			tags.em 		= basic.em;
			tags.embed 		= basic.embed;
			tags.eventsource= basic.eventsource;
			tags.fieldset 	= basic.fieldset;
			tags.figure 	= basic.figure;
			tags.footer 	= basic.footer;
			tags.form 		= forms.form;
			tags.h1 		= basic.h1;
			tags.h2 		= basic.h2;
			tags.h3 		= basic.h3;
			tags.h4 		= basic.h4;
			tags.h5 		= basic.h5;
			tags.h6 		= basic.h6;
			tags.head 		= basic.head;
			tags.header 	= basic.header;
			tags.hr 		= basic.hr;
			tags.html 		= basic.html;
			tags.i 			= basic.i;		
			tags.iframe 	= basic.iframe;
			tags.img 		= basic.img;
			tags.input 		= forms.input;
			// tags.ins 		= basic.ins;
			tags.kbd 		= basic.kbd;
			tags.label 		= forms.label;
			tags.legend 	= basic.legend;
			// tags.li 		= basic.li;
			tags.link 		= basic.link;
			// tags.mark 		= basic.mark;
			tags.map 		= basic.map;
			tags.menu 		= basic.menu;
			tags.meta 		= basic.meta;
			tags.meter 		= basic.meter;
			tags.nav 		= basic.nav;		
			tags.noscript 	= basic.noscript;		
			tags.object 	= basic.object;
			// tags.ol 		= basic.ol;
			tags.optgroup 	= forms.optgroup;
			tags.option 	= forms.option;
			tags.output 	= basic.output;
			tags.p 			= basic.p;
			tags.param 		= basic.param;
			tags.pre 		= basic.pre;
			tags.progress 	= forms.progress;
			// tags.q 			= basic.q;
			tags.ruby 		= basic.ruby;
			tags.rp 		= basic.rp;	
			tags.rt 		= basic.rt;	
			tags.samp 		= basic.samp;
			tags.script 	= basic.script;
			tags.section 	= basic.section;
			tags.select 	= forms.select;
			tags.small 		= basic.small;
			// tags.source 	= basic.source;
			tags.span 		= basic.span;
			tags.strong 	= basic.strong;
			tags.style 		= basic.style;
			tags.sub 		= basic.sub;
			tags.sup 		= basic.sup;
			tags.table 		= basic.table;
			tags.tbody 		= basic.tbody;
			tags.td 		= basic.td;
			tags.textarea 	= forms.textarea;
			tags.tfoot 		= basic.tfoot;
			tags.th 		= basic.th;		
			tags.thead 		= basic.thead;
			// tags.time 		= basic.time;		
			tags.title 		= basic.title;	
			tags.tr 		= basic.tr;
			tags.ul 		= basic.ul;
			// tags["var"]		= basic["var"];
			// tags.video 		= VideoTag.tag;
			
		}
	}
}