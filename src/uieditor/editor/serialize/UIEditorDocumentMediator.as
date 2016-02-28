
package uieditor.editor.serialize
{
	import uieditor.editor.model.FileSetting;
	import uieditor.editor.UIEditorApp;
	import uieditor.editor.serialize.IDocumentMediator;

	import flash.filesystem.File;

	public class UIEditorDocumentMediator implements IDocumentMediator
	{
		public function UIEditorDocumentMediator()
		{
		}

		public function createNew( param : FileSetting ) : void
		{
			UIEditorApp.instance.documentEditor.createNew( param );
		}

		public function read( obj : Object, file : File ) : void
		{
			if ( obj )
			{
				UIEditorApp.instance.documentEditor.load( obj, file );
			}
			else
			{
				UIEditorApp.instance.documentEditor.clear();
			}
		}

		public function write() : Object
		{
			return UIEditorApp.instance.documentEditor.export();
		}

		public function get defaultSaveFilename() : String
		{
			return "layout.json";
		}

	}
}
