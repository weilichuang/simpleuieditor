package uieditor.editor.ui.main
{
	import uieditor.editor.ui.tabpanel.AssetTab;
	import uieditor.editor.ui.tabpanel.ComponentTab;
	import uieditor.editor.ui.tabpanel.LayoutTab;
	import uieditor.editor.ui.tabpanel.LibraryTab;

	public class LeftPanel extends TabPanel
	{
		public function LeftPanel()
		{
			super();

			createTabs([{ "label": "图层" },
				{ "label": "资源" },
				{ "label": "组件" },
				{ "label": "库" }],
				[ new LayoutTab(),
				new AssetTab(),
				new ComponentTab(),
				new LibraryTab() ]);
		}
	}
}
