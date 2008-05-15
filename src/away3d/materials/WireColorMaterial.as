package away3d.materials
{
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;

    import flash.display.Graphics;
    import flash.display.*;

    /** Material for solid color drawing with face's border outlining */
    public class WireColorMaterial implements ITriangleMaterial
    {
        public var color:int;
        public var alpha:Number;

        public var width:Number;
        public var wirecolor:int;
        public var wirealpha:Number;
		
		protected var ini:Init;
		
        public function WireColorMaterial(color:* = null, init:Object = null)
        {
            if (color == null)
                color = "random";

            this.color = Cast.trycolor(color);

            ini = Init.parse(init);
            
            alpha = ini.getNumber("alpha", 1, {min:0, max:1});
            wirecolor = ini.getColor("wirecolor", 0x000000);
            width = ini.getNumber("width", 1, {min:0});
            wirealpha = ini.getNumber("wirealpha", 1, {min:0, max:1});
        }
		
		internal var graphics:Graphics;
		
        public function renderTriangle(tri:DrawTriangle):void
        {
			tri.source.session.renderTriangleLineFill(width, color, alpha, wirecolor, wirealpha, tri.v0, tri.v1, tri.v2);
        }
        
        public function get visible():Boolean
        {
            return (alpha > 0) || (wirealpha > 0);
        }
 
    }
}
