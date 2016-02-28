package uieditor.editor.cursor
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.ui.MouseCursorData;

	public class CursorManager
	{
		public static var CURSOR_SIZE_WE : String = "size_we";
		public static var CURSOR_SIZE_NS : String = "size_ns";
		public static var CURSOR_SIZE_NWSE : String = "size_nwse";
		public static var CURSOR_SIZE_NESW : String = "size_nesw";
		public static var CURSOR_MOVE : String = "move";
		public static var CURSOR_NO_DROP : String = "no_drop";

		[Embed( source = "../../../embed/cursors/SizeWE.png" )]
		private static const CURSOR_SIZEWE : Class;

		[Embed( source = "../../../embed/cursors/SizeNS.png" )]
		private static const CURSOR_SIZENS : Class;

		[Embed( source = "../../../embed/cursors/SizeNWSE.png" )]
		private static const CURSOR_SIZENWSE : Class;

		[Embed( source = "../../../embed/cursors/SizeNESW.png" )]
		private static const CURSOR_SIZENESW : Class;

		[Embed( source = "../../../embed/cursors/Move.png" )]
		private static const MOVE : Class;

		[Embed( source = "../../../embed/cursors/NoDrop.png" )]
		private static const NO_DROP : Class;

		public static function initialize() : void
		{
			var cursorData : MouseCursorData = new MouseCursorData();
			cursorData.data = Vector.<BitmapData>([ new CURSOR_SIZEWE().bitmapData ]);
			cursorData.hotSpot = new Point( 7.5, 7.5 );
			Mouse.registerCursor( CURSOR_SIZE_WE, cursorData );

			cursorData = new MouseCursorData();
			cursorData.data = Vector.<BitmapData>([ new CURSOR_SIZENS().bitmapData ]);
			cursorData.hotSpot = new Point( 3.5, 8.5 );
			Mouse.registerCursor( CURSOR_SIZE_NS, cursorData );

			cursorData = new MouseCursorData();
			cursorData.data = Vector.<BitmapData>([ new CURSOR_SIZENWSE().bitmapData ]);
			cursorData.hotSpot = new Point( 7.5, 7.5 );
			Mouse.registerCursor( CURSOR_SIZE_NWSE, cursorData );

			cursorData = new MouseCursorData();
			cursorData.data = Vector.<BitmapData>([ new CURSOR_SIZENESW().bitmapData ]);
			cursorData.hotSpot = new Point( 7.5, 7.5 );
			Mouse.registerCursor( CURSOR_SIZE_NESW, cursorData );

			cursorData = new MouseCursorData();
			cursorData.data = Vector.<BitmapData>([ new MOVE().bitmapData ]);
			cursorData.hotSpot = new Point( 0, 0 );
			Mouse.registerCursor( CURSOR_MOVE, cursorData );

			//showDefault();
		}

		/**
		 * 显示默认光标
		 *
		 */
		public static function showDefault() : void
		{
			Mouse.cursor = MouseCursor.AUTO;
		}

		public static function showCursor( type : String ) : void
		{
			if ( Mouse.cursor != type )
				Mouse.cursor = type;
		}
	}
}
