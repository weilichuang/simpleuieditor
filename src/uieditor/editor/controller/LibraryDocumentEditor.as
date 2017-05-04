package uieditor.editor.controller
{
	import flash.geom.Point;
	import flash.utils.Dictionary;

	import feathers.core.FeathersControl;
	import feathers.data.ListCollection;
	import feathers.dragDrop.IDropTarget;

	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;

	import uieditor.editor.UIEditorApp;
	import uieditor.editor.UIEditorScreen;
	import uieditor.editor.events.DocumentEventType;
	import uieditor.editor.feathers.popup.MsgBox;
	import uieditor.editor.ui.inspector.PropertyPanel;
	import uieditor.editor.ui.inspector.UIMapperEventType;

	/**
	 * 库元件编辑场景
	 */
	public class LibraryDocumentEditor extends AbstractDocumentEditor implements IDocumentEditor, IDropTarget
	{
		private var _documentEditor : DocumentEditor;

		private var _linkage : String;

		public function LibraryDocumentEditor( documentEditor : DocumentEditor )
		{
			_documentEditor = documentEditor;

			super( documentEditor.assetManager, documentEditor.localizationManager );

			PropertyPanel.globalDispatcher.addEventListener( UIMapperEventType.PROPERTY_CHANGE, onPropertyChange );

			this.visible = false;
		}

		private function createRoot( cls : String, linkage : String ) : void
		{
			var data : Object = { cls: cls, customParams: {}, params: { name: linkage }};
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

		override protected function reset() : void
		{
			super.reset();

			_linkage = null;

			selectObject( null );
			hoverObject( null );

			_mutliSelectBox.clean();

			_historyManager.reset();

			_layoutContainer.removeChildren( 0, -1, true );
			_snapContainer.removeChildren( 0, -1, true );
			_extraParamsDict = new Dictionary();
			_dataProvider = new ListCollection();
			_dataProviderForList = new ListCollection();

			canvasSize = new Point( UIEditorScreen.instance.setting.defaultCanvasWidth, UIEditorScreen.instance.setting.defaultCanvasHeight );
			background = null;
		}

		override public function createComponentFromLibrary( linkage : String, x : Number, y : Number ) : void
		{
			if ( _linkage == linkage )
			{
				MsgBox.show( "提示", "不能在自身容器内加入自己" );
				return;
			}
			super.createComponentFromLibrary( linkage, x, y );
		}

		public function importData( data : Object ) : void
		{
			this.visible = true;

			reset();

			_linkage = data.layout.params.name;

			var result : Object = _uiBuilder.load( data, UIEditorApp.instance.documentEditor.librarys );

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

			if ( data.layout.setting )
				importSetting( data.layout.setting );
			else
				importSetting({ canvasSize: { x: 500, y: 500 }, backgroundColor: 0x555555 });

			resize();

			setLayerChanged();
			setChanged();
		}

		public function get linkage() : String
		{
			return _linkage;
		}

		override public function set rootName( name : String ) : void
		{
			if ( _linkage != name )
			{
				_documentEditor.renameLibrary( _linkage, name );
				_linkage = name;
			}

			super.rootName = name;
		}

		public function save() : void
		{
			if ( _linkage == null )
				return;

			var data : Object = _uiBuilder.saveLibrary( _layoutContainer, _extraParamsDict, _documentEditor.librarys, exportSetting());
			_documentEditor.updateLibrary( _linkage, data, false );
		}

		override public function setChanged() : void
		{
			refreshLabels();
			dispatchEventWith( DocumentEventType.CHANGE );

			if ( this.parent is FeathersControl )
			{
				( this.parent as FeathersControl ).invalidate();
			}

			//修改库文件时，主文档也需要刷新
			save();
			_documentEditor.setChanged();
		}
	}
}
