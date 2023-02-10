package
{
    import flash.display.*;
    import flash.geom.*;
     
    /** 
    * Catmull-Rom spline through N points.
    * @author makc
    * @license WTFPLv2, http://sam.zoy.org/wtfpl/
    */ 
    public class CatmullRomSpline extends Sprite
    {
        public var b:Bitmap, ct:ColorTransform, s:Shape;

        public var ps:Array = [];
        public var vs:Array = [];

        public function CatmullRomSpline ()  
        {
            b = new Bitmap (new BitmapData (465, 465, true, 0xFFFFFF));
            addChild (b);ct = new ColorTransform (1,1,1,0.95);
            s = new Shape;addChild (s);

            var N:int = 3 + 10 * Math.random ();
            for (var i:int = 0; i < N; i++) {
                ps.push (new Point (465 * Math.random (), 465 * Math.random ()));
                vs.push (new Point (5 * (Math.random () - Math.random ()), 5 * (Math.random () - Math.random ())));
            }

            addEventListener ("enterFrame", loop);
        }

        public function loop (e:*):void 
        {
            var i:int;

            // move points around randomly
            for (i = 0; i < ps.length; i++) {
                var p:Point = ps [i];
                var v:Point = vs [i];
                p.x += v.x; p.y += v.y;
                if ((p.x < 0) || (p.x > 465)) { p.x = Math.max (0, Math.min (465, p.x)); v.x *= -1; }
                if ((p.y < 0) || (p.y > 465)) { p.y = Math.max (0, Math.min (465, p.y)); v.y *= -1; }
            }

            // prepare graphics
            s.graphics.clear ();

            // draw spline
            for (i = 0; i < ps.length; i++) {
                var p0:Point = ps [(i -1 + ps.length) % ps.length];
                var p1:Point = ps [i];
                var p2:Point = ps [(i +1 + ps.length) % ps.length];
                var p3:Point = ps [(i +2 + ps.length) % ps.length];

                s.graphics.lineStyle (0, 0x7FFF);
                s.graphics.beginFill (0, 0);
                s.graphics.moveTo (p1.x, p1.y);
                for (var j:int = 1; j < 101; j++) {
                    var q:Point = spline (p0, p1, p2, p3, 0.01 * j);
                    s.graphics.lineTo (q.x, q.y);
                }
                s.graphics.lineStyle ();
                s.graphics.endFill ();
            }

            b.bitmapData.draw (s);
            b.bitmapData.colorTransform (b.bitmapData.rect, ct) 

            // draw points 
            s.graphics.beginFill (0xFF0000);
            for (i = 0; i < ps.length; i++) {
                s.graphics.drawCircle (ps [i].x, ps [i].y, 3.5);
            }
        }

        /* 
        * Calculates 2D cubic Catmull-Rom spline.
        * @see http://www.mvps.org/directx/articles/catmull/ 
        */ 
        public function spline (p0:Point, p1:Point, p2:Point, p3:Point, t:Number):Point 
        {
            return new Point (
                0.5 * ((          2*p1.x) +
                    t * (( -p0.x           +p2.x) +
                    t * ((2*p0.x -5*p1.x +4*p2.x -p3.x) +
                    t * (  -p0.x +3*p1.x -3*p2.x +p3.x)))),
                0.5 * ((          2*p1.y) +
                    t * (( -p0.y           +p2.y) +
                    t * ((2*p0.y -5*p1.y +4*p2.y -p3.y) +
                    t * (  -p0.y +3*p1.y -3*p2.y +p3.y))))
            );
        }

    }

}