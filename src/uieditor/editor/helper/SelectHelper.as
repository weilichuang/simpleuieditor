package uieditor.editor.helper
{
	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class SelectHelper
	{
		public static function startSelect( object : DisplayObject, onSelect : Function, onHover : Function = null ) : void
		{
			function onTouch( event : TouchEvent ) : void
			{
				var touch : Touch = event.getTouch( object );

				if ( touch )
				{
					if ( touch.phase == TouchPhase.BEGAN )
					{
						onSelect( object,event.ctrlKey );
					}
					else if ( touch.phase == TouchPhase.HOVER )
					{
						if ( onHover != null )
						{
							onHover( object );
						}
					}
				}
			}

			object.addEventListener( TouchEvent.TOUCH, onTouch );
		}

		public static function endSelect( obj : DisplayObject ) : void
		{
			obj.removeEventListeners( TouchEvent.TOUCH );
		}
	}
}
