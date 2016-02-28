package uieditor.editor.localization
{
	import uieditor.engine.localization.DefaultLocalization;
	import uieditor.engine.localization.ILocalization;

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class DefaultLocalizationFileWrapper
	{
		private var _workspace : File;

		private var _localization : ILocalization;

		public function DefaultLocalizationFileWrapper( workspace : File )
		{
			_workspace = workspace;

			var template : File = _workspace.resolvePath( "localization/strings.json" );

			if ( template.exists )
			{
				var fs : FileStream = new FileStream();
				fs.open( template, FileMode.READ );
				var data : Object = JSON.parse( fs.readUTFBytes( fs.bytesAvailable ));
				fs.close();

				_localization = new DefaultLocalization( data );
			}
		}

		public function get localization() : ILocalization
		{
			return _localization;
		}

	}
}
