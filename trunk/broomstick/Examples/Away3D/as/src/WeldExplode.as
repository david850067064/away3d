﻿package {		[SWF(width="1168", height="630", frameRate="60", backgroundColor="#CCCCCC")]			import away3d.containers.ObjectContainer3D;	import away3d.containers.View3D;	import away3d.events.LoadingEvent;	import away3d.loaders.Loader3D;	import away3d.loaders.parsers.AC3DParser;	import away3d.tools.Explode;	import away3d.tools.Weld;		import flash.display.Sprite;	import flash.events.Event;	import flash.net.URLRequest;	import flash.text.TextField;
	 	public class WeldExplode extends Sprite	{		private var _view : View3D;		private var _loader : Loader3D;				private var field:TextField;		 		public function WeldExplode()		{			_view = new View3D();			_view.camera.z = -900;			addChild(_view);						Loader3D.enableParser(AC3DParser);			 			_loader = new Loader3D();			_loader.addEventListener(LoadingEvent.RESOURCE_COMPLETE, onResourceComplete);			_loader.load(new URLRequest('assets/models/2faces.ac'));			_view.scene.addChild(_loader);		}		 		private function onResourceComplete(e:LoadingEvent) : void		{			trace("onResourceRetrieved event fired");						Weld.apply(_loader);			trace("VerticesRemoved:--> "+Weld.verticesRemoved);						Explode.apply(_loader);			trace("VerticesAdded:--> "+Explode.verticesAdded);						_view.scene.addChild(_loader);			this.addEventListener(Event.ENTER_FRAME, handleEnterFrame);		}				private function handleEnterFrame(e:Event) : void		{			_loader.rotationY += 1;			_view.render();		}	}}