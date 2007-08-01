package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.mesh.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;

    import flash.display.BitmapData;
    import flash.geom.Matrix;

    /** Solid color material that takes lighting into considiration */
    public class ShadingColorMaterial extends CenterLightingMaterial
    {
        public var ambient:int;
        public var diffuse:int;
        public var specular:int;
        public var alpha:Number;
        public var static:Boolean;

        public function ShadingColorMaterial(init:Object = null)
        {
            super(init);

            init = Init.parse(init);

            var color:int = init.getColor("color", 0xFFFFFF);
            ambient = init.getColor("ambient", color);
            diffuse = init.getColor("diffuse", color);
            specular = init.getColor("specular", color);
            alpha = init.getNumber("alpha", 1);
            static = init.getBoolean("static", false);
        }

        public override function renderTri(tri:DrawTriangle, session:RenderSession, kar:Number, kag:Number, kab:Number, kdr:Number, kdg:Number, kdb:Number, ksr:Number, ksg:Number, ksb:Number):void
        {
            var v0:ScreenVertex = tri.v0;
            var v1:ScreenVertex = tri.v1;
            var v2:ScreenVertex = tri.v2;

            var fr:int = int(((ambient & 0xFF0000) * kar + (diffuse & 0xFF0000) * kdr + (specular & 0xFF0000) * ksr) >> 16);
            var fg:int = int(((ambient & 0x00FF00) * kag + (diffuse & 0x00FF00) * kdg + (specular & 0x00FF00) * ksg) >> 8);
            var fb:int = int(((ambient & 0x0000FF) * kab + (diffuse & 0x0000FF) * kdb + (specular & 0x0000FF) * ksb));
            
            if (fr > 0xFF)
                fr = 0xFF;
            if (fg > 0xFF)
                fg = 0xFF;
            if (fb > 0xFF)
                fb = 0xFF;

            var color:int = fr << 16 | fg << 8 | fb;

            session.renderTriangleColor(color, alpha, v0.x, v0.y, v1.x, v1.y, v2.x, v2.y);

            if (static)
                if (tri.face != null)
                {
                    var sfr:int = int(((ambient & 0xFF0000) * kar + (diffuse & 0xFF0000) * kdr) >> 16);
                    var sfg:int = int(((ambient & 0x00FF00) * kag + (diffuse & 0x00FF00) * kdg) >> 8);
                    var sfb:int = int(((ambient & 0x0000FF) * kab + (diffuse & 0x0000FF) * kdb));

                    if (sfr > 0xFF)
                        sfr = 0xFF;
                    if (sfg > 0xFF)
                        sfg = 0xFF;
                    if (sfb > 0xFF)
                        sfb = 0xFF;

                    var scolor:int = sfr << 16 | sfg << 8 | sfb;

                    tri.face.material = new ColorMaterial(scolor);
                }
        }

        public override function get visible():Boolean
        {
            return true;
        }
 
    }
}
