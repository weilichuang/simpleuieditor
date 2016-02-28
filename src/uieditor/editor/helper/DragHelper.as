package uieditor.editor.helper
{
	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class DragHelper
	{
		public function DragHelper()
		{
		}

		public static function startDrag( obj : DisplayObject, onDrag : Function, onComplete : Function, onOver : Function = null ) : void
		{
			var previousX : Number;
			var previousY : Number;

			function onTouch( event : TouchEvent ) : void
			{
				var touch : Touch = event.getTouch( obj );

				if ( touch )
				{
					if ( touch.phase == TouchPhase.MOVED )
					{
						if ( !isNaN( previousX ) && !isNaN( previousY ))
						{
							var dx : Number = touch.globalX - previousX;
							var dy : Number = touch.globalY - previousY;

							if ( onDrag( obj, dx, dy ))
							{
								previousX = touch.globalX;
								previousY = touch.globalY;
							}
						}
						else
						{
							previousX = touch.globalX;
							previousY = touch.globalY;
						}
					}
					else if ( touch.phase == TouchPhase.ENDED )
					{
						onComplete();

						previousX = Number.NaN;
						previousY = Number.NaN;
					}
					else if ( touch.phase == TouchPhase.HOVER )
					{
						if ( onOver != null )
						{
							onOver( obj );
						}
					}
				}
			}


			obj.addEventListener( TouchEvent.TOUCH, onTouch );
		}

		public static function endDrag( obj : DisplayObject ) : void
		{
			obj.removeEventListeners( TouchEvent.TOUCH );
		}


	}
}
