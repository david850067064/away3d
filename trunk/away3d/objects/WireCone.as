﻿package away3d.objects
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.mesh.*;
    import away3d.core.material.*;
    import away3d.core.utils.*;
	import away3d.core.stats.*;
    
    /** Wire cone */ 
    public class WireCone extends WireMesh
    {
        public function WireCone(init:Object = null)
        {
            super(init);
            
            init = Init.parse(init);

            var radius:Number = init.getNumber("radius", 100, {min:0});
            var height:Number = init.getNumber("height", 200, {min:0});
            var segmentsW:int = init.getInt("segmentsW", 8, {min:3});
            var segmentsH:int = init.getInt("segmentsH", 1, {min:1})

            buildWireCone(radius, height, segmentsW, segmentsH);
        }
    
        private var grid:Array;

        private function buildWireCone(radius:Number, height:Number, segmentsW:int, segmentsH:int):void
        {
            var i:int;
            var j:int;

            height /= 2;
            segmentsH += 1;

            grid = new Array(segmentsH + 1);

            var bottom:Vertex = new Vertex(0, -height, 0);
            grid[0] = new Array(segmentsW);
            for (i = 0; i < segmentsW; i++) 
                grid[0][i] = bottom;

            for (j = 1; j < segmentsH; j++)  
            { 
                var z:Number = -height + 2 * height * (j-1) / (segmentsH-1);

                grid[j] = new Array(segmentsW);
                for (i = 0; i < segmentsW; i++) 
                { 
                    var verangle:Number = 2 * i / segmentsW * Math.PI;
                    var ringradius:Number = radius * (segmentsH-j)/(segmentsH-1)
                    var x:Number = ringradius * Math.sin(verangle);
                    var y:Number = ringradius * Math.cos(verangle);
                    grid[j][i] = new Vertex(y, z, x);
                }
            }

            var top:Vertex = new Vertex(0, height, 0);
            grid[segmentsH] = new Array(segmentsW);
            for (i = 0; i < segmentsW; i++) 
                grid[segmentsH][i] = top;

            for (j = 1; j <= segmentsH; j++) 
                for (i = 0; i < segmentsW; i++) 
                {
                    var a:Vertex = grid[j][i];
                    var b:Vertex = grid[j][(i-1+segmentsW) % segmentsW];
                    var c:Vertex = grid[j-1][(i-1+segmentsW) % segmentsW];
                    var d:Vertex = grid[j-1][i];

                    addSegment(new Segment(a, d));
                    addSegment(new Segment(b, c));
                    if (j < segmentsH)  
                        addSegment(new Segment(a, b));
                }
			
			Stats.instance.register("WireCone",0,"primitive");
        }

        public function vertex(i:int, j:int):Vertex
        {
            return grid[j][i];
        }
    }
}