package starling.text
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import starling.core.Starling;
	import starling.core.starling_internal;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	import starling.rendering.Painter;
	import starling.utils.RectangleUtil;

	use namespace starling_internal;

	/**
	 * 类似于TextField，但只支持位图字体，
	 * <p>不支持换行,不支持html,需要设置最大长度,最多支持50个字符</p>
	 * 用于固定长度的文本，文本不用每次修改后重新上传VertexBuffer了，只需要传递Uniform即可
	 */
	public class SimpleBitmapText extends DisplayObjectContainer implements ITextField
	{
		// helper objects
		private static var sMatrix : Matrix = new Matrix();

		public static var sDefaultBitmapFont : BitmapFont;

		public var group : SimpleBitmapTextGroup;

		private var _text : String;
		private var _options : TextOptions;
		private var _format : TextFormat;
		private var _textBounds : Rectangle;
		private var _hitArea : Rectangle;
		private var _compositor : BitmapFont;
		private var _requiresRecomposition : Boolean;

		starling_internal var _textBatch : SimpleTextBatch;
		private var _style : SimpleTextStyle;

		private var _maxChar : int;

		private var _helperFormat : TextFormat = new TextFormat();

		public function SimpleBitmapText( width : int, height : int, maxCharCount : int = 10, text : String = "", format : TextFormat = null )
		{
			_hitArea = new Rectangle( 0, 0, width, height );
			_maxChar = maxCharCount;

			this.text = text;

			this.touchGroup = true;

			_options = new TextOptions();
			_options.wordWrap = false;
			_options.isHtmlText = false;
			_options.autoScale = false;

			_format = format ? format.clone() : new TextFormat( "default_bitmap_font", 13, 0xffffff );
			_format.addEventListener( Event.CHANGE, setRequiresRecomposition );

			_style = new SimpleTextStyle();

			_compositor = getBitmapFont( _format.font );

			_textBatch = new SimpleTextBatch( _maxChar, _style );
			_textBatch.touchable = false;
			_textBatch.pixelSnapping = false;
			_textBatch.texture = _compositor.texture;
			addChild( _textBatch );

			setRequiresRecomposition();
		}

		public function isRequiresRecomposition() : Boolean
		{
			return _requiresRecomposition;
		}

		public function set maxChar( value : int ) : void
		{
			if ( _maxChar != value )
			{
				_maxChar = value;
				_textBatch.setMaxChar( _maxChar );

				if ( _text.length > _maxChar )
				{
					_text = _text.slice( 0, _maxChar );
				}
				setRequiresRecomposition();
			}
		}

		public function get maxChar() : int
		{
			return _maxChar;
		}

		/**
		 * 寻找位图字体，找不到时使用默认的mini字体
		 */
		private function getBitmapFont( font : String ) : BitmapFont
		{
			var bitmapFont : BitmapFont = TextField.getBitmapFont( _format.font );
			if ( bitmapFont == null )
			{
				if ( sDefaultBitmapFont == null )
				{
					sDefaultBitmapFont = new BitmapFont();
					TextField.registerCompositor( sDefaultBitmapFont, BitmapFont.MINI );
				}
				bitmapFont = sDefaultBitmapFont;
			}
			return bitmapFont;
		}

		/** Disposes the underlying texture data. */
		public override function dispose() : void
		{
			if ( _format != null )
			{
				_format.removeEventListener( Event.CHANGE, setRequiresRecomposition );
				_format = null;
			}

			if ( _compositor != null )
			{
				_compositor.clearMeshBatch( _textBatch );
				_compositor = null;
			}

			_style = null;

			if ( _textBatch )
			{
				_textBatch.dispose();
				_textBatch = null;
			}

			_compositor = null;

			this.group = null;

			super.dispose();
		}

		/** @inheritDoc */
		public override function render( painter : Painter ) : void
		{
			//如果有group则不渲染，渲染工作留给group进行
			if ( group == null )
			{
				if ( _requiresRecomposition )
					recompose();

				super.render( painter );
			}
		}

		/** Forces the text contents to be composed right away.
		 *  Normally, it will only do so lazily, i.e. before being rendered. */
		internal function recompose() : void
		{
			if ( _requiresRecomposition )
			{
				if ( _compositor )
					_compositor.clearMeshBatch( _textBatch );

				_compositor = getBitmapFont( _format.font );

				updateText();

				_requiresRecomposition = false;
			}
		}

		// font and border rendering

		private function updateText() : void
		{
			var width : Number = _hitArea.width;
			var height : Number = _hitArea.height;
			var format : TextFormat = _helperFormat;

			// By working on a copy of the TextFormat, we make sure that modifications done
			// within the 'fillMeshBatch' method do not cause any side effects.
			//
			// (We cannot use a static variable, because that might lead to problems when
			//  recreating textures after a context loss.)

			format.copyFrom( _format );
			_textBatch.setColor( format.color, this.alpha );
			_textBatch.x = _textBatch.y = 0;
			_options.textureScale = Starling.contentScaleFactor;
			_options.textureFormat = TextField.defaultTextureFormat;
			_compositor.fillMeshBatch( _textBatch, width, height, _text, format, _options, true, _maxChar );

			// hit area doesn't change, and text bounds can be created on demand
			_textBounds = null;
		}

		/** Forces the text to be recomposed before rendering it in the upcoming frame. */
		public function setRequiresRecomposition() : void
		{
			_requiresRecomposition = true;
			setRequiresRedraw();
		}

		// properties
		/** Returns the bounds of the text within the text field. */
		public function get textBounds() : Rectangle
		{
			if ( _requiresRecomposition )
				recompose();
			if ( _textBounds == null )
				_textBounds = _textBatch.getBounds( this );
			return _textBounds.clone();
		}

		/** @inheritDoc */
		public override function getBounds( targetSpace : DisplayObject, out : Rectangle = null ) : Rectangle
		{
			if ( _requiresRecomposition )
				recompose();
			getTransformationMatrix( targetSpace, sMatrix );
			return RectangleUtil.getBounds( _hitArea, sMatrix, out );
		}

		/** @inheritDoc */
		public override function hitTest( localPoint : Point ) : DisplayObject
		{
			if ( !visible || !touchable || !hitTestMask( localPoint ))
				return null;
			else if ( _hitArea.containsPoint( localPoint ))
				return this;
			else
				return null;
		}

		/** @inheritDoc */
		public override function set width( value : Number ) : void
		{
			// different to ordinary display objects, changing the size of the text field should 
			// not change the scaling, but make the texture bigger/smaller, while the size 
			// of the text/font stays the same (this applies to the height, as well).

			_hitArea.width = value / ( scaleX || 1.0 );
			setRequiresRecomposition();
		}

		/** @inheritDoc */
		public override function set height( value : Number ) : void
		{
			_hitArea.height = value / ( scaleY || 1.0 );
			setRequiresRecomposition();
		}

		/** The displayed text. */
		public function get text() : String
		{
			return _text;
		}

		public function set text( value : String ) : void
		{
			if ( value == null )
				value = "";
			if ( _text != value )
			{
				_text = value;
				if ( _text.length > _maxChar )
					_text = _text.slice( 0, _maxChar );

				setRequiresRecomposition();
			}
		}

		override public function set alpha( value : Number ) : void
		{
			super.alpha = value;

			_textBatch.setColor( _format.color, this.alpha );
		}

		/** The format describes how the text will be rendered, describing the font name and size,
		 *  color, alignment, etc.
		 *
		 *  <p>Note that you can edit the font properties directly; there's no need to reassign
		 *  the format for the changes to show up.</p>
		 *
		 *  <listing>
		 *  var textField:TextField = new TextField(100, 30, "Hello Starling");
		 *  textField.format.font = "Arial";
		 *  textField.format.color = Color.RED;</listing>
		 *
		 *  @default Verdana, 12 pt, black, centered
		 */
		public function get format() : TextFormat
		{
			return _format;
		}

		public function set format( value : TextFormat ) : void
		{
			if ( value == null )
				throw new ArgumentError( "format cannot be null" );
			_format.copyFrom( value );
		}
	}
}
