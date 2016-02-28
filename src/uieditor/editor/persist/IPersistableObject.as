package uieditor.editor.persist
{

	public interface IPersistableObject
	{
		function save() : Object;
		function load( data : Object ) : void;

		function persist() : void;
	}
}
