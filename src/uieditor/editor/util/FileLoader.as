package uieditor.editor.util
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileReference;
	import flash.utils.ByteArray;

	public class FileLoader
	{
		public function FileLoader()
		{

		}

		public static function getByteArray( file : File ) : ByteArray
		{
			var fs : FileStream = new FileStream();
			fs.open( file, FileMode.READ );
			var byteArray : ByteArray = new ByteArray();
			fs.readBytes( byteArray, 0, fs.bytesAvailable );
			fs.close();
			return byteArray;
		}

		public static function getString( file : File ) : String
		{
			var fs : FileStream = new FileStream();
			fs.open( file, FileMode.READ );
			var result : String = fs.readUTFBytes( fs.bytesAvailable );
			fs.close();
			return result;
		}

		public static function load( onComplete : Function ) : void
		{
			var name : String;

			var file : FileReference = new FileReference();


			file.addEventListener( Event.SELECT, onFileSelected );
			file.addEventListener( Event.CANCEL, onFileCanceled );
			file.browse();


			function onFileSelected( event : Event ) : void
			{
				name = file[ "nativePath" ];
				file.removeEventListener( Event.SELECT, onFileSelected );
				file.removeEventListener( Event.CANCEL, onFileCanceled );

				file.addEventListener( Event.COMPLETE, onLoadComplete );
				file.load();
			}

			function onFileCanceled( event : Event ) : void
			{
				file.removeEventListener( Event.SELECT, onFileSelected );
				file.removeEventListener( Event.CANCEL, onFileCanceled );

			}

			function onLoadComplete( event : Event ) : void
			{
				file.removeEventListener( Event.COMPLETE, onLoadComplete );

				if ( isImage( name ))
				{
					var loader : Loader = new Loader();
					loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onLoadTextureComplete );
					loader.loadBytes( file.data );
				}
				else
				{
					if ( onComplete != null )
						onComplete( file.data, name );
				}
			}

			function onLoadTextureComplete( event : Event ) : void
			{
				var loaderInfo : LoaderInfo = event.target as LoaderInfo;
				loaderInfo.removeEventListener( Event.COMPLETE, onLoadTextureComplete );

				if ( onComplete != null )
					onComplete( loaderInfo.content, name );
			}
		}

		private static function isImage( name : String ) : Boolean
		{
			var n : String = name.toLowerCase();
			return ( n.indexOf( ".png" ) >= 0 || n.indexOf( ".jpg" ) >= 0 || n.indexOf( "atf" ) >= 0 );
		}

		public static function save( data : Object, fileName : String, onComplete : Function ) : void
		{
			var file : FileReference = new FileReference();
			file.addEventListener( Event.COMPLETE, onSaveComplete );
			file.save( JSON.stringify( data ), fileName );

			function onSaveComplete( event : * ) : void
			{
				file.removeEventListener( Event.COMPLETE, onComplete );

				if ( onComplete != null )
					onComplete();
			}
		}

		public static function browse( onComplete : Function = null, onCancel : Function = null, typeFilter : Array = null ) : void
		{
			var file : File = new File();

			file.addEventListener( Event.SELECT, onFileSelected );
			file.addEventListener( Event.CANCEL, onFileCanceled );
			file.browseForOpen( "请选择文件", typeFilter );

			function onFileSelected( event : Event ) : void
			{
				file.removeEventListener( Event.SELECT, onFileSelected );
				file.removeEventListener( Event.CANCEL, onFileCanceled );

				if ( onComplete != null )
					onComplete( file );
			}

			function onFileCanceled( event : Event ) : void
			{
				file.removeEventListener( Event.SELECT, onFileSelected );
				file.removeEventListener( Event.CANCEL, onFileCanceled );
				
				if ( onCancel != null )
					onCancel( );
			}
		}

		public static function browseForDirectory( title : String, onComplete : Function = null ) : void
		{
			var file : File = File.documentsDirectory;

			file.addEventListener( Event.SELECT, onSelect );
			file.browseForDirectory( title );

			function onSelect( event : Event ) : void
			{
				file.removeEventListener( Event.SELECT, onSelect );

				if ( onComplete != null )
					onComplete( file );
			}

		}




	}
}
