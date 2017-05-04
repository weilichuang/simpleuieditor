package uieditor.editor.util
{
	import starling.display.DisplayObject;

	public class UIAlignType
	{
		public static const LEFT : int = 0;
		public static const CENTER_X : int = 1;
		public static const RIGHT : int = 2;
		public static const TOP : int = 3;
		public static const CENTER_Y : int = 4;
		public static const BOTTOM : int = 5;

		public static const LAYOUT_X : int = 6;
		public static const LAYOUT_Y : int = 7;
		
		public static function alignUI( alignType : int,targets:Array ) : void
		{
			var count : int = targets.length;
			if ( count <= 1 )
				return;
			
			var i : int;
			var displayObj : DisplayObject;
			var minX : Number;
			var maxX : Number;
			var maxY : Number;
			var minY : Number;
			switch ( alignType )
			{
				case UIAlignType.LEFT:
					targets.sortOn( "x", Array.NUMERIC );
					minX = targets[ 0 ].x;
					for ( i = 0; i < count; i++ )
					{
						displayObj = targets[ i ];
						displayObj.x = minX;
					}
					break;
				case UIAlignType.TOP:
					targets.sortOn( "y", Array.NUMERIC );
					minY = targets[ 0 ].y;
					for ( i = 0; i < count; i++ )
					{
						displayObj = targets[ i ];
						displayObj.y = minY;
					}
					break;
				case UIAlignType.RIGHT:
					maxX = -10000;
					for ( i = 0; i < count; i++ )
					{
						displayObj = targets[ i ];
						if ( displayObj.x + displayObj.width > maxX )
							maxX = displayObj.x + displayObj.width;
					}
					for ( i = 0; i < count; i++ )
					{
						displayObj = targets[ i ];
						displayObj.x = maxX - displayObj.width;
					}
					break;
				case UIAlignType.BOTTOM:
					maxY = -10000;
					for ( i = 0; i < count; i++ )
					{
						displayObj = targets[ i ];
						if ( displayObj.y + displayObj.height > maxY )
							maxY = displayObj.y + displayObj.height;
					}
					for ( i = 0; i < count; i++ )
					{
						displayObj = targets[ i ];
						displayObj.y = maxY - displayObj.height;
					}
					break;
				case UIAlignType.CENTER_Y:
					minY = 10000;
					maxY = -10000;
					for ( i = 0; i < count; i++ )
					{
						displayObj = targets[ i ];
						
						if ( displayObj.y < minY )
							minY = displayObj.y;
						
						if ( displayObj.y + displayObj.height > maxY )
							maxY = displayObj.y + displayObj.height;
					}
					
					var centerY : Number = minY + ( maxY - minY ) / 2;
					
					for ( i = 0; i < count; i++ )
					{
						displayObj = targets[ i ];
						displayObj.y = centerY - displayObj.height / 2;
					}
					break;
				case UIAlignType.CENTER_X:
					minX = 10000;
					maxX = -10000;
					for ( i = 0; i < count; i++ )
					{
						displayObj = targets[ i ];
						
						if ( displayObj.x < minX )
							minX = displayObj.x;
						
						if ( displayObj.x + displayObj.width > maxX )
							maxX = displayObj.x + displayObj.width;
					}
					
					var centerX : Number = minX + ( maxX - minX ) / 2;
					
					for ( i = 0; i < count; i++ )
					{
						displayObj = targets[ i ];
						displayObj.x = centerX - displayObj.width / 2;
					}
					break;
				
				case UIAlignType.LAYOUT_Y:
					if ( count > 2 )
					{
						targets.sortOn( "x", Array.NUMERIC );
						
						var middleWidth : Number = 0;
						for ( i = 1; i < count - 1; i++ )
						{
							displayObj = targets[ i ];
							middleWidth += displayObj.width;
						}
						
						var gap : Number = ( targets[ count - 1 ].x - ( targets[ 0 ].x + targets[ 0 ].width ) - middleWidth ) / ( count - 1 );
						
						var px : Number = targets[ 0 ].x + targets[ 0 ].width + gap;
						for ( i = 1; i < count - 1; i++ )
						{
							displayObj = targets[ i ];
							displayObj.x = px;
							px += displayObj.width + gap;
						}
					}
					break;
				case UIAlignType.LAYOUT_X:
					if ( count > 2 )
					{
						targets.sortOn( "y", Array.NUMERIC );
						
						var middleHeight : Number = 0;
						for ( i = 1; i < count - 1; i++ )
						{
							displayObj = targets[ i ];
							middleHeight += displayObj.height;
						}
						
						gap = ( targets[ count - 1 ].y - ( targets[ 0 ].y + targets[ 0 ].height ) - middleHeight ) / ( count - 1 );
						
						var py : Number = targets[ 0 ].y + targets[ 0 ].height + gap;
						for ( i = 1; i < count - 1; i++ )
						{
							displayObj = targets[ i ];
							displayObj.y = py;
							py += displayObj.height + gap;
						}
					}
					break;
			}
		}
	}
}
