package
{
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;
    import flash.utils.*;

    import mx.core.BitmapAsset;
    
    import away3d.cameras.*;
    import away3d.objects.*;
    import away3d.loaders.*;
    import away3d.test.*;
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.render.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.draw.*;
    
    [SWF(backgroundColor="#222266", frameRate="60", width="800", height="600")]
    public class SculptTest extends BaseDemo
    {
        public function SculptTest()
        {
            super("Sculpt demo");
                        
            camera.mintiltangle = -70;

            addSlide("Sculpting", 
"",
            new Scene3D(new Sculpt(6)), 
            //new BasicRenderer());
            new QuadrantRenderer(new AnotherRivalFilter));

        }
    }
}

    import flash.display.*;
    import flash.events.*;
    import flash.text.*;
    import flash.utils.*;
    import flash.geom.*;

    import mx.core.BitmapAsset;
    
    import away3d.cameras.*;
    import away3d.objects.*;
    import away3d.loaders.*;
    import away3d.core.*;
    import away3d.core.render.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;

class Asset
{
}

class Sculpt extends ObjectContainer3D
{
    public var light1:Light3D;
    public var light2:Light3D;
    public var light3:Light3D;
    public var light4:Light3D;
                       
    public function Sculpt(n:int = 1)
    {
        light1 = new Light3D(0xFFFFFF, 1, 1, 0, {x:900, z:900, y:900});
        light2 = new Light3D(0x555500, 1, 1, 0, {x:-900, z:900, y:900});
        light3 = new Light3D(0x999999, 1, 1, 0, {x:900, z:-900, y:900});
        light4 = new Light3D(0xFFFFFF, 1, 1, 0, {x:-900, z:-900, y:900});

        super(light1, light4);

        build(n);

        events.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    }

    public function onMouseDown(e:MouseEvent3D):void
    {
        if (e.drawpri is DrawTriangle)
        {
            var tri:DrawTriangle = e.drawpri as DrawTriangle;
            removeFace(tri.face);
        }
    }

    public function removeFace(face:Face3D, level:int = 0):void
    {
        var cavity:Cavity;
        for each (cavity in face.extra.cavities)
            if (cavity.visible)
            {
                removeCavity(cavity, level);
                break;
            }
    }

    public function removeCavity(cavity:Cavity, level:int):void
    {
        cavity.visible = false;
        var face:Face3D;
        for each (face in cavity.faces)
        {
            face.extra.viscount -= 1;
            face.visible = face.extra.viscount == 1;
        }
        for each (face in cavity.faces)
            if (Math.random() < 1 / (level + 1))
                removeFace(face, level + 1);
    }

    public function build(n:int):void
    {
        var white:IMaterial = new ColorShadingBitmapMaterial(0xFFFFFF, 0xFFFFFF, 0xFFFFFF, {alpha:20});
        var i:int;
        var j:int;
        var h:int;
        var vertices:Array = new Array();
        for (i = 0; i <= n; i++)
        {
            vertices[i] = new Array();
            for (j = 0; j <= n; j++)
            {
                vertices[i][j] = new Array();
                for (h = 0; h <= n; h++)
                    vertices[i][j][h] = new Vertex3D(i/n*1000-500, j/n*1000-500, h/n*1000-500);
            }
        }

        var centers:Array = new Array();
        for (i = 0; i < n; i++)
        {
            centers[i] = new Array();
            for (j = 0; j < n; j++)
            {
                centers[i][j] = new Array();
                for (h = 0; h < n; h++)
                    centers[i][j][h] = new Vertex3D((i+0.5)/n*1000-500, (j+0.5)/n*1000-500, (h+0.5)/n*1000-500);
            }
        }

        var centerfaces:Array = new Array();
        for (i = 0; i < n; i++)
        {
            centerfaces[i] = new Array();
            for (j = 0; j < n; j++)
            {
                centerfaces[i][j] = new Array();
                for (h = 0; h < n; h++)
                {
                    centerfaces[i][j][h] = new Array();
                    centerfaces[i][j][h]["i j "] = new Face3D(centers[i][j][h], vertices[i  ][j  ][h], vertices[i  ][j  ][h+1]);
                    centerfaces[i][j][h]["i#j "] = new Face3D(centers[i][j][h], vertices[i+1][j  ][h], vertices[i+1][j  ][h+1]);
                    centerfaces[i][j][h]["i j#"] = new Face3D(centers[i][j][h], vertices[i  ][j+1][h], vertices[i  ][j+1][h+1]);
                    centerfaces[i][j][h]["i#j#"] = new Face3D(centers[i][j][h], vertices[i+1][j+1][h], vertices[i+1][j+1][h+1]);

                    centerfaces[i][j][h]["i h "] = new Face3D(centers[i][j][h], vertices[i  ][j][h  ], vertices[i  ][j+1][h  ]);
                    centerfaces[i][j][h]["i#h "] = new Face3D(centers[i][j][h], vertices[i+1][j][h  ], vertices[i+1][j+1][h  ]);
                    centerfaces[i][j][h]["i h#"] = new Face3D(centers[i][j][h], vertices[i  ][j][h+1], vertices[i  ][j+1][h+1]);
                    centerfaces[i][j][h]["i#h#"] = new Face3D(centers[i][j][h], vertices[i+1][j][h+1], vertices[i+1][j+1][h+1]);

                    centerfaces[i][j][h]["j h "] = new Face3D(centers[i][j][h], vertices[i][j  ][h  ], vertices[i+1][j  ][h  ]);
                    centerfaces[i][j][h]["j#h "] = new Face3D(centers[i][j][h], vertices[i][j+1][h  ], vertices[i+1][j+1][h  ]);
                    centerfaces[i][j][h]["j h#"] = new Face3D(centers[i][j][h], vertices[i][j  ][h+1], vertices[i+1][j  ][h+1]);
                    centerfaces[i][j][h]["j#h#"] = new Face3D(centers[i][j][h], vertices[i][j+1][h+1], vertices[i+1][j+1][h+1]);
                }
            }
        }

        var ifaces:Array = new Array();
        for (i = 0; i <= n; i++)
        {
            ifaces[i] = new Array();
            for (j = 0; j < n; j++)
            {
                ifaces[i][j] = new Array();
                for (h = 0; h < n; h++)
                {
                    ifaces[i][j][h] = new Array();
                    ifaces[i][j][h]["0++"] = new Face3D(vertices[i][j][h], vertices[i][j+1][h], vertices[i][j][h+1]);
                    ifaces[i][j][h]["++1"] = new Face3D(vertices[i][j+1][h], vertices[i][j][h+1], vertices[i][j+1][h+1]);
                }                                    
            }                                        
        }

        var jfaces:Array = new Array();
        for (i = 0; i < n; i++)
        {
            jfaces[i] = new Array();
            for (j = 0; j <= n; j++)
            {
                jfaces[i][j] = new Array();
                for (h = 0; h < n; h++)
                {
                    jfaces[i][j][h] = new Array();
                    jfaces[i][j][h]["0++"] = new Face3D(vertices[i][j][h], vertices[i+1][j][h], vertices[i][j][h+1]);
                    jfaces[i][j][h]["++1"] = new Face3D(vertices[i+1][j][h], vertices[i][j][h+1], vertices[i+1][j][h+1]);
                }
            }
        }

        var hfaces:Array = new Array();
        for (i = 0; i < n; i++)
        {
            hfaces[i] = new Array();
            for (j = 0; j < n; j++)
            {
                hfaces[i][j] = new Array();
                for (h = 0; h <= n; h++)
                {
                    hfaces[i][j][h] = new Array();
                    hfaces[i][j][h]["0++"] = new Face3D(vertices[i][j][h], vertices[i+1][j][h], vertices[i][j+1][h]);
                    hfaces[i][j][h]["++1"] = new Face3D(vertices[i+1][j][h], vertices[i][j+1][h], vertices[i+1][j+1][h]);
                }
            }
        }

        var face:Face3D;
        var mesh:Mesh3D = new Mesh3D(white, {parent:this, bothsides:true});
        mesh.vertices = vertices.concat(centers);
        for (i = 0; i < n; i++)
            for (j = 0; j < n; j++)
                for (h = 0; h < n; h++)
                    for each (face in centerfaces[i][j][h])
                        mesh.faces.push(face);

        for (i = 0; i <= n; i++)
            for (j = 0; j < n; j++)
                for (h = 0; h < n; h++)
                    for each (face in ifaces[i][j][h])
                        mesh.faces.push(face);
        for (i = 0; i < n; i++)
            for (j = 0; j <= n; j++)
                for (h = 0; h < n; h++)
                    for each (face in jfaces[i][j][h])
                        mesh.faces.push(face);
        for (i = 0; i < n; i++)
            for (j = 0; j < n; j++)
                for (h = 0; h <= n; h++)
                    for each (face in hfaces[i][j][h])
                        mesh.faces.push(face);

        for each (face in mesh.faces)
            face.extra = {cavities:new Array(), viscount:0};
        
        for (i = 0; i < n; i++)
            for (j = 0; j < n; j++)
                for (h = 0; h < n; h++)
                {   
                    var fi:Array = ifaces[i][j][h];
                    var fj:Array = jfaces[i][j][h];
                    var fh:Array = hfaces[i][j][h];
                    var fip:Array = ifaces[i+1][j][h];
                    var fjp:Array = jfaces[i][j+1][h];
                    var fhp:Array = hfaces[i][j][h+1];
                    var c:Array = centerfaces[i][j][h];
                    new Cavity(fi["0++"],  fi["++1"],  c["i j "], c["i j#"], c["i h "], c["i h#"]);
                    new Cavity(fip["0++"], fip["++1"], c["i#j "], c["i#j#"], c["i#h "], c["i#h#"]);
                    new Cavity(fj["0++"],  fj["++1"],  c["i j "], c["i#j "], c["j h "], c["j h#"]);
                    new Cavity(fjp["0++"], fjp["++1"], c["i j#"], c["i#j#"], c["j#h "], c["j#h#"]);
                    new Cavity(fh["0++"],  fh["++1"],  c["i h "], c["i#h "], c["j h "], c["j#h "]);
                    new Cavity(fhp["0++"], fhp["++1"], c["i h#"], c["i#h#"], c["j h#"], c["j#h#"]);
                }

        for each (face in mesh.faces)
            face.visible = face.extra.viscount == 1;
    }
    
}

class Cavity
{
    public var faces:Array = [];
    public var visible:Boolean = true;

    public function Cavity(...faces)
    {
        for each (var face:Face3D in faces)
        {
            this.faces.push(face);
            face.extra.cavities.push(this);
            face.extra.viscount += 1;
        }
    }
}

class Pyramid extends Mesh3D
{
    public function Pyramid(material:IMaterial, top:Vertex3D, a:Vertex3D, b:Vertex3D, c:Vertex3D, d:Vertex3D, init:Object = null)
    {
        super(material, init);

        faces.push(new Face3D(a, d, c));
        faces.push(new Face3D(c, b, a));
        faces.push(new Face3D(top, a, b));
        faces.push(new Face3D(top, b, c));
        faces.push(new Face3D(top, c, d));
        faces.push(new Face3D(top, d, a));
    }
}