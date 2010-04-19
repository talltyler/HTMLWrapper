package framework.view.htmlwrapper
{
	import framework.components.Button;
	import flash.events.MouseEvent;

	public class Form
	{
		public var action:String;
		public var encoding:String;
		public var method:String;
		public var name:String;
		public var elements:Array = [];
		public var target:String;
		public var radioButtons:Object = {};
		public var submitButton:Button;
	
		public function get length():int
		{
			return elements.length;
		}
	
		public function Form()
		{
			super();
		}
		
		public function submit():void
		{
			submitButton.dispatchEvent( new MouseEvent( MouseEvent.CLICK, true, false ) );
		}
		
	}
}