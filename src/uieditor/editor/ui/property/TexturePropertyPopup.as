package uieditor.editor.ui.property
{
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.TextInput;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.layout.VerticalLayout;

	import starling.events.Event;

	import uieditor.editor.UIEditorApp;
	import uieditor.editor.ui.AssetTab;
	import uieditor.editor.ui.itemrenderer.IconItemRenderer;

	public class TexturePropertyPopup extends AbstractPropertyPopup
	{
		protected var _searchTextInput : TextInput;
		protected var _list : List;

		public function TexturePropertyPopup( owner : Object, target : Object, targetParam : Object, onComplete : Function )
		{
			super( owner, target, targetParam, onComplete );

			title = "选择图片";
			buttons = [ "确定", "取消" ];

			addEventListener( Event.COMPLETE, onDialogComplete );
		}

		override protected function createContent( container : LayoutGroup ) : void
		{
			container.layout = new VerticalLayout();

			_searchTextInput = new TextInput();
			_searchTextInput.prompt = "搜索...";
			_searchTextInput.addEventListener( Event.CHANGE, onSearch );

			addChild( _searchTextInput );

			_list = new List();
			_list.width = 200;
			_list.height = 400;
			_list.selectedIndex = -1;
			_list.itemRendererFactory = function() : IListItemRenderer
			{
				return new IconItemRenderer();
			}

			addChild( _list );

			refreshAssets();
		}

		private function onSearch( event : Event ) : void
		{
			refreshAssets();
		}

		private function filterList( text : String, array : Vector.<String> ) : Vector.<String>
		{
			if ( text.length )
			{
				var result : Vector.<String> = new Vector.<String>();

				for each ( var s : String in array )
				{
					if ( s.indexOf( text ) != -1 )
					{
						result.push( s );
					}
				}

				return result;
			}
			else
			{
				return array;
			}
		}

		private function refreshAssets() : void
		{
			var data : ListCollection = new ListCollection();

			var array : Vector.<String> = filterList( _searchTextInput.text, AssetTab.assetList );

			for each ( var name : String in array )
			{
				data.push({ label: name });
			}

			_list.dataProvider = data;
		}

		protected function onDialogComplete( event : Event ) : void
		{
			var index : int = int( event.data );

			if ( index == 0 )
			{
				if ( _list.selectedIndex >= 0 )
				{
					var textureName : String = _list.selectedItem.label;

					_target = UIEditorApp.instance.assetManager.getTexture( textureName );

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

		protected function setCustomParam( textureName : String ) : void
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
					cls: "starling.textures.Texture",
					textureName: textureName
				};
		}


		protected function complete() : void
		{
			_onComplete( _target );
		}

	}
}
