package uieditor.editor.model
{
	import uieditor.editor.persist.DefaultPersistableObject;

	public class Setting extends DefaultPersistableObject
	{
		public var rootContainerClass : String = "starling.display.Sprite";

		public var defaultCanvasWidth : int = 400;

		public var defaultCanvasHeight : int = 400;
	}
}
