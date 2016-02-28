package uieditor.editor
{
	import feathers.core.ToolTipManager;
	import uieditor.editor.ui.property.TileGridTexturePopup;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.EventDispatcher;
	import starling.utils.AssetManager;
	
	import uieditor.editor.controller.AbstractDocumentEditor;
	import uieditor.editor.controller.DocumentEditor;
	import uieditor.editor.controller.LibraryDocumentEditor;
	import uieditor.editor.controller.LocalizationManager;
	import uieditor.editor.data.EmbedAsset;
	import uieditor.editor.events.DocumentEventType;
	import uieditor.editor.themes.AeonDesktopTheme;
	import uieditor.editor.ui.DefaultCreateComponentPopup;
	import uieditor.editor.ui.property.Scale9GridTexturePopup;
	import uieditor.editor.ui.property.ChooseDirectoryPropertyPopup;
	import uieditor.editor.ui.property.ChooseFilePropertyPopup;
	import uieditor.editor.ui.property.DefaultEditPropertyPopup;
	import uieditor.editor.ui.property.DisplayObjectPropertyPopup;
	import uieditor.editor.ui.property.TextureConstructorPopup;
	import uieditor.editor.ui.property.TexturePropertyPopup;

	public class UIEditorApp extends Sprite
	{
		private static const linker : Array = [ Scale9GridTexturePopup, DefaultCreateComponentPopup,
			DefaultEditPropertyPopup, TexturePropertyPopup, DisplayObjectPropertyPopup, 
			ChooseDirectoryPropertyPopup, ChooseFilePropertyPopup,TextureConstructorPopup,TileGridTexturePopup ];

		private var _assetManager : AssetManager;
		private var _documentEditor : DocumentEditor;
		private var _libraryDocumentEditor : LibraryDocumentEditor;

		private var _currentDocumentEditor : AbstractDocumentEditor;

		private var _localizationManager : LocalizationManager;
		private var _notificationDispatcher : EventDispatcher;

		private static var _instance : UIEditorApp;

		public static function get instance() : UIEditorApp
		{
			return _instance;
		}

		public function UIEditorApp()
		{
			setup();

			new AeonDesktopTheme( _documentEditor );

			EmbedAsset.initBitmapFonts();

			ToolTipManager.setEnabledForStage( Starling.current.stage, true );

			addChild( new UIEditorScreen());
		}

		private function setup() : void
		{
			_assetManager = new AssetManager();
			_assetManager.keepFontXmls = true;
			_notificationDispatcher = new EventDispatcher();

			_instance = this;
		}

		public function init() : void
		{
			_localizationManager = new LocalizationManager();
			_documentEditor = new DocumentEditor( _assetManager, _localizationManager );
			_libraryDocumentEditor = new LibraryDocumentEditor(_documentEditor);

			_currentDocumentEditor = _documentEditor;
		}

		public function get assetManager() : AssetManager
		{
			return _assetManager;
		}

		public function get currentDocumentEditor() : AbstractDocumentEditor
		{
			return _currentDocumentEditor;
		}

		public function set currentDocumentEditor( value : AbstractDocumentEditor ) : void
		{
			if(_currentDocumentEditor == value)
				return;
			
			_currentDocumentEditor = value;
			
			_notificationDispatcher.dispatchEventWith(DocumentEventType.CHANGE_DOCUMENT_EDITOR);
		}

		public function get libraryDocumentEditor() : LibraryDocumentEditor
		{
			return _libraryDocumentEditor;
		}

		public function get documentEditor() : DocumentEditor
		{
			return _documentEditor;
		}

		public function get localizationManager() : LocalizationManager
		{
			return _localizationManager;
		}

		public function get notificationDispatcher() : EventDispatcher
		{
			return _notificationDispatcher;
		}


	}
}
