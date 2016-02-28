package uieditor.editor.ui
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import feathers.controls.ScrollContainer;
	
	import starling.display.Canvas;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	import uieditor.editor.UIEditorApp;
	import uieditor.editor.controller.AbstractDocumentEditor;

	public class DocumentPanel extends ScrollContainer
	{
		private var _background : Quad;

		private var _documentEditor : AbstractDocumentEditor;

		private var _selectRect : Canvas;

		public function DocumentPanel(isLibrary:Boolean = false)
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
			this.addChild( _selectRect );

			this.addEventListener( Event.RESIZE, onResize );
			onResize( null );

			this.addEventListener( TouchEvent.TOUCH, onTouchDocument );
		}
		
		public function get documentEditor():AbstractDocumentEditor
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
				return;

			if ( touch.phase == TouchPhase.BEGAN )
			{
				_startPoint = touch.getLocation( this );

				var clickObj : DisplayObject = this.hitTest( _startPoint );
				if ( clickObj == null || clickObj == this || clickObj == _documentEditor )
				{
					_beginMultiSelect = true;
				}
			}
			else if ( touch.phase == TouchPhase.MOVED )
			{
				if ( _beginMultiSelect )
				{
					var endPoint : Point = touch.getLocation( this );

					var w : int = Math.abs( endPoint.x - _startPoint.x ) / 1;
					var h : int = Math.abs( endPoint.y - _startPoint.y ) / 1;
					var x : int = Math.min( _startPoint.x, endPoint.x ) / 1;
					var y : int = Math.min( _startPoint.y, endPoint.y ) / 1;

					_selectRect.clear();
					_selectRect.beginFill( 0x0066cc, 1 );

					_selectRect.drawRectangle( x, y, w, 1 );
					_selectRect.drawRectangle( x, y + h - 1, w, 1 );
					_selectRect.drawRectangle( x, y, 1, h );
					_selectRect.drawRectangle( x + w - 1, y, 1, h );

					_selectRect.endFill();
				}
			}
			else if ( touch.phase == TouchPhase.ENDED )
			{
				_selectRect.clear();
				if ( _beginMultiSelect )
				{
					endPoint = touch.getLocation( this );

					_rect.width = Math.abs( endPoint.x - _startPoint.x );
					_rect.height = Math.abs( endPoint.y - _startPoint.y );
					_rect.x = Math.min( _startPoint.x, endPoint.x );
					_rect.y = Math.min( _startPoint.y, endPoint.y );

					_rect.x = Math.max( _rect.x - _documentEditor.x, 0 );
					_rect.y = Math.max( _rect.y - _documentEditor.y, 0 );

					if ( _rect.width > _documentEditor.width )
						_rect.width = _documentEditor.width;

					if ( _rect.height > _documentEditor.height )
						_rect.height = _documentEditor.height;

					_documentEditor.selectObjectsByRect( _rect );

					_beginMultiSelect = false;
				}

			}

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
			_documentEditor.removeChildren(); //make sure DocumentManager component is not disposed
			super.dispose();
		}

	}
}
