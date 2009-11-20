package away3d.core.base;

import away3d.core.utils.ValueObject;


// use namespace arcane;

/**
 * Texture coordinates value object.
 * Properties u and v represent the horizontal and vertical texture axes.
 */
class UV extends ValueObject  {
	public var v(getV, setV) : Float;
	public var u(getU, setU) : Float;
	
	/** @private */
	public var _u:Float;
	/** @private */
	public var _v:Float;
	/**
	 * An optional untyped object that can contain used-defined properties.
	 */
	public var extra:Dynamic;
	

	/** @private */
	public static function median(a:UV, b:UV):UV {
		
		if (a == null) {
			return null;
		}
		if (b == null) {
			return null;
		}
		return new UV((a._u + b._u) / 2, (a._v + b._v) / 2);
	}

	/** @private */
	public static function weighted(a:UV, b:UV, aw:Float, bw:Float):UV {
		
		if (a == null) {
			return null;
		}
		if (b == null) {
			return null;
		}
		var d:Float = aw + bw;
		var ak:Float = aw / d;
		var bk:Float = bw / d;
		return new UV(a._u * ak + b._u * bk, a._v * ak + b._v * bk);
	}

	/**
	 * Defines the vertical corrdinate of the texture value.
	 */
	public function getV():Float {
		
		return _v;
	}

	public function setV(value:Float):Float {
		
		if (value == _v) {
			return value;
		}
		_v = value;
		notifyChange();
		return value;
	}

	/**
	 * Defines the horizontal corrdinate of the texture value.
	 */
	public function getU():Float {
		
		return _u;
	}

	public function setU(value:Float):Float {
		
		if (value == _u) {
			return value;
		}
		_u = value;
		notifyChange();
		return value;
	}

	/**
	 * Creates a new <code>UV</code> object.
	 *
	 * @param	u		[optional]	The horizontal corrdinate of the texture value. Defaults to 0.
	 * @param	v		[optional]	The vertical corrdinate of the texture value. Defaults to 0.
	 */
	public function new(?u:Float=0, ?v:Float=0) {
		// autogenerated
		super();
		
		
		_u = u;
		_v = v;
	}

	/**
	 * Duplicates the vertex properties to another <code>Vertex</code> object
	 * 
	 * @return	The new vertex instance with duplicated properties applied
	 */
	public function clone():UV {
		
		return new UV(_u, _v);
	}

	/**
	 * Used to trace the values of a uv object.
	 * 
	 * @return A string representation of the uv object.
	 */
	public override function toString():String {
		
		return "new UV(" + _u + ", " + _v + ")";
	}

}
