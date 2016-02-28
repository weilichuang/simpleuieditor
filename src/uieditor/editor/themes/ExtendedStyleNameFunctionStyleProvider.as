
package uieditor.editor.themes
{
	import feathers.skins.StyleNameFunctionStyleProvider;

	public class ExtendedStyleNameFunctionStyleProvider extends StyleNameFunctionStyleProvider
	{
		public function ExtendedStyleNameFunctionStyleProvider( styleFunction : Function = null )
		{
			super( styleFunction );
		}

		public function get styleNameMap() : Object
		{
			return _styleNameMap;
		}


	}
}
