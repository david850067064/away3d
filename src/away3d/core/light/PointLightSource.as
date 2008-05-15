package away3d.core.light
{
	import away3d.lights.*;

    /** Point light source */
    public class PointLightSource extends AbstractLightSource
    {
        public var x:Number;
        public var y:Number;
        public var z:Number;
        
        public var light:PointLight3D;
    }
}

