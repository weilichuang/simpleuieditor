package uieditor.editor.helper
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.textures.Texture;
	
	import uieditor.editor.UIEditorApp;
	import uieditor.editor.controller.AbstractDocumentEditor;
	import uieditor.editor.cursor.CursorManager;
	import uieditor.editor.data.TemplateData;
	import uieditor.editor.events.DocumentEventType;
	import uieditor.editor.history.MovePivotOperation;
	import uieditor.editor.history.ResizeOperation;
	import uieditor.editor.ui.inspector.PropertyPanel;
	import uieditor.editor.ui.inspector.UIMapperEventType;
	import uieditor.engine.util.DisplayObjectUtil;
	import uieditor.engine.util.ParamUtil;


	/**
	 * 选中框
	 */
	public class InteractiveBoundingBox extends Sprite
	{
		public static const TOP_LEFT : String = "topLeft";
		public static const TOP_CENTER : String = "topCenter";
		public static const TOP_RIGHT : String = "topRight";

		public static const BOTTOM_LEFT : String = "bottomLeft";
		public static const BOTTOM_CENTER : String = "bottomCenter";
		public static const BOTTOM_RIGHT : String = "bottomRight";

		public static const LEFT_CENTER : String = "leftCenter";
		public static const RIGHT_CENTER : String = "rightCenter";

		public static const CENTER : String = "center";

		public static const TOP : String = "top";
		public static const BOTTOM : String = "bottom";
		public static const LEFT : String = "left";
		public static const RIGHT : String = "right";

		public static const PIVOT_POINT : String = "pivotPoint";

		public static const DRAG_BOX : String = "dragBox";

		public static const BOUNDING_BOX : Array = [

			TOP, BOTTOM, LEFT, RIGHT, CENTER,
			TOP_LEFT, TOP_CENTER, TOP_RIGHT,
			BOTTOM_LEFT, BOTTOM_CENTER, BOTTOM_RIGHT,
			LEFT_CENTER, RIGHT_CENTER,

			]

		public static const INTERACTABLE : Array = [ CENTER,
			TOP_LEFT, TOP_CENTER, TOP_RIGHT,
			BOTTOM_LEFT, BOTTOM_CENTER, BOTTOM_RIGHT,
			LEFT_CENTER, RIGHT_CENTER,
			]

		private var _target : DisplayObject;

		private var _boundingBoxContainer : Sprite;

		private var _enable : Boolean = true;

		private var _color : uint;

		private var _documentEditor : AbstractDocumentEditor;

		public function InteractiveBoundingBox( color : uint, documentEditor : AbstractDocumentEditor, touchable : Boolean )
		{
			_color = color;
			createBoundingBox();
			_boundingBoxContainer.visible = false;

			_documentEditor = documentEditor;
			_documentEditor.addEventListener( DocumentEventType.CHANGE, onChange );

			this.touchable = touchable;
			if ( touchable )
				this.addEventListener( TouchEvent.TOUCH, onTouch );
		}

		private function onTouch( event : TouchEvent ) : void
		{
			var touch : Touch = event.getTouch( this );
			if ( touch == null )
			{
				CursorManager.showDefault();
			}
		}

		public function set target( value : DisplayObject ) : void
		{
			if(_target == value)
				return;
			if(_target)
			{
				_target.removeEventListener(Event.REMOVED_FROM_STAGE,onRemoveFromStage);
			}
			_target = value;
			if(_target != null)
			{
				_target.addEventListener(Event.REMOVED_FROM_STAGE,onRemoveFromStage);
				if(!hasEventListener(Event.ENTER_FRAME))
					this.addEventListener(Event.ENTER_FRAME,onEnterFrame);
			}
			else
			{
				this.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
			}
		}
		
		private function onRemoveFromStage(event:Event):void
		{
			target = null;
		}
		
		private function onEnterFrame(event:Event):void
		{
			reload();
		}

		public function get target() : DisplayObject
		{
			return _target;
		}

		public function reload() : void
		{
			if ( _target && _target.parent )
			{
				_boundingBoxContainer.visible = true;

				var rect : Rectangle = _target.getBounds( parent );
				updateBoundingBox( rect.x, rect.y, rect.width, rect.height, _target.pivotX, _target.pivotY );
			}
			else
			{
				_boundingBoxContainer.visible = false;
				updateBoundingBox( 0, 0, 0, 0, 0, 0 );
			}
		}

		private function createBoundingBox() : void
		{
			var quad : Quad;

			_boundingBoxContainer = new Sprite();
			addChild( _boundingBoxContainer );

			for each ( var name : String in BOUNDING_BOX )
			{
				quad = createSquare( name );

				_boundingBoxContainer.addChild( quad );

				if ( INTERACTABLE.indexOf( name ) != -1 )
				{
					DragHelper.startDrag( quad, onDrag, onComplete, onHover );
				}
			}

			var dragBox : Sprite = createDragBox( DRAG_BOX );
			DragHelper.startDrag( dragBox, onDrag, onComplete );
			_boundingBoxContainer.addChild( dragBox );

			quad = createPivot( PIVOT_POINT );
			DragHelper.startDrag( quad, onDrag, onComplete );

			_boundingBoxContainer.addChild( quad );
		}

		private function updateBoundingBox( x : Number, y : Number, width : Number, height : Number, pivotX : Number, pivotY : Number ) : void
		{
			var quad : Quad;

			if ( _target )
			{
				this.x = x;
				this.y = y;
			}
			else
			{
				this.x = 0;
				this.y = 0;
			}

			if ( _target )
			{
				var p : Point = _target.localToGlobal( new Point( _target.pivotX, _target.pivotY ));
				p = this.globalToLocal( p );
				pivotX = p.x;
				pivotY = p.y;
				//pivotX *= _target.scaleX;
				//pivotY *= _target.scaleY;

				if ( _target.width == 0 && _target.height == 0 )
				{
					_boundingBoxContainer.getChildByName( DRAG_BOX ).visible = true;
				}
				else
				{
					_boundingBoxContainer.getChildByName( DRAG_BOX ).visible = false;
				}
			}

			quad = _boundingBoxContainer.getChildByName( PIVOT_POINT ) as Quad;
			if ( quad )
			{
				updateSquare( quad, width, height, pivotX, pivotY, _enable );
			}

			var b : Boolean = interactable( _target );
			var visible : Boolean = false;

			for each ( var name : String in BOUNDING_BOX )
			{
				if ( INTERACTABLE.indexOf( name ) != -1 )
				{
					if ( b && _enable )
						visible = true;
					else
						visible = false;
				}
				else
				{
					visible = true;
				}

				quad = _boundingBoxContainer.getChildByName( name ) as Quad;
				if ( quad )
				{
					updateSquare( quad, width, height, pivotX, pivotY, visible );
				}
			}
		}

		private function interactable( target : DisplayObject ) : Boolean
		{
			if ( target == null )
				return false;

			var params : Array = ParamUtil.getParams( TemplateData.editor_template, target );

			var count : int = 0;

			for each ( var param : Object in params )
			{
				if ( param.name == "width" && ( !target.hasOwnProperty( "explicitWidth" ) || !isNaN( target[ "explicitWidth" ])))
					++count;

				if ( param.name == "height" && ( !target.hasOwnProperty( "explicitHeight" ) || !isNaN( target[ "explicitHeight" ])))
					++count;
			}

			return count >= 2;
		}

		private function createDragBox( name : String ) : Sprite
		{
			var dragBox : Sprite = new Sprite();
			dragBox.name = name;

			var square : Quad = new Quad( 50, 50, 0xffff00 );
			square.alpha = 0.5;
			square.alignPivot();
			square.name = name + "_quad";

			dragBox.addChild( square );

			var shape : Shape = new Shape();
			shape.graphics.lineStyle( 2, 0x0 );
			shape.graphics.beginFill( 0xffffff );
			shape.graphics.drawCircle( 8, 8, 7 );
			shape.graphics.endFill();

			var bitmapData : BitmapData = new BitmapData( 16, 16, true, 0x0 );
			bitmapData.draw( shape, null, null, null, null, true );

			var texture : Texture = Texture.fromBitmapData( bitmapData, false );

			var centerPoint : Image = new Image( texture );
			centerPoint.width = 14;
			centerPoint.height = 14;
			centerPoint.pivotX = centerPoint.width * 0.5;
			centerPoint.pivotY = centerPoint.height * 0.5;
			centerPoint.name = name + "_center";

			dragBox.addChild( centerPoint );

			return dragBox;
		}

		private function createPivot( name : String ) : Quad
		{
			var shape : Shape = new Shape();
			shape.graphics.lineStyle( 2, 0x0 );
			shape.graphics.beginFill( 0xffffff );
			shape.graphics.drawCircle( 8, 8, 7 );
			shape.graphics.endFill();

			var bitmapData : BitmapData = new BitmapData( 16, 16, true, 0x0 );
			bitmapData.draw( shape, null, null, null, null, true );

			var texture : Texture = Texture.fromBitmapData( bitmapData, false );

			var square : Image = new Image( texture );
			square.width = 14;
			square.height = 14;
			square.pivotX = square.width * 0.5;
			square.pivotY = square.height * 0.5;
			square.name = name;
			return square;
		}

		private function createSquare( name : String ) : Quad
		{
			var square : Quad = new Quad( 10, 10, _color );
			square.pivotX = square.width * 0.5;
			square.pivotY = square.height * 0.5;
			square.name = name;
			if ( name == CENTER )
			{
				square.alpha = 0;
			}
			return square;
		}

		private function updateSquare( quad : Quad, width : Number, height : Number, pivotX : Number, pivotY : Number, visible : Boolean ) : void
		{
			quad.visible = visible;

			switch ( quad.name )
			{
				case CENTER:
					quad.x = width * 0.5;
					quad.y = height * 0.5;
					quad.width = width;
					quad.height = height;
					break;
				case TOP_LEFT:
					quad.x = 0;
					quad.y = 0;
					break;
				case TOP_CENTER:
					quad.x = width * 0.5;
					quad.y = 0;
					break;
				case TOP_RIGHT:
					quad.x = width;
					quad.y = 0;
					break;
				case BOTTOM_LEFT:
					quad.x = 0;
					quad.y = height;
					break;
				case BOTTOM_CENTER:
					quad.x = width * 0.5;
					quad.y = height;
					break;
				case BOTTOM_RIGHT:
					quad.x = width;
					quad.y = height;
					break;
				case LEFT_CENTER:
					quad.x = 0;
					quad.y = height * 0.5;
					break;
				case RIGHT_CENTER:
					quad.x = width;
					quad.y = height * 0.5;
					break;
				case TOP:
					quad.x = width * 0.5;
					quad.y = 0;
					quad.width = width;
					quad.height = 1;
					break;
				case BOTTOM:
					quad.x = width * 0.5;
					quad.y = height;
					quad.width = width;
					quad.height = 1;
					break;
				case LEFT:
					quad.x = 0;
					quad.y = height * 0.5;
					quad.width = 1;
					quad.height = height;
					break;
				case RIGHT:
					quad.x = width;
					quad.y = height * 0.5;
					quad.width = 1;
					quad.height = height;
					break;
				case PIVOT_POINT:
					quad.x = pivotX;
					quad.y = pivotY;
					break;
			}


		}

		private function onHover( object : DisplayObject ) : void
		{
			switch ( object.name )
			{
				case CENTER:
					CursorManager.showCursor( CursorManager.CURSOR_MOVE );
					break;
				case TOP_LEFT:
					CursorManager.showCursor( CursorManager.CURSOR_SIZE_NWSE );
					break;
				case TOP_CENTER:
					CursorManager.showCursor( CursorManager.CURSOR_SIZE_NS );
					break;
				case TOP_RIGHT:
					CursorManager.showCursor( CursorManager.CURSOR_SIZE_NESW );
					break;
				case BOTTOM_LEFT:
					CursorManager.showCursor( CursorManager.CURSOR_SIZE_NESW );
					break;
				case BOTTOM_CENTER:
					CursorManager.showCursor( CursorManager.CURSOR_SIZE_NS );
					break;
				case BOTTOM_RIGHT:
					CursorManager.showCursor( CursorManager.CURSOR_SIZE_NWSE );
					break;
				case LEFT_CENTER:
					CursorManager.showCursor( CursorManager.CURSOR_SIZE_WE );
					break;
				case RIGHT_CENTER:
					CursorManager.showCursor( CursorManager.CURSOR_SIZE_WE );
					break;
				case PIVOT_POINT:
					break;
				default:
					CursorManager.showDefault();
					break;
			}
		}

		private function onDrag( object : DisplayObject, dx : Number, dy : Number ) : Boolean
		{
			//disable resize when rotation is not 0
			if ( _target.rotation != 0 )
				return false;

			dx /= UIEditorApp.instance.documentEditor.scale;
			dy /= UIEditorApp.instance.documentEditor.scale;

			var ratioX : Number = 1 - _target.pivotX / ( _target.width / _target.scaleX );
			var ratioY : Number = 1 - _target.pivotY / ( _target.height / _target.scaleY );
			if ( isNaN( ratioX ))
				ratioX = 1;
			if ( isNaN( ratioY ))
				ratioY = 1;

			var oldValue : Rectangle = new Rectangle( _target.x, _target.y, _target.width, _target.height );

			switch ( object.name )
			{
				case CENTER:
					_target.x += dx * ratioX;
					_target.y += dy * ratioY;
					break;
				case TOP_LEFT:
					_target.x += dx * ratioX;
					_target.y += dy * ratioY;
					_target.width -= dx;
					_target.height -= dy;
					break;
				case TOP_CENTER:
					_target.y += dy * ratioY;
					_target.height -= dy;
					break;
				case TOP_RIGHT:
					_target.x += dx * ( 1 - ratioX );
					_target.y += dy * ratioY;
					_target.width += dx;
					_target.height -= dy;
					break;
				case BOTTOM_LEFT:
					_target.x += dx * ratioX;
					_target.y += dy * ( 1 - ratioY );
					_target.width -= dx;
					_target.height += dy;
					break;
				case BOTTOM_CENTER:
					_target.y += dy * ( 1 - ratioY );
					_target.height += dy;
					break;
				case BOTTOM_RIGHT:
					_target.x += dx * ( 1 - ratioX );
					_target.y += dy * ( 1 - ratioY );
					_target.width += dx;
					_target.height += dy;
					break;
				case LEFT_CENTER:
					_target.x += dx * ratioX;
					_target.width -= dx;
					break;
				case RIGHT_CENTER:
					_target.x += dx * ( 1 - ratioX );
					_target.width += dx;
					break;
				case PIVOT_POINT:
					DisplayObjectUtil.movePivotTo( _target, _target.pivotX + dx, _target.pivotY + dy );
					UIEditorApp.instance.documentEditor.historyManager.add( new MovePivotOperation( _target, new Point( _target.pivotX - dx, _target.pivotY - dx ),
						new Point( _target.pivotX, _target.pivotY )));
					break;
				case DRAG_BOX:
					_target.x += dx * ratioX;
					_target.y += dy * ratioY;
					break;
			}

			//This will lock width/height ratio when linked button is active
			if ( _target.width != oldValue.width )
				PropertyPanel.globalDispatcher.dispatchEventWith( UIMapperEventType.PROPERTY_CHANGE, false, { target: _target, propertyName: "width" });
			if ( _target.height != oldValue.height )
				PropertyPanel.globalDispatcher.dispatchEventWith( UIMapperEventType.PROPERTY_CHANGE, false, { target: _target, propertyName: "height" });


			if ( object.name != PIVOT_POINT )
			{
				var newValue : Rectangle = new Rectangle( _target.x, _target.y, _target.width, _target.height );
				UIEditorApp.instance.documentEditor.historyManager.add( new ResizeOperation( _target, oldValue, newValue ));
			}

			UIEditorApp.instance.documentEditor.setChanged();

			return ( dx * dx + dy * dy > 0.5 );
		}

		private function onComplete() : void
		{
			CursorManager.showDefault();
		}

		private function onChange( event : Event ) : void
		{
			reload();
		}

		public function get enable() : Boolean
		{
			return _enable;
		}

		public function set enable( value : Boolean ) : void
		{
			_enable = value;

			reload();
		}

		override public function dispose() : void
		{
			this.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
			this.removeEventListener( TouchEvent.TOUCH, onTouch );
			_documentEditor.removeEventListener( DocumentEventType.CHANGE, onChange );
			_documentEditor = null;
			super.dispose();
		}
	}
}
