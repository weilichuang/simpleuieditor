package uieditor.editor.util
{
	import flash.events.Event;
	import flash.filesystem.File;

	public class FileUtil
	{
		public static function getDirection( file : File ) : String
		{
			return file.nativePath.slice( 0, file.nativePath.lastIndexOf( file.name ));
		}
		
		public static function inSameDirection(fileA:File,fileB:File):Boolean
		{
			return getDirection(fileA) == getDirection(fileB);
		}

		/**
		 * 拷贝文件到指定目录下
		 */
		public static function copyFileTo( file : File, direction : String ) : File
		{
			var newFile : File = new File( direction + file.name );
			file.copyTo( newFile, true );
			return newFile;
		}

		/**
		 * 获取修改后缀名的文件
		 */
		public static function getFile( file : File, newExtension : String ) : File
		{
			return new File( file.nativePath.slice( 0, file.nativePath.lastIndexOf( file.extension )) + newExtension );
		}

		public static function browseForSave( title : String, extension : String, selectHandle : Function, cancelHandle : Function = null ) : void
		{
			var file : File = new File();

			var selectFunc : Function = function( event : Event ) : void
			{
				var file : File = event.target as File;
				file.removeEventListener( Event.SELECT, selectFunc );
				file.removeEventListener( Event.CANCEL, cancelFunc );

				if ( file.extension == null || file.extension == "" )
				{
					file = new File( file.nativePath + "." + extension );
				}
				else if ( file.extension != extension )
				{
					file = getFile( file, extension );
				}

				if ( selectHandle != null )
				{
					selectHandle( file );
				}
			};

			var cancelFunc : Function = function( event : Event ) : void
			{
				var file : File = event.target as File;
				file.removeEventListener( Event.SELECT, selectFunc );
				file.removeEventListener( Event.CANCEL, cancelFunc );

				if ( cancelHandle != null )
				{
					cancelHandle( file );
				}
			}

			file.addEventListener( Event.SELECT, selectFunc );
			file.addEventListener( Event.CANCEL, cancelFunc );
			file.browseForSave( title );
		}

		public static function browseForOpen( title : String, typeFilter : Array, selectHandle : Function, cancelHandle : Function = null ) : void
		{
			var file : File = new File();

			var selectFunc : Function = function( event : Event ) : void
			{
				var file : File = event.target as File;
				file.removeEventListener( Event.SELECT, selectFunc );
				file.removeEventListener( Event.CANCEL, cancelFunc );

				if ( selectHandle != null )
				{
					selectHandle( file );
				}
			};

			var cancelFunc : Function = function( event : Event ) : void
			{
				var file : File = event.target as File;
				file.removeEventListener( Event.SELECT, selectFunc );
				file.removeEventListener( Event.CANCEL, cancelFunc );

				if ( cancelHandle != null )
				{
					cancelHandle( file );
				}
			}

			file.addEventListener( Event.SELECT, selectFunc );
			file.addEventListener( Event.CANCEL, cancelFunc );
			file.browseForOpen( title, typeFilter );
		}
		
		
		public static function browseForDirectory( title : String, selectHandle : Function, cancelHandle : Function = null ) : void
		{
			var file : File = new File();
			
			var selectFunc : Function = function( event : Event ) : void
			{
				var file : File = event.target as File;
				file.removeEventListener( Event.SELECT, selectFunc );
				file.removeEventListener( Event.CANCEL, cancelFunc );
				
				if ( selectHandle != null )
				{
					selectHandle( file );
				}
			};
			
			var cancelFunc : Function = function( event : Event ) : void
			{
				var file : File = event.target as File;
				file.removeEventListener( Event.SELECT, selectFunc );
				file.removeEventListener( Event.CANCEL, cancelFunc );
				
				if ( cancelHandle != null )
				{
					cancelHandle( file );
				}
			}
			
			file.addEventListener( Event.SELECT, selectFunc );
			file.addEventListener( Event.CANCEL, cancelFunc );
			file.browseForDirectory(title);
		}
	}
}
