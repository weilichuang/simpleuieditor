package uieditor.editor.ui.inspector
{

	public class UIMapperUtil
	{
		public static function processParamsWithFonts( params : Array, fonts : Array ) : void
		{
			for each ( var item : Object in params )
			{
				if (( item.component == PropertyComponentType.TEXT_INPUT || item.component == PropertyComponentType.PICKER_LIST ) && item.name == "fontName" )
				{
					item.options = fonts;
				}
			}
		}
	}
}
