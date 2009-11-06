﻿package away3d.materials{	import away3d.arcane;	import away3d.core.utils.*;	import away3d.events.*;		import flash.display.BitmapData;	import flash.display.Sprite;	import flash.events.AsyncErrorEvent;	import flash.events.IOErrorEvent;	import flash.events.NetStatusEvent;	import flash.events.SecurityErrorEvent;	import flash.media.Video;	import flash.net.NetConnection;	import flash.net.NetStream;	import flash.text.StyleSheet;	import flash.text.TextField;	import flash.media.SoundTransform;		use namespace arcane;	     public class VideoMaterial extends MovieMaterial    {                private var _file:String;        private var _netStream:NetStream;		private var _video:Video;        private var _loop:Boolean;    		private var _lockW:Number;		private var _lockH:Number;		private var CustomClient:Object;         private function initStream():void        {			try {				nc = new NetConnection();				nc.client = CustomClient;				nc.addEventListener(NetStatusEvent.NET_STATUS,netStatusHandler);				nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityErrorHandler,false,0,true);	        	nc.connect(_rtmp);				this.movie = sprite;				updateDimensions();			} catch (e:Error) {				showError("An error has occured with the flv stream:" + e.message);			}        }                private function playStream():void        {        	_netStream = new NetStream(nc);			_netStream.checkPolicyFile = true;			_netStream.client = CustomClient;        	_netStream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler,false,0,true);			_netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, ayncErrorHandler,false,0,true);			_netStream.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler,false,0,true);			play();						if(video == null){				// Setup video object				video = new Video();				video.smoothing = true;				sprite.addChild(video);			}						video.attachNetStream(_netStream);        }                /**        * We must update the material        */        private function updateDimensions():void        {        	_lockW = ini.getNumber("lockW", movie.width);			_lockH = ini.getNumber("lockH", movie.height);            _bitmap = new BitmapData(Math.max(1,_lockW), Math.max(1,_lockH), transparent, (transparent) ? 0x00ffffff : 0);        }				// Event handling		private function ayncErrorHandler(event:AsyncErrorEvent): void		{			// Must be present to prevent errors, but won't do anything		}				private function metaDataHandler(oData:Object = null):void		{			// Offers info such as oData.duration, oData.width, oData.height, oData.framerate and more (if encoded into the FLV)			this.dispatchEvent( new VideoEvent(VideoEvent.METADATA,_netStream,file,oData) );		}				private function ioErrorHandler(e:IOErrorEvent):void		{			showError("An IOerror occured: "+e.text);		}				private function securityErrorHandler(e:SecurityErrorEvent):void		{			showError("A security error occured: "+e.text+" Remember that the FLV must be in the same security sandbox as your SWF.");		}				private function onBWDone():void		{			// Must be present to prevent errors for RTMP, but won't do anything		}	    private function streamClose():void		{			 showError("The stream was closed. Incorrect URL?");		}				private function showError(txt:String, e:NetStatusEvent = null):void		{			sprite.graphics.beginFill(0x333333);			sprite.graphics.drawRect(0,0,400,300);			sprite.graphics.endFill();						// Error text formatting			var style:StyleSheet = new StyleSheet();			var styleObj:Object = {};			styleObj["fontSize"] = 24;			styleObj["fontWeight"] = "bold";			styleObj["color"] = "#FF0000";			style.setStyle("p", styleObj);						// make textfield			var text:TextField = new TextField();			text.width = 400;			text.multiline = true;			text.wordWrap = true;			text.styleSheet = style;			text.text = "<p>"+txt+"</p>";			sprite.addChild(text);			 			updateDimensions();		}				private function netStatusHandler(e:NetStatusEvent):void		{            switch (e.info["code"]) {                case "NetStream.Play.Stop": 					this.dispatchEvent( new VideoEvent(VideoEvent.STOP,_netStream, file) ); 					if(loop)						_netStream.play(file);											break;                case "NetStream.Play.Play":					this.dispatchEvent( new VideoEvent(VideoEvent.PLAY,_netStream, file) );					break;                case "NetStream.Play.StreamNotFound":					showError("The file "+file+" was not found", e);					break;                case "NetConnection.Connect.Success":					playStream();					break;            }        }				/**        * Plays the NetStream object. The material plays the NetStream object by default at init. Use this handler only if you pause the NetStream object;        */		public function play():void		{			_netStream.play(file); 		}				/**        * Pauses the NetStream object        */		public function pause():void		{			_netStream.pause();		}				/**        * Seeks to a given time in the file, specified in seconds, with a precision of three decimal places (milliseconds).		* For a progressive download, you can seek only to a keyframe, so a seek takes you to the time of the first keyframe after the specified time. (When streaming, a seek always goes to the precise specified time even if the source FLV file doesn't have a keyframe there.) 		* @param	val		Number: the playheadtime        */		public function seek(val:Number):void		{ 			pause(); 			_netStream.seek(val);			_netStream.resume();		}				/**        * Returns the actual time of the netStream        */		public function get time():Number		{			return _netStream.time;		}				/**        * Closes the NetStream object        */		public function close():void		{			_netStream.close();		}				 /**        * The sound pan		* @param	val		Number: the sound pan, a value from -1 to 1. Default is 0;        */		public function set pan(val:Number):void		{            var transform:SoundTransform = _netStream.soundTransform;            transform.pan = val;            _netStream.soundTransform = transform;        }				 /**        * The sound volume		* @param	val		Number: the sound volume, a value from 0 to 1. Default is 0;        */        public function set volume(val:Number):void		{            var transform:SoundTransform = _netStream.soundTransform;            transform.volume = val;            _netStream.soundTransform = transform;        }				 /**        * The FLV url used for rendering the material        */        public function get file():String        {        	return _file;        }         public function set file(file:String):void        {        	// first split out the file and server			if(file.indexOf("rtmp") != -1){ // is RTMP				_rtmp = "";				var tmpArr:Array = file.split("/");				var i:uint; var l:uint = tmpArr.length;				for(i=0;i<l-1;i++){					_rtmp += tmpArr[i]+"/";				}				_file = tmpArr[tmpArr.length-1];			} else { // is FLV				_rtmp = null;				_file = file;			}        	initStream();        } 				 /**        * The NetStream object used by the class        */		public function get netStream():NetStream        {        	return _netStream;        } 		        public function set netStream(ns:NetStream):void        {        	_netStream = ns;        }				/**        * Defines if the FLV will loop        */		public function get loop():Boolean        {        	return _loop;        } 		        public function set loop(b:Boolean):void        {        	_loop = b;        }				/**        * The Video Object        */		public function get video():Video        {        	return _video;        } 		        public function set video(newvideo:Video):void        {        	if( _video ){				sprite.removeChild(_video);        	}			_video = null;			_video = newvideo;			_video.smoothing = true;			sprite.addChild(_video);			_video.attachNetStream(_netStream);        }        		/**        * Defines the NetConnection we'll use        */        public var nc:NetConnection;				/**        * If the filename starts with "rtmp", this var will hold the path to the server        */        private var _rtmp:String;             /**        * A Sprite we can return to the MovieMaterial        */        public var sprite:Sprite;				/**		* Creates a new <code>VideoMaterial</code> object.		* Pass file:"somevideo.flv" in the initobject or set the file to start playing a video.		* Be aware that FLV files must be located in the same domain as the SWF or you will get security errors.		* NOTE: rtmp is not yet supported		* 		* @param	file				The url to the FLV file.		* @param	init	[optional]	An initialisation object for specifying default instance properties. loop:Boolean, file:String, rtmp:String.		*/                public function VideoMaterial(init:Object = null)        {        	sprite = new Sprite();			super(sprite,ini);                        // client object that'll redirect various calls from the video stream            CustomClient = {};			CustomClient["onCuePoint"] = metaDataHandler;			CustomClient["onMetaData"] = metaDataHandler;			CustomClient["onBWDone"] = onBWDone;			CustomClient["close"] = streamClose;						ini = Init.parse(init);            loop = ini.getBoolean("loop", false);            file = ini.getString("file", "");        }		    }}