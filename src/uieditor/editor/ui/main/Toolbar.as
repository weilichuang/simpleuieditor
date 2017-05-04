package uieditor.editor.ui.main
{
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.filesystem.File;
	
	import feathers.controls.Button;
	import feathers.controls.ButtonGroup;
	import feathers.controls.LayoutGroup;
	import feathers.controls.TextInput;
	import feathers.core.PopUpManager;
	import feathers.data.ListCollection;
	import feathers.layout.HorizontalLayout;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.TextureAtlas;
	import starling.utils.AssetManager;
	
	import uieditor.editor.UIEditorApp;
	import uieditor.editor.UIEditorScreen;
	import uieditor.editor.controller.AbstractDocumentEditor;
	import uieditor.editor.controller.DocumentEditor;
	import uieditor.editor.data.EmbedAsset;
	import uieditor.editor.events.DocumentEventType;
	import uieditor.editor.feathers.popup.MsgBox;
	import uieditor.editor.history.HistoryManager;
	import uieditor.editor.history.OpenRecentManager;
	import uieditor.editor.menu.MainMenu;
	import uieditor.editor.serialize.DocumentSerializer;
	import uieditor.editor.serialize.IDocumentMediator;
	import uieditor.editor.serialize.UIEditorDocumentMediator;
	import uieditor.editor.ui.popup.AboutPopup;
	import uieditor.editor.ui.popup.TestPanel;
	import uieditor.editor.util.UIAlignType;

	public class Toolbar extends LayoutGroup
	{
		public static const RELOAD : String = "reload";

		private var _assetManager : AssetManager;
		private var _documenEditor : DocumentEditor;

		private var _serializer : DocumentSerializer;
		private var _mediator : IDocumentMediator;

		private var _recentOpenManager : OpenRecentManager;

		private var _buttonGroup : ButtonGroup;

		private var _canvasSizeWidth : TextInput;
		private var _canvasSizeHeight : TextInput;

		private var _canvasScale : TextInput;

		public function Toolbar()
		{
			super();

			var layout : HorizontalLayout = new HorizontalLayout();
			layout.padding = 2;
			layout.gap = 2;
			this.layout = layout;

			_assetManager = UIEditorApp.instance.assetManager;
			_documenEditor = UIEditorApp.instance.documentEditor;

			_mediator = new UIEditorDocumentMediator();

			_serializer = new DocumentSerializer( _mediator );
			_serializer.addEventListener( RELOAD, doReload );
			_serializer.addEventListener( DocumentSerializer.CHANGE, onChange );

			_recentOpenManager = new OpenRecentManager();

			_buttonGroup = new ButtonGroup();
			_buttonGroup.direction = ButtonGroup.DIRECTION_HORIZONTAL;
			_buttonGroup.dataProvider = new ListCollection( createTextButtons());
			addChild( _buttonGroup );

			addEventListener( starling.events.Event.ENTER_FRAME, onEnterFrame );

			var window : NativeWindow = Starling.current.nativeStage.nativeWindow;

			window.addEventListener( flash.events.Event.CLOSING, onClosing );

			UIEditorApp.instance.documentEditor.addEventListener( DocumentEventType.CHANGE, onDocumentChange );

			registerMenuActions();

			//NativeDragAndDropHelper.start(function(file:File):void {
			//if (file.extension != "json")
			//return;
			//_serializer.openWithFile(file);
			//});

			UIEditorApp.instance.notificationDispatcher.addEventListener( DocumentEventType.CHANGE_DOCUMENT_EDITOR, onChangeDocumentEditor );
			onChangeDocumentEditor(null);
		}

		private var _curDocumentEditor : AbstractDocumentEditor;
		private var _isFirstTime:Boolean=true;
		private function onChangeDocumentEditor( event : starling.events.Event ) : void
		{
			if ( _curDocumentEditor != null )
			{
				_curDocumentEditor.historyManager.removeEventListener( starling.events.Event.CHANGE, updateHistoryManager );
				_curDocumentEditor.historyManager.removeEventListener( HistoryManager.RESET, updateHistoryManager );
			}
			_curDocumentEditor = UIEditorApp.instance.currentDocumentEditor;
			_curDocumentEditor.historyManager.addEventListener( starling.events.Event.CHANGE, updateHistoryManager );
			_curDocumentEditor.historyManager.addEventListener( HistoryManager.RESET, updateHistoryManager );
			
			if(_isFirstTime)
			{
				_isFirstTime = false;
				return;
			}
			updateHistoryManager();
		}

		private function createTextButtons() : Array
		{
			var atlas : TextureAtlas = EmbedAsset.getEditorTextureAtlas();
			return [
				{ defaultIcon: new Image( atlas.getTexture( "iconfont-file" )), label: "", toolTip: "新建文件", triggered: onNewButtonClick },
				{ defaultIcon: new Image( atlas.getTexture( "iconfont-folderopen" )), label: "", toolTip: "打开文件", triggered: onOpenButtonClick },
				{ defaultIcon: new Image( atlas.getTexture( "iconfont-save" )), label: "", toolTip: "保存文件", triggered: onSaveButtonClick },
				{ defaultIcon: new Image( atlas.getTexture( "iconfont-play" )), label: "", toolTip: "测试", triggered: onTestButtonClick },
				{ defaultIcon: new Image( atlas.getTexture( "iconfont-undo" )), label: "", toolTip: "撤销", triggered: onUndoButtonClick },
				{ defaultIcon: new Image( atlas.getTexture( "iconfont-repeat" )), label: "", toolTip: "重做", triggered: onRedoButtonClick },
				{ defaultIcon: new Image( atlas.getTexture( "iconfont-zoomin" )), label: "", toolTip: "放大窗口", triggered: onZoomInButtonClick },
				{ defaultIcon: new Image( atlas.getTexture( "iconfont-zoomout" )), label: "", toolTip: "缩小窗口", triggered: onZoomOutButtonClick },
				{ defaultIcon: new Image( atlas.getTexture( "iconfont-search" )), label: "", toolTip: "还原窗口大小", triggered: onZoomResetButtonClick },
				{ defaultIcon: new Image( atlas.getTexture( "iconfont-cog" )), label: "", toolTip: "设置", triggered: onConfigButtonClick },

				{ defaultIcon: new Image( atlas.getTexture( "iconfont-zuoduiqi" )), label: "", toolTip: "左对齐", triggered: onLeftAlignClick },
				{ defaultIcon: new Image( atlas.getTexture( "iconfont-shuipingjuzhongduiqi" )), label: "", toolTip: "水平居中", triggered: onCenterXAlignButtonClick },
				{ defaultIcon: new Image( atlas.getTexture( "iconfont-youduiqi" )), label: "", toolTip: "右对齐", triggered: onRightAlignClick },
				{ defaultIcon: new Image( atlas.getTexture( "iconfont-shangduiqi" )), label: "", toolTip: "顶对齐", triggered: onTopAlignButtonClick },
				{ defaultIcon: new Image( atlas.getTexture( "iconfont-chuizhijuzhongduiqi" )), label: "", toolTip: "垂直居中", triggered: onCenterYAlignButtonClick },
				{ defaultIcon: new Image( atlas.getTexture( "iconfont-xiaduiqi" )), label: "", toolTip: "底对齐", triggered: onBottomAlignButtonClick },
				{ defaultIcon: new Image( atlas.getTexture( "iconfont-alignjustify-x" )), label: "", toolTip: "垂直居中分布", triggered: onLayoutXButtonClick },
				{ defaultIcon: new Image( atlas.getTexture( "iconfont-alignjustify-y" )), label: "", toolTip: "水平居中分布", triggered: onLayoutYButtonClick }
				]
		}

		private function onLayoutXButtonClick( event : starling.events.Event ) : void
		{
			UIEditorApp.instance.currentDocumentEditor.alignUI( UIAlignType.LAYOUT_X );
		}

		private function onLayoutYButtonClick( event : starling.events.Event ) : void
		{
			UIEditorApp.instance.currentDocumentEditor.alignUI( UIAlignType.LAYOUT_Y );
		}

		private function onLeftAlignClick( event : starling.events.Event ) : void
		{
			UIEditorApp.instance.currentDocumentEditor.alignUI( UIAlignType.LEFT );
		}

		private function onCenterXAlignButtonClick( event : starling.events.Event ) : void
		{
			UIEditorApp.instance.currentDocumentEditor.alignUI( UIAlignType.CENTER_X );
		}

		private function onRightAlignClick( event : starling.events.Event ) : void
		{
			UIEditorApp.instance.currentDocumentEditor.alignUI( UIAlignType.RIGHT );
		}

		private function onTopAlignButtonClick( event : starling.events.Event ) : void
		{
			UIEditorApp.instance.currentDocumentEditor.alignUI( UIAlignType.TOP );
		}

		private function onCenterYAlignButtonClick( event : starling.events.Event ) : void
		{
			UIEditorApp.instance.currentDocumentEditor.alignUI( UIAlignType.CENTER_Y );
		}

		private function onBottomAlignButtonClick( event : starling.events.Event ) : void
		{
			UIEditorApp.instance.currentDocumentEditor.alignUI( UIAlignType.BOTTOM );
		}

		private function onNewButtonClick( event : starling.events.Event ) : void
		{
			create();
		}

		private function onOpenButtonClick( event : starling.events.Event ) : void
		{
			open();
		}

		private function onSaveButtonClick( event : starling.events.Event ) : void
		{
			save();
		}

		private function onUndoButtonClick( event : starling.events.Event ) : void
		{
			onUndo();
		}

		private function onRedoButtonClick( event : starling.events.Event ) : void
		{
			onRedo();
		}

		private function onTestButtonClick( event : starling.events.Event ) : void
		{
			startTestGame();
		}

		private function onZoomInButtonClick( event : starling.events.Event ) : void
		{
			onZoomIn();
		}

		private function onZoomOutButtonClick( event : starling.events.Event ) : void
		{
			onZoomOut();
		}

		private function onZoomResetButtonClick( event : starling.events.Event ) : void
		{
			onResetZoom();
		}

		private function onConfigButtonClick( event : starling.events.Event ) : void
		{
			UIEditorScreen.instance.openSetting();
		}

		private function create() : void
		{
			_serializer.create();
		}

		private function open() : void
		{
			_serializer.open();
		}

		private function save() : void
		{
			_serializer.save();
		}

		private function saveAs() : void
		{
			_serializer.saveAs();
		}

		public function getSeralizer() : DocumentSerializer
		{
			return _serializer;
		}

		private function onEnterFrame( event : starling.events.Event ) : void
		{
			var title : String = "UI Editor";

			var str : String = title;

			var file : File = _serializer.getFile();

			if ( file )
				str += " " + file.nativePath;
			else
				str += " [NEW]";

			str += " @ " + int( UIEditorApp.instance.documentEditor.canvasScale * 100 ) + "%";

			if ( _serializer.isDirty())
			{
				str += "*";
			}

			var window : NativeWindow = Starling.current.nativeStage.nativeWindow;
			if ( !window.closed )
				window.title = str;
		}

		private function startTest() : void
		{
			var testPanel : TestPanel = new TestPanel( _documenEditor, false );
			PopUpManager.addPopUp( testPanel );
		}

		private function startTestGame() : void
		{
			var testPanel : TestPanel = new TestPanel( _documenEditor, true );
			PopUpManager.addPopUp( testPanel );
		}

		private function quit() : void
		{
			Starling.current.nativeStage.nativeWindow.dispatchEvent( new flash.events.Event( flash.events.Event.CLOSING ));
		}

		private function onClosing( event : flash.events.Event ) : void
		{
			event.preventDefault();
			_serializer.close();
		}

		private function onDocumentChange() : void
		{
			_serializer.markDirty( true );
		}

		private function onReload( event : starling.events.Event ) : void
		{
			_serializer.customAction( RELOAD );
		}

		private function doReload( event : starling.events.Event ) : void
		{
			dispatchEventWith( RELOAD );
		}

		private function onShowTextBorder() : void
		{
			_documenEditor.showTextBorder = !_documenEditor.showTextBorder;
			UIEditorApp.instance.libraryDocumentEditor.showTextBorder = _documenEditor.showTextBorder;
			MainMenu.instance.getItemByName( MainMenu.SHOW_TEXT_BORDER ).checked = _documenEditor.showTextBorder;
		}

		private function onSnapPixel() : void
		{
			_documenEditor.snapPixel = !_documenEditor.snapPixel;
			UIEditorApp.instance.libraryDocumentEditor.snapPixel = _documenEditor.snapPixel;
			MainMenu.instance.getItemByName( MainMenu.SNAP_PIXEL ).checked = _documenEditor.snapPixel;
		}

		private function onResizableBox() : void
		{
			_documenEditor.enableScaleBox = !_documenEditor.enableScaleBox;
			UIEditorApp.instance.libraryDocumentEditor.enableScaleBox = _documenEditor.enableScaleBox;
			MainMenu.instance.getItemByName( MainMenu.RESIZABLE_BOX ).checked = _documenEditor.enableScaleBox;
		}

		private function onUndo() : void
		{
			UIEditorApp.instance.currentDocumentEditor.historyManager.undo();
			updateHistoryManager();
		}

		private function onRedo() : void
		{
			UIEditorApp.instance.currentDocumentEditor.historyManager.redo();
			updateHistoryManager();
		}

		private var OFFSET : Number = 0.5;

		private function onZoomIn() : void
		{
			UIEditorApp.instance.currentDocumentEditor.canvasScale /= OFFSET;
		}

		private function onZoomOut() : void
		{
			UIEditorApp.instance.currentDocumentEditor.canvasScale *= OFFSET;
		}

		private function onResetZoom() : void
		{
			UIEditorApp.instance.currentDocumentEditor.canvasScale = 1;
		}

		private function updateHistoryManager() : void
		{
			var hint : String = UIEditorApp.instance.currentDocumentEditor.historyManager.getNextRedoHint();
			var item : NativeMenuItem = MainMenu.instance.getItemByName( MainMenu.REDO );
			if ( hint )
			{
				item.label = MainMenu.REDO + " " + hint;
				item.enabled = true;
			}
			else
			{
				item.label = MainMenu.REDO;
				item.enabled = false;
			}

			( _buttonGroup.getChildAt( 5 ) as Button ).isEnabled = hint != null;

			hint = UIEditorApp.instance.currentDocumentEditor.historyManager.getNextUndoHint();
			item = MainMenu.instance.getItemByName( MainMenu.UNDO );
			if ( hint )
			{
				item.label = MainMenu.UNDO + " " + hint;
				item.enabled = true;
			}
			else
			{
				item.label = MainMenu.UNDO;
				item.enabled = false;
			}

			( _buttonGroup.getChildAt( 4 ) as Button ).isEnabled = hint != null;
		}

		private function registerMenuActions() : void
		{
			var menu : MainMenu = MainMenu.instance;

			menu.registerAction( MainMenu.NEW, create );
			menu.registerAction( MainMenu.OPEN, open );
			menu.registerAction( MainMenu.SAVE, save );
			menu.registerAction( MainMenu.SAVE_AS, saveAs );

			menu.registerAction( MainMenu.TEST, startTest );
			menu.registerAction( MainMenu.TEST_GAME, startTestGame );
			menu.registerAction( MainMenu.QUIT, quit );

			menu.registerAction( MainMenu.SHOW_TEXT_BORDER, onShowTextBorder );
			menu.registerAction( MainMenu.SNAP_PIXEL, onSnapPixel );
			menu.registerAction( MainMenu.RESIZABLE_BOX, onResizableBox );

			menu.getItemByName( MainMenu.SHOW_TEXT_BORDER ).checked = _documenEditor.showTextBorder;
			menu.getItemByName( MainMenu.SNAP_PIXEL ).checked = _documenEditor.snapPixel;
			menu.getItemByName( MainMenu.RESIZABLE_BOX ).checked = _documenEditor.enableScaleBox;

			menu.registerAction( MainMenu.UNDO, onUndo );
			menu.registerAction( MainMenu.REDO, onRedo );

			menu.registerAction( MainMenu.ZOOM_IN, onZoomIn );
			menu.registerAction( MainMenu.ZOOM_OUT, onZoomOut );
			menu.registerAction( MainMenu.RESET_ZOOM, onResetZoom );

			menu.registerAction( MainMenu.ABOUT, onAbout );

			updateRecentOpenMenu();
		}

		public function get documentSerializer() : DocumentSerializer
		{
			return _serializer;
		}

		private function onAbout() : void
		{
			var popup : AboutPopup = new AboutPopup();
			PopUpManager.addPopUp( popup );
		}

		private function onChange( e : starling.events.Event ) : void
		{
			_recentOpenManager.open( e.data as String );

			updateRecentOpenMenu();
		}

		public static const RESET : String = "Reset";

		private function updateRecentOpenMenu() : void
		{
			var menu : NativeMenu = MainMenu.instance.root;
			var subMenu : NativeMenu = menu.getItemByName( MainMenu.FILE ).submenu.getItemByName( MainMenu.OPEN_RECENT ).submenu;

			subMenu.removeAllItems();

			var item : NativeMenuItem;

			for each ( var url : String in _recentOpenManager.recentFiles )
			{
				item = new NativeMenuItem( url );
				item.name = url;
				item.addEventListener( flash.events.Event.SELECT, onOpenRecent, false, 0, true );
				subMenu.addItem( item );
			}

			if ( _recentOpenManager.recentFiles.length > 0 )
			{
				item = new NativeMenuItem( "", true );
				subMenu.addItem( item );
			}

			item = new NativeMenuItem( RESET );
			item.name = RESET;
			item.addEventListener( flash.events.Event.SELECT, onOpenRecent, false, 0, true );
			subMenu.addItem( item );

		}

		private function onOpenRecent( e : flash.events.Event ) : void
		{
			var item : NativeMenuItem = e.target as NativeMenuItem;

			if ( item.name == RESET )
			{
				_recentOpenManager.reset();
				updateRecentOpenMenu();
			}
			else
			{
				var file : File = new File();
				file.url = item.name;

				if ( file.exists )
				{
					_serializer.openWithFile( file );
				}
				else
				{
					MsgBox.show( "提示", "File not found!" );
				}
			}
		}
	}
}
