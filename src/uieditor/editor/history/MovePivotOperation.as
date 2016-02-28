package uieditor.editor.history
{
	import uieditor.engine.util.DisplayObjectUtil;

	import starling.display.DisplayObject;

	public class MovePivotOperation extends AbstractHistoryOperation
	{
		public function MovePivotOperation( target : Object, beforeValue : Object, afterValue : Object )
		{
			super( OperationType.MOVE_PIVOT, target, beforeValue, afterValue );
		}

		override public function undo() : void
		{
			var obj : DisplayObject = _target as DisplayObject;
			DisplayObjectUtil.movePivotTo( obj, _beforeValue.x, _beforeValue.y );
			setChanged();
		}

		override public function redo() : void
		{
			var obj : DisplayObject = _target as DisplayObject;
			DisplayObjectUtil.movePivotTo( obj, _afterValue.x, _afterValue.y );
			setChanged();
		}

		override public function info() : String
		{
			return "移动原点";
		}

	}
}
