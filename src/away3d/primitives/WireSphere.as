﻿package away3d.primitives
{
    import away3d.core.base.*;
    
    /** Wire sphere */ 
    public class WireSphere extends WireMesh
    {
        public function WireSphere(init:Object = null)
        {
            super(init);

            var segmentsW:int = ini.getInt("segmentsW", 8, {min:3});
            var segmentsH:int = ini.getInt("segmentsH", 6, {min:2});
            var radius:Number = ini.getNumber("radius", 100, {min:0});
			var yUp:Boolean = ini.getBoolean("yUp", true);
			
            buildWireSphere(radius, segmentsW, segmentsH, yUp);
        }
    
        private var grid:Array;

        private function buildWireSphere(radius:Number, segmentsW:int, segmentsH:int, yUp:Boolean):void
        {
            var i:int;
            var j:int;

            grid = new Array(segmentsH + 1);
            
            var bottom:Vertex = yUp? new Vertex(0, -radius, 0) : new Vertex(0, 0, -radius);
            grid[0] = new Array(segmentsW);
            for (i = 0; i < segmentsW; i++) 
                grid[0][i] = bottom;
            
            for (j = 1; j < segmentsH; j++)  
            { 
                var horangle:Number = j / segmentsH * Math.PI;
                var z:Number = -radius * Math.cos(horangle);
                var ringradius:Number = radius * Math.sin(horangle);

                grid[j] = new Array(segmentsW);
				
                for (i = 0; i < segmentsW; i++) 
                { 
                    var verangle:Number = 2 * i / segmentsW * Math.PI;
                    var x:Number = ringradius * Math.sin(verangle);
                    var y:Number = ringradius * Math.cos(verangle);
                    
					if (yUp)
                    	grid[j][i] = new Vertex(y, z, x);
                    else
                    	grid[j][i] = new Vertex(y, -x, z);
                }
            }
			
			var top:Vertex = yUp? new Vertex(0, radius, 0) : new Vertex(0, 0, radius);
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
				
			type = "WireSphere";
        	url = "primitive";
        }

        public function vertex(i:int, j:int):Vertex
        {
            return grid[j][i];
        }
    }
}