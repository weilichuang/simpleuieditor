package uieditor.editor.ui.itemrenderer
{
	import feathers.controls.renderers.DefaultGroupedListItemRenderer;
	import feathers.dragDrop.DragData;
	import feathers.dragDrop.DragDropManager;
	import feathers.dragDrop.IDragSource;
	import feathers.events.DragDropEvent;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import uieditor.editor.controller.DragFormat;
	import uieditor.editor.data.EmbedAsset;
	import uieditor.engine.util.ParamUtil;

	/**
	 * ...
	 * @author
	 */
	public class ComponentGroupedListItemRenderer extends DefaultGroupedListItemRenderer implements IDragSource
	{
		private var _image : Image;

		private var _touchID : int = -1;
		private var _draggedObject : DisplayObject;
		private var _dragFormat : String = DragFormat.FORMAT_COMPONENT;

		public function ComponentGroupedListItemRenderer()
		{
			super();

			this.isQuickHitAreaEnabled = true;
			this.labelField = "text";
			this._iconFunction = createIcon;

			this.addEventListener( TouchEvent.TOUCH, touchHandler );
			this.addEventListener( DragDropEvent.DRAG_START, dragStartHandler );
			this.addEventListener( DragDropEvent.DRAG_COMPLETE, dragCompleteHandler );
		}

		private function touchHandler( event : TouchEvent ) : void
		{
			if ( DragDropManager.isDragging )
			{
				//one drag at a time, please
				return;
			}
			if ( this._touchID >= 0 )
			{
				var touch : Touch = event.getTouch( this._draggedObject, null, this._touchID );
				if ( touch.phase == TouchPhase.MOVED )
				{
					this._touchID = -1;

					var image : Image = new Image( _image.texture );
					image.width = _image.width;
					image.height = _image.height;
					image.alpha = 0.8;

					var dragData : DragData = new DragData();
					var editorData : Object = getItemEditorData( this.data );

					dragData.setDataForFormat( this._dragFormat, editorData );
					DragDropManager.startDrag( this, touch, dragData, image, -image.width / 2, -image.height / 2 );
				}
				else if ( touch.phase == TouchPhase.ENDED )
				{
					this._touchID = -1;
				}
			}
			else
			{
				touch = event.getTouch( this, TouchPhase.BEGAN );
				if ( !touch || touch.target != this )
				{
					return;
				}
				this._touchID = touch.id;
				this._draggedObject = touch.target;
			}
		}

		public function getItemEditorData( item : Object ) : Object
		{
			var cls : String = item.text;
			var name : String = ParamUtil.getDisplayObjectName( cls );
			var editorData : Object = { cls: cls, name: name, label: name };
			return editorData;
		}

		private function dragStartHandler( event : DragDropEvent, dragData : DragData ) : void
		{
			//the drag was started with the call to DragDropManager.startDrag()
		}

		private function dragCompleteHandler( event : DragDropEvent, dragData : DragData ) : void
		{
			if ( event.isDropped )
			{
				//the object was dropped somewhere
			}
			else
			{
				//the drag cancelled and the object was not dropped
			}
		}

		private function createIcon( item : Object ) : DisplayObject
		{
			var texture : Texture = EmbedAsset.getEditorTextureAtlas().getTexture( item.icon );
			if ( texture == null )
				return null;

			if ( _image == null )
			{
				_image = new Image( texture );
			}
			else
			{
				_image.texture = texture;
				_image.readjustSize();
			}

			_image.width = 18;
			_image.height = 18;
			return _image;
		}

	}

}
