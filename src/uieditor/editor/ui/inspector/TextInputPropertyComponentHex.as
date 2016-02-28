package uieditor.editor.ui.inspector
{

	public class TextInputPropertyComponentHex extends TextInputPropertyComponent
	{
		public function TextInputPropertyComponentHex( propertyRetriever : IPropertyRetriever, param : Object )
		{
			super( propertyRetriever, param );
		}

		override public function update() : void
		{
			var obj : Object = _propertyRetriever.get( _param.name );

			obj = int( obj ).toString( 16 );

			_textInput.text = "0x" + String( obj );
		}
	}
}
