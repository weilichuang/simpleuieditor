package uieditor.editor.ui.main
{
	import feathers.controls.Label;

	import starling.events.Event;

	import uieditor.editor.UIEditorApp;
	import uieditor.editor.controller.DocumentEditor;
	import uieditor.editor.events.DocumentEventType;
	import uieditor.engine.util.ParamUtil;
	import uieditor.editor.ui.tabpanel.CustomParamsTab;
	import uieditor.editor.ui.tabpanel.PropertyTab;

	public class RightPanel extends TabPanel
	{
		private var _documentManager : DocumentEditor;

		private var _label : Label;

		public function RightPanel()
		{
			super();

			_documentManager = UIEditorApp.instance.documentEditor;
			_documentManager.addEventListener( DocumentEventType.CHANGE, onChange );

			_label = new Label();
			addChild( _label );

			createTabs([{ "label": "属性" }, { "label": "自定义" }], [ new PropertyTab(), new CustomParamsTab()], _label );
		}

		private function onChange( event : Event ) : void
		{
			if ( ParamUtil.isLibraryItem( _documentManager.selectedObject ))
			{
				_label.text = "库名：" + ParamUtil.getLibraryName( _documentManager.selectedObject );
			}
			else
			{
				_label.text = ParamUtil.getClassName( _documentManager.selectedObject );
			}
		}
	}
}
