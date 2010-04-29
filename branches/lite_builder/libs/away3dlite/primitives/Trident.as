package away3dlite.primitives
{
	import away3dlite.containers.ObjectContainer3D;
	import away3dlite.materials.WireframeMaterial;
	import away3dlite.primitives.LineSegment;
	
	import flash.geom.Vector3D;
	import flash.utils.*;

	public class Trident extends ObjectContainer3D
	{
		private var _lines:Vector.<LineSegment>;

		public function Trident(size:int = 500)
		{
			var _size:int = size;

			// axis
			_lines = new Vector.<LineSegment>(3, true);
			_lines[0] = new LineSegment(new WireframeMaterial(0xFF0000), new Vector3D(0, 0, 0), new Vector3D(_size, 0, 0));
			_lines[1] = new LineSegment(new WireframeMaterial(0x00FF00), new Vector3D(0, 0, 0), new Vector3D(0, _size, 0));
			_lines[2] = new LineSegment(new WireframeMaterial(0x0000FF), new Vector3D(0, 0, 0), new Vector3D(0, 0, _size));

			for each (var _line:LineSegment in _lines)
				addChild(_line);
		}
		
		override public function destroy():void
		{
			if(_isDestroyed)
				return;
			
			if (_lines)
				for each (var _line:LineSegment in _lines)
					removeChild(_line);
			
			_lines = null;
			
			super.destroy();
		}
	}
}