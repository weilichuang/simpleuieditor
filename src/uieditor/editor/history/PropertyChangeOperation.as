package uieditor.editor.history
{
	import uieditor.editor.ui.inspector.PropertyPanel;
	import uieditor.editor.ui.inspector.UIMapperEventType;

	public class PropertyChangeOperation extends AbstractHistoryOperation
	{
		protected var _propertyName : String;

		public function PropertyChangeOperation( target : Object, propertyName : String, beforeValue : Object, afterValue : Object )
		{
			super( OperationType.CHANGE_PROPERTY, target, beforeValue, afterValue );

			_target = target;
			_propertyName = propertyName;
		}

		override public function undo() : void
		{
			_target[ _propertyName ] = _beforeValue;
			setChanged();
		}

		override public function redo() : void
		{
			_target[ _propertyName ] = _afterValue;
			setChanged();
		}

		override public function info() : String
		{
			return "修改" + _propertyName;
		}

		override protected function setChanged() : void
		{
			PropertyPanel.globalDispatcher.dispatchEventWith( UIMapperEventType.PROPERTY_CHANGE, false, { target: _target, propertyName: _propertyName });
		}
	}
}
