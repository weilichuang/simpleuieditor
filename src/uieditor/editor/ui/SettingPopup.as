package uieditor.editor.ui
{
	import uieditor.editor.model.Setting;
	import uieditor.editor.feathers.popup.InfoPopup;
	import uieditor.editor.ui.inspector.PropertyPanel;

	import feathers.controls.LayoutGroup;

	import starling.events.Event;

	public class SettingPopup extends InfoPopup
	{
		private var _propertyPanel : PropertyPanel;

		private var _setting : Setting;
		private var _params : Array;

		private var _oldSetting : Object;

		public function SettingPopup( setting : Setting, params : Array )
		{
			_setting = setting;
			_params = params;

			_oldSetting = _setting.save();

			_propertyPanel = new PropertyPanel( setting, params );

			super();

			title = "设置";
			buttons = [ "确定", "取消" ];

			addEventListener( Event.COMPLETE, onDialogComplete );
		}

		override protected function createContent( container : LayoutGroup ) : void
		{
			container.addChild( _propertyPanel );
		}

		private function onDialogComplete( event : Event ) : void
		{
			var index : int = int( event.data );

			if ( index != 0 )
			{
				_setting.load( _oldSetting );
			}

			_setting.persist();
		}
	}
}
