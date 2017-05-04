package uieditor.editor.ui.popup
{
	import feathers.controls.LayoutGroup;
	import feathers.core.PopUpManager;
	
	import starling.events.Event;
	
	import uieditor.editor.feathers.popup.InfoPopup;
	import uieditor.editor.model.LibrarySetting;
	import uieditor.editor.ui.inspector.PropertyPanel;
	
	public class CloneLibraryItemPopUp extends InfoPopup
	{
		private var _onComplete : Function;
		private var _data:Object;
		
		private var _propertyPanel : PropertyPanel;
		private var _linkageObj:Object;
		
		public function CloneLibraryItemPopUp(data:Object,onComplete : Function)
		{
			this._data = data;
			this._onComplete = onComplete;
			_linkageObj = {linkage:data.params.name};
			_propertyPanel = new PropertyPanel(_linkageObj , [{ "label": "链接名", "name": "linkage" }] );
			
			super();
			
			title = "复制元件为";
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
					_data.params.name = _linkageObj.linkage;
					_onComplete( _data );
				}
			}
		}
		
		public static function show(data:Object, onComplete : Function ) : void
		{
			var newPopup : CloneLibraryItemPopUp = new CloneLibraryItemPopUp(data, onComplete );
			PopUpManager.addPopUp( newPopup );
		}
	}
}