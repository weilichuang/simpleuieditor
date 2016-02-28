package uieditor.editor.model
{
	import uieditor.editor.persist.DefaultPersistableObject;

	public class FileSetting extends DefaultPersistableObject
	{
		public static const PARAMS : Array = [
			{ "label": "主容器类型", "name": "rootContainerClass", "component": "pickerList",
				options: [ "starling.display.Sprite",
					"feathers.controls.LayoutGroup",
					"feathers.controls.ScrollContainer" ]},
			{ "label": "UI资源", "name": "atlasFile",
				"component": "popup", "cls": true,
				"editPropertyClass": "uieditor.editor.ui.property.ChooseFilePropertyPopup",
				"extension": [ "*.jpeg" ]
			},
			{ "label": "宽度", "name": "width" },
			{ "label": "高度", "name": "height" }
			];

		public var rootContainerClass : String = "starling.display.Sprite";

		public var width : int = 400;

		public var height : int = 400;

		public var atlasFile : String = "";
	}
}
