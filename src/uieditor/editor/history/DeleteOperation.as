package uieditor.editor.history
{
	import flash.utils.Dictionary;

	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;

	import uieditor.editor.controller.AbstractDocumentEditor;

	public class DeleteOperation extends AbstractHistoryOperation
	{
		protected var _indices : Array;

		protected var _documentEditor : AbstractDocumentEditor;

		public function DeleteOperation( target : Array, paramDict : Dictionary, documentEditor : AbstractDocumentEditor )
		{
			_indices = [];

			var parents : Array = [];
			for ( var i : int = 0; i < target.length; i++ )
			{
				var display : DisplayObject = target[ i ];
				parents[ i ] = display.parent;
				_indices[ i ] = display.parent.getChildIndex( display );
			}

			super( OperationType.DELETE, target, paramDict, parents );

			_documentEditor = documentEditor;
		}

		override public function undo() : void
		{
			var list : Array = _target as Array;
			for ( var i : int = 0; i < list.length; i++ )
			{
				var display : DisplayObject = list[ i ];
				var paramDict : Dictionary = _beforeValue as Dictionary;
				var parent : DisplayObjectContainer = _afterValue[ i ];
				_documentEditor.addTree( display, paramDict, parent, _indices[ i ]);
			}
		}

		override public function redo() : void
		{
			var list : Array = _target as Array;
			for ( var i : int = 0; i < list.length; i++ )
			{
				var display : DisplayObject = list[ i ];
				_documentEditor.removeTree( display );
			}
		}

		override public function canMergeWith( previousOperation : IHistoryOperation ) : Boolean
		{
			return false;
		}

		override public function dispose() : void
		{
			var list : Array = _target as Array;
			for ( var i : int = 0; i < list.length; i++ )
			{
				var display : DisplayObject = list[ i ];
				if ( display.stage == null )
					display.dispose();
			}
			_target = null;
			_documentEditor = null;
		}

		override public function info() : String
		{
			return "删除";
		}
	}
}
