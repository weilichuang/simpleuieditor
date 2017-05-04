package uieditor.editor.ui.popup
{
	import flash.desktop.NativeApplication;
	
	import feathers.FEATHERS_VERSION;
	import feathers.controls.LayoutGroup;
	import feathers.layout.VerticalLayout;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.utils.Align;
	
	import uieditor.editor.UIEditorApp;
	import uieditor.editor.feathers.FeathersUIUtil;
	import uieditor.editor.feathers.popup.InfoPopup;




	public class AboutPopup extends InfoPopup
	{
		[Embed( source = "../../../../assets/icon/128.png" )]
		public static const ICON : Class;

		private var _iconTexture : Texture;

		public function AboutPopup()
		{
			_iconTexture = Texture.fromBitmap( new ICON());
			super();
			title = "Simple UI Editor";
			buttons = [ "确定" ];
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
			container.addChild(FeathersUIUtil.labelWithText("Starling version: " + Starling.VERSION));
			container.addChild(FeathersUIUtil.labelWithText("Feathers version: " + FEATHERS_VERSION));
			container.addChild(FeathersUIUtil.labelWithText("SWF version: " + UIEditorApp.SWF_VERSION));
		}

		override public function dispose() : void
		{
			_iconTexture.dispose();
			super.dispose();
		}
	}
}
