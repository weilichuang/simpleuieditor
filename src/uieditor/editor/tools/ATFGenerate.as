package uieditor.editor.tools
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;


	public class ATFGenerate extends EventDispatcher
	{
		public static const EVENT_GENERATE_COMPLETE : String = "EVENT_GENERATE_COMPLETE";
		public static const EVENT_GENERATE_ERROR : String = "EVENT_GENERATE_ERROR";

		private var info : GenerateInfo;

		private var loader : Loader;

		private var nativeProcess : NativeProcess;

		private var logHandle : Function;

		private var executableFile : File;

		private var file : File;

		public function ATFGenerate()
		{
		}

		public function generate( file : File, info : GenerateInfo, logHandle : Function = null ) : void
		{
			this.file = file;
			this.info = info;
			this.logHandle = logHandle;

			if(logHandle != null)
				logHandle( "----开始生成" + this.file.name + "的atf文件----" );

			createAtf( this.file);
		}

		private function createAtf( file : File ) : void
		{
			var sourceFilePath : String = file.nativePath;
			var exportFilePath : String = sourceFilePath.replace( this.info.sourceDir, this.info.exportDir );
			exportFilePath = exportFilePath.replace( "." + file.extension, "." + this.info.exportExt );

			if ( executableFile == null )
			{
				executableFile = File.applicationDirectory.resolvePath( "assets\\tools\\png2atf.exe" );
			}

			var params : Vector.<String> = new Vector.<String>();

			if ( info.compress )
			{
				params.push( "-c" );
			}
			
			if ( info.platform != "" )
			{
				params.push( info.platform );
			}
			
			params.push( "-q" );
			params.push( info.quality );
			
			if ( info.mips )
			{
				params.push( "-n" );
				params.push( "0," );
			}
			else
			{
				params.push( "-n" );
				params.push( "0,0" );
			}

			if ( info.compress )
			{
				params.push( "-r" );
			}

			params.push( "-i" );
			params.push( sourceFilePath );
			params.push( "-o" );
			params.push( exportFilePath );

			var workingDirectory : File = new File( this.info.sourceDir );
			var startUpInfo : NativeProcessStartupInfo = new NativeProcessStartupInfo();
			startUpInfo.workingDirectory = workingDirectory;
			startUpInfo.arguments = params;
			startUpInfo.executable = executableFile;

			if ( nativeProcess == null )
			{
				nativeProcess = new NativeProcess();
				nativeProcess.addEventListener( NativeProcessExitEvent.EXIT, onExit );
				nativeProcess.addEventListener( ProgressEvent.STANDARD_OUTPUT_DATA, onData );
				nativeProcess.addEventListener( ProgressEvent.STANDARD_ERROR_DATA, onError );
			}

			try
			{
				nativeProcess.start( startUpInfo );
			}
			catch ( error : Error )
			{
				if(logHandle != null)
					logHandle( error.message );
			}
		}

		private function onExit( e : NativeProcessExitEvent ) : void
		{
			dispatchEvent( new Event( EVENT_GENERATE_COMPLETE ));
		}

		private function onData( e : ProgressEvent ) : void
		{
			if(logHandle != null)
			{
				var log : String = nativeProcess.standardOutput.readUTFBytes( nativeProcess.standardOutput.bytesAvailable );
				log = log.replace( /^\.+/g, "" );
				log = log.replace( /$\.+/g, "" );
				log = log.replace( /\r\n/g, "" );
				if ( log == "" )
					return;
				logHandle( log );
			}
		}

		private function onError( e : ProgressEvent ) : void
		{
			if(logHandle != null)
			{
				var log : String = nativeProcess.standardOutput.readUTFBytes( nativeProcess.standardOutput.bytesAvailable );
				log = log.replace( /^\.+/g, "" );
				log = log.replace( /$\.+/g, "" );
				log = log.replace( /\r\n/g, "" );
				if ( log == "" )
					return;
				logHandle( log, 0xFF0000 );
			}
			
		}
		
		private function readBytes( file : File ) : ByteArray
		{
			var fs : FileStream = new FileStream();
			fs.open( file, FileMode.READ );

			var bytes : ByteArray = new ByteArray();
			fs.readBytes( bytes );
			fs.close();

			return bytes;
		}

		private function writeBytes( filePath : String, bytes : ByteArray ) : File
		{
			var newFile : File = new File( filePath );

			var fs : FileStream = new FileStream();
			fs.open( newFile, FileMode.WRITE );
			fs.writeBytes( bytes );
			fs.close();

			return newFile;
		}
	}
}
