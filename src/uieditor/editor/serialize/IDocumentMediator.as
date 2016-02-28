
package uieditor.editor.serialize
{
	import flash.filesystem.File;
	import uieditor.editor.model.FileSetting;

	public interface IDocumentMediator
	{
		function read( obj : Object, file : File ) : void;
		function write() : Object;
		function createNew( param : FileSetting ) : void;
		function get defaultSaveFilename() : String;
	}
}
