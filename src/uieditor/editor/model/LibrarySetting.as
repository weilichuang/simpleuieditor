package uieditor.editor.model
{
	import uieditor.editor.persist.DefaultPersistableObject;
	
	public class LibrarySetting extends DefaultPersistableObject
	{
		public static const PARAMS : Array = [
			{ "label": "主容器类型", "name": "rootContainerClass", "component": "pickerList",
				options: [ "starling.display.Sprite",
					"feathers.controls.LayoutGroup",
					"feathers.controls.ScrollContainer" ]},
			{ "label": "链接名", "name": "linkage" },
			{ "label": "宽度", "name": "width" },
			{ "label": "高度", "name": "height" }
		];
		
		public var rootContainerClass : String = "starling.display.Sprite";
		
		public var linkage : String = "";
		
		public var width : int = 400;
		
		public var height : int = 400;
	}
}

