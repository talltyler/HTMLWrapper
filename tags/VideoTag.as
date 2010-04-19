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
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class VideoTag extends Element
	{	
		private var video:Video;
		private var file:String;
		private var nc:NetConnection;
		private var ns:NetStream;
		private var st:SoundTransform;
		private var totalTime:int = 20;
		private var isStarted:Boolean = false;	
		private var isPlaying:Boolean = false;
		private var isPaused:Boolean = false;
		private var isLooping:Boolean = false;
		private var poster:Bitmap
		private var posterURL:String
		//private var barWidth:int;
		private const volumeHeight:int = 132;
		
		/*
		private var window:Box;
		private var back:Box;
		private var videoBack:Box;
		private var controller:Box;
		private var closeBtn:CloseBtnSymbol;
		private var playBtn:PlayBtnSymbol;
		private var pauseBtn:*;
		private var volumeHolder:Sprite;
		private var volumeBtn:*;
		private var seekBack:Box;
		private var seekBar:ProcessingSymbol;
		private var seekBarMask:Box;
		private var seekHandle:Box;
		
		private var volumeBack:Box;
		private var volumeBack2:Box;
		private var volumeBar:Box;
		private var volumeHandle:Box;
		*/
		
		public function VideoTag( document:Document=null, element:Node=null, xml:XML=null )
		{
			super( document, element, xml );			
			addEventListener(Event.ADDED_TO_STAGE, setup);
		}
		
		//&lt;var&gt;	Specifies a variable	 
		//http://www.w3schools.com/tags/html5_var.asp
		/*
		public function var( document:Document, target:Element, xml:XML ):Object
		{
			var obj:Object = element( document, target, xml, INLINE );
			obj.style.fontFace = "_typewriter";
			// obj.style.digitWidth = DigitWidth.TABULAR;
			return obj;
		}
		*/
		//&lt;video&gt;	Specifies a video	NEW
		//http://www.w3schools.com/tags/html5_video.asp
		/*
		//	autoplay	true | false	If true, then the audio will start playing as soon as it is ready
			controls	true | false	If true, the user is shown some controls, such as a play button.
			end	numeric value	Defines where in the audio stream the player should stop playing. As default, the audio is played to the end.
		//	height	pixels	Sets the height of the video player
			loopend	numeric value	Defines where in the audio stream the loop should stop, before jumping to the start of the loop. Default is the end attribute's values
			loopstart	numeric value	Defines where in the audio stream the loop should start. Default is the start attribute's values
			playcount	numeric value	Defines how many times the audio clip should be played. Default is 1.
			poster	url	 The URL of an image to show before the video is ready
		//	src	url	 The URL of the audio to play
			start	numeric value	Defines where in the audio stream the player should start playing. As default, the audio starts playing at the beginning.
		//	width	pixels	Sets the width of the video player
		*/
		public static function tag( document:Document, target:Element, xml:XML ):void
		{
			var video:VideoTag = new VideoTag(document);
			video.create( {document:document, element:target, xml:xml} );
			video.style.display = "block";
			target.addChild( video );
		}

		public function setup( event:Event ) :void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, setup);
			
			var elementStyles:Object = computedStyles;
			
			video = new Video(); 
			
			var customClient:Object = new Object();
			customClient.onMetaData = metaDataHandler;

 			nc = new NetConnection();
			nc.connect(null);
            
			ns = new NetStream(nc);
			ns.client = customClient;
			ns.bufferTime = 5;

			st = new SoundTransform();
			ns.soundTransform = st;
			
			video.attachNetStream(ns);
			
			//!data.file ? file = "movie.flv" : file = data.file; //data.file;
			//file = "http://74.125.1.98/get_video?video_id=cowCS_OoDSY&origin=ash-v122.ash.youtube.com";
			
			file = innerXML.@src.toString();
			
			video.x = elementStyles.padding.left||0;
			video.y = elementStyles.padding.top||0;
			var w:int = innerXML.@width.toString() || elementStyles.width;
			var h:int = innerXML.@height.toString() || elementStyles.height;
			video.width = w - elementStyles.padding.left - elementStyles.padding.right;
			video.height = h - elementStyles.padding.top - elementStyles.padding.bottom;
			if( video.height == 0 ) // if there is no height make it 4:3
				video.height = video.width*0.75; 
				
			if( file && innerXML.@autoplay.toString() ) play();
			else if( innerXML.@poster.toString() ){
				posterURL = innerXML.@poster.toString()
				/*
				app.loader.add( posterURL );
				app.loader.addEventListener(Event.COMPLETE, onPosterLoaded);
				app.loader.start()
				*/
			}
			addChild( video );
		}
		
		private function metaDataHandler(infoObject:Object, ...rest):void {
			totalTime = infoObject.duration;
		}
		
		private function onPosterLoaded( event:Event ):void
		{
			//poster = app.loader.getBitmap( posterURL, true );
			poster.width = video.width;
			poster.height = video.height;
			addChild( poster );
		}
		
		/*
		private function progressBarEv( ev:Event ) : void {
			if(Math.floor( barWidth * ns.time / totalTime) > 25)
				seekBarMask.draw( 0, -5, Math.floor( barWidth * ns.time / totalTime), 25, { r:25 } );
			else
				seekBarMask.draw( 0, -5, 25, 25, { r:25 } );
				
			seekHandle.x = seekBarMask.width - 20;	
		}
		
		private function percentBarEv(ev:Event) :void {
			
			var loaded:int = ns.bytesLoaded;
			var total:int = ns.bytesTotal;
			if( loaded == total && loaded > 1000) {
				//seekBack2.width = barWidth - 4;
				removeEventListener(Event.ENTER_FRAME, percentBarEv);
			} else {
				//seekBack2.width = (barWidth - 4) * loaded / total;
			}
		};
		*/
		public function pause(ev:Event = null):void{
			if( ns.time == totalTime ){
				ns.seek(0);
				ns.resume();
				//pauseBtn.alpha = 0;
			}else{
				if( isPaused ){
					//pauseBtn.alpha = 0;
					ns.pause();
				}else{
					//pauseBtn.alpha = 1;
					ns.resume();
				}
			}
		}

		public function play(ev:Event = null) :void {
			isStarted = true;
			isPlaying = true;
			isPaused = false;
			ns.play( file );
			//pauseBtn.alpha = 1;
			if( poster && poster.parent )
				poster.parent.removeChild(poster);
		}
		/*
		public function videoBtn() :void {
			if( pauseBtn.alpha != 1 ) playMovie();
			else pauseMovie();
		}
		
		public function percentBarDown( ev:MouseEvent ) :void {
			seekBar.addEventListener(Event.ENTER_FRAME, whileDownPercent);
		}
		
		private function whileDownPercent(ev:Event) :void {
			var scale:Number = (mouseX - 80) * 100 / barWidth / 100;
			ns.seek( ( scale * totalTime) );
		}

		private function percentBarUp(ev:MouseEvent) :void { 
			seekBar.removeEventListener(Event.ENTER_FRAME, whileDownPercent);
			//pauseBtn.alpha == 0 ? pauseMovie() : null;
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
				var volH:int = Math.abs(volumeHeight * scale - volumeHeight);
				if(volH< 17)
					volumeBar.draw(4, Math.ceil(( (volumeBack2.height - 8) / 100 ) * ( scale * 100 ))+4, 17,  17 , { color:0xFCB62A, r:17 });
				else
					volumeBar.draw(4, Math.ceil(( (volumeBack2.height - 8) / 100 ) * ( scale * 100 ))+4, 17,  volH , { color:0xFCB62A, r:17 });
				st.volume = 1 - scale;
			}
			ns.soundTransform = st;
		}

		private function volumeUp(ev:MouseEvent = null) :void 
		{ 
			volumeBack.removeEventListener(Event.ENTER_FRAME, whileDownVolume);
			removeEventListener(MouseEvent.MOUSE_UP, volumeUp);
			volumeBack.visible = false;
		}
		
		private function closePlayer(  ev:MouseEvent ):void 
		{
			ns.close();
			nc = new NetConnection();
			video = new Video();
			removeEventListener(Event.ENTER_FRAME, progressBarEv);
			target.closeSelected( this );
		}
		
		private function onResize(ev:Event):void 
		{
			placeElements();
		}
		*/
	}
	
}

