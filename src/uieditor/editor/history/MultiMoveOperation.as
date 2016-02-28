package uieditor.editor.history
{
	import uieditor.editor.UIEditorApp;

	public class MultiMoveOperation extends AbstractHistoryOperation
	{
		public function MultiMoveOperation( target : Array, beforeValue : Array, afterValue : Array )
		{
			super( OperationType.MULTI_MOVE, target, beforeValue, afterValue );
		}

		override public function undo() : void
		{
			var targets : Array = _target as Array;
			var beforeValues : Array = _beforeValue as Array;
			var afterValues : Array = _afterValue as Array;
			for ( var i : int = 0; i < targets.length; i++ )
			{
				var t : Object = targets[ i ];
				t.x = beforeValues[ i ].x;
				t.y = beforeValues[ i ].y;
			}
			
			setChanged();
			UIEditorApp.instance.documentEditor.refreshMultiSelect();
		}

		override public function redo() : void
		{
			var targets : Array = _target as Array;
			var afterValues : Array = _afterValue as Array;
			for ( var i : int = 0; i < targets.length; i++ )
			{
				var t : Object = targets[ i ];
				t.x = afterValues[ i ].x;
				t.y = afterValues[ i ].y;
			}
			setChanged();
			UIEditorApp.instance.documentEditor.refreshMultiSelect();
		}

		override public function info() : String
		{
			return "多项移动";
		}
	}
}
