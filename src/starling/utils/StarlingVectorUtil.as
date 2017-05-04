package starling.utils
{
	import starling.display.DisplayObject;
	import starling.events.Touch;

	public class StarlingVectorUtil
	{
		public static function removeDisplayObjectAt( vector : Vector.<DisplayObject>, index : int ) : void
		{
			var i : int;
			var length : uint = vector.length;
			for ( i = index + 1; i < length; ++i )
				vector[ i - 1 ] = vector[ i ];

			vector.length = length - 1;
		}

		public static function removeTouchAt( vector : Vector.<Touch>, index : int ) : void
		{
			var i : int;
			var length : uint = vector.length;
			for ( i = index + 1; i < length; ++i )
				vector[ i - 1 ] = vector[ i ];

			vector.length = length - 1;
		}

	}
}
