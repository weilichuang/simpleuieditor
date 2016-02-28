package uieditor.editor.history
{

	public interface IHistoryOperation
	{
		function get type() : String;
		function get timestamp() : Number;
		function get beforeValue() : Object;

		function canMergeWith( previousOperation : IHistoryOperation ) : Boolean;
		function merge( previousOperation : IHistoryOperation ) : void;


		function redo() : void;
		function undo() : void;

		function info() : String;

		function dispose() : void;
	}


}
