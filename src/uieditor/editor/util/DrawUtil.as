package uieditor.editor.util
{
	import starling.display.Quad;

	public class DrawUtil
	{
		public static function makeLine( x1 : Number, y1 : Number, x2 : Number, y2 : Number ) : Quad
		{
			var len : Number = MathUtil.distance( x1, y1, x2, y2 );

			if ( len == 0 )
			{
				len = 1;
			}

			var quad : Quad = new Quad( len, 1, 0xff0000 );
			quad.pivotY = quad.height * 0.5;
			quad.x = x1;
			quad.y = y1;
			quad.rotation = Math.atan2( y2 - y1, x2 - x1 );
			return quad;
		}
	}
}
