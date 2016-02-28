package uieditor.editor.model
{

	public class SettingParams
	{
		public static const PARAMS : Array = [
			{ "label": "工作空间", "name": "workspaceUrl", "component": "popup", "cls": true, "editPropertyClass": "uieditor.editor.ui.property.ChooseDirectoryPropertyPopup" },
			{ "label": "默认容器类型", "name": "rootContainerClass", "component": "pickerList",
				options: [ "starling.display.Sprite",
					"feathers.controls.LayoutGroup",
					"feathers.controls.ScrollContainer",
					"feathers.controls.Panel" ]},
			{ "label": "默认宽度", "name": "defaultCanvasWidth" },
			{ "label": "默认高度", "name": "defaultCanvasHeight" }
			]
	}
}
