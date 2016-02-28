package uieditor.editor.history
{
	import flash.utils.Dictionary;

	public class PasteOperation extends CreateOperation
	{
		public function PasteOperation( target : Object, paramDict : Dictionary, parent : Object )
		{
			super( target, paramDict, parent );
		}

		override public function info() : String
		{
			return "粘贴";
		}
	}
}
