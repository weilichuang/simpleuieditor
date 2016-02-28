package uieditor.editor.controller
{
	import flash.geom.Rectangle;
	
	import starling.display.DisplayObject;
	
	import uieditor.editor.history.HistoryManager;
	import uieditor.engine.IUIBuilder;


	public interface IDocumentEditor
	{
		function get selectedObject() : DisplayObject;

		function setChanged() : void;

		function get historyManager() : HistoryManager;

		function selectObjectsByRect( rect : Rectangle ) : void;
		
		function get uiBuilder() : IUIBuilder;
	}
}
