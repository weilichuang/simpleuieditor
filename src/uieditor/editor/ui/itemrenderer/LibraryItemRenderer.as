package uieditor.editor.ui.itemrenderer
{
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
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	import uieditor.editor.controller.DragFormat;
	import uieditor.editor.data.EmbedAsset;
	
	public class LibraryItemRenderer extends DefaultListItemRenderer implements IDragSource, IDropTarget
	{
		public static const SOURCE:String = "source";
		public static const TARGET:String = "target";
		public static const INDEX:String = "index";
		
		public static const DROP_ABOVE:String = "above";
		public static const DROP_BELOW:String = "below";
		
		private var _group : LayoutGroup;
		private var _iconImage:Image;

		private var _dropLine:Quad;
		
		public function LibraryItemRenderer()
		{
			super();
			
			createIconGroup();
			_iconFunction = layoutIconFunction;
			
			addEventListener(TouchEvent.TOUCH, onTouch);
			addEventListener(DragDropEvent.DRAG_ENTER, onDragEnter);
			addEventListener(DragDropEvent.DRAG_MOVE, onDragMove);
			addEventListener(DragDropEvent.DRAG_EXIT, onDragExit);
			addEventListener(DragDropEvent.DRAG_DROP, onDragDrop);
		}
		
		private function createIconGroup() : void
		{
			_group = new LayoutGroup();
			_group.layout = new HorizontalLayout();
			( _group.layout as HorizontalLayout ).gap = 2;
			
			var texture : Texture = EmbedAsset.getEditorTextureAtlas().getTexture("component_sprite");
			_iconImage = new Image(texture);
			_group.addChild( _iconImage );
		}
	
		private function layoutIconFunction( item : Object ) : DisplayObject
		{
			return _group;
		}
		
		override public function set data( value : Object ) : void
		{
			super.data = value;
		}
		
		private function onTouch(event:TouchEvent):void
		{
			if (DragDropManager.isDragging)
			{
				return;
			}
			
			var touch:Touch = event.getTouch(this);
			if (touch && touch.phase == TouchPhase.MOVED)
			{
				var clone:LibraryItemRenderer = new LibraryItemRenderer();
				clone.width = width;
				clone.height = height;
				clone.styleName = this.styleName;
				clone.data = _data;
				clone.owner = owner;
				clone.alpha = 0.5;
				
				var dragData:DragData = new DragData();
				dragData.setDataForFormat(DragFormat.FORMAT_LIBRARY, _data);
				
				DragDropManager.startDrag(this, touch, dragData, clone);
			}
		}
		
		private function onDragEnter(event:DragDropEvent, dragData:DragData):void
		{
			DragDropManager.acceptDrag(this);
			showDropLine(event, dragData);
		}
		
		private function onDragMove(event:DragDropEvent, dragData:DragData):void
		{
			showDropLine(event, dragData);
		}
		
		private function onDragDrop(event:DragDropEvent, dragData:DragData):void
		{
			hideDropLine(event);
			
//			var target:DisplayObjectContainer = dragData.getDataForFormat(TARGET);
//			var source:DisplayObject = dragData.getDataForFormat(SOURCE);
//			var index:int = dragData.getDataForFormat(INDEX);
//			
//			if (target === source) return;
			
//			if (canDrop(target, source))
//			{
//				UIEditorApp.instance.documentManager.historyManager.add(new MoveLayerOperation(source, target, source.parent.getChildIndex(source), index));
//				
//				target.addChildAt(source, index);
//				
//				UIEditorApp.instance.documentManager.setLayerChanged();
//				UIEditorApp.instance.documentManager.setChanged();
//			}
		}
		
		private function canDrop(target:DisplayObjectContainer, source:DisplayObject):Boolean
		{
			if (target === source)
			{
				return false;
			}
			else if (source is DisplayObjectContainer && (source as DisplayObjectContainer).contains(target))
			{
				return false;
			}
			else
			{
				return true;
			}
		}
		
		private function onDragExit(event:DragDropEvent, dragData:DragData):void
		{
			hideDropLine(event);
		}
		
		private function showDropLine(event:DragDropEvent, dragData:DragData):void
		{
			createDropLine();
			
			var dropPosition:String;
			var target:DisplayObjectContainer;
			var index:int;
			
			if (event.localY < height / 2)
			{
				dropPosition = DROP_ABOVE;
			}
			else
			{
				dropPosition = DROP_BELOW;
			}
			
//			if (dropPosition == DROP_ABOVE)
//			{
//				_dropLine.visible = true;
//				_dropLine.y = 0;
//				alpha = 1;
//				target = _data.obj.parent;
//				index = target.getChildIndex(_data.obj);
//			}
//			else
//			{
//				_dropLine.visible = true;
//				_dropLine.y = height;
//				target = _data.obj.parent;
//				index = target.getChildIndex(_data.obj) + 1;
//			}
//			
//			dragData.setDataForFormat(TARGET, target);
//			dragData.setDataForFormat(INDEX, index);
		}
		
		private function hideDropLine(event:DragDropEvent):void
		{
			createDropLine();
			
			_dropLine.visible = false;
			alpha = 1;
		}
		
		private function createDropLine():void
		{
			if (!_dropLine)
			{
				_dropLine = new Quad(width, 1,0x0);
				addChild(_dropLine);
			}
		}
	}
}

