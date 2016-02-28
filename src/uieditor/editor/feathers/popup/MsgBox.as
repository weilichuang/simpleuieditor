package uieditor.editor.feathers.popup
{
	import feathers.controls.LayoutGroup;
	import feathers.controls.TextArea;
	import feathers.core.PopUpManager;

	/**
	 * ...
	 * @author
	 */
	public class MsgBox extends InfoPopup
	{
		private var _contentText : TextArea;

		public function MsgBox()
		{

		}

		override protected function createContent( container : LayoutGroup ) : void
		{
			_contentText = new TextArea();
			_contentText.isEditable = false;
			_contentText.isEnabled = false;
			_contentText.autoHideBackground = true;
			_contentText.height = 100;
			container.addChild( _contentText );
		}

		public function setContent( content : String ) : void
		{
			_contentText.text = content;
		}

		public static function show( title : String, contentText : String, buttons : Array = null ) : MsgBox
		{
			if ( buttons == null )
				buttons = [ "确定" ];
			var popup : MsgBox = new MsgBox();
			popup.title = title;
			popup.setContent( contentText );
			popup.buttons = buttons;
			PopUpManager.addPopUp( popup );
			return popup;
		}

	}

}
