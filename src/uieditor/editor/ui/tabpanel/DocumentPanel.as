package uieditor.editor.ui.tabpanel
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import feathers.controls.ScrollContainer;
	import feathers.dragDrop.DragData;
	import feathers.dragDrop.DragDropManager;
	import feathers.dragDrop.IDropTarget;
	import feathers.events.DragDropEvent;

	import starling.display.Canvas;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	import uieditor.editor.UIEditorApp;
	import uieditor.editor.controller.AbstractDocumentEditor;
	import uieditor.editor.controller.DragFormat;

	public class DocumentPanel extends ScrollContainer implements IDropTarget
	{
		private var _background : Quad;

		private var _documentEditor : AbstractDocumentEditor;

		private var _selectRect : Canvas;

		protected var _dragFormats : Array = [ DragFormat.FORMAT_ASSET, DragFormat.FORMAT_COMPONENT, DragFormat.FORMAT_LIBRARY ];

		public function DocumentPanel( isLibrary : Boolean = false )
		{
			this.useLRUDKey = false;

			_documentEditor = isLibrary ? UIEditorApp.instance.libraryDocumentEditor : UIEditorApp.instance.documentEditor;

			_background = new Quad( 1, 1, 0x888888 );
			_background.touchable = false;
			this.addChild( _background );

			this.addChild( _documentEditor );
			_documentEditor.setDocumentPanel( this );

			_selectRect = new Canvas();
			_selectRect.touchable = false;
			_selectRect.visible = true;
			this.addChild( _selectRect );

			this.addEventListener( Event.RESIZE, onResize );
			onResize( null );

			this.addEventListener( TouchEvent.TOUCH, onTouchDocument );

			this.addEventListener( DragDropEvent.DRAG_ENTER, dragEnterHandler );
			this.addEventListener( DragDropEvent.DRAG_DROP, dragDropHandler );
		}

		public function get documentEditor() : AbstractDocumentEditor
		{
			return _documentEditor;
		}

		private var _startPoint : Point;
		private var _beginMultiSelect : Boolean;
		private var _rect : Rectangle = new Rectangle();

		private function onTouchDocument( event : TouchEvent ) : void
		{
			var touch : Touch = event.getTouch( this );
			if ( touch == null )
			{
				enableEditor();
				return;
			}

			if ( touch.phase == TouchPhase.BEGAN )
			{
				onBegan( touch );
			}
			else if ( touch.phase == TouchPhase.MOVED )
			{
				onMoved( touch );
			}
			else if ( touch.phase == TouchPhase.ENDED )
			{
				onEnd( touch );
			}

		}

		private function enableEditor() : void
		{
			_documentEditor.touchGroup = false;
			_documentEditor.touchable = true;
		}

		private function disableEditor() : void
		{
			_documentEditor.touchGroup = true;
			_documentEditor.touchable = false;
		}

		private function onBegan( touch : Touch ) : void
		{
			_startPoint = touch.getLocation( this );
			_startPoint.x += this.horizontalScrollPosition;
			_startPoint.y += this.verticalScrollPosition;

			var clickObj : DisplayObject = this.hitTest( _startPoint );
			if ( clickObj == null || clickObj == this )
			{
				disableEditor();

				_beginMultiSelect = true;
			}
		}

		private function onMoved( touch : Touch ) : void
		{
			if ( _beginMultiSelect )
			{
				var endPoint : Point = touch.getLocation( this );
				endPoint.x += this.horizontalScrollPosition;
				endPoint.y += this.verticalScrollPosition;

				var w : int = Math.abs( endPoint.x - _startPoint.x );
				var h : int = Math.abs( endPoint.y - _startPoint.y );
				var x : int = Math.min( _startPoint.x, endPoint.x );
				var y : int = Math.min( _startPoint.y, endPoint.y );

				_selectRect.clear();
				_selectRect.beginFill( 0x0066cc, 1 );

				_selectRect.drawRectangle( x, y, w, 1 );
				_selectRect.drawRectangle( x, y + h - 1, w, 1 );
				_selectRect.drawRectangle( x, y, 1, h );
				_selectRect.drawRectangle( x + w - 1, y, 1, h );

				_selectRect.endFill();
				_selectRect.visible = true;
			}
		}

		private function onEnd( touch : Touch ) : void
		{
			enableEditor();

			_selectRect.clear();
			if ( _beginMultiSelect )
			{
				var endPoint : Point = touch.getLocation( this );
				endPoint.x += this.horizontalScrollPosition;
				endPoint.y += this.verticalScrollPosition;

				_rect.width = Math.abs( endPoint.x - _startPoint.x );
				_rect.height = Math.abs( endPoint.y - _startPoint.y );
				_rect.x = Math.min( _startPoint.x, endPoint.x );
				_rect.y = Math.min( _startPoint.y, endPoint.y );

				_rect.x -= _documentEditor.x;
				_rect.y -= _documentEditor.y;

				_documentEditor.selectObjectsByRect( _rect );

				_beginMultiSelect = false;
			}
		}

		private function dragEnterHandler( event : DragDropEvent, dragData : DragData ) : void
		{
			var hasFormat : Boolean = false;
			for ( var i : int = 0; i < _dragFormats.length; i++ )
			{
				if ( dragData.hasDataForFormat( _dragFormats[ i ]))
				{
					hasFormat = true;
					break;
				}
			}

			if ( !hasFormat )
				return;

			DragDropManager.acceptDrag( this );
		}

		private function dragDropHandler( event : DragDropEvent, dragData : DragData ) : void
		{
			var offset : Point = new Point( event.localX, event.localY );
			offset.x -= _documentEditor.x;
			offset.y -= _documentEditor.y;

			_documentEditor.onDropData( offset, dragData );
		}

		/*
		 * 缩放背景
		 */
		public function resizeBg() : void
		{
			_background.width = this.width < _documentEditor.width ? _documentEditor.width : this.width;
			_background.height = this.height < _documentEditor.height ? _documentEditor.height : this.height;
		}

		private function onResize( e : Event ) : void
		{
			resizeBg();
			_documentEditor.resize();
		}

		override public function get isFocusEnabled() : Boolean
		{
			return this._isEnabled && this._isFocusEnabled;
		}

		override public function dispose() : void
		{
			this.removeEventListener( Event.RESIZE, onResize );
			this.removeEventListener( TouchEvent.TOUCH, onTouchDocument );
			this.removeEventListener( DragDropEvent.DRAG_ENTER, dragEnterHandler );
			this.removeEventListener( DragDropEvent.DRAG_DROP, dragDropHandler );
			_documentEditor.removeChildren(); //make sure DocumentManager component is not disposed
			super.dispose();
		}

	}
}
