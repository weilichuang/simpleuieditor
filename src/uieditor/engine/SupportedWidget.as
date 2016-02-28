package uieditor.engine
{
	import feathers.controls.Alert;
	import feathers.controls.AutoComplete;
	import feathers.controls.Button;
	import feathers.controls.ButtonGroup;
	import feathers.controls.Callout;
	import feathers.controls.Check;
	import feathers.controls.DateTimeSpinner;
	import feathers.controls.Drawers;
	import feathers.controls.GroupedList;
	import feathers.controls.Header;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.NumericStepper;
	import feathers.controls.PageIndicator;
	import feathers.controls.Panel;
	import feathers.controls.PanelScreen;
	import feathers.controls.PickerList;
	import feathers.controls.ProgressBar;
	import feathers.controls.Radio;
	import feathers.controls.Screen;
	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	import feathers.controls.ScrollBar;
	import feathers.controls.ScrollContainer;
	import feathers.controls.ScrollScreen;
	import feathers.controls.ScrollText;
	import feathers.controls.Scroller;
	import feathers.controls.SimpleScrollBar;
	import feathers.controls.Slider;
	import feathers.controls.SpinnerList;
	import feathers.controls.StackScreenNavigator;
	import feathers.controls.StackScreenNavigatorItem;
	import feathers.controls.TabBar;
	import feathers.controls.TextArea;
	import feathers.controls.TextInput;
	import feathers.controls.ToggleButton;
	import feathers.controls.ToggleSwitch;
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
	import starling.display.Sprite3D;
	import starling.text.TextField;

	/**
	 * 确保这些类被引用
	 */
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
			starling.display.Button,
			Quad,
			List,
			Sprite,
			Sprite3D,

			Alert,
			AutoComplete,
			feathers.controls.Button,
			ButtonGroup,
			Callout,
			Check,
			DateTimeSpinner,
			Drawers,
			GroupedList,
			Header,
			ImageLoader,
			Label,
			LayoutGroup,
			List,
			NumericStepper,
			PageIndicator,
			Panel,
			PanelScreen,
			PickerList,
			ProgressBar,
			Radio,
			Screen,
			ScreenNavigator,
			ScreenNavigatorItem,
			ScrollBar,
			ScrollContainer,
			Scroller,
			ScrollScreen,
			ScrollText,
			SimpleScrollBar,
			Slider,
			SpinnerList,
			StackScreenNavigator,
			StackScreenNavigatorItem,
			TabBar,
			TextArea,
			TextInput,
			ToggleButton,
			ToggleSwitch,

			HorizontalLayout,
			VerticalLayout,
			FlowLayout,
			TiledRowsLayout,
			TiledColumnsLayout,
			VerticalSpinnerLayout,
			WaterfallLayout
			];
	}
}
