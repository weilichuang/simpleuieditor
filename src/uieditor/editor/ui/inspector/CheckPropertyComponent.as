package uieditor.editor.ui.inspector
{
	import feathers.controls.Check;

	import starling.events.Event;

	public class CheckPropertyComponent extends BasePropertyComponent
	{
		protected var _check : Check;

		public function CheckPropertyComponent( propertyRetriever : IPropertyRetriever, param : Object )
		{
			super( propertyRetriever, param );

			_check = new Check();
			_check.addEventListener( Event.CHANGE, onCheckChange );
			_check.isSelected = _propertyRetriever.get( _param.name );
			addChild( _check );
		}

		private function onCheckChange( event : Event ) : void
		{
			_oldValue = _propertyRetriever.get( _param.name );
			_propertyRetriever.set( _param.name, _check.isSelected );

			setChanged();
		}

		override public function dispose() : void
		{
			_check.removeEventListener( Event.CHANGE, onCheckChange );
			_check = null;
			super.dispose();
		}

		override public function update() : void
		{
			_check.isSelected = _propertyRetriever.get( _param.name );
		}


	}
}
