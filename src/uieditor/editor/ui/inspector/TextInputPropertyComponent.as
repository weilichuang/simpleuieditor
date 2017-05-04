package uieditor.editor.ui.inspector
{
	import feathers.controls.Check;
	import feathers.events.FeathersEventType;

	import starling.events.Event;

	import uieditor.editor.feathers.AutoCompleteWithDropDown;
	import uieditor.editor.feathers.FeathersUIUtil;

	public class TextInputPropertyComponent extends BasePropertyComponent
	{
		protected var _textInput : AutoCompleteWithDropDown;

		protected var _check : Check;

		public function TextInputPropertyComponent( propertyRetriever : IPropertyRetriever, param : Object )
		{
			super( propertyRetriever, param );

			layout = FeathersUIUtil.horizontalLayout();

			_textInput = new AutoCompleteWithDropDown();
			addChild( _textInput );

			if ( _param.width )
			{
				_textInput.width = _param.width;
			}
			else
			{
				_textInput.width = 200;
			}

			if ( _param.disable )
			{
				_textInput.isEnabled = false;
			}
			else
			{
				_textInput.isEnabled = true;
			}

			if ( _param.options )
			{
				_textInput.autoCompleteSource = _param.options;
			}
			else
			{
				_textInput.autoCompleteSource = [];
			}

			if ( _param.restrict )
			{
				_textInput.restrict = _param.restrict;
			}
			else
			{
				_textInput.restrict = null;
			}

			update();

			_textInput.addEventListener( FeathersEventType.FOCUS_OUT, onTextInputFocusOut );
			_textInput.addEventListener( FeathersEventType.FOCUS_IN, onTextInputFocusIn );
			_textInput.addEventListener( FeathersEventType.ENTER, onTextInput );
			_textInput.addEventListener( Event.CHANGE, onTextInput );
			_textInput.addEventListener( Event.CLOSE, onTextInput );

			if ( _param.explicitField )
			{
				_check = new Check();
				_check.label = "explicit";
				_check.addEventListener( Event.CHANGE, onCheck );
				addChild( _check );
			}
		}

		override public function dispose() : void
		{
			_textInput.removeEventListener( FeathersEventType.FOCUS_OUT, onTextInputFocusOut );
			_textInput.removeEventListener( FeathersEventType.FOCUS_IN, onTextInputFocusIn );
			_textInput.removeEventListener( FeathersEventType.ENTER, onTextInput );
			_textInput.removeEventListener( Event.CHANGE, onTextInput );
			_textInput.removeEventListener( Event.CLOSE, onTextInput );
			_textInput = null;

			if ( _check != null )
			{
				_check.removeEventListener( Event.CHANGE, onCheck );
				_check = null;
			}

			super.dispose();
		}

		private function onTextInputFocusIn( event : Event ) : void
		{
			_textInput.selectRange( 0, _textInput.text.length );
		}

		private function onTextInputFocusOut( event : Event ) : void
		{
			changeValue( _textInput.text );
		}

		private function onTextInput( event : Event ) : void
		{
			changeValue( _textInput.text );
		}

		private function changeValue( value : Object ) : void
		{
			if ( !_param.disable )
			{
				if ( _textInput.text == "-" )
					return;

				_oldValue = _propertyRetriever.get( _param.name );
				_propertyRetriever.set( _param.name, value );
				setChanged();
			}
		}

		override public function update() : void
		{
			_textInput.text = String( _propertyRetriever.get( _param.name ));

			if ( _check )
			{
				_textInput.isEnabled = _check.isSelected = _propertyRetriever.get( _param.explicitField );
			}
		}

		private function onCheck( event : Event ) : void
		{
			_textInput.isEnabled = _check.isSelected;

			if ( _textInput.isEnabled )
			{
				changeValue( _textInput.text );
			}
			else
			{
				changeValue( NaN );
			}
		}

	}
}
