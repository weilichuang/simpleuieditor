package uieditor.editor.feathers.popup
{
	import feathers.controls.Panel;
	import feathers.core.PopUpManager;
	import feathers.layout.VerticalLayout;

	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Event;

	public class BasePopupDev extends Panel
	{
		public static const TWEEN_DURATION_SECONDS : Number = 0.25;

		public function BasePopupDev()
		{
			super();

			this.styleNameList.add( "custom_panel" );

			Starling.current.stage.addEventListener( Event.RESIZE, onResize );
		}

		protected function onResize( event : Event ) : void
		{
			PopUpManager.centerPopUp( this );
			this.invalidate( INVALIDATION_FLAG_LAYOUT );
		}

		private function onClosePopUpTweenComplete( actionCallback : Function = null ) : void
		{
			if ( actionCallback != null )
				actionCallback();
			PopUpManager.removePopUp( this );
		}

		private function onDisplayPopUpTweenComplete( actionCallback : Function = null ) : void
		{
			if ( actionCallback != null )
				actionCallback();
		}

		public static function TweenInFromRight( popup : DisplayObject ) : Object
		{
			var result : Object = new Object();

			result.durationSeconds = TWEEN_DURATION_SECONDS;
			result.startX = Starling.current.stage.stageWidth;
			result.startY = ( Math.abs( Starling.current.stage.stageHeight - popup.height ) / 2 );
			result.endX = ( Math.abs( Starling.current.stage.stageWidth - popup.width ) / 2 );
			result.endY = result.startY;

			return result;
		}

		public static function TweenOutToLeft( popup : DisplayObject ) : Object
		{
			var result : Object = new Object();

			result.durationSeconds = TWEEN_DURATION_SECONDS;
			result.startX = ( Math.abs( Starling.current.stage.stageWidth - popup.width ) / 2 );
			result.startY = ( Math.abs( Starling.current.stage.stageHeight - popup.height ) / 2 );
			result.endX = popup.width * -1;
			result.endY = result.startY;

			return result;
		}

		public static function TweenInFromBottom( popup : DisplayObject ) : Object
		{
			var result : Object = new Object();

			result.durationSeconds = TWEEN_DURATION_SECONDS;
			result.startX = ( Math.abs( Starling.current.stage.stageWidth - popup.width ) / 2 );
			result.startY = Starling.current.stage.stageHeight;
			result.endX = result.startX;
			result.endY = ( Math.abs( Starling.current.stage.stageHeight - popup.height ) / 2 );

			return result;
		}

		public static function TweenOutToBottom( popup : DisplayObject ) : Object
		{
			var result : Object = new Object();

			result.durationSeconds = TWEEN_DURATION_SECONDS;
			result.startX = ( Math.abs( Starling.current.stage.stageWidth - popup.width ) / 2 );
			result.startY = ( Math.abs( Starling.current.stage.stageHeight - popup.height ) / 2 );
			result.endX = result.startX
			result.endY = Starling.current.stage.stageHeight;

			return result;
		}

		public static function OverlayFactoryWithAlpha() : DisplayObject
		{
			const quad : Quad = new Quad( 100, 100, 0x000000 );
			quad.alpha = 0.8;
			return quad;
		}

		public function initData( data : Object = null ) : void
		{

		}

		override protected function initialize() : void
		{
			var layout : VerticalLayout = new VerticalLayout();
			layout.gap = 3;
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			this.layout = layout;

			super.initialize();
		}
	}
}
