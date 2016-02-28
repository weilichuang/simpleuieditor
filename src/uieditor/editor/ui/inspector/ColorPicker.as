package uieditor.editor.ui.inspector
{
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import feathers.controls.TextInput;

	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.display.Stage;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.filters.ColorMatrixFilter;
	import starling.textures.Texture;

	public class ColorPicker extends Sprite
	{
		public static const TOP_LEFT : String = "topLeft";
		public static const TOP_RIGHT : String = "topRight";
		public static const BOTTOM_LEFT : String = "bottomLeft";
		public static const BOTTOM_RIGHT : String = "bottomRight";

		[Embed( source = "palette.png" )]
		private static const Palette : Class;

		private var _square : Button;
		private var _colorFilter : ColorMatrixFilter;

		private var _bgSquare : Quad;

		private var _paletteContainer : Sprite;
		private var _textInput : TextInput;
		private var _palette : Image;
		private var _bitmap : Bitmap;

		private var _value : uint = 0xffffff;

		public function ColorPicker()
		{
			_bitmap = new Palette();
			_colorFilter = new ColorMatrixFilter();

			_bgSquare = new starling.display.Quad( 22, 22, 0x0 );

			addChild( _bgSquare );

			_square = new Button( Texture.fromColor( 20, 20 ));
			_square.filter = _colorFilter;
			_square.scaleWhenDown = 1;
			_square.x = 1;
			_square.y = 1;

			addChild( _square );

			_paletteContainer = new Sprite();
			_palette = new Image( Texture.fromBitmap( _bitmap ));
			_textInput = new TextInput();
			_textInput.restrict = "0-9a-fA-F";
			_textInput.maxChars = 6;
			_textInput.width = _palette.width;
			_palette.y = 20;
			_paletteContainer.addChild( _textInput );
			_paletteContainer.addChild( _palette );


			_square.addEventListener( Event.TRIGGERED, onSquare );
			_palette.addEventListener( TouchEvent.TOUCH, onPalette );
			_textInput.addEventListener( "enter", onTextEnter );
		}

		private function onSquare( event : Event ) : void
		{
			togglePalette();
		}

		private function togglePalette() : void
		{
			if ( _paletteContainer.stage == null )
			{
				Starling.current.stage.addChild( _paletteContainer );
				autoPositionPalette();
			}
			else
			{
				Starling.current.stage.removeChild( _paletteContainer );
			}
		}

		private function autoPositionPalette() : void
		{
			var directions : Array = [ BOTTOM_LEFT, TOP_LEFT, BOTTOM_RIGHT, TOP_RIGHT ];

			for each ( var direction : String in directions )
			{
				positionPalette( direction );

				if ( insideViewPort( _paletteContainer ))
				{
					break;
				}
			}
		}

		private function insideViewPort( obj : DisplayObject ) : Boolean
		{
			var stage : Stage = Starling.current.stage;

			var rect : Rectangle = obj.getBounds( stage );
			var stageRect : Rectangle = new Rectangle( 0, 0, stage.stageWidth, stage.stageHeight );

			return stageRect.containsRect( rect );
		}


		private function positionPalette( type : String ) : void
		{
			var pt : Point;

			switch ( type )
			{
				case BOTTOM_LEFT:
					pt = localToGlobal( new Point( -10, 0 ));
					_paletteContainer.x = pt.x - _paletteContainer.width;
					_paletteContainer.y = pt.y;
					break;
				case BOTTOM_RIGHT:
					pt = localToGlobal( new Point( 30, 0 ));
					_paletteContainer.x = pt.x;
					_paletteContainer.y = pt.y;
					break;
				case TOP_LEFT:
					pt = localToGlobal( new Point( -10, 20 ));
					_paletteContainer.x = pt.x - _paletteContainer.width;
					_paletteContainer.y = pt.y - _paletteContainer.height;
					break;
				case TOP_RIGHT:
					pt = localToGlobal( new Point( 30, 20 ));
					_paletteContainer.x = pt.x;
					_paletteContainer.y = pt.y - _paletteContainer.height;
					break;
			}
		}

		private function onTextEnter( event : Event ) : void
		{
			var text : String = "0x" + _textInput.text;
			value = uint( Number( text ));
			dispatchEventWith( Event.CHANGE );
			_paletteContainer.removeFromParent();
		}

		private function onPalette( event : TouchEvent ) : void
		{
			var target : DisplayObject = DisplayObject( event.target );

			var touch : Touch = event.getTouch( target );

			if ( touch )
			{
				var loc : Point = touch.getLocation( target );

				if ( touch.phase == TouchPhase.BEGAN || touch.phase == TouchPhase.MOVED || touch.phase == TouchPhase.ENDED )
				{
					value = getColor( loc.x, loc.y );

					_textInput.text = value.toString( 16 );

					dispatchEventWith( Event.CHANGE );
				}

				if ( touch.phase == TouchPhase.ENDED )
				{
					togglePalette();
				}
			}
		}

		public function get value() : uint
		{
			return _value;
		}

		public function set value( value : uint ) : void
		{
			_value = value;

			updateColor( _value );
		}

		private function updateColor( color : uint ) : void
		{
			_colorFilter.reset();
			_colorFilter.tint( color );
		}

		private function getColor( x : int, y : int ) : uint
		{
			return _bitmap.bitmapData.getPixel( x, y );
		}

		override public function dispose() : void
		{
			_square.removeEventListener( Event.TRIGGERED, onSquare );
			_palette.removeEventListener( TouchEvent.TOUCH, onPalette );
			_textInput.removeEventListener( "enter", onTextEnter );

			_palette.texture.dispose();
			_paletteContainer.removeFromParent( true );

			_square.removeFromParent( true );
			_square.upState.dispose();

			super.dispose();
		}


	}

}
