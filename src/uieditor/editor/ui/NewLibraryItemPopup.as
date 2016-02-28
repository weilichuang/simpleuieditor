package uieditor.editor.ui
{
	import feathers.controls.LayoutGroup;
	import feathers.core.PopUpManager;
	
	import starling.events.Event;
	
	import uieditor.editor.feathers.popup.InfoPopup;
	import uieditor.editor.model.LibrarySetting;
	import uieditor.editor.ui.inspector.PropertyPanel;
	
	public class NewLibraryItemPopup extends InfoPopup
	{
		private var _onComplete : Function;
		private var _propertyPanel : PropertyPanel;
		private var _librarySetting : LibrarySetting;
		
		public function NewLibraryItemPopup( onComplete : Function )
		{
			this._onComplete = onComplete;
			_librarySetting = new LibrarySetting();
			_propertyPanel = new PropertyPanel( _librarySetting, LibrarySetting.PARAMS );
			
			super();
			
			title = "创建新元件";
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
			
			if ( index == 0 )
			{
				if ( _onComplete != null )
				{
					_onComplete( _librarySetting );
				}
			}
		}
		
		public static function show( onComplete : Function ) : void
		{
			var newPopup : NewLibraryItemPopup = new NewLibraryItemPopup( onComplete );
			PopUpManager.addPopUp( newPopup );
		}
	}
}

