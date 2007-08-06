﻿package nl.projects{	import flash.display.*;	import flash.events.*;	import flash.text.*;	import flash.utils.*;	import flash.ui.Keyboard;	import flash.geom.*;	import away3d.loaders.*;	import away3d.cameras.*;	import away3d.objects.*;	import away3d.core.*;	import away3d.core.material.*;	import away3d.core.scene.*;	import away3d.core.render.*;	import away3d.loaders.Obj;	//	import nl.fabrice.widgets.Slider;	import flash.text.TextFormat;	import nl.fabrice.bitmapdata.BMDScrollerRegister;		import away3d.core.material.fx.*;	public class BumpInterface extends Sprite	{		public var scene:Scene3D;		public var objmodel:Object3D;		public var objmodel2:Object3D;		public var objmodel3:Object3D;		public var destbm:Bitmap;		public var destBMD:BitmapData;		protected var view:View3D;		protected var camera:HoverCamera3D;		//perftest		private var fpslabel:TextField;		private var cpulabel:TextField;		private var lastrender:int = 0;		//light		private var light:AmbientLight;		//sliders		private var mySliderR:Slider;		private var mySliderG:Slider;		private var mySliderB:Slider;		//private var mySliderY:Slider;		public var lightmodel;		//		private var zeroPoint:Point;				public var texture:BitmapData;		public var bumpsource:BitmapData;		private var bumpmask:BitmapData;		public var sourcetexture:BitmapData;		public var lightMap:BitmapData;		public var lightMap2:BitmapData;		private var bump:Bump;		private var perlin:PerlinNoise;		//		public function BumpInterface()		{			//this.goFullScreen();			this.initSWFEnvironement();			fpslabel = new TextField();			 			this.prepareWorld();			this.preparePerfFields();			//this.addSliders(); 		}		private function preparePerfFields():void		{			//fpslabel = new TextField();			fpslabel.x = 10;			fpslabel.y = 10;			fpslabel.defaultTextFormat = new TextFormat("Verdana", 10, 0x000000);			fpslabel.text = "";			fpslabel.background = true;			fpslabel.height = 15;			fpslabel.width = 200;			fpslabel.backgroundColor = 0xFF9900;			 			this.addChild(fpslabel);		}		private function goFullScreen():void		{			//stage["fullScreenSourceRect"] = new Rectangle(0, 0, Stage.width, Stage.height);			stage.displayState = "fullScreen";		}		private function initSWFEnvironement():void		{			stage.align = StageAlign.TOP_LEFT;			stage.scaleMode = StageScaleMode.NO_SCALE;			stage.showDefaultContextMenu = false;			stage.stageFocusRect = false;		}		private function generateFromLib(source_ID:String):BitmapData		{			var classRef:Class = getDefinitionByName(source_ID) as Class;			var mySprite:Sprite = new classRef();			var temp_bmd:BitmapData = new BitmapData(mySprite.width, mySprite.height, true, 0x00FFFFFF);			temp_bmd.draw(mySprite, null, null, null, temp_bmd.rect, true);			return temp_bmd;		}		private function prepareWorld():void		{			this.lightMap = this.generateFromLib("stonelight");//			this.lightMap2 = this.lightMap.clone();						this.texture = this.generateFromLib("stonecolor");//fur,lightMap			this.sourcetexture = this.texture.clone();			this.bumpsource = this.generateFromLib("stonebump");//stonebump			//mask of fx			this.bumpmask = this.generateFromLib("stonereflect");//mask on fx			//this.destbm = new Bitmap();			//this.destBMD = new BitmapData(stage.stageWidth , stage.stageHeight, false, 0x000000);			//this.destbm.bitmapData = this.destBMD;			//this.addChild(this.destbm);			this.scene = new Scene3D();			//XXXXXXXXXXXXXXXXX			//Away new FX's			//XXXXXXXXXXXXXXXXX			//BUMP			////add, overlay, screen, substract, multiply, layer, invert, hardlight, erase, darken, alpha, difference			this.bump = new Bump(this.bumpsource, this.lightMap, "overlay", this.bumpmask);//, 						//PERLINNOISE			// perlin_bmd:BitmapData, baseX:Number, baseY:Number, numOctaves:uint, randomSeed:int, stitch:Boolean, fractalNoise:Boolean, channelOptions:uint = 7, grayScale:Boolean = false, offsets:Array = null			this.perlin = new PerlinNoise(this.bumpsource, this.bumpsource.width, this.bumpsource.height, 4, 5, false, true, 4, false, null);			//custom pixelscroller, will be updated as an internal class			BMDScrollerRegister.getInstance().setDestBMD(this.lightMap);			BMDScrollerRegister.getInstance().addScroll("lightmap", this.lightMap.width, this.lightMap.height, this.lightMap2, 0, 0, false);						//XXXXXXXXXXXXXXXXX			//new Away materials			//XXXXXXXXXXXXXXXXX			//var mat:IMaterial = new PointBitmapMaterial(this.destBMD, 0x0099FF, {offsetX:stage.stageWidth / 2,  offsetY:stage.stageHeight / 2, pointsize:8, light:"flat"});			//var mat:IMaterial = new FillBitmapMaterial(this.destBMD, 0x880099FF, {offsetX:stage.stageWidth / 2,  offsetY:stage.stageHeight / 2, linecolor:0x886633CC , light:"flat"});			//var mat:IMaterial = new WireframeBitmapMaterial(this.destBMD, 0xFFccFFcc, {offsetX:stage.stageWidth / 2, offsetY:stage.stageHeight / 2, light:"flat"});//flat,smooth			//var mat:IMaterial = new TraceBitmapMaterial(texture, this.destBMD, {offsetX:stage.stageWidth / 2, offsetY:stage.stageHeight / 2, light:"flat"},[bump]);//flat,smooth			var mat:IMaterial = new BitmapMaterial(this.texture, {light:"flatno", smooth:false},[this.bump]);//,this.perlin , 			//			//XXXXXXXXXXXXXXXXX			// objects			//XXXXXXXXXXXXXXXXXs						//var mat:IMaterial = new WireframeMaterial(0xFF0000);			// this.objmodel = Obj.parse("OBJs/turtle.obj", mat , {bothsides:false}, 1 );			//this.objmodel = Obj.parse("OBJs/turtle.obj", mat, {bothsides:false}, 1);			//this.objmodel = new Sphere({material:mat, radius:350, segmentsW:10, segmentsH:10});			//this.objmodel = new Sphere({material:"blue#cyan", radius:250, segmentsW:12, segmentsH:9, y:50, x:10, z:10});			this.objmodel = new Sphere({material:mat, radius:300, segmentsW:16, segmentsH:16, y:0, x:0, z:0});			//this.objmodel = new Plane(mat, {width:800,height:800, segmentsW:4, segmentsH:4});			//this.objmodel = Ase.parse("ASEs/seaturtle.ase",mat,{},4);			this.objmodel.x = 0;			this.scene.addChild(this.objmodel);						 			//skybox			//var bumptest = new Bump(this.bumpsource, this.lightMap , "erase")			var mat2:IMaterial = new BitmapMaterial(this.lightMap);//,{}, [bumptest]);			this.objmodel2 = new Sphere({material:mat2, radius:3000, segmentsW:15, segmentsH:15,bothsides:true, y:0, x:0, z:0});			this.scene.addChild(this.objmodel2);			 						//FF9900			this.light = new AmbientLight(0xFFFFFF, 600, 200, 300, 60, 0.2);						this.camera = new HoverCamera3D({zoom:3, focus:200, distance:800});			this.camera.tiltangle = 10;			this.camera.targettiltangle = 40;			this.camera.panangle = 40;			this.camera.targetpanangle = 120;			this.camera.mintiltangle = -10;			this.camera.lookAt(this.objmodel.position);						this.view = new View3D({scene:this.scene, camera:this.camera, renderer:Renderer.BASIC});			this.view.x = stage.stageWidth / 2;			this.view.y = stage.stageHeight / 2;			this.view.camera = camera;			this.addChild(this.view);			stage.addEventListener(Event.ENTER_FRAME, this.refreshScreen);			stage.addEventListener(Event.RESIZE, this.onResize);		}		private function refreshScreen(event:Event):void		{						//uncomment for bitmapdata only traces			//this.destBMD.fillRect(this.destBMD.rect, 0x000000);			//			 			var offsetx:Number = 2;			var offsety:Number = 2;			if (this.view.mouseX > 0) {				this.camera.targetpanangle -= 2;				offsetx = -2;			}			if (this.view.mouseX < 0) {				this.camera.targetpanangle += 2;				offsetx = 2;			}			if (this.view.mouseY > 0) {				this.camera.targettiltangle -= 2;				offsety = -2;			}			if (this.view.mouseY < 0) {				this.camera.targettiltangle += 2;				offsety = 2;			}			  			//this.objmodel.rotationY +=5;			//this.objmodel.rotationX +=5;			//this.objmodel2.rotationY +=5;			//this.objmodel2.rotationX +=5;			//this.objmodel3.rotationY +=5;			//this.objmodel3.rotationX +=5;			 this.camera.hover();			 									//perlin update			//this.bumpsource.width, this.bumpsource.height, 4, 5, false, true, 4, false, null			//var oNoise = {baseX:this.bumpsource.width, baseY:this.bumpsource.height, numOctaves:Math.random()*10, randomSeed:Math.random()*10, stitch:false, fractalNoise:true, channelOptions:4, grayScale:false, offsets:null};			//this.perlin.noise = oNoise;						/*http://www.gamedev.net/reference/articles/article791.asptheta = arctan (y/x).rho = arccos (z/R).R = sqrt (x^2 + y^2 + z^2)*/			//BMDScrollerRegister.getInstance().update("lightmap", 0, 0, offsetx, offsety );															 BMDScrollerRegister.getInstance().update("lightmap", 0, 0, this.view.mouseX/2, this.view.mouseY/2 );			//BMDScrollerRegister.getInstance().update("lightmap", 5, 5, 0, 0 );			//stage.removeEventListener(Event.ENTER_FRAME, this.refreshScreen);			this.view.render();			this.updateFPS();		}		private function updateFPS():void		{			var now:int = getTimer();			var performance:int = now - lastrender;			lastrender = now;			if (performance < 1000) {				fpslabel.text = "" + int(1000 / (performance+0.001)) + " fps " + performance + " ms";				fpslabel.width = 4 * performance;			}		}		private function onResize(event:Event):void		{			//this.destBMD = new BitmapData(stage.stageWidth ,stage.stageHeight , false, 0x00);			//this.destbm.bitmapData = this.destBMD;			this.view.x = stage.stageWidth / 2;			this.view.y = stage.stageHeight / 2;		}		//XXXXXXXXXXXXXXXXXXXX  sliders  XXXXXXXXXXXXXXXXXXXXXX		private function addSliders():void		{			trace("add sliders");			var tf = new TextFormat();			tf.size = 10;			tf.align = "left";			tf.font = "Verdana";			tf.color = 0xFFFFFF;			 			this.mySliderR = new Slider();			this.mySliderR.start(this, 10, 40, 255, 254, 127, -127, 2 ,"Red", tf);			this.mySliderR.addEventListener("SCROLL",onScrollR);			//color sliders			this.mySliderG = new Slider();			this.mySliderG.start(this, 10, 90, 255, 2, 1, -1, 1,"Green", tf);			this.mySliderG.addEventListener("SCROLL", onScrollG);			this.mySliderB = new Slider();			this.mySliderB.start(this, 10, 130, 255, 2, 1, 0, 2,"Blue", tf);			this.mySliderB.addEventListener("SCROLL", onScrollB);			//this.mySliderY = new Slider();			//this.mySliderY.start(this, 10, 170, 255, 2, 1, 0, 2,"Y", tf);			//this.mySliderY.addEventListener("SCROLL", onScrollB); 			//refresh			// this.light.color = this.composeColor();		}				//light positions		private function onScrollX(e:Event):void		{			this.lightmodel.x = e.target.value ;			this.light.x = e.target.value;		}		private function onScrollY(e:Event):void		{			this.lightmodel.y = e.target.value ;			this.light.y = e.target.value;		}		private function onScrollZ(e:Event):void		{			this.lightmodel.z = e.target.value ;			this.light.z = e.target.value;		}		//		private function onScrollR(e:Event):void		{			 this.light.color = this.composeColor();		}		private function onScrollG(e:Event):void		{			 this.light.color = this.composeColor();		}		private function onScrollB(e:Event):void		{			 this.light.color = this.composeColor();		}		private function composeColor():Number		{			var r:Number = this.mySliderR.value;			var g:Number = this.mySliderG.value;			var b:Number = this.mySliderB.value;			return r << 16 | g << 8 | b;		}		private function onScrollBias(e:Event):void		{			//this.light.brightness = e.target.value;	//this.CF = null;	//			this.CF.bias = e.target.value;		}		private function onScrollDivisor(e:Event):void		{			//this.light.ambient = e.target.value;			//this.CF.divisor = e.target.value;		}	}}