package uieditor.editor.ui.property
{
	import uieditor.editor.controller.DocumentEditor;
	import uieditor.editor.UIEditorApp;

	public class AbstractPropertyEdit
	{
		protected var _documentManager : DocumentEditor;

		protected var _onComplete : Function;

		protected var _target : Object;

		protected var _oldTarget : Object;

		protected var _owner : Object;

		protected var _targetParam : Object;

		public function AbstractPropertyEdit( owner : Object, target : Object, targetParam : Object, onComplete : Function )
		{
			_documentManager = UIEditorApp.instance.documentEditor;
			_owner = owner;
			_targetParam = targetParam;
			_oldTarget = _target = target;
			_onComplete = onComplete;

		}
	}

}
