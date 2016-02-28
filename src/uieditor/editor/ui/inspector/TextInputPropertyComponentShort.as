package uieditor.editor.ui.inspector
{

	public class TextInputPropertyComponentShort extends TextInputPropertyComponent
	{
		public function TextInputPropertyComponentShort( propertyRetriever : IPropertyRetriever, param : Object )
		{
			super( propertyRetriever, param );

			_textInput.width = 50;
		}
	}
}
