package uieditor.editor.data
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;

	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	//import starling.extensions.pixelmask.PixelMaskDisplayObject;

	public class EmbedAsset extends Sprite
	{
		[Embed( source = "custom_component_template.json", mimeType = "application/octet-stream" )]
		public static const custom_component_template : Class;

		//public static const linkers:Array = [PixelMaskDisplayObject];

		[Embed( source = "../../../embed/ui/ui.png" )]
		private static const UI_ATLAS_BITMAP : Class;

		[Embed( source = "../../../embed/ui/ui.xml", mimeType = "application/octet-stream" )]
		private static const UI_ATLAS_XML : Class;

		[Embed( source = "../../../embed/font/default_bitmap_font.fnt", mimeType = "application/octet-stream" )]
		private static const default_font_xml : Class;

		[Embed( source = "../../../embed/font/default_bitmap_font_0.png" )]
		private static const default_font_bitmap : Class;

		[Embed( source = "../../../embed/font/default_bitmap_font_bold.fnt", mimeType = "application/octet-stream" )]
		private static const default_font_bold_xml : Class;

		[Embed( source = "../../../embed/font/default_bitmap_font_bold_0.png" )]
		private static const default_font_bold_bitmap : Class;

		public static function initBitmapFonts() : void
		{
			var xml : XML = XML( new default_font_xml());
			var bitmap : Bitmap = new default_font_bitmap();
			var bitmapFont : BitmapFont = new BitmapFont( starling.textures.Texture.fromBitmap( bitmap ), xml );
			starling.text.TextField.registerBitmapFont( bitmapFont, "default_bitmap_font" );

			xml = XML( new default_font_bold_xml());
			bitmap = new default_font_bold_bitmap();
			bitmapFont = new BitmapFont( starling.textures.Texture.fromBitmap( bitmap, false ), xml );
			starling.text.TextField.registerBitmapFont( bitmapFont, "default_bitmap_font_bold" );
		}

		private static var _editorTextureAtlas : TextureAtlas;

		public static function getEditorTextureAtlas() : TextureAtlas
		{
			if ( _editorTextureAtlas != null )
				return _editorTextureAtlas;

			var atlasBitmapData : BitmapData = Bitmap( new EmbedAsset.UI_ATLAS_BITMAP()).bitmapData;
			var atlasTexture : Texture = Texture.fromBitmapData( atlasBitmapData, false, false, 1 );
			atlasBitmapData.dispose();

			_editorTextureAtlas = new TextureAtlas( atlasTexture, XML( new EmbedAsset.UI_ATLAS_XML()));

			return _editorTextureAtlas;
		}
	}
}
