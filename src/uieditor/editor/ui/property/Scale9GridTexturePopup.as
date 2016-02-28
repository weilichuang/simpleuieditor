package uieditor.editor.ui.property
{
	import feathers.controls.LayoutGroup;
	import feathers.controls.PickerList;
	import feathers.data.ListCollection;
	import flash.geom.Rectangle;
	import flash.ui.MouseCursor;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import starling.utils.AssetManager;
	import starling.utils.RectangleUtil;
	import uieditor.editor.cursor.CursorManager;
	import uieditor.editor.feathers.popup.InfoPopup;
	import uieditor.editor.ui.inspector.PropertyPanel;
	import uieditor.editor.ui.inspector.UIMapperEventType;
	import uieditor.editor.UIEditorApp;

	public class Scale9GridTexturePopup extends AbstractPropertyPopup
	{
		private static const MAX_SIZE : int = 600;

		private var _assetManager : AssetManager;

		private var _gridContainer : Sprite;

		private var _scale9Grid:Rectangle;

		private var _image : Image;

		private var _propertyPanel : PropertyPanel;
		
		private var _texture:Texture;
		
		private var _scale:Number;

		private var _scaleLines : Vector.<ScaleLine> = new Vector.<ScaleLine>();

		public function Scale9GridTexturePopup( owner : Object, target : Object, targetParam : Object, onComplete : Function )
		{
			super( owner, target, targetParam, onComplete );
			
			title =  "9宫格设置";
			buttons = [ "确定", "取消" ];

			addEventListener( Event.COMPLETE, onDialogComplete );

			PropertyPanel.globalDispatcher.addEventListener( UIMapperEventType.PROPERTY_CHANGE, onRectChange );
		}

		override protected function createContent( container : LayoutGroup ) : void
		{
			var imageContainer : Sprite = new Sprite();
			
			var ownerImage:Image = (_owner as Image);
			
			_texture = ownerImage.texture;
			
			var oldScale9Grid:Rectangle = ownerImage.scale9Grid;

			_image = new Image(_texture);

			if ( _image.width < 200 && _image.height < 200 )
			{
				_scale = Math.min( 200 / _image.width, 200 / _image.height );
				_image.scale = _scale;
			}
			else
			{
				_scale = 1;
			}

			_gridContainer = new Sprite();

			_scale9Grid = new Rectangle();

			if ( oldScale9Grid != null )
			{
				_scale9Grid.copyFrom(oldScale9Grid);
			}
			else
			{
				_scale9Grid.setTo(0.2 * _texture.width, 0.2 * _texture.height, 0.6 * _texture.width, 0.6 * _texture.height);
			}

			initLines();

			var params : Array = createUIMapperParams();
			_propertyPanel = new PropertyPanel( _scale9Grid, params );

			imageContainer.addChild( _image );
			imageContainer.addChild( _gridContainer );

			fitDisplayObject( _image );

			container.addChild( imageContainer );
			container.addChild( _propertyPanel );
		}

		private function initLines() : void
		{
			_scaleLines.length = 0;
			_gridContainer.removeChildren( 0, -1, true );

			addLine( _scale9Grid.left * _scale, 0, _scale9Grid.left * _scale, _image.height, true );
			addLine( _scale9Grid.right * _scale, 0, _scale9Grid.right * _scale, _image.height, true );
			addLine( 0, _scale9Grid.top * _scale, _image.width, _scale9Grid.top * _scale, false );
			addLine( 0, _scale9Grid.bottom * _scale, _image.width, _scale9Grid.bottom * _scale, false );
		}

		private function onRectChange( event : Event ) : void
		{
			if ( event && event.data.target !== _scale9Grid )
				return;

			_scaleLines[ 0 ].x = _scale9Grid.left * _scale;
			_scaleLines[ 1 ].x = _scale9Grid.right * _scale;
			_scaleLines[ 2 ].y = _scale9Grid.top * _scale;
			_scaleLines[ 3 ].y = _scale9Grid.bottom * _scale;
		}

		private function addLine( x1 : Number, y1 : Number, x2 : Number, y2 : Number, isHorizontal : Boolean ) : void
		{
			var line : ScaleLine = new ScaleLine( x1, y1, x2, y2, isHorizontal );

			line.addEventListener( TouchEvent.TOUCH, onTouchLine );

			_gridContainer.addChild( line );

			_scaleLines.push( line );
		}

		private function onTouchLine( event : TouchEvent ) : void
		{
			var touch : Touch = null;
			var touchObject : ScaleLine = null;
			for ( var i : int = 0; i < _scaleLines.length; i++ )
			{
				touchObject = _scaleLines[ i ];
				touch = event.getTouch( touchObject );
				if ( touch != null )
					break;
			}

			if ( touch == null )
			{
				CursorManager.showDefault();
				return;
			}

			if ( touch.phase == TouchPhase.MOVED )
			{
				if ( !isNaN( touchObject.previousX ) && !isNaN( touchObject.previousY ))
				{
					var dx : Number = touch.globalX - touchObject.previousX;
					var dy : Number = touch.globalY - touchObject.previousY;

					if ( touchObject.isHorizontal )
					{
						touchObject.x += dx;
						if ( touchObject.x > _image.width )
							touchObject.x = _image.width;
						else if ( touchObject.x < 0 )
							touchObject.x = 0;
					}
					else
					{
						touchObject.y += dy;
						if ( touchObject.y > _image.height )
							touchObject.y = _image.height;
						else if ( touchObject.y < 0 )
							touchObject.y = 0;
					}
					touchObject.previousX = touch.globalX;
					touchObject.previousY = touch.globalY;

					updateRect();
				}
				else
				{
					touchObject.previousX = touch.globalX;
					touchObject.previousY = touch.globalY;
				}
			}
			else if ( touch.phase == TouchPhase.ENDED )
			{
				touchObject.previousX = Number.NaN;
				touchObject.previousY = Number.NaN;
			}
			else if ( touch.phase == TouchPhase.HOVER )
			{
				CursorManager.showCursor( MouseCursor.BUTTON );
			}

		}

		private function updateRect() : void
		{
			if ( _scaleLines[ 1 ].x < _scaleLines[ 0 ].x )
				_scaleLines[ 1 ].x = _scaleLines[ 0 ].x + 4;
			if ( _scaleLines[ 3 ].y < _scaleLines[ 2 ].y )
				_scaleLines[ 3 ].y = _scaleLines[ 2 ].y + 4;
			_scale9Grid.left = _scaleLines[ 0 ].x / _scale;
			_scale9Grid.right = _scaleLines[ 1 ].x / _scale;
			_scale9Grid.top = _scaleLines[ 2 ].y / _scale;
			_scale9Grid.bottom = _scaleLines[ 3 ].y / _scale;

			_propertyPanel.reset();

			var params : Array = createUIMapperParams();
			_propertyPanel.reloadData( _scale9Grid, params );
		}

		private function createUIMapperParams() : Array
		{
			var params : Array = [];

			params.push( createUIMapperParam( "left",_texture.width ));
			params.push( createUIMapperParam( "right",_texture.width ));
			params.push( createUIMapperParam( "top",_texture.height ));
			params.push( createUIMapperParam( "bottom",_texture.height ));

			return params;
		}

		private function createUIMapperParam( name : String,maxValue:int ) : Object
		{
			return { "name": name, "component": "slider", "min": 0, "max": maxValue, "step": 1 };
		}

		private function onDialogComplete( event : Event ) : void
		{
			var index : int = int( event.data );
			if ( index == 0 )
			{
				complete();
			}
			else
			{
				_owner = null;

				_onComplete = null;
			}

		}

		private function removeLines() : void
		{
			for ( var i : int = 0; i < _scaleLines.length; i++ )
			{
				_scaleLines[ i ].removeEventListener( TouchEvent.TOUCH, onTouchLine );
			}
			_scaleLines.length = 0;
		}

		override public function dispose() : void
		{
			removeLines();

			removeEventListener( Event.COMPLETE, onDialogComplete );

			PropertyPanel.globalDispatcher.removeEventListener( UIMapperEventType.PROPERTY_CHANGE, onRectChange );

			super.dispose();
		}

		private function fitDisplayObject( object : DisplayObject ) : void
		{
			if ( object.width > MAX_SIZE || object.height > MAX_SIZE )
			{
				var rect : Rectangle = RectangleUtil.fit( new Rectangle( 0, 0, object.width, object.height ), new Rectangle( 0, 0, MAX_SIZE, MAX_SIZE ));
				object.width = rect.width;
				object.height = rect.height;
			}
		}

		protected function complete() : void
		{
			_onComplete( _scale9Grid );
		}
	}
}
import starling.display.Quad;
import uieditor.editor.util.MathUtil;


class ScaleLine extends Quad
{
	public var previousX : Number = NaN;
	public var previousY : Number = NaN;
	public var isHorizontal : Boolean;

	public function ScaleLine( x1 : Number, y1 : Number, x2 : Number, y2 : Number, isHorizontal : Boolean )
	{
		var len : Number = MathUtil.distance( x1, y1, x2, y2 );

		if ( len == 0 )
		{
			len = 1;
		}

		super( len, 4, 0xff0000 );

		pivotY = height * 0.5;
		x = x1;
		y = y1;
		rotation = Math.atan2( y2 - y1, x2 - x1 );

		this.isHorizontal = isHorizontal;
	}
}
