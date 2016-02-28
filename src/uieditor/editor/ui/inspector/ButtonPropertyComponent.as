package uieditor.editor.ui.inspector
{
	import uieditor.editor.feathers.FeathersUIUtil;

	import feathers.controls.Button;
	import feathers.core.PopUpManager;

	import flash.utils.getDefinitionByName;

	import starling.display.DisplayObject;
	import starling.events.Event;

	public class ButtonPropertyComponent extends BasePropertyComponent
	{
		private var _button : Button;

		public function ButtonPropertyComponent( propertyRetriever : IPropertyRetriever, param : Object )
		{
			super( propertyRetriever, param );

			_button = FeathersUIUtil.buttonWithLabel( "修改", onEdit );
			addChild( _button );
		}

		private function onEdit( event : Event ) : void
		{
			if ( param.editPropertyClass )
			{
				var target : Object = _propertyRetriever.get( _param.name );

				var cls : Class = getDefinitionByName( param.editPropertyClass ) as Class;
				var proEdit : * = new cls( _propertyRetriever.target, target, param, function( item : Object ) : void {
					if ( !_param.read_only )
					{
						_oldValue = _propertyRetriever.get( _param.name );
						_propertyRetriever.set( _param.name, item );
						setChanged();
					}
				});

				if ( proEdit is DisplayObject )
				{
					PopUpManager.addPopUp( proEdit as DisplayObject );
				}
			}
		}




	}
}
