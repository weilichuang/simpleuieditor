package uieditor.editor.history
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class OpenRecentManager
	{
		public static const MAX_RECORD : int = 20;

		public static const PATH : String = "assets/settings/recent_open.json";

		private var _recentFiles : Array = [];

		public function OpenRecentManager()
		{
			load();
		}

		public function open( url : String ) : void
		{
			var index : int = _recentFiles.indexOf( url );

			if ( index != -1 )
			{
				_recentFiles.splice( index, 1 );
			}

			_recentFiles.unshift( url );

			if ( _recentFiles.length > MAX_RECORD )
				_recentFiles.pop();

			save();
		}

		public function reset() : void
		{
			_recentFiles = [];

			save();
		}

		public function get recentFiles() : Array
		{
			return _recentFiles;
		}

		protected function load() : void
		{
			var file : File = new File( File.applicationDirectory.resolvePath( PATH ).nativePath );
			if ( file.exists )
			{
				var fs : FileStream = new FileStream();
				fs.open( file, FileMode.READ );
				_recentFiles = JSON.parse( fs.readUTFBytes( fs.bytesAvailable )) as Array;
				fs.close();
			}
		}

		protected function save() : void
		{
			var file : File = new File( File.applicationDirectory.resolvePath( PATH ).nativePath );
			var fs : FileStream = new FileStream();
			fs.open( file, FileMode.WRITE );
			fs.writeUTFBytes( JSON.stringify( _recentFiles ));
			fs.close();
		}
	}
}
