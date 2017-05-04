package uieditor.editor.ui.inspector
{
	import starling.events.Event;

	public class ColorPickerPropertyComponent extends BasePropertyComponent
	{
		protected var _colorPicker : ColorPicker;

		public function ColorPickerPropertyComponent( propertyRetriever : IPropertyRetriever, param : Object )
		{
			super( propertyRetriever, param );

			var name : String = param.name;

			_colorPicker = new ColorPicker();

			_colorPicker.value = uint( _propertyRetriever.get( name ));
			_colorPicker.addEventListener( Event.CHANGE, onColorPick );
			addChild( _colorPicker );
		}

		override public function dispose() : void
		{
			_colorPicker.removeEventListener( Event.CHANGE, onColorPick );
			_colorPicker = null;
			super.dispose();
		}

		private function onColorPick( event : Event ) : void
		{
			_oldValue = _propertyRetriever.get( _param.name );
			_propertyRetriever.set( _param.name, _colorPicker.value );
			setChanged();
		}

		override public function update() : void
		{
			_colorPicker.value = uint( _propertyRetriever.get( _param.name ));
		}
	}
}
