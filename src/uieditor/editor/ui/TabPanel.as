package uieditor.editor.ui
{
	import feathers.controls.LayoutGroup;
	import feathers.controls.TabBar;
	import feathers.core.FeathersControl;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;

	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.Event;

	public class TabPanel extends LayoutGroup
	{
		protected var _tabScreens : Array;

		protected var _tab : TabBar;

		protected var _currentTab : Sprite;

		protected var _listCollection : ListCollection;

		public function TabPanel()
		{
			this.layout = new AnchorLayout();
		}

		public function addTab( label : String, content : DisplayObject ) : void
		{
			_tabScreens.push( content );
			_listCollection.addItem({ "label": label });

			_tab.selectedIndex = _tabScreens.length - 1;
		}

		public function removeTab( index : int ) : void
		{
			if ( index >= _tabScreens.length )
				return;

			var content : DisplayObject = _tabScreens[ index ];
			if ( content )
			{
				content.dispose();
			}
			_listCollection.removeItemAt( index );
		}

		protected function createTabs( data : Array, tabs : Array, topAnchorDisplayObject : DisplayObject = null ) : void
		{
			_tabScreens = tabs;

			_listCollection = new ListCollection( data );

			var anchorLayoutData : AnchorLayoutData = new AnchorLayoutData();
			if ( topAnchorDisplayObject != null )
			{
				anchorLayoutData.top = 2;
				anchorLayoutData.topAnchorDisplayObject = topAnchorDisplayObject;
			}
			else
				anchorLayoutData.top = 0;

			_tab = new TabBar();
			_tab.layoutData = anchorLayoutData;
			_tab.dataProvider = _listCollection;
			_tab.addEventListener( Event.CHANGE, onTabChange );
			addChild( _tab );

			onTabChange( null );
		}

		protected function onTabChange( event : Event ) : void
		{
			if ( _currentTab )
			{
				_currentTab.removeFromParent();
			}

			_currentTab = _tabScreens[ _tab.selectedIndex ];

			if ( _currentTab is FeathersControl && ( _currentTab as FeathersControl ).layoutData == null )
			{
				var anchorLayoutData : AnchorLayoutData = new AnchorLayoutData();
				anchorLayoutData.bottom = 0;
				anchorLayoutData.top = 2;
				anchorLayoutData.left = 0;
				anchorLayoutData.right = 0;
				anchorLayoutData.topAnchorDisplayObject = _tab;
				( _currentTab as FeathersControl ).layoutData = anchorLayoutData;
			}
			addChild( _currentTab );
		}

		public function getTabAt( index : int ) : Sprite
		{
			return _tabScreens[ index ];
		}

		public function get currentTab() : Sprite
		{
			return _currentTab;
		}

		override public function dispose() : void
		{
			for each ( var obj : DisplayObject in _tabScreens )
			{
				obj.removeFromParent( true );
			}

			super.dispose();
		}
	}
}
