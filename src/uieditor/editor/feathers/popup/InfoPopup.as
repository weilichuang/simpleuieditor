package uieditor.editor.feathers.popup
{
	import feathers.controls.Button;
	import feathers.controls.LayoutGroup;
	import feathers.core.PopUpManager;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;

	import starling.display.DisplayObject;
	import starling.events.Event;

	import uieditor.editor.feathers.FeathersUIUtil;

	public class InfoPopup extends BasePopupDev
	{
		private var _buttonContainer : LayoutGroup;

		public function InfoPopup( w : Number = NaN, h : Number = NaN )
		{
			super();

			init();

			if ( !isNaN( w ) && !isNaN( h ))
			{
				this.width = w;
				this.height = h;
			}
		}

		private function init() : void
		{
			var container : LayoutGroup = new LayoutGroup();

			var layout : VerticalLayout = new VerticalLayout();
			layout.gap = 10;
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			container.layout = layout;

			createContent( container );

			_buttonContainer = new LayoutGroup(); //FeathersUIUtil.scrollContainerWithHorizontalLayout();
			_buttonContainer.layout = new HorizontalLayout();
			( _buttonContainer.layout as HorizontalLayout ).gap = 5;
			container.addChild( _buttonContainer );

			addChild( container );
		}

		public function set buttons( array : Array ) : void
		{
			removeButtons();

			for each ( var label : String in array )
			{
				var button : Button = FeathersUIUtil.buttonWithLabel( label );
				button.minWidth = 40;
				button.addEventListener( Event.TRIGGERED, onButtonTrigger );
				_buttonContainer.addChild( button );
			}
		}

		private function onButtonTrigger( event : Event ) : void
		{
			for ( var i : int = 0; i < _buttonContainer.numChildren; i++ )
			{
				var button : DisplayObject = _buttonContainer.getChildAt( i );
				if ( button === event.target )
				{
					dispatchEventWith( Event.COMPLETE, false, i );
				}
			}

			PopUpManager.removePopUp( this, true );
		}

		private function removeButtons() : void
		{
			for ( var i : int = 0; i < _buttonContainer.numChildren; i++ )
			{
				var button : DisplayObject = _buttonContainer.getChildAt( i );
				button.removeEventListener( Event.TRIGGERED, onButtonTrigger );
			}

			_buttonContainer.removeChildren();
		}

		protected function createContent( container : LayoutGroup ) : void
		{


		}
	}
}
