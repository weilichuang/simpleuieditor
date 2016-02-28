package uieditor.editor.history
{
	import flash.utils.Dictionary;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	
	import uieditor.editor.UIEditorApp;

	public class CreateOperation extends AbstractHistoryOperation
	{
		protected var _index : int;

		public function CreateOperation( target : Object, paramDict : Dictionary, parent : Object )
		{
			super( OperationType.CREATE, target, paramDict, parent );

			_index = ( parent as DisplayObjectContainer ).getChildIndex( target as DisplayObject );
		}

		override public function undo() : void
		{
			UIEditorApp.instance.documentEditor.removeTree( _target as DisplayObject );
		}

		override public function redo() : void
		{
			var obj : DisplayObject = _target as DisplayObject;
			var paramDict : Dictionary = _beforeValue as Dictionary;
			var parent : DisplayObjectContainer = _afterValue as DisplayObjectContainer;

			UIEditorApp.instance.documentEditor.addTree( obj, paramDict, parent, _index );
		}

		override public function canMergeWith( previousOperation : IHistoryOperation ) : Boolean
		{
			return false;
		}

		override public function dispose() : void
		{
			var obj : DisplayObject = _target as DisplayObject;
			if ( obj.stage == null )
				obj.dispose();
		}

		override public function info() : String
		{
			return "创建";
		}
	}
}
