package uieditor.editor.ui.property
{
	import flash.filesystem.File;
	import flash.net.FileFilter;

	import uieditor.editor.util.FileLoader;

	public class ChooseFilePropertyPopup extends AbstractPropertyEdit
	{
		public function ChooseFilePropertyPopup( owner : Object, target : Object, targetParam : Object, onComplete : Function )
		{
			super( owner, target, targetParam, onComplete );

			var typeFilters : Array = [];
			if ( _targetParam.extension )
			{
				var array : Array = _targetParam.extension;
				typeFilters.push( new FileFilter( array.join( ";" ), array.join( ";" )));
			}
			FileLoader.browse( function( file : File ) : void {
				if ( file != null )
					onComplete( file.url );
			}, function() : void
			{
				onComplete( null );
			}, typeFilters );
		}
	}
}
