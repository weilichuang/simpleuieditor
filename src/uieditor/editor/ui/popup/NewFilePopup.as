package uieditor.editor.ui.popup
{
	import feathers.controls.LayoutGroup;
	import feathers.core.PopUpManager;
	
	import starling.events.Event;
	
	import uieditor.editor.feathers.popup.InfoPopup;
	import uieditor.editor.feathers.popup.MsgBox;
	import uieditor.editor.model.FileSetting;
	import uieditor.editor.ui.inspector.PropertyPanel;

	public class NewFilePopup extends InfoPopup
	{
		private var _onComplete : Function;
		private var _propertyPanel : PropertyPanel;
		private var _newFileSetting : FileSetting;

		public function NewFilePopup( onComplete : Function )
		{
			this._onComplete = onComplete;
			_newFileSetting = new FileSetting();
			_propertyPanel = new PropertyPanel( _newFileSetting, FileSetting.PARAMS );

			super();

			title = "新建";
			buttons = [ "确定", "取消" ];

			addEventListener( starling.events.Event.COMPLETE, onDialogComplete );
		}

		override protected function createContent( container : LayoutGroup ) : void
		{
			container.addChild( _propertyPanel );
		}

		private function onDialogComplete( event : starling.events.Event ) : void
		{
			var index : int = int( event.data );

			if ( index == 0 )
			{
				if ( _newFileSetting.atlasFile == "" || _newFileSetting.atlasFile == null )
				{
					MsgBox.show( "提示", "您还未选择纹理" );
					return;
				}

				if ( _newFileSetting.atlasFile.indexOf( "file:" ) != 0 )
				{
					MsgBox.show( "提示", "您选择的纹理地址不正确" );
					return;
				}
				
				if ( _onComplete != null )
				{
					_onComplete( _newFileSetting );
				}
			}
		}

		public static function show( onComplete : Function ) : void
		{
			var newPopup : NewFilePopup = new NewFilePopup( onComplete );
			PopUpManager.addPopUp( newPopup );
		}
	}
}
