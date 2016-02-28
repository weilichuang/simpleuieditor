package uieditor.editor.ui.itemrenderer
{
	import feathers.dragDrop.DragData;
	import feathers.dragDrop.DragDropManager;
	import feathers.dragDrop.IDragSource;
	import feathers.events.DragDropEvent;
	import starling.events.TouchEvent;
	import starling.events.Touch;
	import starling.events.TouchPhase;
	import uieditor.editor.ui.AssetTab;
	import uieditor.editor.UIEditorApp;
	import uieditor.editor.UIEditorScreen;

	import feathers.controls.renderers.DefaultListItemRenderer;

	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.textures.Texture;

	public class DragIconItemRenderer extends DefaultListItemRenderer implements IDragSource
	{
		private var _image : Image;

		private var _touchID : int = -1;
		private var _draggedObject : DisplayObject;
		private var _dragFormat : String;

		public function DragIconItemRenderer( dragFormat : String )
		{
			super();

			this.touchGroup = true;
			_iconFunction = createIcon;

			this._dragFormat = dragFormat;
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
					image.alpha = 0.8;

					var dragData : DragData = new DragData();
					var editorData : Object = ( UIEditorScreen.instance.leftPanel.getTabAt( 1 ) as AssetTab ).getItemEditorData( this );
					editorData.width = _image.texture.width;
					editorData.height = _image.texture.height;

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
			var texture : Texture = UIEditorApp.instance.assetManager.getTexture( item.label );

			if ( _image == null )
			{
				_image = new Image( texture );
			}
			else
			{
				_image.texture = texture;
				_image.readjustSize();
			}

			_image.width = 50;
			_image.height = 50;
			return _image;
		}
	}
}
