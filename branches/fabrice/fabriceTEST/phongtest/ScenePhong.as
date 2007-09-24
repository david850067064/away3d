﻿package nl.projects{	import flash.display.*;	import flash.events.Event;	import flash.geom.*;	import flash.utils.getDefinitionByName;	import away3d.loaders.*;	import away3d.cameras.*;	import away3d.objects.*;	import away3d.core.*;	import away3d.core.material.*;	import away3d.core.scene.*;	import away3d.core.render.*;	import away3d.core.math.Number3D;		//debug	import away3d.register.AWClass;	import nl.fabrice.widgets.Slider;	import flash.text.TextFormat;		 	 	public class ScenePhong extends AWClass	{		public var scene:Scene3D;		public var objmodel:ObjectContainer3D;		public var objmodel2:ObjectContainer3D;		public var lightmodel:Object3D;		protected var view:View3D;		protected var camera:HoverCamera3D;		public var texture:BitmapData;		public var light:AmbientLight;		private var groupone:Object3D;		private var sign:Sprite;		private var myloader:Object3DLoader;		//debug		public var debugbmd:BitmapData;		public var debugtracebmd:BitmapData;		// sliders		private var mySliderR:Slider;		private var mySliderG:Slider;		private var mySliderB:Slider;		private var mySliderX:Slider;		private var mySliderY:Slider;		private var mySliderZ:Slider;		private var mySliderBrightness:Slider;		private var mySliderAmbient:Slider;				private var mySliderOffsetX:Slider;		private var mySliderOffsetY:Slider;		//		// scnery lightning		private var globallight:GlobalLight;				//		public function ScenePhong()		{			this.register("MAIN");			//			//{id:"default", color: 0xFFFFFF, new Number3D(300,300,0)}			this.globallight = new GlobalLight();			this.initSWFEnvironement();			this.prepareWorld();			this.showSignature();			this.addSliders(); 		}		private function showSignature():void		{			this.sign = new signature()			this.addChild(sign);			//sign.x = 20;			this.sign.y = stage.stageHeight-(this.sign.height);					}		private function initSWFEnvironement():void		{			stage.align = StageAlign.TOP_LEFT;			stage.scaleMode = StageScaleMode.NO_SCALE;			stage.showDefaultContextMenu = true;			stage.stageFocusRect = false;		}		private function generateFromLib(source_ID:String):BitmapData		{			var classRef:Class = getDefinitionByName(source_ID) as Class;			var mySprite:Sprite = new classRef();			var temp_bmd:BitmapData = new BitmapData(mySprite.width, mySprite.height, true, 0x00FFFFFF);			temp_bmd.draw(mySprite, null, null, null, temp_bmd.rect, true);			return temp_bmd;		}				//loader events		public function setobj(e:Event):void		{ 			this.lightmodel =  this.myloader.result;			this.scene.addChild(this.lightmodel);		}				private function prepareWorld():void		{			//loader.handle.x=80						var test:BitmapData = this.generateFromLib("color");			this.debugbmd = new BitmapData(test.width*3, test.height*3, false, 0xFFFFFF);			//this.debugbmd.copyPixels(test,test.rect,new Point(test.width, test.height));			this.debugtracebmd = this.debugbmd.clone();			var bm = new Bitmap();			bm.bitmapData = this.debugtracebmd;			var sprite = new Sprite();			sprite.addChild(bm);			//this.addChild(sprite);			sprite.scaleX = sprite.scaleY = .3;									//this.texture = this.generateFromLib("color");			this.scene = new Scene3D();			//light ambient			//CC9900			this.light = new AmbientLight(0x009999, 300, 0, 0, 60, 0.3);			//test object			//var mat:IMaterial = new EnviroMaterial(this.generateFromLib("gradient"),null,{light:"flat0", smooth:false}, []);			//var mat:IMaterial = new PhongMaterial(this.generateFromLib("color"),{light:"flat0", smooth:false});			var mat:IMaterial = new ScenicPhongMaterial(this.generateFromLib("color"),{smooth:false});			//var mat2:IMaterial = new PhongMaterial(this.generateFromLib("color"),{light:"flat0", smooth:false});			//var objmodel2 = new Sphere({material:mat2, radius:10, segmentsW:3, segmentsH:3, y:0, x:0, z:0,bothsides:false});			//this.scene.addChild(this.objmodel2);			//this.objmodel = new Cube({material:mat, width:350, height:350, depth:350, y:0, x:0, z:0,bothsides:false});			//this.objmodel = new Plane({material:mat, height:300, width:300, y:0, x:0, z:0});			//this.objmodel = Obj.load("OBJs/colibri.obj", {material:mat, scaling:0.22, bothsides:false, mousable:false});			//			//this.objmodel = Ase.load("ASEs/bush.ase", {material:mat, scaling:.25, bothsides:false, mousable:false, y:0, x:0, z:0});			this.objmodel = Ase.load("ASEs/seaturtle.ase", {material:mat, scaling:1.5, bothsides:false, mousable:false, y:0, x:0, z:0});			//this.objmodel = Ase.load("ASEs/Horse.ase", {material:mat, scaling:0.002, bothsides:false, mousable:false, y:0, x:0, z:0});			// this.objmodel = Obj.load("OBJs/1triangle.obj", {material:mat, scaling:2, bothsides:true, mousable:false, y:0, x:0, z:0});			//this.objmodel = Obj.load("OBJs/test6.obj", {material:mat, scaling:1, bothsides:true, mousable:false, debug:true});			//this.objmodel = Md2still.load("MD2s/man.md2", {material:mat, scaling:0.2, bothsides:false, mousable:false,y:0, x:300, z:0});			//this.objmodel = Obj.load("OBJs/cat_270.obj", {material:mat, scaling:0.2, bothsides:false, mousable:false,y:0, x:300, z:0});			//this.scene.addChild(this.objmodel);			//			//:::::::			//GROUPS 			//::::::: 			 			//this.objmodel = Obj.load("OBJs/Guitar_fab.obj", {material:mat, scaling:0.1, bothsides:false, mousable:false});			//this.objmodel = Md2still.load("MD2s/diamondX.MD2", {material:mat, scaling:.3, bothsides:true, mousable:false});						var sphere1 = new Sphere({material:mat, radius:220, segmentsW:10, segmentsH:6, y:500, x:600, z:0,bothsides:false});			var sphere2 = new Sphere({material:mat, radius:220, segmentsW:10, segmentsH:6, y:500, x:-600, z:0,bothsides:false});						this.groupone=new ObjectContainer3D(this.objmodel, sphere1, sphere2);			//, objmodel2			this.objmodel.y = 45;			 			//this.objmodel.rotationZ = -90;			//this.objmodel.rotationX = 90;			//objmodel2.y = 550;			//objmodel2.z = 2000;						//this.myloader = new Object3DLoader();			//this.myloader = Md2still.load("MD2s/diamondX.MD2", {material:mat, scaling:1.5, bothsides:false, mousable:false});			//this.myloader.addEventListener("loadsuccess", this.setobj);			//var mat2:IMaterial = new EnviroMaterial(this.generateFromLib("color"),this.generateFromLib("color"),{smooth:false}, []);			//var mat2:IMaterial = new ScenicPhongMaterial(this.generateFromLib("enviro"),{smooth:false});			this.lightmodel = new Sphere({material:mat, radius:220, segmentsW:10, segmentsH:6, y:500, x:0, z:0,bothsides:false});			this.scene.addChild(this.lightmodel); 			this.view = new View3D({scene:this.scene,  renderer:Renderer.BASIC});			this.view.x = stage.stageWidth / 2;			this.view.y = stage.stageHeight / 2;						this.view.camera.x = 0;			this.view.camera.y = 0;			this.view.camera.z = -2800;						this.view.camera.lookAt(new Number3D(0,0,0));			view.scene.addChild(groupone);			this.addChild(this.view);						stage.addEventListener(Event.ENTER_FRAME, this.refreshScreen);			stage.addEventListener(Event.RESIZE, this.onResize);			 		}		private function refreshScreen(event:Event):void		{			try{			//this.debugtracebmd.copyPixels(this.debugbmd, this.debugbmd.rect, new Point(0,0));						//AmbientLight.x -= 5;						this.groupone.rotationY += 1;			//this.groupone.rotationX += 2;			//this.groupone.rotationZ -= 2;			 			this.lightmodel.rotationY -= 4;			//this.objmodel2.rotationX += 1;									//this.view.camera.x =  stage.stageWidth / 2 - (this.mouseX*2) ;			//this.view.camera.y =  stage.stageHeight / 2 - (this.mouseY*2) ;			//this.view.camera.z =  -3000 -(stage.stageHeight / 2 - (this.mouseX*2)) ;			//this.view.camera.lookAt(new Number3D(-400,0,0));			this.view.render();			}catch(e:Error){				trace("--> render error");			}		}				private function onResize(event:Event):void		{			this.view.x = stage.stageWidth / 2;			this.view.y = stage.stageHeight / 2;			this.sign.y = stage.stageHeight-(this.sign.height);		}				//XXXXXXXXXXXXXXXXXXXX  sliders  XXXXXXXXXXXXXXXXXXXXXX		private function addSliders():void		{			//trace("add sliders");			var tf = new TextFormat();			tf.size = 10;			tf.align = "left";			tf.font = "Verdana";			tf.color = 0xFFFFFF;			//this.mySliderBrightness = new Slider();			//this.mySliderBrightness.start(this, 10, 40, 255, 100, 80, 0, 0,"brightness", tf);			//this.mySliderBrightness.addEventListener("SCROLL",onScrollBright);			//color sliders			/*			this.mySliderR = new Slider();			this.mySliderR.start(this, 10, 90, 255, 255, 255, 0, 0,"red", tf);			this.mySliderR.addEventListener("SCROLL", onScrollR);			this.mySliderG = new Slider();			this.mySliderG.start(this, 10, 130, 255, 255, 255, 0, 0,"green", tf);			this.mySliderG.addEventListener("SCROLL", onScrollG);			this.mySliderB = new Slider();			this.mySliderB.start(this, 10, 170, 255, 255, 255, 0, 0,"blue", tf);			this.mySliderB.addEventListener("SCROLL", onScrollB);			*/			//light position sliders			this.mySliderOffsetX = new Slider();			this.mySliderOffsetX.start(this, 275, 400, 250, 2, 0.5, -1, 5,"x light", tf);			this.mySliderOffsetX.addEventListener("SCROLL", onOffsetX);			this.mySliderOffsetY = new Slider();			this.mySliderOffsetY.start(this, 275, 450, 250, 2, 0.5, -1, 5,"y light", tf);			this.mySliderOffsetY.addEventListener("SCROLL", onOffsetY);			this.mySliderZ = new Slider();			this.mySliderZ.start(this, 275, 500, 250, 2, 0.5, -1, 5,"z light", tf);			this.mySliderZ.addEventListener("SCROLL", onOffsetZ);			 			//refresh			/* 			this.light.color = this.composeColor();			var pos:Number3D = this.light.position;			this.lightmodel.x = 0;			this.lightmodel.y = 0;			this.lightmodel.z = -300;			*/		}				//light position test normale phong		/*		private function onOffsetX(e:Event):void		{			this.light.offsetx = e.target.value;		}		private function onOffsetY(e:Event):void		{			this.light.offsety = e.target.value;		}		*/		private function onOffsetX(e:Event):void		{			this.globallight.x = e.target.value;		}		private function onOffsetY(e:Event):void		{			this.globallight.y = e.target.value;		}		private function onOffsetZ(e:Event):void		{			this.globallight.z = e.target.value;		}		//light positions		/*		private function onScrollX(e:Event):void		{			this.lightmodel.x = -e.target.value ;			this.light.x = e.target.value;		}		private function onScrollY(e:Event):void		{			this.lightmodel.y = -e.target.value ;			this.light.y = e.target.value;		}		private function onScrollZ(e:Event):void		{			this.lightmodel.z = -e.target.value ;			this.light.z = e.target.value;		}				//		private function onScrollR(e:Event):void		{			this.light.color = this.composeColor();		}		private function onScrollG(e:Event):void		{			this.light.color = this.composeColor();		}		private function onScrollB(e:Event):void		{			this.light.color = this.composeColor();		}		private function composeColor():Number		{			var r:Number = this.mySliderR.value;			var g:Number = this.mySliderG.value;			var b:Number = this.mySliderB.value;						return r<< 16 | g << 8 | b;		}		private function onScrollBright(e:Event):void		{			this.light.brightness = e.target.value;		}		private function onScrollAmbient(e:Event):void		{			this.light.ambient = e.target.value;		}		*/	}}