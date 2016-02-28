package uieditor.editor.history
{
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	
	import uieditor.editor.UIEditorApp;
	import uieditor.editor.history.IHistoryOperation;

	public class MoveLayerOperation extends AbstractHistoryOperation
	{
		private var _oldParent:DisplayObjectContainer;
		private var _newParent:DisplayObjectContainer;
		
		public function MoveLayerOperation( target:Object, newParent:DisplayObjectContainer, beforeLayer:int, afterLayer:int )
		{
			super( OperationType.MOVE_LAYER, target, beforeLayer, afterLayer );

			_target = target;
			_oldParent = _target.parent;
			_newParent = newParent;
		}

		override public function undo() : void
		{
			var obj : DisplayObject = _target as DisplayObject;

			if ( obj )
			{
				_oldParent.addChildAt( obj, int( _beforeValue ));
			}

			setChanged();
		}

		override public function redo() : void
		{
			var obj : DisplayObject = _target as DisplayObject;

			if ( obj )
			{
				_newParent.addChildAt( obj, int( _afterValue ));
			}

			setChanged();
		}

		override public function info() : String
		{
			return "移动图层";
		}

		override protected function setChanged() : void
		{
			UIEditorApp.instance.documentEditor.setLayerChanged();
			UIEditorApp.instance.documentEditor.setChanged();
		}

		override public function canMergeWith( previousOperation : IHistoryOperation ) : Boolean
		{
			return false;
		}

	}
}
