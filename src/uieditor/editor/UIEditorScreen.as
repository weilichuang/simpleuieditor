package uieditor.editor
{
	import flash.utils.Dictionary;
	
	import feathers.controls.LayoutGroup;
	import feathers.core.PopUpManager;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.core.Starling;
	import starling.display.Stage;
	import starling.events.Event;
	import starling.events.ResizeEvent;
	import starling.text.TextField;
	import starling.utils.AssetManager;
	
	import uieditor.editor.cursor.CursorManager;
	import uieditor.editor.data.TemplateData;
	import uieditor.editor.menu.MainMenu;
	import uieditor.editor.model.Setting;
	import uieditor.editor.model.SettingParams;
	import uieditor.editor.ui.main.ContentPanel;
	import uieditor.editor.ui.main.LeftPanel;
	import uieditor.editor.ui.main.RightPanel;
	import uieditor.editor.ui.popup.SettingPopup;
	import uieditor.editor.ui.main.Toolbar;
	import uieditor.editor.util.AppUtil;

	public class UIEditorScreen extends LayoutGroup
	{
		public static const TOP_MARGIN : int = 50;

		private var _stage : Stage;
		private var _assetManager : AssetManager;

		private var _toolbar : Toolbar;

		private var _leftPanel : LeftPanel;
		private var _rightPanel : RightPanel;
		private var _contentPanel : ContentPanel;

		private var _setting : Setting;

		private static var _instance : UIEditorScreen;

		public static function get instance() : UIEditorScreen
		{
			return _instance;
		}

		public function UIEditorScreen()
		{
			_instance = this;

			new MainMenu();

			_assetManager = UIEditorApp.instance.assetManager;

			this.layout = new AnchorLayout();

			_stage = Starling.current.stage;
			_stage.addEventListener( Event.RESIZE, onResize );


			width = Starling.current.viewPort.width = Starling.current.stage.stageWidth = Starling.current.nativeStage.stageWidth;
			height = Starling.current.viewPort.height = Starling.current.stage.stageHeight = Starling.current.nativeStage.stageHeight;

			initSetting();
		}

		private function initSetting() : void
		{
			_setting = new Setting();
			reload();
		}

		private function reload() : void
		{
			var assetManager : AssetManager = UIEditorApp.instance.assetManager;

			assetManager.purge();

			init();

			//var assetLoader:AssetLoaderWithOptions = new AssetLoaderWithOptions(assetManager, _workspaceDir);
			//assetLoader.enqueue(_workspaceDir.resolvePath("textures"));
			//assetLoader.enqueue(_workspaceDir.resolvePath("fonts"));
			//assetLoader.enqueue(_workspaceDir.resolvePath("backgrounds"));
//
			//assetManager.loadQueue(function(ratio:Number):void{
			//if (ratio == 1)
			//{
			//setTimeout(function():void{
			//init();
			//}, 1);
			//}
			//});

		}

		private function onReload( event : * ) : void
		{
			AppUtil.reboot();
		}

		private function init() : void
		{
			CursorManager.initialize();

			var menu : MainMenu = MainMenu.instance;

			menu.unregisterAll();

//			var template : String = new EmbedAsset.custom_component_template().toString();
			TemplateData.load( null );

			UIEditorApp.instance.init();

			menu.registerAction( MainMenu.SETTING, openSetting );

			initUI();
		}

		private function initUI() : void
		{
			removeChildren( 0, -1, true );

			createToolbar();
			createLeftPanel();
			createRightPanel();
			createContentPanel();

//            UIEditorApp.instance.documentManager.clear();
//            _toolbar.documentSerializer.markDirty(false);
		}

		public function openSetting() : void
		{
			var popup : SettingPopup = new SettingPopup( _setting, SettingParams.PARAMS );
			PopUpManager.addPopUp( popup );
		}

		private function onResize( event : ResizeEvent ) : void
		{
			width = Starling.current.stage.stageWidth = Starling.current.viewPort.width = event.width;
			height = Starling.current.stage.stageHeight = Starling.current.viewPort.height = event.height;
		}

		private function createToolbar() : void
		{
			var layoutData : AnchorLayoutData = new AnchorLayoutData();
			layoutData.top = 0;
			layoutData.left = 0;

			_toolbar = new Toolbar();
			_toolbar.layoutData = layoutData;
			_toolbar.addEventListener( Toolbar.RELOAD, onReload );

			addChild( _toolbar );

			_toolbar.validate();
		}

		private function createLeftPanel() : void
		{
			var layoutData : AnchorLayoutData = new AnchorLayoutData();
			layoutData.left = 0;
			layoutData.top = 0;
			layoutData.bottom = 0;
			layoutData.topAnchorDisplayObject = _toolbar;

			_leftPanel = new LeftPanel();
			_leftPanel.layoutData = layoutData;
			addChild( _leftPanel );

			_leftPanel.validate();
		}

		private function createRightPanel() : void
		{
			var layoutData : AnchorLayoutData = new AnchorLayoutData();
			layoutData.right = 5;
			layoutData.bottom = 5;
			layoutData.top = _toolbar.height;

			_rightPanel = new RightPanel();
			_rightPanel.layoutData = layoutData;
			addChild( _rightPanel );
		}

		private function createContentPanel() : void
		{
			var layoutData : AnchorLayoutData = new AnchorLayoutData();
			layoutData.left = _leftPanel.width;
			layoutData.top = _toolbar.height;
			layoutData.bottom = 0;
			layoutData.right = 5;
			layoutData.rightAnchorDisplayObject = _rightPanel;

			_contentPanel = new ContentPanel();
			_contentPanel.layoutData = layoutData;
			addChild( _contentPanel );

			_contentPanel.validate();
		}

		public function get toolbar() : Toolbar
		{
			return _toolbar;
		}

		public function get leftPanel() : LeftPanel
		{
			return _leftPanel;
		}

		public function get rightPanel() : RightPanel
		{
			return _rightPanel;
		}
		
		public function get contentPanel():ContentPanel
		{
			return _contentPanel;
		}

		public function getBitmapFontNames() : Array
		{
			var array : Array = [];

			var dict:Dictionary = Starling.current.painter.sharedData[TextField.COMPOSITOR_DATA_NAME] as Dictionary;
			for ( var name : String in dict )
			{
				array.push( name );
			}
			array.sort();

			return array;
		}

		public function get setting() : Setting
		{
			return _setting;
		}

	}
}
