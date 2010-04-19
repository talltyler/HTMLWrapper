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
import flash.external.*;
import flash.events.*;
import flash.display.*;
import flash.net.*;
import flash.text.*;

import framework.*;
import framework.components.*;
import framework.controller.*;
import framework.net.*;
import framework.view.html.*;
import framework.utils.*;
import framework.view.html.Form;
import framework.display.Base;

public class FormTags
{
	
	private var _window:Window;
	private var _navigator:Navigator;
	private var _controller:Controller;
	private var _currentElement:*;
	
	public function FormTags( controller:Controller )
	{
		super();
		
		_controller = controller;
	}
	
	// public var forms:Array = [{action:null,encoding:null,length:null,method:null,name:null,elements:[],target:null}];
	
	//<form>	Specifies a form 	 
	//http://www.w3schools.com/tags/html5_form.asp
	public function form( document:Document, target:Element, xml:XML ):Object
	{
		var form:Form = new Form();
		form.action = xml.@action.toString();
		form.method = xml.@method.toString() || "post";
		form.name = xml.@name.toString() || "form"+document.forms.length;
		form.target = xml.@target.toString() || null;
		document.forms.push( form ); 
		return {};
	}
	
	//<label>	Specifies a label for a form control	 
	//http://www.w3schools.com/tags/html5_label.asp
	public function label( document:Document, target:Element, xml:XML ):Object
	{
		if( _navigator == null )
			_navigator = document.window.navigator;
		if( _window == null )
			_window = document.window;
		var element:Element = _navigator.pools.retrieve( Element );
		var style:Object = _window.css.getElementStyles( xml, target ).style;
		element.create( { controller:_controller, document:document, element:target, xml:xml, styles:style } );
		if( element.style.display == null ) 
			element.style.display = "block";
		element.addCData( xml.toXMLString() );
		return {element:element};
	}
	
	//&lt;select&gt;	Specifies a selectable list	 
	//http://www.w3schools.com/tags/html5_select.asp
	public function select( document:Document, target:Element, xml:XML ):Object
	{
		// // Log.info("select", xml.toXMLString())
		// TODO: need to hook up components
		//var obj:Object = element( document, target, xml, BLOCK );
		return {}
	}
	
	//&lt;optgroup&gt;	Specifies an option group	 
	//http://www.w3schools.com/tags/html5_optgroup.asp
	public function optgroup( document:Document, target:Element, xml:XML ):Object
	{
		// Log.info("optgroup", xml.toXMLString())
		return {};
	}
	
	//&lt;option&gt;	Specifies an option in a drop-down list	 
	//http://www.w3schools.com/tags/html5_option.asp
	public function option( document:Document, target:Element, xml:XML ):void
	{
		// Log.info("option", xml.toXMLString())
	}
	
	
	
	//&lt;progress&gt;	Specifies progress of a task of any kind	NEW
	//http://www.w3schools.com/tags/html5_progress.asp
	public function progress( document:Document, target:Element, xml:XML ):Object
	{
		//return element( document, target, xml, INLINE );
		return {};
	}
	
	//<input>	Specifies an input field	 
	//http://www.w3schools.com/html5/tag_input.asp
	// This method just calls a method of each type of input. All of these methods should just be wrappers for your compnent set
	public function input( document:Document, target:Element, xml:XML ):Object
	{
		return this[String(xml.@type.toString()||"text").toLowerCase()]( document, target, xml );
	}
	
	/**
	 *	&lt;button&gt;	Specifies a push button	 
	 *	http://www.w3schools.com/tags/html5_button.asp
	 *	
	 *	Attributes
	 *	autofocus	true | false	Makes the button focused or not, as the page loads	 	5
	 *	disabled	disabled	Disables the button	4/5
	 *	name		button_name	Specifies a unique name for the button	4/5
	 *	type		[button,reset,submit] 		Defines the type of button	4/5
	 *	value		some_value	Specifies an initial value for the button. The value can be changed by a script	4/5
	 *	
	 *	Standard Attributes
	 *		class, contenteditable, contextmenu, dir, draggable, id, irrelevant, lang, ref, registrationmark, tabindex, template, title
	 *	
	 *	Event Attributes
	 *		onabort, onbeforeunload, onblur, onchange, onclick, oncontextmenu, ondblclick, ondrag, ondragend, ondragenter, ondragleave, ondragover, ondragstart, ondrop, onerror, onfocus, onkeydown, onkeypress, onkeyup, onload, onmessage, onmousedown, onmousemove, onmouseover, onmouseout, onmouseup, onmousewheel, onresize, onscroll, onselect, onsubmit, onunload
	 */
	public function button( document:Document, target:Element, xml:XML ):void
	{
		var form:Form = document.forms[ document.forms.length-1 ];
		var element:Button = new Button( document, target, xml );
		target.addChild( element );
		element.label = xml.text().toString();
		element.name = xml.@name.toString();
		element.form = form;
		document.selectedForm = form;
		_currentElement = element;
		return
	}
	
	public function checkbox( document:Document, target:Element, xml:XML ):void
	{
		// <p><label> <input type=radio name=size> Large </label></p>
		var form:Form = document.forms[ document.forms.length-1 ];
		var element:CheckBox = new CheckBox( document, target, xml );
		target.addChild( element );
		if( xml.@checked.toString() == "true" ) {
			element.checked = true;
		}
		element.name = xml.@name.toString();
		element.form = form;
		document.selectedForm = form;
		_currentElement = element;
	}
	
	public function color( document:Document, target:Element, xml:XML ):Object
	{
		// ColorPicker
		return {}
	}
	
	public function date( document:Document, target:Element, xml:XML ):Object
	{
		var form:Form = document.forms[ document.forms.length-1 ];
		var element:DatePicker = new DatePicker( document, target, xml );
		target.addChild( element );
		
		element.value = xml.@value.toString();
		element.name = xml.@name.toString();
		element.placeholder = xml.@placeholder.toString();
		
		element.form = form;
		document.selectedForm = form;
		form.elements.push( element );
		_currentElement = element;
		return { element:element };
	}
	
	public function datetime( document:Document, target:Element, xml:XML ):Object
	{
		// calendar component with time
		return {}
	}
	
	public function email( document:Document, target:Element, xml:XML ):Object
	{
		var result:Object = text( document, target, xml );
		result.element.pattern = "([0-9a-zA-Z]+[-._+&])*[0-9a-zA-Z]+@([-0-9a-zA-Z]+[.])+[a-zA-Z]{2,6}";
		return result;
	}
	
	public function file( document:Document, target:Element, xml:XML ):void
	{
		button( document, target, xml );
		_currentElement.label = xml.@label.toString()||"Choose File";
		_currentElement.addEventListener( MouseEvent.CLICK, onFileClick );
	}
	
	public function hidden( document:Document, target:Element, xml:XML ):void
	{
		var form:Form = document.forms[ document.forms.length-1 ];
		var input:InputBase = new InputBase();
		input.name = xml.@name.toString();
		input.value = xml.@value.toString();
		form.elements.push( input );
		_currentElement = input;
	}
	
	public function month( document:Document, target:Element, xml:XML ):Object
	{
		// calendar that can only select a month
		return {}
	}	
	
	public function number( document:Document, target:Element, xml:XML ):Object
	{
		var form:Form = document.forms[ document.forms.length-1 ];
		var element:Stepper = new Stepper( document, target, xml );
		target.addChild( element );
		
		element.value = xml.@value.toString();
		element.name = xml.@name.toString();
		element.placeholder = xml.@placeholder.toString();
		
		if( xml.@restrict.toString() ) {
			element.field.restrict = "0-9";
		}
		if( xml.@min.toString() ) {
			element.min = parseInt( xml.@min.toString() );
		}
		if( xml.@max.toString() ) {
			element.max = parseInt( xml.@max.toString() );
		}
		
		element.form = form;
		document.selectedForm = form;
		form.elements.push( element );
		_currentElement = element;
		return { element:element };
	}
	
	public function password( document:Document, target:Element, xml:XML ):Object
	{
		var result:Object = text( document, target, xml );
		result.element.field.displayAsPassword = true;
		return result;
	}
	
	public function radio( document:Document, target:Element, xml:XML ):void
	{
		var form:Form = document.forms[ document.forms.length-1 ];
		var element:RadioButton = new RadioButton( document, target, xml );
		target.addChild( element );
		var name:String = xml.@name.toString();
		var group:Array = form.radioButtons[ name ];
		if( group == null ) {
			group = form.radioButtons[ name ] = [];
			element.checked = true;
		}
		group.push( element );
		element.group = group;
		if( xml.@checked.toString() == "true" ) {
			element.checked = true;
		}
		element.form = form;
		document.selectedForm = form;
		_currentElement = element;
	}
	
	public function range( document:Document, target:Element, xml:XML ):Object
	{
		return {} // slider
	}	
	
	public function reset( document:Document, target:Element, xml:XML ):void
	{
		button( document, target, xml );
		_currentElement.label = xml.@label.toString();
		_currentElement.addEventListener( MouseEvent.CLICK, onReset );
	}
	
	public function search( document:Document, target:Element, xml:XML ):Object
	{
		var result:Object = text( document, target, xml );
		// could add X button to delete the text like safari
		return result;
	}
	
	public function submit( document:Document, target:Element, xml:XML ):void
	{
		button( document, target, xml );
		_currentElement.label = xml.@label.toString();
		_currentElement.form.submitButton = _currentElement;
		_currentElement.addEventListener( MouseEvent.CLICK, onSubmit );
	}
	
	public function tel( document:Document, target:Element, xml:XML ):Object
	{
		var result:Object = text( document, target, xml );
		var regex:RegExp = /^(?=(\(\d{3}\)\s)|\d{3}[-])\(?([0-9]{3})\)?\s*[ -]?\s*([0-9]{3})\s*[ -]?\s*([0-9]{4})((\sext|\sx)\s*\.?:?\s([0-9]+))?$/gim
		result.element.pattern = regex.source;
		return result;
	}
	
	// <input id="" class="" style="" type="text" name="formName" tabindex="1" value="" size="12" placeholder="Search" maxlength="12" password="true" restrict="A-Z" min="2" max="12" required="true" pattern="[A-Z]">
	public function text( document:Document, target:Element, xml:XML ):Object
	{
		var form:Form = document.forms[ document.forms.length-1 ];
		var element:TextInput = new TextInput( document, target, xml );
		target.addChild( element );
		
		element.value = xml.@value.toString();
		element.name = xml.@name.toString();
		element.placeholder = xml.@placeholder.toString();
		
		if( xml.@password.toString() == "true" ) {
			element.field.displayAsPassword = true;
		}
		if( xml.@maxlength.toString() ) {
			element.field.maxChars = parseInt( xml.@maxlength.toString() );
		}
		if( xml.@restrict.toString() ) {
			element.field.restrict = xml.@restrict.toString();
		}
		if( xml.@pattern.toString() ) {
			element.pattern = xml.@pattern.toString();
		}
		if( xml.@required.toString() == "true" ) {
			element.required = true;
		}
		if( xml.@min.toString() ) {
			element.min = parseInt( xml.@min.toString() );
		}
		if( xml.@max.toString() ) {
			element.max = parseInt( xml.@max.toString() );
		}
		
		element.form = form;
		document.selectedForm = form;
		form.elements.push( element );
		_currentElement = element;
		return { element:element };
	}
	
	//&lt;textarea&gt;	Specifies a text area	 
	//http://www.w3schools.com/tags/html5_textarea.asp
	public function textarea( document:Document, target:Element, xml:XML ):Object
	{
		var form:Form = document.forms[ document.forms.length-1 ];
		var element:TextArea = new TextArea( document, target, xml );
		target.addChild( element );
		
		element.value = xml.@value.toString();
		element.name = xml.@name.toString();
		element.placeholder = xml.@placeholder.toString();
		
		if( xml.@password.toString() == "true" ) {
			element.field.displayAsPassword = true;
		}
		if( xml.@maxlength.toString() ) {
			element.field.maxChars = parseInt( xml.@maxlength.toString() );
		}
		if( xml.@restrict.toString() ) {
			element.field.restrict = xml.@restrict.toString();
		}
		if( xml.@pattern.toString() ) {
			element.pattern = xml.@pattern.toString();
		}
		if( xml.@required.toString() == "true" ) {
			element.required = true;
		}
		if( xml.@min.toString() ) {
			element.min = parseInt( xml.@min.toString() );
		}
		if( xml.@max.toString() ) {
			element.max = parseInt( xml.@max.toString() );
		}
		if( xml.@cols.toString() ) {
			element.cols = parseFloat( xml.@cols.toString() );
		}
		if( xml.@rows.toString() ) {
			element.rows = parseFloat( xml.@rows.toString() );
		}
		if( xml.@disabled.toString() == "true" ) {
			element.disabled = true;
		}
		if( xml.@readonly.toString() == "true" ) {
			element.readonly = true;
		}
		if( xml.@wrap.toString() ) {
			element.wrap = xml.@wrap.toString();
		}
		
		element.form = form;
		document.selectedForm = form;
		form.elements.push( element );
		_currentElement = element;
		return { element:element };
	}
	
	public function time( document:Document, target:Element, xml:XML ):Object
	{
		return {}
	}
	
	public function url( document:Document, target:Element, xml:XML ):Object
	{
		var result:Object = text( document, target, xml );
		var regex:RegExp = /(ht|f)tp:\/\/w{0,3}[a-zA-Z0-9_\-.:#\/~}]+/gim;
		result.element.pattern = regex.source;
		return result
	}
	
	public function week( document:Document, target:Element, xml:XML ):Object
	{
		return {}
	}
	
	private function onReset( event:Event ):void
	{
		var form:Form = event.target.form;
		for each( var input:* in form.elements ) {
			if( input.hasOwnProperty("reset") && input.reset is Function ) {
				input.reset();
			}
		}
	}
	
	private function onSubmit( event:Event ):void
	{
		var form:Form = event.target.form;
		var input:*
		var v:URLVariables;
		
		// check for errors
		var errors:String = "";
		for each( input in form.elements ) {
			if( input.hasOwnProperty("errors") && input.errors.length != 0 ) {
				for each( var error:Object in input.errors ) {
					errors += error.message+"\n";
				}
			}
		}
		
		// save values so we can create auto populate
		/* var so:SharedObject = SharedObject.getLocal( "form_data","/astrid" );
		for each( input in form.elements ) {
			so[ input.name ] = input.value;
		}*/
		
		if( form.target == "_blank" || form.target == "_self" || form.target == "_parent" ) {
			var req:URLRequest = new URLRequest(form.action);
			v = new URLVariables();
			for each( input in form.elements ) {
				if( input.value != null ) {
					v[input.name] = input.value;
				}
			}
			if( errors != "" ) {
				v.errors = errors;
			}
			req.data = v;
			navigateToURL( req, form.target );
		}else if( form.target == "_internal" ){
			var asset:Asset = _controller.assets.add( form.action );
			asset.method = form.method;
			for each( input in form.elements ) {
				if( input.value != null ) {
					asset.addVariable( input.name, input.value );
				}
			}
			if( errors != "" ) {
				asset.addVariable( "errors", errors );
			}
			asset.addEventListener(Event.COMPLETE, onSubmitComplete );
			_controller.assets.load();
		}else{
			var params:Object = {};
			if( form.method == "post" ) {
				for each( input in form.elements ) {
					if( input.value != null ) {
						params[input.name] = input.value;
					}
				}
				if( errors != "" ) {
					params.errors = errors;
				}
				params.content = "";
				_controller.redirectTo(form.action, params );
			}else{
				v = new URLVariables();
				for each( input in form.elements ) {
					if( input.value != null ) {
						v[input.name] = input.value;
					}
				}
				if( errors != "" ) {
					v.errors = errors;
				}
				v.content = "";
				SWFAddress.setValue( form.action+"?"+v.toString());
			}
			
		}
		// form.encoding:String;
	}
	
	private function onSubmitComplete( event:Event ):void
	{
		// ?
	}
	
	private var _file:FileReference;
	private function onFileClick(event:Event):void
	{
		_currentElement = event.target;
		_file = new FileReference();
        _file.addEventListener(Event.CANCEL, cancelHandler);
        _file.addEventListener(Event.COMPLETE, completeHandler);
        _file.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
        _file.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        _file.addEventListener(Event.OPEN, openHandler);
        _file.addEventListener(ProgressEvent.PROGRESS, progressHandler);
        _file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        _file.addEventListener(Event.SELECT, selectHandler);
        _file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,uploadCompleteDataHandler);
		_file.browse();
	}
	
    private function uploadCompleteDataHandler(event:DataEvent):void {
        //trace( "uploadCompleteData: " + event)
		// trace( "uploadCompleteDataHandler, data", event.data )
    }

	private function selectHandler(event:Event):void 
	{
		trace("File input tags are still work in progress, files will not be saved.")
		if( _file.type == "jpg" || _file.type == "jepg" ) {
			_currentElement.addChild( _file.data );
		}
		
		if( _file.size > 4194304 ) { // File smaller than 4mb
			//app.controller.currentPage.window.redirect( sizeErrorPath, "bottom", true );
		}else{
			//app.controller.currentPage.window.redirect( progressPath, "bottom", true );
			//app.assets.addEventListener("allQuiet", startUpload)
		}
    }
	//

	private function cancelHandler(event:Event):void {}

    private function completeHandler(event:Event):void {}

    private function httpStatusHandler(event:HTTPStatusEvent):void {}
    
    private function ioErrorHandler(event:IOErrorEvent):void {}

    private function securityErrorHandler(event:SecurityErrorEvent):void {}

	private function openHandler(event:Event):void {}
	
	private function progressHandler(event:ProgressEvent):void {
        //trace( "progressHandler name=" + file.name + " bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal)
    }
}

}

import framework.display.*;

class InputBase 
{	
	public var name:String;
	public var value:*;
	public var element:Base;
	public function InputBase()
	{
		super();
	}
}