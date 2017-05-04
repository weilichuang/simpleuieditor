package uieditor.editor
{
	import feathers.controls.ImageLoader;
	import feathers.controls.LayoutGroup;
	import feathers.controls.ScrollContainer;
	import feathers.controls.ScrollText;
	import feathers.controls.TextArea;
	import feathers.controls.TextInput;
	import feathers.layout.FlowLayout;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.TiledColumnsLayout;
	import feathers.layout.TiledRowsLayout;
	import feathers.layout.VerticalLayout;
	import feathers.layout.VerticalSpinnerLayout;
	import feathers.layout.WaterfallLayout;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.filters.BlurFilter;
	import starling.filters.DropShadowFilter;
	import starling.filters.GlowFilter;
	import starling.text.SimpleBitmapText;
	import starling.text.TextField;
	

	public class SupportedWidget
	{
		/*
		 * NOTE:
		 *
		 * Add to this linkers if you want your component to be officially supported by the editor, as well as adding meta data in editor_template.json
		 * If you want to register custom component, then you should call TemplateData.registerCustomComponent instead
		 *
		 */

		public static const LINKERS : Array = [
			Image,
			TextField,
			SimpleBitmapText,
			starling.display.Button,
			Quad,
			Sprite,
			
			ImageLoader,
			LayoutGroup,
			ScrollContainer,
			ScrollText,
			TextArea,
			TextInput,

			HorizontalLayout,
			VerticalLayout,
			FlowLayout,
			TiledRowsLayout,
			TiledColumnsLayout,
			VerticalSpinnerLayout,
			WaterfallLayout,
			
			BlurFilter,
			GlowFilter,
			DropShadowFilter
			];
	}
}
