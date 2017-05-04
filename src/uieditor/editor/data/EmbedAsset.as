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

		[Embed( source = "../../../embed/font/default_bitmap_font.png" )]
		private static const default_font_bitmap : Class;

		[Embed( source = "../../../embed/font/default_bitmap_font_16.fnt", mimeType = "application/octet-stream" )]
		private static const default_font_16_xml : Class;

		[Embed( source = "../../../embed/font/default_bitmap_font_16.png" )]
		private static const default_font_16_bitmap : Class;

		[Embed( source = "../../../embed/font/big_bitmap_font.fnt", mimeType = "application/octet-stream" )]
		private static const big_font_xml : Class;

		[Embed( source = "../../../embed/font/big_bitmap_font.png" )]
		private static const big_font_bitmap : Class;

		[Embed( source = "../../../embed/font/big_bitmap_font_24.fnt", mimeType = "application/octet-stream" )]
		private static const big_font_24_xml : Class;

		[Embed( source = "../../../embed/font/big_bitmap_font_24.png" )]
		private static const big_font_24_bitmap : Class;

		[Embed( source = "../../../embed/font/gold_font.fnt", mimeType = "application/octet-stream" )]
		private static const gold_font_xml : Class;

		[Embed( source = "../../../embed/font/gold_font.png" )]
		private static const gold_font_bitmap : Class;

		[Embed( source = "../../../embed/font/blue_score_font_32.fnt", mimeType = "application/octet-stream" )]
		private static const blue_score_font_32_xml : Class;

		[Embed( source = "../../../embed/font/blue_score_font_32.png" )]
		private static const blue_score_font_32_bitmap : Class;

		[Embed( source = "../../../embed/font/yellow_score_font_32.fnt", mimeType = "application/octet-stream" )]
		private static const yellow_score_font_32_xml : Class;

		[Embed( source = "../../../embed/font/yellow_score_font_32.png" )]
		private static const yellow_score_font_32_bitmap : Class;

		[Embed( source = "../../../embed/font/yellow_score_font_24.fnt", mimeType = "application/octet-stream" )]
		private static const yellow_score_font_24_xml : Class;

		[Embed( source = "../../../embed/font/yellow_score_font_24.png" )]
		private static const yellow_score_font_24_bitmap : Class;
		
		[Embed( source = "../../../embed/font/match_score_font_16.fnt", mimeType = "application/octet-stream" )]
		private static const match_score_font_16_xml : Class;
		
		[Embed( source = "../../../embed/font/match_score_font_16.png" )]
		private static const match_score_font_16_bitmap : Class;
		
		[Embed( source = "../../../embed/font/match_score_font_24.fnt", mimeType = "application/octet-stream" )]
		private static const match_score_font_24_xml : Class;
		
		[Embed( source = "../../../embed/font/match_score_font_24.png" )]
		private static const match_score_font_24_bitmap : Class;

		public static function initBitmapFonts() : void
		{
			addFonts([ "default_bitmap_font", "default_bitmap_font_bold" ], default_font_xml, default_font_bitmap );
			addFont( "default_bitmap_font_16", default_font_16_xml, default_font_16_bitmap );
			addFont( "big_bitmap_font", big_font_xml, big_font_bitmap );
			addFont( "big_bitmap_font_24", big_font_24_xml, big_font_24_bitmap );
			addFont( "gold_font", gold_font_xml, gold_font_bitmap );
			addFont( "blue_score_font_32", blue_score_font_32_xml, blue_score_font_32_bitmap );
			addFont( "yellow_score_font_32", yellow_score_font_32_xml, yellow_score_font_32_bitmap );
			addFont( "yellow_score_font_24", yellow_score_font_24_xml, yellow_score_font_24_bitmap );
			addFont( "match_score_font_16", match_score_font_16_xml, match_score_font_16_bitmap );
			addFont( "match_score_font_24", match_score_font_24_xml, match_score_font_24_bitmap );
		}

		private static function addFonts( names : Array, xmlClass : Class, bitmapClass : Class ) : void
		{
			var xml : XML = XML( new xmlClass());
			var bitmap : Bitmap = new bitmapClass();
			var bitmapFont : BitmapFont = new BitmapFont( starling.textures.Texture.fromBitmap( bitmap, false ), xml );
			for ( var i : int = 0; i < names.length; i++ )
			{
				TextField.registerCompositor( bitmapFont, names[ i ]);
			}
		}

		private static function addFont( name : String, xmlClass : Class, bitmapClass : Class ) : void
		{
			var xml : XML = XML( new xmlClass());
			var bitmap : Bitmap = new bitmapClass();
			var bitmapFont : BitmapFont = new BitmapFont( starling.textures.Texture.fromBitmap( bitmap, false ), xml );
			TextField.registerCompositor( bitmapFont, name );
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
