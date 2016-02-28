package uieditor.editor.ui
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import feathers.controls.LayoutGroup;
	
	import starling.display.Quad;
	import starling.display.Sprite;
	
	import uieditor.editor.UIEditorApp;
	import uieditor.editor.controller.DocumentEditor;
	import uieditor.editor.feathers.popup.InfoPopup;

	public class TestPanel extends InfoPopup
	{
		private var _documentManager : DocumentEditor;
		private var _forGame : Boolean;

		private var _container : Sprite;

		private var _background : Quad;

		public function TestPanel( documentMananger : DocumentEditor, forGame : Boolean = false )
		{
			_documentManager = documentMananger;
			_forGame = forGame;

			super();

			this.title = "预览";
			this.buttons = [ "确定" ];

			this.styleNameList.remove( "custom_panel" );
		}

		override protected function createContent( container : LayoutGroup ) : void
		{
			var canvasSize : Point = UIEditorApp.instance.documentEditor.canvasSize;

			_container = new Sprite();
			_container.width = canvasSize.x;
			_container.height = canvasSize.y;

			_background = new Quad( canvasSize.x, canvasSize.y, 0x0 );
			_background.alpha = 0.1;
			_container.addChild( _background );

			var sprite : Sprite = _documentManager.startTest( _forGame );
			_container.addChild( sprite );

			//_container.clipRect = new Rectangle( 0, 0, canvasSize.x, canvasSize.y );

			container.addChild( _container );
			container.validate();

			sprite.x = ( container.width - canvasSize.x ) * 0.5;
		}
	}
}
