/**
 * Created by redge on 16.12.15.
 */
package starling.text
{
    import flash.display3D.Context3DTextureFormat;

    import starling.core.Starling;

    /** The TextOptions class contains data that describes how the letters of a text should
     *  be assembled on text composition.
     *
     *  <p>Note that not all properties are supported by all text compositors.</p>
     */
    public class TextOptions
    {
		/** Indicates if the text should be wrapped at word boundaries if it does not fit into
		 *  the TextField otherwise. @default true */
		public var wordWrap:Boolean;
		
		/** Indicates whether the font size is automatically reduced if the complete text does
		 *  not fit into the TextField. @default false */
		public var autoScale:Boolean;
		
		/** Specifies the type of auto-sizing set on the TextField. Custom text compositors may
		 *  take this into account, though the basic implementation (done by the TextField itself)
		 *  is often sufficient: it passes a very big size to the <code>fillMeshBatch</code>
		 *  method and then trims the result to the actually used area. @default none */
		public var autoSize:String;
		
		/** Indicates if text should be interpreted as HTML code. For a description
		 *  of the supported HTML subset, refer to the classic Flash 'TextField' documentation.
		 *  Beware: Only supported for TrueType fonts. @default false */
		public var isHtmlText:Boolean;
		
		/** The scale factor of any textures that are created during text composition.
		 *  @default Starling.contentScaleFactor */
		public var textureScale:Number;
		
		/** The Context3DTextureFormat of any textures that are created during text composition.
		 *  @default Context3DTextureFormat.BGRA_PACKED */
		public var textureFormat:String;

        /** Creates a new TextOptions instance with the given properties. */
        public function TextOptions(wordWrap:Boolean=true, autoScale:Boolean=false)
        {
            this.wordWrap = wordWrap;
			this.autoScale = autoScale;
			this.autoSize = TextFieldAutoSize.NONE;
			this.textureScale = Starling.contentScaleFactor;
			this.textureFormat = Context3DTextureFormat.BGRA;
			this.isHtmlText = false;
        }

        /** Copies all properties from another TextOptions instance. */
        public function copyFrom(options:TextOptions):void
        {
			this.wordWrap = options.wordWrap;
			this.autoScale = options.autoScale;
			this.autoSize = options.autoSize;
			this.isHtmlText = options.isHtmlText;
			this.textureScale = options.textureScale;
			this.textureFormat = options.textureFormat;
        }

        /** Creates a clone of this instance. */
        public function clone():TextOptions
        {
            var clone:TextOptions = new TextOptions();
            clone.copyFrom(this);
            return clone;
        }
    }
}
