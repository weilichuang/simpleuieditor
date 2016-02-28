package uieditor.editor.history
{
	import flash.utils.Dictionary;
	
	import uieditor.editor.controller.AbstractDocumentEditor;

	public class CutOperation extends DeleteOperation
	{
		public function CutOperation( target : Array, paramDict : Dictionary, documentEditor : AbstractDocumentEditor )
		{
			super( target, paramDict, documentEditor );
		}

		override public function info() : String
		{
			return "剪切";
		}
	}
}
