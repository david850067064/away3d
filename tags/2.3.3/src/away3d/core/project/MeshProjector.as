package away3d.core.project
{
	import away3d.cameras.*;
	import away3d.cameras.lenses.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.clip.*;
	import away3d.core.draw.*;
	import away3d.core.geom.*;
	import away3d.core.math.*;
	import away3d.core.utils.*;
	import away3d.materials.*;
	
	import flash.utils.*;
	
	public class MeshProjector implements IPrimitiveProvider
	{
		private var _view:View3D;
		private var _drawPrimitiveStore:DrawPrimitiveStore;
		private var _cameraVarsStore:CameraVarsStore;
		private var _mesh:Mesh;
		private var _frustumClipping:Boolean;
		private var _frustum:Frustum;
		private var _vertices:Array;
		private var _faces:Array;
		private var _triangles:Array;
		private var _clipFaceVOs:Boolean;
		private var _clippedFaceVOs:Array;
		private var _segments:Array;
		private var _billboards:Array;
		private var _camera:Camera3D;
		private var _clipping:Clipping;
		private var _lens:ILens;
		private var _focus:Number;
		private var _zoom:Number;
		private var _faceMaterial:ITriangleMaterial;
		private var _segmentMaterial:ISegmentMaterial;
		private var _billboardMaterial:IBillboardMaterial;
		private var _vertex:Vertex;
		private var _face:Face;
		private var _faceVO:FaceVO;
		private var _tri:DrawTriangle;
		private var _layerMaterial:ILayerMaterial;
		private var _faceMaterialVO:FaceMaterialVO;
		private var _uvt:UV;
		private var _smaterial:ISegmentMaterial;
		private var _bmaterial:IBillboardMaterial;
		private var _segment:Segment;
		private var _billboard:Billboard;
		private var _drawTriangle:DrawTriangle;
		private var _drawSegment:DrawSegment;
		private var _drawBillBoard:DrawBillboard;
		private var _backmat:ITriangleMaterial;
        private var _backface:Boolean;
        private var _uvmaterial:Boolean;
        private var _vt:ScreenVertex;
		private var _n01:Face;
		private var _n12:Face;
		private var _n20:Face;
		
		private var _sv0:ScreenVertex;
		private var _sv1:ScreenVertex;
		private var _sv2:ScreenVertex;
		
        private function front(face:Face, viewTransform:Matrix3D):Number
        {
            _sv0 = _lens.project(viewTransform, face.v0);
			_sv1 = _lens.project(viewTransform, face.v1);
			_sv2 = _lens.project(viewTransform, face.v2);
                
            return (_sv0.x*(_sv2.y - _sv1.y) + _sv1.x*(_sv0.y - _sv2.y) + _sv2.x*(_sv1.y - _sv0.y));
        }
        
        public function get view():View3D
        {
        	return _view;
        }
        public function set view(val:View3D):void
        {
        	_view = val;
        	_drawPrimitiveStore = view.drawPrimitiveStore;
        	_cameraVarsStore = view.cameraVarsStore;
        }
        
		public function primitives(source:Object3D, viewTransform:Matrix3D, consumer:IPrimitiveConsumer):void
		{
			_drawPrimitiveStore.createVertexDictionary(source);
			_cameraVarsStore.createVertexClassificationDictionary(source);
			
			_mesh = source as Mesh;
			_vertices = _mesh.vertices;
			_faces = _mesh.faces;
			_segments = _mesh.segments;
			_billboards = _mesh.billboards;
			
			_camera = _view.camera;
			_clipping = _view.screenClipping;
			_lens = _camera.lens;
        	_focus = _camera.focus;
        	_zoom = _camera.zoom;
        	
			_faceMaterial = _mesh.faceMaterial;
			_segmentMaterial = _mesh.segmentMaterial;
			_billboardMaterial = _mesh.billboardMaterial;
			
			_backmat = _mesh.back || _faceMaterial;
			
			_clippedFaceVOs = new Array();
			
			if (_cameraVarsStore.nodeClassificationDictionary[source] == Frustum.INTERSECT)
				_clipFaceVOs = true;
			else
				_clipFaceVOs = false;
			
			//loop through all faces
            for each (_face in _faces)
            {
                 if (!_face.visible)
                    continue;
                
                //check if a face needs clipping
                if (_clipFaceVOs)
                	_clipping.checkFace(_face.faceVO, source, _clippedFaceVOs);
                else
                	_clippedFaceVOs.push(_face.faceVO);
            }

            for each (_faceVO in _clippedFaceVOs) {
				_sv0 = _lens.project(viewTransform, _faceVO.v0);
				_sv1 = _lens.project(viewTransform, _faceVO.v1);
				_sv2 = _lens.project(viewTransform, _faceVO.v2);
				
                if (!_sv0.visible || !_sv1.visible || !_sv2.visible)
                    continue;
                
            	_face = _faceVO.face;
                
            	_tri = _drawPrimitiveStore.createDrawTriangle(source, _faceVO, null, _sv0, _sv1, _sv2, _faceVO.uv0, _faceVO.uv1, _faceVO.uv2, _faceVO.generated);
                
				//determine if _triangle is facing towards or away from camera
                _backface = _tri.backface = _tri.area < 0;
				
				//if _triangle facing away, check for backface material
                if (_backface) {
                    if (!_mesh.bothsides)
                    	continue;
                    
                    _tri.material = _faceVO.back;
                    
                    if (!_tri.material)
                    	_tri.material = _faceVO.material;
                } else {
                    _tri.material = _faceVO.material;
                }
                
				//determine the material of the _triangle
                if (!_tri.material) {
                    if (_backface)
                        _tri.material = _backmat;
                    else
                        _tri.material = _faceMaterial;
                }
                
				//do not draw material if visible is false
                if (_tri.material && !_tri.material.visible)
                    _tri.material = null;
				
				//if there is no material and no outline, continue
                if (!_mesh.outline && !_tri.material)
                        continue;
                
                //check whether screenClipping removes triangle
                if (!consumer.primitive(_tri))
                	continue;
				
                if (_mesh.pushback)
                    _tri.screenZ = _tri.maxZ;
				
                if (_mesh.pushfront)
                    _tri.screenZ = _tri.minZ;
				
				_tri.screenZ += _mesh.screenZOffset;
				
                if (_mesh.outline && !_backface)
                {
                    _n01 = _mesh.geometry.neighbour01(_face);
                    if (_n01 == null || front(_n01, viewTransform) <= 0)
                    	consumer.primitive(_drawPrimitiveStore.createDrawSegment(source, _mesh.outline, _tri.v0, _tri.v1));
					
                    _n12 = _mesh.geometry.neighbour12(_face);
                    if (_n12 == null || front(_n12, viewTransform) <= 0)
                    	consumer.primitive(_drawPrimitiveStore.createDrawSegment(source, _mesh.outline, _tri.v1, _tri.v2));
					
                    _n20 = _mesh.geometry.neighbour20(_face);
                    if (_n20 == null || front(_n20, viewTransform) <= 0)
                    	consumer.primitive(_drawPrimitiveStore.createDrawSegment(source, _mesh.outline, _tri.v2, _tri.v0));
                }
            }
            
            //loop through all segments
            for each (_segment in _segments)
            {
            	_sv0 = _lens.project(viewTransform, _segment.v0);
            	_sv1 = _lens.project(viewTransform, _segment.v1);
    
                if (!_sv0.visible || !_sv1.visible)
                    continue;
            	
            	_smaterial = _segment.material || _segmentMaterial;
				
                if (!_smaterial.visible)
                    continue;
                
                consumer.primitive(_drawPrimitiveStore.createDrawSegment(source, _smaterial, _sv0, _sv1));
            }
            
            //loop through all billboards
            for each (_billboard in _billboards)
            {
                if (!_billboard.visible)
                    continue;
				
				_sv0 = _lens.project(viewTransform, _billboard.vertex);
				
            	if (!_sv0.visible)
                    continue;
                
                _bmaterial = _billboard.material || _billboardMaterial;
                
                if (!_bmaterial.visible)
                    continue;
		        
	            consumer.primitive(_drawPrimitiveStore.createDrawBillboard(source, _bmaterial, _sv0, _billboard.width, _billboard.height, _billboard.scaling*_zoom / (1 + _sv0.z / _focus), _billboard.rotation));
            }
		}
	}
}