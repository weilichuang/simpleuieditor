package uieditor.editor.ui
{
	import feathers.controls.LayoutGroup;
	import feathers.layout.VerticalLayout;
	import flash.desktop.NativeApplication;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.utils.Align;
	import uieditor.editor.feathers.FeathersUIUtil;
	import uieditor.editor.feathers.popup.InfoPopup;




	public class AboutPopup extends InfoPopup
	{
		[Embed( source = "../../../assets/icon/128.png" )]
		public static const ICON : Class;

		private var _iconTexture : Texture;

		public function AboutPopup()
		{
			_iconTexture = Texture.fromBitmap( new ICON());
			super();
			title = "Simple UI Editor";
			buttons = [ "OK" ];
		}

		override protected function createContent( container : LayoutGroup ) : void
		{
			var layout : VerticalLayout = new VerticalLayout();
			layout.gap = 20;
			layout.horizontalAlign = Align.CENTER;
			container.layout = layout;

			var descriptor : XML = NativeApplication.nativeApplication.applicationDescriptor;

			var version : String;
			var copyright : String;

			var ns : Namespace = descriptor.namespace();
			version = descriptor.ns::versionLabel[ 0 ].toString();
			if ( version == "" )
				version = descriptor.ns::versionNumber[ 0 ].toString();

			copyright = descriptor.ns::copyright[ 0 ].toString();

			container.addChild( new Image( _iconTexture ));
			container.addChild( FeathersUIUtil.labelWithText( version ));
			container.addChild( FeathersUIUtil.labelWithText( copyright ));
		}

		override public function dispose() : void
		{
			_iconTexture.dispose();
			super.dispose();
		}
	}
}
