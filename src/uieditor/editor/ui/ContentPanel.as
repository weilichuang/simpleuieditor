package uieditor.editor.ui
{
	import starling.events.Event;
	
	import uieditor.editor.UIEditorApp;
	import uieditor.editor.controller.LibraryDocumentEditor;
	import uieditor.editor.events.DocumentEventType;

	public class ContentPanel extends TabPanel
	{
		private var _sceneDocument : DocumentPanel;
		private var _libraryDocument : DocumentPanel;

		public function ContentPanel()
		{
			super();

			_sceneDocument = new DocumentPanel();
			_libraryDocument = new DocumentPanel( true );

			createTabs([{ "label": "场景" }, { "label": "库" }],
				[ _sceneDocument, _libraryDocument ]);

			this.minWidth = 200;

			UIEditorApp.instance.notificationDispatcher.addEventListener( DocumentEventType.EDIT_LIBRARY_ITEM, onEditLibraryItem );
		}

		private function onEditLibraryItem( event : Event, data : Object ) : void
		{
			_listCollection.getItemAt( 1 ).label = data.label;
			_listCollection.updateItemAt( 1 );
			_tab.selectedIndex = 1;
			onTabChange( null );
			
			LibraryDocumentEditor(_libraryDocument.documentEditor).importData({layout:data.data});
		}

		override protected function onTabChange( event : Event ) : void
		{
			super.onTabChange( event );
			
			if ( _tab.selectedIndex == 0 )
			{
				_sceneDocument.documentEditor.setActive(true);
				_libraryDocument.documentEditor.setActive(false);
				
				UIEditorApp.instance.currentDocumentEditor = _sceneDocument.documentEditor;
				UIEditorApp.instance.documentEditor.refresh();
			}
			else
			{
				_sceneDocument.documentEditor.setActive(false);
				_libraryDocument.documentEditor.setActive(true);
				
				UIEditorApp.instance.currentDocumentEditor = _libraryDocument.documentEditor;
			}

//			if ( _tab.selectedIndex == 0 )
//			{
//				this.removeTab( 1 );
//			}
		}
	}
}
