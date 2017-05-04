package uieditor.editor.ui.tabpanel
{
	import flash.geom.Point;
	
	import feathers.controls.Button;
	import feathers.controls.LayoutGroup;
	import feathers.controls.PickerList;
	import feathers.data.ListCollection;
	
	import starling.display.DisplayObject;
	import starling.events.Event;
	
	import uieditor.editor.controller.IDocumentEditor;
	import uieditor.editor.feathers.FeathersUIUtil;
	import uieditor.editor.history.MovePivotOperation;
	import uieditor.engine.util.DisplayObjectUtil;

	public class PivotTool extends LayoutGroup
	{
		public static const LEFT : String = "left";
		public static const CENTER : String = "center";
		public static const RIGHT : String = "right";
		public static const TOP : String = "top";
		public static const BOTTOM : String = "bottom";


		private var _hAlighPickerList : PickerList;
		private var _vAlighPickerList : PickerList;
		private var _pivotButton : Button;

		private var _documentManager : IDocumentEditor;

		public function PivotTool()
		{
			super();
			initPivotTools();
		}
		
		public function setDocumentEditor(documentEditor:IDocumentEditor):void
		{
			_documentManager = documentEditor;
		}

		private function initPivotTools() : void
		{
			var layoutGroup : LayoutGroup = FeathersUIUtil.layoutGroupWithHorizontalLayout();

			_hAlighPickerList = new PickerList();
			_hAlighPickerList.dataProvider = new ListCollection([ LEFT, CENTER, RIGHT ]);
			_hAlighPickerList.selectedIndex = 1;

			_vAlighPickerList = new PickerList();
			_vAlighPickerList.dataProvider = new ListCollection([ TOP, CENTER, BOTTOM ]);
			_vAlighPickerList.selectedIndex = 1;

			_pivotButton = FeathersUIUtil.buttonWithLabel( "原点设置", onPivotButton );
			_pivotButton.toolTip = "原点设置";

			layoutGroup.addChild( _pivotButton );
			layoutGroup.addChild( _hAlighPickerList );
			layoutGroup.addChild( _vAlighPickerList );

			addChild( layoutGroup );
		}

		private function onPivotButton( event : Event ) : void
		{
			var obj : DisplayObject = _documentManager.selectedObject;

			if ( obj )
			{
				var oldValue : Point = new Point( obj.pivotX, obj.pivotY );

				DisplayObjectUtil.movePivotToAlign( obj, String( _hAlighPickerList.selectedItem ), String( _vAlighPickerList.selectedItem ));
				_documentManager.setChanged();

				var newValue : Point = new Point( obj.pivotX, obj.pivotY );
				_documentManager.historyManager.add( new MovePivotOperation( obj, oldValue, newValue ));
			}
		}
	}
}
