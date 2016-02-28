package uieditor.editor.ui.itemrenderer
{
	import feathers.controls.renderers.DefaultListItemRenderer;

	import starling.display.DisplayObject;
	import starling.text.TextField;
	import starling.utils.Color;

	public class TextItemRenderer extends DefaultListItemRenderer
	{
		private var _text : TextField;

		public function TextItemRenderer()
		{
			super();
			_iconFunction = createIcon;
		}

		private function createIcon( item : Object ) : DisplayObject
		{
			if ( _text == null )
			{
				_text = new TextField( 50, 50, TextTab.DEFAULT_TEXT );
			}

			_text.color = Color.WHITE;
			_text.fontName = item.label;
			return _text;
		}
	}
}
