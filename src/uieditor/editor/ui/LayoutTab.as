package uieditor.editor.ui
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import feathers.controls.ButtonGroup;
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.VerticalLayout;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.TextureAtlas;
	
	import uieditor.editor.UIEditorApp;
	import uieditor.editor.controller.AbstractDocumentEditor;
	import uieditor.editor.data.EmbedAsset;
	import uieditor.editor.events.DocumentEventType;
	import uieditor.editor.menu.MainMenu;
	import uieditor.editor.ui.itemrenderer.LayoutItemRenderer;

	public class LayoutTab extends LayoutGroup
	{
		private var _list : List;

		private var _documentEditor : AbstractDocumentEditor;

		private var _buttonGroup : ButtonGroup;

		public function LayoutTab()
		{
			var anchorLayoutData : AnchorLayoutData = new AnchorLayoutData();
			anchorLayoutData.bottom = 0;
			anchorLayoutData.top = 25;
			layoutData = anchorLayoutData;

			layout = new AnchorLayout();

			_buttonGroup = createToolButtons( createTextButtons());

			createList();

			registerMenuActions();

			UIEditorApp.instance.notificationDispatcher.addEventListener( DocumentEventType.CHANGE_DOCUMENT_EDITOR, onChangeDocumentEditor );
			onChangeDocumentEditor(null);
		}

		private function onChangeDocumentEditor( event : Event ) : void
		{
			if ( _documentEditor != null )
			{
				_documentEditor.removeEventListener( DocumentEventType.CHANGE, onChange );
				_documentEditor.removeEventListener( DocumentEventType.EXPAND_CHANGE, onExpandChange );
				_documentEditor.removeEventListener( DocumentEventType.SELECT_CHANGE, onSelectChange );
			}

			_documentEditor = UIEditorApp.instance.currentDocumentEditor;
			_documentEditor.addEventListener( DocumentEventType.CHANGE, onChange );
			_documentEditor.addEventListener( DocumentEventType.EXPAND_CHANGE, onExpandChange );
			_documentEditor.addEventListener( DocumentEventType.SELECT_CHANGE, onSelectChange );
			
			updateList();
		}

		private function createList() : void
		{
			_list = new List();
			_list.useLRUDKey = false;
			_list.width = 280;
			_list.height = 400;

			_list.itemRendererFactory = function() : IListItemRenderer
			{
				return new LayoutItemRenderer();
			}

			_list.addEventListener( Event.CHANGE, onListChange );
			_list.addEventListener( FeathersEventType.FOCUS_IN, onFocusIn );
			_list.addEventListener( FeathersEventType.FOCUS_OUT, onFocusOut );

			var layout : VerticalLayout = new VerticalLayout();
			layout.useVirtualLayout = true;
			layout.padding = 0;
			layout.gap = 1;
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
			layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			_list.layout = layout;

			var anchorLayoutData : AnchorLayoutData = new AnchorLayoutData();
			anchorLayoutData.top = 0
			anchorLayoutData.bottom = 0;
			anchorLayoutData.bottomAnchorDisplayObject = _buttonGroup;
			_list.layoutData = anchorLayoutData;

			addChild( _list );
		}

		private function onListChange( event : Event ) : void
		{
			if ( _list.selectedIndex >= 0 )
			{
				var item : Object = _list.selectedItem;
				if ( item.obj && !item.hidden && !item.lock )
				{
					_documentEditor.selectObject( item.obj );
				}
			}
		}

		private function onExpandChange( event : Event ) : void
		{
			updateList();
		}
		
		private function onSelectChange(event:Event):void
		{
			updateList();
		}

		private function onChange( event : Event ) : void
		{
			updateList(false);
		}
		
		private function updateList(scrollToIndex:Boolean=true):void
		{
			_list.dataProvider = _documentEditor.dataProvider;
			
			var index : int = _documentEditor.selectedIndex;
			if ( _list.selectedIndex != index )
			{
				_list.selectedIndex = index;
				if(scrollToIndex)
				{
					_list.scrollToDisplayIndex( index );
				}
			}
		}

		private function createToolButtons( buttons : Array ) : ButtonGroup
		{
			var group : ButtonGroup = new ButtonGroup();
			group.paddingTop = 5;
			group.paddingBottom = 5;
			group.gap = 2;
			group.direction = ButtonGroup.DIRECTION_HORIZONTAL;
			//group.maxWidth = 200;
			group.dataProvider = new ListCollection( buttons );

			var layoutData : AnchorLayoutData = new AnchorLayoutData();
			layoutData.left = 0;
			layoutData.right = 0;
			layoutData.bottom = 0;

			group.layoutData = layoutData;

			addChild( group );

			return group;
		}

		private function createTextButtons() : Array
		{
			var atlas : TextureAtlas = EmbedAsset.getEditorTextureAtlas();

			return [{ defaultIcon: new Image( atlas.getTexture( "iconfont-chevronup" )), label: "", toolTip: "上移", triggered: onUpButton },
				{ defaultIcon: new Image( atlas.getTexture( "iconfont-chevrondown" )), label: "", toolTip: "下移", triggered: onDownButton },
				{ defaultIcon: new Image( atlas.getTexture( "iconfont-delete01" )), label: "", toolTip: "删除", triggered: onDeleteButton },
				{ defaultIcon: new Image( atlas.getTexture( "iconfont-cut" )), label: "", toolTip: "剪切", triggered: onCutButton },
				{ defaultIcon: new Image( atlas.getTexture( "iconfont-copy" )), label: "", toolTip: "复制", triggered: onCopyButton },
				{ defaultIcon: new Image( atlas.getTexture( "iconfont-paste" )), label: "", toolTip: "粘贴", triggered: onPasteButton },
				{ defaultIcon: new Image( atlas.getTexture( "iconfont-duplicate" )), label: "", toolTip: "复制并粘贴", triggered: onDuplicateButton }];
		}

		private function onUpButton( event : Event ) : void
		{
			moveUp();
		}

		private function onDownButton( event : Event ) : void
		{
			moveDown();
		}

		private function onDeleteButton( event : Event ) : void
		{
			remove();
		}

		private function onCutButton( event : Event ) : void
		{
			cut();
		}

		private function onCopyButton( event : Event ) : void
		{
			copy();
		}

		private function onPasteButton( event : Event ) : void
		{
			paste();
		}

		private function onDuplicateButton( event : Event ) : void
		{
			duplicate();
		}

		private function cut() : void
		{
			_documentEditor.cut();
		}

		private function copy() : void
		{
			_documentEditor.copy();
		}

		private function paste() : void
		{
			_documentEditor.paste();
		}

		private function duplicate() : void
		{
			_documentEditor.duplicate();
		}

		private function deselect() : void
		{
			_list.selectedIndex = -1;
			_documentEditor.selectObject( null );
		}

		private function moveUp() : void
		{
			_documentEditor.moveLayerUp();
		}

		private function moveDown() : void
		{
			_documentEditor.moveLayerDown();
		}

		private function remove() : void
		{
			_documentEditor.remove();
		}

		private function registerMenuActions() : void
		{
			var menu : MainMenu = MainMenu.instance;

			menu.registerAction( MainMenu.CUT, cut );
			menu.registerAction( MainMenu.COPY, copy );
			menu.registerAction( MainMenu.PASTE, paste );
			menu.registerAction( MainMenu.DUPLICATE, duplicate );

			menu.registerAction( MainMenu.DESELECT, deselect );

			menu.registerAction( MainMenu.MOVE_UP, moveUp );
			menu.registerAction( MainMenu.MOVE_DOWN, moveDown );

			Starling.current.nativeStage.addEventListener( KeyboardEvent.KEY_UP, onKeyUp );
		}

		private function onKeyUp( event : KeyboardEvent ) : void
		{
			switch ( event.keyCode )
			{
				case Keyboard.DELETE:
					if ( _documentEditor.hasFocus )
						remove();
					break;
			}
		}

		private var _focus : Boolean = false;

		protected function onFocusIn( event : Event ) : void
		{
			_focus = true;
		}

		protected function onFocusOut( event : Event ) : void
		{
			_focus = false;
		}
	}
}
