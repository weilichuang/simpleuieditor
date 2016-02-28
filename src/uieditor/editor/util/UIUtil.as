package uieditor.editor.util
{
	import starling.display.DisplayObject;

	public class UIUtil
	{
		public function UIUtil()
		{
		}
		
		/**
		 * 是否是库文件
		 */
		public static function isLibraryItem(object:DisplayObject):Boolean
		{
			return object.customData != null && object.customData.isLibrary;
		}
	}
}