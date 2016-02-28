package uieditor.editor.menu
{

	import flash.display.NativeMenu;

	public class MainMenu extends BaseMenu
	{
		public static const FILE : String = "文件";
		public static const EDIT : String = "编辑";
		public static const VIEW : String = "视图";
		public static const OPTION : String = "选项";
		public static const WORKSPACE : String = "工作空间";
		public static const LOCALIZATION : String = "语言";
		public static const HELP : String = "帮助";

		public static const NEW : String = "新建";
		public static const OPEN : String = "打开";
		public static const OPEN_RECENT : String = "打开最近";
		public static const SAVE : String = "保存";
		public static const SAVE_AS : String = "另存为";
		public static const TEST : String = "测试";
		public static const TEST_GAME : String = "游戏中测试";
		public static const QUIT : String = "退出";

		public static const UNDO : String = "撤销";
		public static const REDO : String = "重做";

		public static const CUT : String = "剪切 ";
		public static const COPY : String = "复制";
		public static const PASTE : String = "粘贴";
		public static const DUPLICATE : String = "复制并粘贴";
		public static const DESELECT : String = "不选";
		public static const DELETE : String = "删除";
		public static const MOVE_UP : String = "上移";
		public static const MOVE_DOWN : String = "下移";

		public static const ZOOM_IN : String = "缩小";
		public static const ZOOM_OUT : String = "放大";
		public static const RESET_ZOOM : String = "恢复";

		public static const SHOW_TEXT_BORDER : String = "显示文本边框";
		public static const SNAP_PIXEL : String = "网格对齐";
		public static const RESIZABLE_BOX : String = "显示缩放框";

		public static const SETTING : String = "设置";

		public static const ABOUT : String = "关于";

		public static const FILE_MENU : Array = [
			{ "label": NEW, "key": "n" },
			{ "label": OPEN, "key": "o" },
			{ "label": OPEN_RECENT, "menu": true },
			{ "label": SAVE, "key": "s" },
			{ "label": SAVE_AS, "key": "S" },
			{ "separator": true },
			{ "label": TEST, "key": "t" },
			{ "label": TEST_GAME, "key": "T" },
			{ "separator": true },
			{ "label": QUIT }
			]

		public static const EDIT_MENU : Array = [
			{ "label": UNDO, "key": "z", "disabled": true },
			{ "label": REDO, "key": "y", "disabled": true },
			{ "separator": true },
			{ "label": CUT, "key": "X" },
			{ "label": COPY, "key": "C" },
			{ "label": PASTE, "key": "V" },
			{ "label": DUPLICATE, "key": "D" },
			{ "label": DESELECT },
			{ "label": DELETE },
			{ "separator": true },
			{ "label": MOVE_UP, "key": "[" },
			{ "label": MOVE_DOWN, "key": "]" },
			{ "separator": true },
			{ "label": SETTING }
			]

		public static const VIEW_MENU : Array = [
			{ "label": ZOOM_IN, "key": "+" },
			{ "label": ZOOM_OUT, "key": "-" },
			{ "label": RESET_ZOOM, "key": "0" },
			]

		public static const OPTION_MENU : Array = [
			{ "label": SHOW_TEXT_BORDER },
			{ "label": SNAP_PIXEL },
			{ "label": RESIZABLE_BOX }
			]

		public static const HELP_MENU : Array = [
			{ "label": ABOUT }
			]

		private static var _instance : MainMenu;

		public function MainMenu() : void
		{
			super();

			if ( !_instance )
			{
				_instance = this;
			}
			else
			{
				throw new Error( "菜单栏已存在" );
			}
		}

		override protected function createRootMenu() : void
		{
			_rootMenu = new NativeMenu();
			createSubMenu( FILE_MENU, FILE );
			createSubMenu( EDIT_MENU, EDIT );
			createSubMenu( VIEW_MENU, VIEW );
			createSubMenu( OPTION_MENU, OPTION );
			createSubMenu( HELP_MENU, ABOUT );
		}

		public static function get instance() : MainMenu
		{
			return _instance;
		}
	}
}
