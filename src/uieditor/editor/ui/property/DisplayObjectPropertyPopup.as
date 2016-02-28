package uieditor.editor.ui.property
{
	import starling.display.Image;
	import starling.events.Event;
	
	import uieditor.editor.UIEditorApp;

	public class DisplayObjectPropertyPopup extends TexturePropertyPopup
	{
		public function DisplayObjectPropertyPopup( owner : Object, target : Object, targetParam : Object, onComplete : Function )
		{
			super( owner, target, targetParam, onComplete );
		}

		override protected function onDialogComplete( event : Event ) : void
		{
			var index : int = int( event.data );

			if ( index == 0 )
			{
				if ( _list.selectedIndex >= 0 )
				{
					var textureName : String = _list.selectedItem.label;

					_target = new Image( UIEditorApp.instance.assetManager.getTexture( textureName ));

					setCustomParam( textureName );
				}
				else
				{
					_target = null;
				}

				complete();
			}
			else
			{
				_owner[ _targetParam.name ] = _oldTarget;
				_onComplete = null;
			}
		}

		override protected function setCustomParam( textureName : String ) : void
		{
			/*
			 TODO:
			 this is a temparary solution to store a custom value since Texture doesn't contain it.
			 This problem will be resolved when we use an intermediate format for the inspector in future version
			 */

			var param : Object = UIEditorApp.instance.currentDocumentEditor.extraParamsDict[ _owner ];

			if ( param.params == undefined )
			{
				param.params = {};
			}

			param.params[ _targetParam.name ] =
				{
					cls: "starling.display.Image",
					constructorParams: [
					{
							cls: "starling.textures.Texture",
							textureName: textureName
						}
					],
					customParams: {}
				};
		}

	}
}
