package uieditor.editor.ui.inspector
{
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.layout.VerticalLayout;

	import starling.display.Button;
	import starling.events.Event;
	import starling.textures.Texture;

	import uieditor.editor.feathers.FeathersUIUtil;

	public class LinkButton extends LayoutGroup
	{
		[Embed( source = "link_sign.png" )]
		public static const link_sign : Class;

		public static var link_sign_texture : Texture;

		private var _label1 : Label;
		private var _label2 : Label;

		private var _linkButton : Button;

		private var _isSelected : Boolean = false;

		public function LinkButton( isSelected : Boolean = false )
		{
			super();

			_isSelected = isSelected;

			if ( link_sign_texture == null )
			{
				link_sign_texture = Texture.fromBitmap( new link_sign());
			}

			layout = new VerticalLayout();
			_label1 = FeathersUIUtil.labelWithText( "┑" );
			_linkButton = new Button( link_sign_texture );
			_linkButton.scaleX = _linkButton.scaleY = 0.5;
			_label2 = FeathersUIUtil.labelWithText( "┛" );
			addChild( _label1 );
			addChild( _linkButton );
			addChild( _label2 );

			_label1.visible = _label2.visible = _isSelected;
			_linkButton.addEventListener( Event.TRIGGERED, onLink );
		}

		private function onLink( event : Event ) : void
		{
			_isSelected = !_isSelected;
			_label1.visible = _label2.visible = _isSelected;

			dispatchEventWith( Event.TRIGGERED );
		}

		public function get isSelected() : Boolean
		{
			return _isSelected;
		}

		override public function dispose() : void
		{
			_linkButton.removeEventListener( Event.TRIGGERED, onLink );
			_linkButton = null;

			super.dispose();
		}
	}
}
