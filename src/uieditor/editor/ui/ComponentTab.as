package uieditor.editor.ui
{
	import feathers.controls.GroupedList;
	import feathers.controls.LayoutGroup;
	import feathers.controls.renderers.IGroupedListItemRenderer;
	import feathers.data.HierarchicalCollection;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.utils.AssetManager;
	
	import uieditor.editor.UIEditorApp;
	import uieditor.editor.data.TemplateData;
	import uieditor.editor.ui.itemrenderer.ComponentGroupedListItemRenderer;



	public class ComponentTab extends LayoutGroup
	{
		private var _assetManager : AssetManager;

		private var _list : GroupedList;

		protected var _supportedComponentTypes : Array;
		protected var _supportedContainerTypes : Array;

		public function ComponentTab()
		{
			_assetManager = UIEditorApp.instance.assetManager;

			createPickerList();

			var anchorLayoutData : AnchorLayoutData = new AnchorLayoutData();
			anchorLayoutData.top = 25;
			anchorLayoutData.bottom = 0;
			this.layoutData = anchorLayoutData;

			layout = new AnchorLayout();

			listAssets();
		}

		protected function createPickerList() : void
		{
			_supportedComponentTypes = TemplateData.getSupportedComponentAndIcon( "starling" );
			_supportedContainerTypes = TemplateData.getSupportedComponentAndIcon( "feathers" );
		}

		private function listAssets() : void
		{
			_list = new GroupedList();

			_list.width = 280;
			_list.height = 800;

			var componentArr : Array = [];
			for each ( var obj : Object in _supportedComponentTypes )
			{
				componentArr.push({ text: obj.cls, icon: obj.icon });
			}

			var containerArr : Array = [];
			for each ( obj in _supportedContainerTypes )
			{
				containerArr.push({ text: obj.cls, icon: obj.icon });
			}

			var group : Array = [{ header: "控件", children: componentArr }, { header: "容器", children: containerArr }];

			var data : HierarchicalCollection = new HierarchicalCollection( group );

			_list.dataProvider = data;

			_list.itemRendererFactory = function() : IGroupedListItemRenderer
			{
				var renderer : ComponentGroupedListItemRenderer = new ComponentGroupedListItemRenderer();
				return renderer;
			};

			var anchorLayoutData : AnchorLayoutData = new AnchorLayoutData();
			anchorLayoutData.top = 0;
			anchorLayoutData.bottom = 0;
			_list.layoutData = anchorLayoutData;

			addChild( _list );
		}
	}
}
