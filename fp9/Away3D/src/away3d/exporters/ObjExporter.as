﻿package away3d.exporters{	import flash.system.*;	import away3d.core.base.UV;	import away3d.core.base.Mesh;	import away3d.core.base.Geometry;	import away3d.core.base.Object3D;	import away3d.containers.ObjectContainer3D;	import away3d.core.base.Face;	import away3d.core.math.Number3D;	import away3d.arcane;	import away3d.animators.utils.PathUtils;		use namespace arcane;		/**	* Class ObjExporter generates a string in the WaveFront obj format representing the object3D(s). Paste to a texteditor and save as filename.obj.	* 	*/	public class ObjExporter	{		private var objString:String;		private var gcount:int = 0;		private var indV:int = 0;		private var indVn:int = 0;		private var indVt:int = 0;		private var indF:int = 0;		private var _scaling:Number;		private var _righthanded:Boolean;		private var nRotation:Number3D = new Number3D();			private  function write(object3d:Object3D):void		{			var aV:Array = [];			var aVn:Array = [];			var aVt:Array = [];			var aF:Array = [];					objString +="\n";						var aFaces:Array = (object3d as Mesh).faces;			var face:Face;			 			var n0:Number3D;			var n1:Number3D;			var n2:Number3D;			 			var geometry:Geometry = (object3d as Mesh).geometry;						var va:int;			var vb:int;			var vc:int;						var vta:int;			var vtb:int;			var vtc:int;						var na:int;			var nb:int;			var nc:int;						nRotation.x = object3d.rotationX;			nRotation.y = object3d.rotationY;			nRotation.z = object3d.rotationZ;			 			var nPos:Number3D = object3d.scenePosition;						var tmp:Number3D = new Number3D();			var j:int;			var aRef:Array = [vc, vb, va];						for(var i:int = 0; i<aFaces.length ; ++i)			{				face = aFaces[i];				for(j=2;j>-1;--j){					tmp.x =  (face["v"+j].x + nPos.x) *_scaling;					tmp.y =  (face["v"+j].y + nPos.y) *_scaling;					tmp.z =  (face["v"+j].z + nPos.z) *_scaling;					tmp = PathUtils.rotatePoint(tmp, nRotation);					if(_righthanded){						//will add Y up var						//tmp.y *= -1;						tmp.x *= -1;					}					aRef[j] = checkDoubles( aV, ("v "+tmp.x.toFixed(10)+" "+tmp.y.toFixed(10)+" "+tmp.z.toFixed(10)+"\n") );				}								vta = checkDoubles( aVt, ("vt "+(_righthanded? 1-face.uv2.u : face.uv2.u)+" "+face.uv2.v +"\n"));				vtb = checkDoubles( aVt, ("vt "+(_righthanded? 1-face.uv1.u : face.uv1.u)+" "+face.uv1.v +"\n"));				vtc = checkDoubles( aVt, ("vt "+(_righthanded? 1-face.uv0.u : face.uv0.u)+" "+face.uv0.v +"\n"));								n0 = geometry.getVertexNormal(face.v0);				n1 = geometry.getVertexNormal(face.v1);				n2 = geometry.getVertexNormal(face.v2);								na = checkDoubles( aVn, ("vn "+n2.x.toFixed(15)+" "+n2.y.toFixed(15)+" "+n2.z.toFixed(15)+"\n") );				nb = checkDoubles( aVn, ("vn "+n1.x.toFixed(15)+" "+n1.y.toFixed(15)+" "+n1.z.toFixed(15)+"\n") );			 	nc = checkDoubles( aVn, ("vn "+n0.x.toFixed(15)+" "+n0.y.toFixed(15)+" "+n0.z.toFixed(15)+"\n") );								aF.push("f "+(aRef[2]+indV)+"/"+(vta+indVt)+"/"+(na+indVn)+" "+(aRef[1]+indV)+"/"+(vtb+indVt)+"/"+(nb+indVn)+" "+(aRef[0]+indV)+"/"+(vtc+indVt)+"/"+(nc+indVn)+"\n");			}						indV += aV.length;			indVn += aVn.length;			indVt += aVt.length;			indF += aF.length;						objString += "# Number of vertices: "+aV.length+"\n";			for( i = 0; i < aV.length ; ++i){				objString += aV[i];			}						objString += "\n# Number of Normals: "+aVn.length+"\n";			for( i = 0; i < aVn.length ; ++i){				objString += aVn[i];			}						objString += "\n# Number of Texture Vertices: "+aVt.length+"\n";			for( i = 0; i < aVt.length ; ++i){				objString += aVt[i];			}			objString += "\n# Number of Polygons: "+aF.length+"\n";			for( i = 0; i < aF.length ; ++i){				objString += aF[i];			}					}				private function checkDoubles(arr:Array, string:String):int		{			for(var i:int = 0;i<arr.length;++i){				if(arr[i] == string) return i+1;			}			arr.push(string);			return arr.length;		}				private  function parse(object3d:Object3D):void		{			if(object3d is ObjectContainer3D){							var obj:ObjectContainer3D = (object3d as ObjectContainer3D);				objString += "g g"+gcount+"\n";				gcount++;				for(var i:int =0;i<obj.children.length;++i){					if(obj.children[i] is ObjectContainer3D){						parse(obj.children[i]);					} else{						write( obj.children[i]);					}				}						} else {				write( object3d);			}		}		/**		* Generates a string in the WaveFront obj format representing the object3D(s). Paste to a texteditor and save as filename.obj.		*		* @param	object3d				Object3D. The Object3D to be exported to WaveFront obj format.		* @param	righthanded			[optional] Boolean. If the model output need to be flipped to righthanded system. Default = true.		* @param	scaling					[optional] Number. if the model output needs to be resized. Default = 0.001.		*/		function ObjExporter(object3d:Object3D, righthanded:Boolean = true, scaling:Number = 0.001){			objString = "# Obj file generated by Away3D: http://www.away3d.com\n# exporter version 1.0 \n";			_righthanded = righthanded;			_scaling = scaling;			parse(object3d);			objString += "\n#\n# Total number of vertices: "+indV;			objString += "\n# Total number of Normals: "+indVn;			objString += "\n# Total number of Texture Vertices: "+indVt;			objString += "\n# Total number of Polygons: "+indF+"\n";			objString += "\n# End of File";			System.setClipboard(objString);			trace("ObjExporter done: open an external texteditor and paste!!");		}		 	}}