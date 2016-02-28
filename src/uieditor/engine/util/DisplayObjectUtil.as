package uieditor.engine.util
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.display.DisplayObject;
	import starling.utils.Align;


    public class DisplayObjectUtil
    {
        public static function movePivotTo(obj:DisplayObject, x:Number, y:Number):void
        {
            var rect1:Rectangle =  obj.getBounds(obj.parent);

            obj.pivotX = x;
            obj.pivotY = y;

            var rect2:Rectangle = obj.getBounds(obj.parent);

            obj.x += rect1.x - rect2.x;
            obj.y += rect1.y - rect2.y;
        }

        public static function setPivotTo(obj:DisplayObject, x:Number, y:Number):void
        {
            obj.pivotX = x;
            obj.pivotY = y;
        }

        public static function movePivotToAlign(obj:DisplayObject, hAlign:String = "center", vAlign:String = "center"):void
        {
            var p:Point = getPivotPoint(obj, hAlign, vAlign);
            movePivotTo(obj, p.x, p.y);
        }


        private static function getPivotPoint(obj:DisplayObject, hAlign:String, vAlign:String):Point
        {
            var bounds:Rectangle = obj.getBounds(obj);

            var pivotX:Number;
            var pivotY:Number;

            if (hAlign == Align.LEFT)        pivotX = bounds.x;
            else if (hAlign == Align.CENTER) pivotX = bounds.x + bounds.width / 2.0;
            else if (hAlign == Align.RIGHT)  pivotX = bounds.x + bounds.width;
            else throw new ArgumentError("Invalid horizontal alignment: " + hAlign);

            if (vAlign == Align.TOP)         pivotY = bounds.y;
            else if (vAlign == Align.CENTER) pivotY = bounds.y + bounds.height / 2.0;
            else if (vAlign == Align.BOTTOM) pivotY = bounds.y + bounds.height;
            else throw new ArgumentError("Invalid vertical alignment: " + vAlign);

            return new Point(pivotX, pivotY);
        }
    }
}
