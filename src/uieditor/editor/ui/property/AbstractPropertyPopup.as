package uieditor.editor.ui.property
{
	import uieditor.editor.UIEditorApp;
	import uieditor.editor.controller.DocumentEditor;
	import uieditor.editor.feathers.popup.InfoPopup;

	public class AbstractPropertyPopup extends InfoPopup
	{
		protected var _onComplete : Function;

		protected var _target : Object;

		protected var _oldTarget : Object;

		protected var _owner : Object;

		protected var _targetParam : Object;


		public function AbstractPropertyPopup( owner : Object, target : Object, targetParam : Object, onComplete : Function )
		{
			_owner = owner;
			_targetParam = targetParam;
			_oldTarget = _target = target;
			_onComplete = onComplete;

			super();

			this.minWidth = 200;
			this.minHeight = 100;
		}
	}
}
