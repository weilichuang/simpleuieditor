package uieditor.editor.ui.itemrenderer
{
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.renderers.DefaultListItemRenderer;
	import feathers.dragDrop.DragData;
	import feathers.dragDrop.DragDropManager;
	import feathers.dragDrop.IDragSource;
	import feathers.dragDrop.IDropTarget;
	import feathers.events.DragDropEvent;
	import feathers.layout.HorizontalLayout;

	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	import uieditor.editor.UIEditorApp;
	import uieditor.editor.data.EmbedAsset;
	import uieditor.editor.history.MoveLayerOperation;
	import uieditor.engine.util.ParamUtil;



	public class LayoutItemRenderer extends DefaultListItemRenderer implements IDragSource, IDropTarget
	{
		public static const SOURCE : String = "source";
		public static const TARGET : String = "target";
		public static const INDEX : String = "index";

		public static const DROP_ABOVE : String = "above";
		public static const DROP_INSIDE : String = "inside";
		public static const DROP_BELOW : String = "below";

		private var _group : LayoutGroup;
		private var _showButton : Button;
		private var _lockButton : Button;
		private var _expandButton : Button;

		private var _spaceText : Label;

		private var _dropLine : Quad;

		public function LayoutItemRenderer()
		{
			super();
			createIconGroup();
			_iconFunction = layoutIconFunction;

			addEventListener( TouchEvent.TOUCH, onTouch );
			addEventListener( DragDropEvent.DRAG_ENTER, onDragEnter );
			addEventListener( DragDropEvent.DRAG_MOVE, onDragMove );
			addEventListener( DragDropEvent.DRAG_EXIT, onDragExit );
			addEventListener( DragDropEvent.DRAG_DROP, onDragDrop );
		}

		private function createIconGroup() : void
		{
			_group = new LayoutGroup();
			_group.layout = new HorizontalLayout();
			( _group.layout as HorizontalLayout ).gap = 2;

			_showButton = new Button();
			_showButton.addEventListener( Event.TRIGGERED, _clickShowBtn );
			_group.addChild( _showButton );

			_lockButton = new Button();
			_lockButton.addEventListener( Event.TRIGGERED, _clickLockBtn );
			_group.addChild( _lockButton );

			_spaceText = new Label();
			_group.addChild( _spaceText );

			_expandButton = new Button();
			_expandButton.addEventListener( Event.TRIGGERED, _clickExpandBtn );
			_group.addChild( _expandButton );
		}

		private function _clickShowBtn( event : Event ) : void
		{
			_data.hidden = !_data.hidden;
			refreshShowButton();
			UIEditorApp.instance.currentDocumentEditor.refreshDataProvider();
		}

		private function _clickLockBtn( event : Event ) : void
		{
			_data.lock = !_data.lock;
			refreshLockButton();
			UIEditorApp.instance.currentDocumentEditor.refreshDataProvider();
		}

		private function _clickExpandBtn( event : Event ) : void
		{
			_data.expand = !_data.expand;
			refreshExpandButton();
			UIEditorApp.instance.currentDocumentEditor.expandChange();
		}

		private function layoutIconFunction( item : Object ) : DisplayObject
		{
			refreshShowButton();
			refreshLockButton();
			refreshExpandButton();
			if ( item )
				_spaceText.text = item.prefix;
			return _group;
		}

		override public function set data( value : Object ) : void
		{
			super.data = value;

			refreshShowButton();
			refreshLockButton();
			refreshExpandButton();

			if ( value )
				_spaceText.text = value.prefix;
		}

		private var expandImage : Image;
		private var unexpandImage : Image;

		private function refreshExpandButton() : void
		{
			if ( _data == null || ParamUtil.isLibraryItem( _data.obj ) || !( _data.obj is DisplayObjectContainer ))
			{
				_expandButton.visible = false;
				return;
			}

			if ( !UIEditorApp.instance.currentDocumentEditor.isContainer( _data.obj ))
			{
				_expandButton.visible = false;
				return;
			}

			_expandButton.visible = true;

			if ( !_data.expand )
			{
				if ( unexpandImage == null )
					unexpandImage = new Image( EmbedAsset.getEditorTextureAtlas().getTexture( "iconfont-caretright" ));
				_expandButton.defaultIcon = unexpandImage;
			}
			else
			{
				if ( expandImage == null )
					expandImage = new Image( EmbedAsset.getEditorTextureAtlas().getTexture( "iconfont-caretdown" ));
				_expandButton.defaultIcon = expandImage;
			}
		}

		private var unlockImage : Image;
		private var lockImage : Image;
		private var eyeImage : Image;
		private var eyecloseImage : Image;

		private function refreshLockButton() : void
		{
			if ( _data == null || !_data.lock )
			{
				if ( unlockImage == null )
					unlockImage = new Image( EmbedAsset.getEditorTextureAtlas().getTexture( "iconfont-unlock" ));
				_lockButton.defaultIcon = unlockImage;
			}
			else
			{
				if ( lockImage == null )
					lockImage = new Image( EmbedAsset.getEditorTextureAtlas().getTexture( "iconfont-clock" ));
				_lockButton.defaultIcon = lockImage;
			}
		}

		private function refreshShowButton() : void
		{
			if ( _data == null || !_data.hidden )
			{
				if ( eyeImage == null )
					eyeImage = new Image( EmbedAsset.getEditorTextureAtlas().getTexture( "iconfont-eye" ));
				_showButton.defaultIcon = eyeImage;
			}
			else
			{
				if ( eyecloseImage == null )
					eyecloseImage = new Image( EmbedAsset.getEditorTextureAtlas().getTexture( "iconfont-eyeclose" ));
				_showButton.defaultIcon = eyecloseImage;
			}
		}


		private function onTouch( event : TouchEvent ) : void
		{
			if ( DragDropManager.isDragging )
			{
				return;
			}

			var touch : Touch = event.getTouch( this );
			if ( touch && touch.phase == TouchPhase.MOVED )
			{
				var clone : LayoutItemRenderer = new LayoutItemRenderer();
				clone.width = width;
				clone.height = height;
				clone.styleName = this.styleName;
				clone.data = _data;
				clone.owner = owner;
				clone.alpha = 0.5;

				var dragData : DragData = new DragData();
				dragData.setDataForFormat( SOURCE, _data.obj );

				DragDropManager.startDrag( this, touch, dragData, clone, -clone.width / 2, -clone.height / 2 );
			}
		}

		private function onDragEnter( event : DragDropEvent, dragData : DragData ) : void
		{
			DragDropManager.acceptDrag( this );
			showDropLine( event, dragData );
		}

		private function onDragMove( event : DragDropEvent, dragData : DragData ) : void
		{
			showDropLine( event, dragData );
		}

		private function onDragDrop( event : DragDropEvent, dragData : DragData ) : void
		{
			hideDropLine( event );

			var target : DisplayObjectContainer = dragData.getDataForFormat( TARGET );
			var source : DisplayObject = dragData.getDataForFormat( SOURCE );
			var index : int = dragData.getDataForFormat( INDEX );

			if ( target === source )
				return;

			if ( canDrop( target, source ))
			{
				UIEditorApp.instance.currentDocumentEditor.historyManager.add( new MoveLayerOperation( source, target, source.parent.getChildIndex( source ), index ));

				//var point:Point = source.parent.localToGlobal(new Point(source.x, source.y));
				target.addChildAt( source, index );
				//point = target.globalToLocal(point);
				//source.x = point.x;
				//source.y = point.y;

				UIEditorApp.instance.currentDocumentEditor.setLayerChanged();
				UIEditorApp.instance.currentDocumentEditor.setChanged();
			}
		}

		private function canDrop( target : DisplayObjectContainer, source : DisplayObject ) : Boolean
		{
			if ( target === source )
			{
				return false;
			}
			else if ( source is DisplayObjectContainer && ( source as DisplayObjectContainer ).contains( target ))
			{
				return false;
			}
			else
			{
				return true;
			}
		}

		private function onDragExit( event : DragDropEvent, dragData : DragData ) : void
		{
			hideDropLine( event );
		}

		private function showDropLine( event : DragDropEvent, dragData : DragData ) : void
		{
			createDropLine();

			var dropPosition : String;
			var target : DisplayObjectContainer;
			var index : int;

			if ( _data.obj === UIEditorApp.instance.currentDocumentEditor.root )
			{
				dropPosition = DROP_INSIDE;
			}
			else if ( _data.isContainer )
			{
				if ( event.localY < height / 3 )
				{
					dropPosition = DROP_ABOVE;
				}
				else if ( event.localY < height * 2 / 3 )
				{
					dropPosition = DROP_INSIDE;
				}
				else
				{
					dropPosition = DROP_BELOW;
				}
			}
			else
			{
				if ( event.localY < height / 2 )
				{
					dropPosition = DROP_ABOVE;
				}
				else
				{
					dropPosition = DROP_BELOW;
				}
			}

			if ( dropPosition == DROP_ABOVE )
			{
				_dropLine.visible = true;
				_dropLine.y = 0;
				alpha = 1;
				target = _data.obj.parent;
				index = target.getChildIndex( _data.obj );
			}
			else if ( dropPosition == DROP_INSIDE )
			{
				_dropLine.visible = false;
				alpha = 0.5;
				target = _data.obj;
				index = target.numChildren;
			}
			else
			{
				_dropLine.visible = true;
				_dropLine.y = height;
				target = _data.obj.parent;
				index = target.getChildIndex( _data.obj ) + 1;
			}

			dragData.setDataForFormat( TARGET, target );
			dragData.setDataForFormat( INDEX, index );
		}

		private function hideDropLine( event : DragDropEvent ) : void
		{
			createDropLine();

			_dropLine.visible = false;
			alpha = 1;
		}

		private function createDropLine() : void
		{
			if ( !_dropLine )
			{
				_dropLine = new Quad( width, 1, 0x0 );
				addChild( _dropLine );
			}
		}
	}
}
