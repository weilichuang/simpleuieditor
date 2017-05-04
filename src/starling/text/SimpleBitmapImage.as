package starling.text
{
	import starling.core.starling_internal;
	import starling.display.Quad;
	import starling.textures.Texture;

	use namespace starling_internal;

	/**
	 * SimpleBitmapText专用Image,不用于渲染，只用来确认字符位置
	 */
	internal class SimpleBitmapImage extends Quad
	{
		public var textWidth : int;
		public var textHeight : int;
		public var textX : Number = 0;
		public var textY : Number = 0;
		public var textScale : Number = 1;
		public var textColor : uint = 0xffffff;
		public var textTexture:Texture;

		public function SimpleBitmapImage()
		{
			super( 100, 100 );
			readjustSize();
		}

		/**
		 * 不创建数据
		 */
		override protected function setupVertices() : void
		{

		}

		/** @private */
		override public function set texture( value : Texture ) : void
		{
		}

		override public function dispose() : void
		{
			super.dispose();
			this.textTexture = null;
		}
	}
}

