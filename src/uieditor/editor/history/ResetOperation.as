package uieditor.editor.history
{

	public class ResetOperation extends AbstractHistoryOperation
	{
		public function ResetOperation( target : Object, beforeValue : Object, afterValue : Object )
		{
			super( OperationType.RESET, target, beforeValue, afterValue );
		}

		override public function undo() : void
		{
			_target.scaleX = _beforeValue.scaleX;
			_target.scaleY = _beforeValue.scaleY;
			_target.rotation = _beforeValue.rotation;
			setChanged();
		}

		override public function redo() : void
		{
			_target.scaleX = _afterValue.scaleX;
			_target.scaleY = _afterValue.scaleY;
			_target.rotation = _afterValue.rotation;
			setChanged();
		}

		override public function info() : String
		{
			return "重置";
		}
	}
}
