package uieditor.editor.ui.property
{
	import flash.filesystem.File;
	import uieditor.editor.util.FileLoader;

	public class ChooseDirectoryPropertyPopup extends AbstractPropertyEdit
	{
		public function ChooseDirectoryPropertyPopup( owner : Object, target : Object, targetParam : Object, onComplete : Function )
		{
			super( owner, target, targetParam, onComplete );

			FileLoader.browseForDirectory( "选择工作空间:", function( file : File ) : void {
				if ( file != null )
					onComplete( file.url + "/" );
			})
		}
	}
}
