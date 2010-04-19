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
	import framework.view.html.Element;
	import framework.view.html.Document;
	import framework.view.html.Node;
	import framework.debug.Log;
	
    import flash.display.Sprite;
    import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
    import flash.media.Sound;
    import flash.media.SoundChannel;
	import flash.media.SoundTransform;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;
    
    public class AudioTag extends Element 
    {
		public var currentPlaycount:int = 0;
		public var playcount:int = 1;
		public var start:int = 0;
		public var end:int;
		public var loopstart:int = 0;
		public var loopend:int;
		public var looping:Boolean = false;
		public var totalTime:Number;
		public var lastPosition:Number;
        private var sound:Sound = new Sound();
        private var channel:SoundChannel;
        private var st:SoundTransform;
        private var target:*;
		private var data:Object;
		private var file:URLRequest;
		private var isPlaying:Boolean = false;
		
		private var w:int;
		private var h:int;
		
		/*
		private var window:Box;
		private var controller:Box;
		private var closeBtn:CloseBtnSymbol;
		private var playBtn:PlayBtnSymbol;
		private var pauseBtn:PauseBtnSymbol;
		private var volumeHolder:Sprite;
		private var volumeBtn:SoundBtnSymbol;

		private var eq:Box;
		private var seekBack:Box;
		private var seekBar:ProcessingSymbol;
		private var seekBarMask:Box;
		private var seekHandle:Box;

		private var volumeBack:Box;
		private var volumeBack2:Box;
		private var volumeBar:Box;
		private var volumeHandle:Box;
		*/
			
		/*
		 *	autoplay	true | false	If set to true, the audio will start playing as soon as it is ready.
		 *	controls	true | false	If set to true, the user is shown some controls, such as a play button.
		 *	end			numeric value	Defines where in the audio stream the player should stop playing. By default, it plays to the end.
		 *	loopend		numeric value	Defines where in the audio stream the loop should stop, before jumping to the start of the loop. Default is the end attribute's value.
		 *	loopstart	numeric value	Defines where in the audio stream the loop should start. Default is the start attribute's value.
		 *	playcount	numeric value	Defines how many times the audio should be played. Default is 1.
		 *	src			url	 Defines the URL of the audio to play
		 *	start		numeric value	Defines where in the audio stream the player should start playing. By default, it plays from the beginning.
		*/
		
		public function AudioTag( document:Document=null, element:Node=null, xml:XML=null )
		{
			super( document, element, xml );			
			addEventListener(Event.ADDED_TO_STAGE, setup);
		}
		
        private function setup( event:Event ) :void
        {
			file = new URLRequest( innerXML.@src.toString() );

            if( innerXML.@playcount.toString() ) playcount = innerXML.@playcount.toString();
			if( innerXML.@start.toString() ) start = innerXML.@start.toString();
			if( innerXML.@end.toString() ) end = innerXML.@end.toString();
			if( innerXML.@loopstart.toString() ) loopstart = innerXML.@loopstart.toString();
			if( innerXML.@loopend.toString() ) loopend = innerXML.@loopend.toString();

			if( innerXML.@autoplay.toString() ) play();
			
            //bytes = new ByteArray();

            st = new SoundTransform();
			channel.soundTransform = st;

            sound.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
            channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);

			//createInterface();
        }
		// The sound has finished playing.
        private function soundCompleteHandler(event:Event=null):void 
        {
			currentPlaycount++;
			if( currentPlaycount == playcount )
            	removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			else{
				sound.play( loopstart );
				looping = true;
			}
        }
		private function enterFrameHandler(event:Event):void 
        {    
            var loadTime:Number = sound.bytesLoaded / sound.bytesTotal;
            //var loadPercent:uint = Math.round(100 * loadTime);
            totalTime = Math.ceil(sound.length / (loadTime));
			
			if( (end && end == channel.position) || (looping && loopend == channel.position ) )
				soundCompleteHandler();
			
			/*
      		if(Math.floor( barWidth * channel.position / totalTime) > 25)
				seekBarMask.draw( 0, -5, Math.floor( barWidth * channel.position / totalTime), 25, { r:25 } );
			else
				seekBarMask.draw( 0, -5, 25, 25, { r:25 } );

			seekHandle.x = seekBarMask.width - 20;

			computeSpectrum();
			*/
        }
		public function play(ev:MouseEvent = null) : void
        {
			if( !isPlaying ){
				try {
	                sound.load( file );
	                channel = sound.play(start);
					isPlaying = true;
	            } catch (err:Error) {
	                // Log.error(err.message);
	            }
			}
		}
		public function stop(ev:MouseEvent = null) : void
        {
			if( isPlaying ){
				channel.stop();
				isPlaying = false;
			}
		}
		private function pause(ev:MouseEvent = null) : void
        {
			if( isPlaying ){
				//pauseBtn.alpha = 0;
				lastPosition = channel.position;
				channel.stop();
				isPlaying = false;
			}else{
				//pauseBtn.alpha = 1;
				channel.stop();
				channel = sound.play( lastPosition );
				isPlaying = true;
			}
		}
		/*
        private function createInterface():void 
		{
			window = new Box( this );
			closeBtn = new CloseBtnSymbol(); window.addChild(closeBtn);
			eq = new Box( window );
			controller = new Box( window );
			seekBack = new Box( controller );
			seekBar = new ProcessingSymbol(); seekBack.addChild(seekBar);
			seekBarMask = new Box( seekBar.processingMask );
			seekHandle = new Box( seekBar );
			playBtn = new PlayBtnSymbol(); controller.addChild(playBtn);
			pauseBtn = new PauseBtnSymbol(); controller.addChild(pauseBtn);
			volumeBack = new Box( controller );
			volumeBack.visible = false;
			volumeBack2 = new Box( volumeBack );
			volumeBtn = new SoundBtnSymbol(); controller.addChild(volumeBtn);
			volumeBar = new Box( volumeBack2 );
			volumeHandle = new Box( volumeBar );
			closeBtn.addEventListener( MouseEvent.MOUSE_DOWN, closePlayer );
			pauseBtn.addEventListener( MouseEvent.MOUSE_DOWN, pause );
			volumeBtn.addEventListener( MouseEvent.MOUSE_DOWN, openVolume );
			volumeBar.addEventListener( MouseEvent.MOUSE_DOWN, volumeDown );
			seekBar.addEventListener(MouseEvent.MOUSE_DOWN, percentBarDown);
			seekBar.addEventListener(MouseEvent.MOUSE_UP, percentBarUp);

			placeElements();

			setUpAudio();

			addEventListener(MouseEvent.MOUSE_UP, percentBarUp);
			target.addEventListener(Event.RESIZE, onResize);
		}
		
		private function placeElements() :void 
		{
			w = App.target.stage.stageWidth-170;
			h = App.target.stage.stageHeight;
			barWidth = w - 210;
			window.draw( 50, 40, w-100, h-90, {color:0xFFFFFF, alpha:0.7, r:40} );
			closeBtn.x = w - 90;
			closeBtn.y = -36;
			eq.x = 20;
			controller.draw( 15, h - 140, w-130, 35, {color:0x4A619C, r:35} );
			seekBack.draw(40, 5, barWidth, 25, {color:0x509DC8, r:25});
			seekHandle.draw(seekBarMask.width - 20, 8, 10, 10, {color:0xCC0000, r:8 });
			playBtn.scaleX = playBtn.scaleY = volumeBtn.scaleX = volumeBtn.scaleY = pauseBtn.scaleX = pauseBtn.scaleY = 0.7;  
			playBtn.x = pauseBtn.x = 2;
			playBtn.y = pauseBtn.y = 2; 
			volumeBack.draw(w - 165, -145, 35, 180, { color:0x4A619C, r:35 } );
			volumeBack2.draw(5, 5, 25, 140, { color:0x509DC8, r:25 } ); 
			volumeBtn.x = w - 162;
			volumeBtn.y = 2;
			volumeBar.draw(4, 4, 17, volumeHeight, { color:0xFCB62A, r:17 });
			volumeHandle.draw(4, 4, 9, 9, { color:0xCC0000, r:9 });

		}
		*/

        private function errorHandler(errorEvent:IOErrorEvent):void 
        {
            // Log.error( "The sound could not be loaded: " + errorEvent.text );
        }

		/*
		private function computeSpectrum():void 
		{
			SoundMixer.computeSpectrum(bytes, false);
			eq.graphics.clear();
			var value:Number;
			var channelLength:int = 256;
			var spacing:Number = (( w - 150) / channelLength);
			var color:Number;
			//first 256 is left channell, second 256 is right channell
			for(var i:int = 0; i < channelLength; i++)
			{
				//normalize it to be a value between 0 and 256
				value = (bytes.readFloat() * channelLength) << 0;

				//figure out the color based on the value
				color = 0xFF0000|(value << 8);
				eq.graphics.beginFill(color);
				eq.graphics.drawRoundRect(i * spacing, (h/2), 10, value*volH/300 , 5);

			}

		}
		
		public function percentBarDown( ev:MouseEvent ) :void 
		{
			seekBar.addEventListener(Event.ENTER_FRAME, whileDownPercent);
		}

		private function whileDownPercent(ev:Event) :void 
		{
			var scale:Number = (mouseX - 80) * 100 / barWidth / 100;
			channel.stop();
			channel = sound.play( scale * totalTime );
			isPlaying = true;
		}

		private function percentBarUp(ev:MouseEvent) :void 
		{ 
			seekBar.removeEventListener(Event.ENTER_FRAME, whileDownPercent);
		}

		private function openVolume(ev:MouseEvent = null):void {
			volumeBack.visible = true;
		}

		public function volumeDown( ev:MouseEvent ) :void 
		{
			if(volumeBack.hasEventListener(Event.ENTER_FRAME)){
				volumeUp();
			}else{
				volumeBack.addEventListener(Event.ENTER_FRAME, whileDownVolume);
				addEventListener(MouseEvent.MOUSE_UP, volumeUp);
			}

		}

		private function whileDownVolume(ev:Event) :void 
		{
			var scale:Number = (volumeBack2.mouseY - 8) * 100 / volumeHeight / 100;

			if( scale < 1 && scale > 0 && volumeBack2.mouseY > 4 && volumeBack2.mouseY - 4 < volumeHeight - 17 ) {
				volH = Math.abs(volumeHeight * scale - volumeHeight);
				if(volH< 17)
					volumeBar.draw(4, Math.ceil(( (volumeBack2.height - 8) / 100 ) * ( scale * 100 ))+4, 17,  17 , { color:0xFCB62A, r:17 });
				else
					volumeBar.draw(4, Math.ceil(( (volumeBack2.height - 8) / 100 ) * ( scale * 100 ))+4, 17,  volH , { color:0xFCB62A, r:17 });
				st.volume = 1 - scale;
			}
			channel.soundTransform = st;
		}

		private function volumeUp(ev:MouseEvent = null) :void 
		{ 
			volumeBack.removeEventListener(Event.ENTER_FRAME, whileDownVolume);
			removeEventListener(MouseEvent.MOUSE_UP, volumeUp);
			volumeBack.visible = false;
		}

		private function closePlayer(  ev:MouseEvent ):void 
		{
			channel.stop();
			channel = new SoundChannel();
			sound = new Sound();
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			target.closeSelected( this );
		}

		private function onResize(ev:Event):void 
		{
			placeElements();
		}
		*/
    }

}