package uieditor.editor.ui
{

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
