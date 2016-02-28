package uieditor.editor.history
{

	public class MoveOperation extends AbstractHistoryOperation
	{
		public function MoveOperation( target : Object, beforeValue : Object, afterValue : Object )
		{
			super( OperationType.MOVE, target, beforeValue, afterValue );
		}

		override public function undo() : void
		{
			_target.x = _beforeValue.x;
			_target.y = _beforeValue.y;
			setChanged();
		}

		override public function redo() : void
		{
			_target.x = _afterValue.x;
			_target.y = _afterValue.y;
			setChanged();
		}

		override public function info() : String
		{
			return "移动";
		}


	}
}
