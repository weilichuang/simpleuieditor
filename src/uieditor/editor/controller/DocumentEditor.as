package uieditor.editor.controller
{
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import feathers.core.FeathersControl;
	import feathers.data.ListCollection;
	import feathers.dragDrop.IDropTarget;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.utils.AssetManager;
	
	import uieditor.editor.UIEditorApp;
	import uieditor.editor.UIEditorScreen;
	import uieditor.editor.data.TemplateData;
	import uieditor.editor.events.DocumentEventType;
	import uieditor.editor.model.FileSetting;
	import uieditor.editor.model.Setting;
	import uieditor.editor.themes.IUIEditorThemeMediator;
	import uieditor.editor.ui.inspector.PropertyPanel;
	import uieditor.editor.ui.inspector.UIMapperEventType;
	import uieditor.engine.IUIBuilder;
	import uieditor.engine.UIBuilder;

	//TODO 添加拖动物品时判断是否可以移入鼠标下的容器内
	public class DocumentEditor extends AbstractDocumentEditor implements IDocumentEditor, IUIEditorThemeMediator, IDropTarget
	{
		private var _uiBuilderForGame : IUIBuilder;

		private var _librarys : Dictionary;

		private var _setting : Setting;

		private var _atlas : String;

		public function DocumentEditor( assetManager : AssetManager, localizationManager : LocalizationManager )
		{
			super( assetManager, localizationManager );

			_librarys = new Dictionary();

			_uiBuilderForGame = new UIBuilder( _assetMediator, false, TemplateData.editor_template, _localizationManager.localization );

			PropertyPanel.globalDispatcher.addEventListener( UIMapperEventType.PROPERTY_CHANGE, onPropertyChange );

			_setting = UIEditorScreen.instance.setting;

			this.visible = false;
		}

		public function get librarys() : Dictionary
		{
			return _librarys;
		}

		public function setAtlas( atlas : String ) : void
		{
			this._atlas = atlas;
		}

		private function createRoot( cls : String ) : void
		{
			var data : Object = { cls: cls, customParams: {}, params: { name: "root" }};
			var result : Object = _uiBuilder.createUIElement( data );
			setRoot( result.object, result.params );

			var objects : Array = [];
			var obj : DisplayObjectContainer = result.object;
			obj.x = 0;
			obj.y = 0;
			getObjectsByPrefixTraversal( obj, _extraParamsDict, objects );
			addFrom( obj, result.params, null );
		}

		private function onPropertyChange( event : Event ) : void
		{
			var target : Object = event.data.target;

			if ( target === _selectedObject )
			{
				recordPropertyChangeHistory( event.data );

				setChanged();
			}
		}

		public function startTest( forGame : Boolean = false ) : Sprite
		{
			var testContainer : Sprite = new Sprite();

			var data : Object = _uiBuilder.save( _layoutContainer, _extraParamsDict, _librarys, _atlas, TemplateData.editor_template );

			var setting : Object = exportSetting();

			var root : DisplayObject;

			if ( forGame )
			{
				root = _uiBuilderForGame.load( data ).object;
			}
			else
			{
				root = _uiBuilder.load( data ).object;
			}

			testContainer.addChild( root );

			return testContainer;
		}

		public function export() : Object
		{
			//如果当前文档是库，先保存库对象
			if ( UIEditorApp.instance.currentDocumentEditor is LibraryDocumentEditor )
			{
				LibraryDocumentEditor( UIEditorApp.instance.currentDocumentEditor ).save();
			}
			return _uiBuilder.save( _layoutContainer, _extraParamsDict, _librarys, _atlas, exportSetting());
		}

		/**
		 * 刷新窗口
		 */
		public function refresh() : void
		{
			if(_assetMediator.file == null)
				return;
			
			var result : Object = export();
			load( result, _assetMediator.file );
		}

		public function load( data : Object, file : File ) : void
		{
			this.visible = true;
			_assetMediator.file = file;

			reset();

			_librarys = _uiBuilder.loadLibrary( data );
			dispatchEventWith( DocumentEventType.UPDATE_LIBRARY );

			var result : Object = _uiBuilder.load( data, _librarys );

			var container : DisplayObjectContainer = result.object;

			var objects : Array = [];

			var obj : DisplayObject;

			getObjectsByPrefixTraversal( container, result.params, objects );

			setRoot( container, result.params[ container ]);

			//add other objects
			for each ( obj in objects )
			{
				addFrom( obj, result.params[ obj ], null );
			}

			importSetting( result.data.setting );

			resize();

			setLayerChanged();
			setChanged();
			
			dispatchEventWith(DocumentEventType.OPEN_NEW_FILE);
		}

		public function hasLibrary( linkage : String ) : Boolean
		{
			return _librarys[ linkage ] != null;
		}

		public function removeLibrary( linkage : String ) : void
		{
			delete _librarys[ linkage ];
		}

		public function renameLibrary( oldLinkage : String, newLinkage : String ) : void
		{
			var data : Object = _librarys[ oldLinkage ];
			_librarys[ newLinkage ] = data;
			delete _librarys[ oldLinkage ];
		}

		public function updateLibrary( linkage : String, data : Object, fireEvent : Boolean = true ) : void
		{
			_librarys[ linkage ] = data;
			if ( fireEvent )
			{
				setChanged();
				dispatchEventWith( DocumentEventType.UPDATE_LIBRARY );
			}
		}
		
		public function cleanLibrarys():void
		{
			_librarys = new Dictionary();
			
			setChanged();
			dispatchEventWith( DocumentEventType.UPDATE_LIBRARY );
		}

		public function getLibrary( linkage : String ) : Object
		{
			return _librarys[ linkage ];
		}

		override protected function reset() : void
		{
			super.reset();

			selectObject( null );
			hoverObject( null );

			_mutliSelectBox.clean();

			_layoutContainer.removeChildren( 0, -1, true );
			_snapContainer.removeChildren( 0, -1, true );
			_extraParamsDict = new Dictionary();
			_dataProvider = new ListCollection();
			_dataProviderForList = new ListCollection();

			canvasSize = new Point( _setting.defaultCanvasWidth, _setting.defaultCanvasHeight );
			background = null;
			_historyManager.reset();
		}

		public function clear() : void
		{
			reset();
			createRoot( _setting.rootContainerClass );
			refreshLabels();
			setChanged();
		}

		public function createNew( param : FileSetting ) : void
		{
			this.visible = true;
			reset();
			createRoot( param.rootContainerClass );
			canvasSize = new Point( param.width, param.height );
			refreshLabels();
			cleanLibrarys();
			setChanged();
			dispatchEventWith(DocumentEventType.OPEN_NEW_FILE);
		}

		override public function setChanged() : void
		{
			refreshLabels();
			dispatchEventWith( DocumentEventType.CHANGE );

			if ( this.parent is FeathersControl )
			{
				( this.parent as FeathersControl ).invalidate();
			}
		}
	}
}
