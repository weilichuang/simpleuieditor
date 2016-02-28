package uieditor.editor.ui.itemrenderer
{
	import uieditor.editor.UIEditorApp;

	import feathers.controls.renderers.DefaultListItemRenderer;

	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.textures.Texture;

	public class IconItemRenderer extends DefaultListItemRenderer
	{
		private var _image : Image;

		public function IconItemRenderer()
		{
			super();
			_iconFunction = createIcon;
		}

		private function createIcon( item : Object ) : DisplayObject
		{
			var texture : Texture = UIEditorApp.instance.assetManager.getTexture( item.label );

			if ( _image == null )
			{
				_image = new Image( texture );
			}
			else
			{
				_image.texture = texture;
				_image.readjustSize();
			}

			_image.width = 50;
			_image.height = 50;
			return _image;
		}
	}
}
