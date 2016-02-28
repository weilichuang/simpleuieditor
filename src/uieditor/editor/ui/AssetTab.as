package uieditor.editor.ui
{
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.PickerList;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.controls.TextInput;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.AssetManager;
	import uieditor.editor.controller.DocumentEditor;
	import uieditor.editor.controller.DragFormat;
	import uieditor.editor.data.TemplateData;
	import uieditor.editor.feathers.FeathersUIUtil;
	import uieditor.editor.helper.UIComponentHelper;
	import uieditor.editor.SupportedWidget;
	import uieditor.editor.ui.itemrenderer.DragIconItemRenderer;
	import uieditor.editor.UIEditorApp;
	import uieditor.editor.UIEditorScreen;
	import uieditor.editor.util.FileLoader;
	import uieditor.engine.util.ParamUtil;

	public class AssetTab extends LayoutGroup
	{
		public static var assetList : Vector.<String>;

		private var _assetManager : AssetManager;

		private var _documentManager : DocumentEditor;

		private var _list : List;

		private var _typePicker : PickerList;

		private var _textInput : TextInput;

		private var _scaleDataGroup : LayoutGroup;

		private var _createButton : Button;

		private var _supportedTypes : Array;

		private var _searchTextInput : TextInput;

		private var _topContainer : LayoutGroup;

		private var _bottomContainer : LayoutGroup;

		public function AssetTab()
		{
			_assetManager = UIEditorApp.instance.assetManager;

			_documentManager = UIEditorApp.instance.documentEditor;

			var anchorLayoutData : AnchorLayoutData = new AnchorLayoutData();
			anchorLayoutData.top = 25;
			anchorLayoutData.bottom = 0;
			this.layoutData = anchorLayoutData;

			layout = new AnchorLayout();

			createSupportedTypes();

			createTopContainer();

			createSearchTextInput();

			//createBrowseButton();

			createBottomContainer();

			listAssets();

			UIEditorApp.instance.addEventListener( "assetChange", onAssetChange );
		}

		private function onAssetChange( e : Event ) : void
		{
			assetList = getTextureNames();

			refreshAssets();
		}

		private function createTopContainer() : void
		{
			_topContainer = FeathersUIUtil.layoutGroupWithHorizontalLayout();
			addChild( _topContainer );
		}

		private function createBottomContainer() : void
		{
			_bottomContainer = new LayoutGroup();
			_bottomContainer.layout = new VerticalLayout();

			var anchorLayoutData : AnchorLayoutData = new AnchorLayoutData();
			anchorLayoutData.bottom = 0;
			_bottomContainer.layoutData = anchorLayoutData;

			addChild( _bottomContainer );

			createPickerList( _bottomContainer );

			createScaleData( _bottomContainer );

			createCreateButton( _bottomContainer );
		}

		private function createSupportedTypes() : void
		{
			_supportedTypes = TemplateData.getSupportedComponent( "asset" );
		}

		private function createSearchTextInput() : void
		{
			_searchTextInput = new TextInput();
			_searchTextInput.prompt = "搜索...";
			_searchTextInput.width = 280;

			var anchorLayoutData : AnchorLayoutData = new AnchorLayoutData();
			anchorLayoutData.top = 5;
			_searchTextInput.layoutData = anchorLayoutData;
			_searchTextInput.addEventListener( Event.CHANGE, onSearch );

			_topContainer.addChild( _searchTextInput );
		}

		private function createBrowseButton() : void
		{
			_topContainer.addChild( FeathersUIUtil.buttonWithLabel( "选择贴图", function() : void {

				FileLoader.browse( function( file : File ) : void {
					var direction : String = file.nativePath.slice( 0, file.nativePath.lastIndexOf( file.name ));
					UIEditorScreen.instance.toolbar.getSeralizer().loadUIAsset( direction, file.name );
				}, null, [ new FileFilter( "*.jpeg", "*.jpeg" )]);

			}));
		}

		private function onListChange( event : Event ) : void
		{
			//if (_list.selectedIndex != -1)
			//{
			//var name:String = _list.selectedItem.label;
//
			////var editorData:Object = {name:name, textureName:name};
			////editorData.cls = _supportedTypes[_typePicker.selectedIndex];
			////if (_textInput.text != "")
			////{
			////editorData.scaleData = JSON.parse(_textInput.text) as Array;
			////}
//
			////UIComponentHelper.createComponent(editorData);
//
			//_list.selectedIndex = -1;
			//}
		}

		public function getItemEditorData( item : Object ) : Object
		{
			var name : String = item.label;
			var editorData : Object = { name: name, textureName: name };
			editorData.cls = _supportedTypes[ _typePicker.selectedIndex ];
			if ( _textInput.text != "" )
			{
				editorData.scaleData = JSON.parse( _textInput.text ) as Array;
			}
			return editorData;
		}

		private function listAssets() : void
		{
			_list = new List();
			_list.width = 280;
			_list.height = 800;
			_list.selectedIndex = -1;
			_list.itemRendererFactory = function() : IListItemRenderer
			{
				return new DragIconItemRenderer( DragFormat.FORMAT_ASSET );
			}

			var anchorLayoutData : AnchorLayoutData = new AnchorLayoutData();
			anchorLayoutData.top = 0;
			anchorLayoutData.bottom = 0;
			anchorLayoutData.topAnchorDisplayObject = _topContainer;
			anchorLayoutData.bottomAnchorDisplayObject = _bottomContainer;
			_list.layoutData = anchorLayoutData;

			assetList = getTextureNames();

			refreshAssets();
			_list.addEventListener( Event.CHANGE, onListChange );
			addChild( _list );
		}

		private function getTextureNames() : Vector.<String>
		{
			var array : Vector.<String> = _assetManager.getTextureNames();

			for ( var i : int = array.length - 1; i >= 0; --i )
			{
				var name : String = array[ i ];

				if ( _assetManager.getTextureAtlas( name ) || TextField.getBitmapFont( name ))
				{
					array.splice( i, 1 );
				}
			}

			return array;
		}

		private function refreshAssets() : void
		{
			var data : ListCollection = new ListCollection();

			var array : Vector.<String> = filterList( _searchTextInput.text, assetList );

			for each ( var name : String in array )
			{
				data.push({ label: name });
			}

			_list.dataProvider = data;
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

		private function createPickerList( container : Sprite ) : void
		{
			_typePicker = new PickerList();

			_typePicker.dataProvider = new ListCollection( _supportedTypes );
			_typePicker.addEventListener( Event.CHANGE, onTypePickerChange );
			_typePicker.selectedIndex = 0;


			var anchorLayoutData : AnchorLayoutData = new AnchorLayoutData();
			anchorLayoutData.bottom = 0;
			anchorLayoutData.bottomAnchorDisplayObject = _createButton;
			_typePicker.layoutData = anchorLayoutData;

			container.addChild( _typePicker );
		}

		private function createScaleData( container : Sprite ) : void
		{
			var label : Label = FeathersUIUtil.labelWithText( "scale data" );
			_textInput = new TextInput();

			_scaleDataGroup = new LayoutGroup();
			_scaleDataGroup.layout = new HorizontalLayout();
			_scaleDataGroup.addChild( label );
			_scaleDataGroup.addChild( _textInput );
			_scaleDataGroup.visible = false;

			container.addChild( _scaleDataGroup );
		}

		private function createCreateButton( container : Sprite ) : void
		{
			_createButton = FeathersUIUtil.buttonWithLabel( "create" );
			_createButton.addEventListener( Event.TRIGGERED, onCreateButton );
			_createButton.visible = false;

			var anchorLayoutData : AnchorLayoutData = new AnchorLayoutData();
			anchorLayoutData.bottom = 0;
			_createButton.layoutData = anchorLayoutData;

			container.addChild( _createButton );
		}

		private function onCreateButton( event : Event ) : void
		{
			var cls : String = _supportedTypes[ _typePicker.selectedIndex ];

			var name : String = ParamUtil.getDisplayObjectName( cls );

			var editorData : Object = { name: name, textureName: name, cls: cls };
			UIComponentHelper.createComponent( editorData );
		}

		private function onTypePickerChange( event : Event ) : void
		{
			var cls : String = _typePicker.selectedItem as String;


			if ( ParamUtil.scale3Data( TemplateData.editor_template, cls ))
			{
				_textInput.text = JSON.stringify( SupportedWidget.DEFAULT_SCALE3_RATIO );
				_scaleDataGroup.visible = true;
			}
			else if ( ParamUtil.scale9Data( TemplateData.editor_template, cls ))
			{
				_textInput.text = JSON.stringify( SupportedWidget.DEFAULT_SCALE9_RATIO );
				_scaleDataGroup.visible = true;
			}
			else
			{
				_textInput.text = "";
				_scaleDataGroup.visible = false;
			}


			if ( ParamUtil.createButton( TemplateData.editor_template, cls ))
			{
				_createButton.visible = true;
			}
			else
			{
				_createButton.visible = false;
			}
		}

		private function onSearch( event : Event ) : void
		{
			refreshAssets();
		}
	}
}
