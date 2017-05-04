package uieditor.editor.ui.tabpanel
{
	import feathers.controls.ScrollContainer;
	import feathers.layout.VerticalLayout;
	
	import starling.events.Event;
	
	import uieditor.editor.UIEditorApp;
	import uieditor.editor.controller.AbstractDocumentEditor;
	import uieditor.editor.data.TemplateData;
	import uieditor.editor.events.DocumentEventType;
	import uieditor.editor.ui.inspector.PropertyPanel;
	import uieditor.editor.ui.inspector.UIMapperEventType;
	import uieditor.engine.localization.ILocalization;
	import uieditor.engine.util.ParamUtil;

	public class CustomParamsTab extends ScrollContainer
	{
		public static const LOCALIZE_KEYS : String = "customParams.localizeKey";

		private var _propertiesPanel : PropertyPanel;

		private var _documentManager : AbstractDocumentEditor;

		private var _params : Array;

		public function CustomParamsTab()
		{
			super();
			
			_params = ParamUtil.getCustomParams( TemplateData.editor_template );

			initUI();
			
			UIEditorApp.instance.notificationDispatcher.addEventListener( DocumentEventType.CHANGE_DOCUMENT_EDITOR, onChangeDocumentEditor );
			onChangeDocumentEditor(null);
		}
		
		private function onChangeDocumentEditor( event : Event ) : void
		{
			if ( _documentManager != null )
			{
				_documentManager.removeEventListener( DocumentEventType.CHANGE, onChange );
			}
			
			_documentManager = UIEditorApp.instance.currentDocumentEditor;
			_documentManager.addEventListener( DocumentEventType.CHANGE, onChange );
			
			onChange(null);
		}
		
		private function initUI() : void
		{
			width = 300;
			
			var layout : VerticalLayout = new VerticalLayout();
			layout.paddingTop = layout.gap = 20;
			layout.paddingLeft = 2;
			layout.paddingRight = 2;
			this.layout = layout;
			
			PropertyPanel.globalDispatcher.addEventListener( UIMapperEventType.PROPERTY_CHANGE, onPropertyChange );

			_propertiesPanel = new PropertyPanel({}, []);

			addChild( _propertiesPanel );
		}

		private function onChange( event : Event ) : void
		{
			if ( _documentManager.selectedObject )
			{
				var target : Object = _documentManager.extraParamsDict[ _documentManager.selectedObject ];

				processParams( _params );

				_propertiesPanel.reloadData( target, _params );
			}
			else
			{
				_propertiesPanel.reloadData();
			}
		}

		private function processParams( params : Array ) : void
		{
			var localization : ILocalization = UIEditorApp.instance.localizationManager.localization;

			for each ( var item : Object in params )
			{
				if ( item.name == LOCALIZE_KEYS && localization )
				{
					delete item.options;
					item.options = localization.getKeys();
				}
			}
		}

		private function onPropertyChange( event : Event ) : void
		{
			if ( event.data.propertyName == LOCALIZE_KEYS )
			{
				_documentManager.uiBuilder.localizeTexts( _documentManager.rootNode, _documentManager.extraParamsDict );
			}
		}

		override public function dispose() : void
		{
			UIEditorApp.instance.notificationDispatcher.removeEventListener( DocumentEventType.CHANGE_DOCUMENT_EDITOR, onChangeDocumentEditor );
			PropertyPanel.globalDispatcher.removeEventListener( UIMapperEventType.PROPERTY_CHANGE, onPropertyChange );

			super.dispose();
		}
	}
}
