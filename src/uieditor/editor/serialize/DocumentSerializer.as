
package uieditor.editor.serialize
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import starling.core.Starling;
	import starling.events.EventDispatcher;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	import uieditor.editor.UIEditorApp;
	import uieditor.editor.feathers.popup.MsgBox;
	import uieditor.editor.model.FileSetting;
	import uieditor.editor.tools.ATFGenerate;
	import uieditor.editor.tools.GenerateInfo;
	import uieditor.editor.ui.popup.NewFilePopup;
	import uieditor.editor.util.FileLoader;
	import uieditor.editor.util.FileUtil;

	public class DocumentSerializer extends EventDispatcher
	{
		public static const DEFUALT_EXT : String = "json";
		public static const COMPRESS_EXT : String = "swf";
		public static const CREATE : String = "create";
		public static const SAVE : String = "save";
		public static const OPEN : String = "open";
		public static const CLOSE : String = "close";
		public static const READ : String = "read";
		public static const READ_WITH_FILE : String = "readWithFile";

		public static const CHANGE : String = "change";

		private var _isDirty : Boolean = false;

		private var _file : File;

		private var _textureFile : File;
		private var _xmlFile : File;

		private var _currentDirectory : File;

		private var _pendingActions : Array = [];

		private var _mediator : IDocumentMediator;

		private var _pendingFile : File;

		public function DocumentSerializer( documentMediator : IDocumentMediator )
		{
			_mediator = documentMediator;
		}

		public function create() : void
		{
			if ( isDirty())
			{
				actionForOldFile();
				_pendingActions.push( CREATE );
			}
			else
			{
				doCreate();
			}
		}

		public function save() : Boolean
		{
			if ( isSelected())
			{
				doSave();
				continuePendingActions();
				return true;
			}
			else
			{
				chooseFileToSave();
				_pendingActions.push( SAVE );
				return false;
			}
		}

		public function saveAs() : void
		{
			chooseFileToSave();
			_pendingActions.push( SAVE );
		}


		private function selectFile() : void
		{
			var file : File = new File();
			file.addEventListener( Event.SELECT, onFileSelected );
			file.addEventListener( Event.CANCEL, onFileCanceled );
			file.browseForOpen( "请选择UI", [ new FileFilter( "*.json;*.swf", "*.json;*.swf" )]);
		}

		private function chooseFileToSave() : void
		{
			var file : File = new File();
			file.addEventListener( Event.SELECT, onFileSelected );
			file.addEventListener( Event.CANCEL, onFileCanceled );
			file.browseForSave( "保存文件" );
		}

		private function onFileSelected( event : Event ) : void
		{
			var file : File = event.target as File;
			file.removeEventListener( Event.SELECT, onFileSelected );
			file.removeEventListener( Event.CANCEL, onFileCanceled );

			_file = file;

			continuePendingActions();
		}

		private function onFileCanceled( event : Event ) : void
		{
			var file : File = event.target as File;
			file.removeEventListener( Event.SELECT, onFileSelected );
			file.removeEventListener( Event.CANCEL, onFileCanceled );

			_pendingActions = [];
			_pendingFile = null;
		}

		/**
		 * 同时保存2个文件,json是正常格式,swf是压缩格式
		 */
		private function doSave() : void
		{
			_isDirty = false;

			var data : Object = _mediator.write();

			if ( _file.extension == null )
			{
				_file = new File( _file.nativePath + "." + DEFUALT_EXT );
			}

			var compressJson : String;
			var fs : FileStream;
			var byteArray : ByteArray;
			if ( _file.extension == COMPRESS_EXT )
			{
				//使用最小化的json数据保存二进制，加快解析速度
				compressJson = JSON.stringify( JSON.parse( data.toString()));

				byteArray = new ByteArray();
				byteArray.writeUTFBytes( compressJson );
				byteArray.compress();
				byteArray.position = 0;

				fs = new FileStream();
				fs.open( _file, FileMode.WRITE );
				fs.writeBytes( byteArray, 0, byteArray.length );
				fs.close();

				var jsonFilePath : String = _file.nativePath.slice( 0, _file.nativePath.indexOf( _file.extension )) + DEFUALT_EXT;
				var jsonFile : File = new File( jsonFilePath );
				fs = new FileStream();
				fs.open( jsonFile, FileMode.WRITE );
				fs.writeUTFBytes( data.toString());
				fs.close();
			}
			else
			{
				fs = new FileStream();
				fs.open( _file, FileMode.WRITE );
				fs.writeUTFBytes( data.toString());
				fs.close();

				//使用最小化的json数据保存二进制，加快解析速度
				compressJson = JSON.stringify( JSON.parse( data.toString()));

				byteArray = new ByteArray();
				byteArray.writeUTFBytes( compressJson );
				byteArray.compress();
				byteArray.position = 0;
				var compressFilePath : String = _file.nativePath.slice( 0, _file.nativePath.indexOf( _file.extension )) + COMPRESS_EXT;
				var compressFile : File = new File( compressFilePath );
				fs = new FileStream();
				fs.open( compressFile, FileMode.WRITE );
				fs.writeBytes( byteArray, 0, byteArray.length );
				fs.close();
			}

			setChange( _file.url );
		}

		public function openWithFile( file : File ) : void
		{
			_pendingFile = file;
			if ( isDirty())
			{
				actionForOldFile();
				_pendingActions.push( READ_WITH_FILE );
			}
			else
			{
				readWithFile();
			}
		}

		public function open() : void
		{
			if ( isDirty())
			{
				actionForOldFile();
				_pendingActions.push( OPEN );
			}
			else
			{
				selectFile();
				_pendingActions.push( READ );
			}
		}

		public function read() : void
		{
			var data : String;

			var fs : FileStream = new FileStream();
			fs.open( _file, FileMode.READ );
			if ( _file.extension == COMPRESS_EXT )
			{
				var byteArray : ByteArray = new ByteArray();
				fs.readBytes( byteArray, 0, fs.bytesAvailable );

				byteArray.uncompress();
				byteArray.position = 0;
				data = byteArray.readUTFBytes( byteArray.bytesAvailable );
			}
			else
			{
				data = fs.readUTFBytes( fs.bytesAvailable );
			}
			fs.close();

			var json : Object = JSON.parse( data );

			//加载对应UI
			var direction : String = _file.nativePath.slice( 0, _file.nativePath.lastIndexOf( _file.name ));
			loadUIAsset( direction, json.atlas );

			_mediator.read( data, _file );

			_isDirty = false;

			setChange( _file.url );
		}

		public function readWithFile() : void
		{
			_file = _pendingFile;
			_pendingFile = null;
			read();
		}

		public function loadUIAsset( direction : String, fileName : String ) : void
		{
			_textureFile = new File( direction + "/" + fileName + ".jpeg" );
			if ( !_textureFile.exists )
			{
				MsgBox.show( "警告", "未找到" + _textureFile.nativePath );
				return;
			}

			_xmlFile = new File( direction + "/" + fileName + ".txt" );
			if ( !_xmlFile.exists )
			{
				_xmlFile = new File( direction + "/" + fileName + ".xml" );

				if ( !_xmlFile )
				{
					MsgBox.show( "警告", "未找到" + _xmlFile.nativePath );
					return;
				}
			}

			UIEditorApp.instance.assetManager.purge();

			UIEditorApp.instance.documentEditor.setAtlas( fileName );

			var texture : Texture = Texture.fromAtfData( FileLoader.getByteArray( _textureFile ), 1, false );
			var xml : XML = new XML( FileLoader.getString( _xmlFile ));

			var textureAtlas : TextureAtlas = new TextureAtlas( texture, xml );

			UIEditorApp.instance.assetManager.addTextureAtlas( fileName, textureAtlas );
			UIEditorApp.instance.dispatchEventWith( "assetChange" );
		}

		public function close() : void
		{
			if ( isDirty())
			{
				actionForOldFile();
				_pendingActions.push( CLOSE );
			}
			else
			{
				doClose();
			}
		}

		private function doClose() : void
		{
			Starling.current.nativeStage.nativeWindow.close();
		}

		public function discard() : void
		{
			_isDirty = false;
		}

		public function isDirty() : Boolean
		{
			return _isDirty;
		}

		public function isSelected() : Boolean
		{
			return _file != null;
		}

		public function getFile() : File
		{
			return _file;
		}

		private static var saveMsgBox : MsgBox;

		private function actionForOldFile() : void
		{
			if ( saveMsgBox != null )
				return;

			saveMsgBox = MsgBox.show( "提示", "当前文件还未保存，是否保存？", [ "保存", "放弃", "取消" ]);
			saveMsgBox.addEventListener( Event.COMPLETE, onPopup );
		}

		private function onPopup( e : * ) : void
		{
			var index : int = e.data;
			switch ( index )
			{
				case 0:
					if ( save())
						continuePendingActions();
					break;
				case 1:
					discard();
					continuePendingActions();
					break;
				case 2:
					_pendingActions = [];
					break;
			}
			saveMsgBox = null;
		}

		private function doCreate() : void
		{
			NewFilePopup.show( function( param : FileSetting ) : void
			{
				checkTextureAtlas( param );
			});
		}

		private function createNewFrom( param : FileSetting ) : void
		{
			var file : File = new File( param.atlasFile );
			var direction : String = file.nativePath.slice( 0, file.nativePath.lastIndexOf( file.name ));
			loadUIAsset( direction, file.name.slice( 0, file.name.indexOf( "." )));

			_file = null;
			_mediator.createNew( param );
			_isDirty = false;
		}

		private var _pngFile : File;
		private var _curFileSetting : FileSetting;
		private var _atfGenerate : ATFGenerate;
		private var _atfMsgBox : MsgBox;

		private function checkTextureAtlas( fileSetting : FileSetting ) : void
		{
			_curFileSetting = fileSetting;
			var file : File = new File( fileSetting.atlasFile );
			if ( file.extension == "png" )
			{
				_pngFile = file;

				var jpegFile : File = FileUtil.getFile( _pngFile, "jpeg" );
				var swfFile : File = FileUtil.getFile( _pngFile, "swf" );

				_curFileSetting.atlasFile = jpegFile.url;

				if ( !jpegFile.exists )
				{
					_atfGenerate = new ATFGenerate();

					var info : GenerateInfo = new GenerateInfo();
					info.compress = true
					info.sourceDir = info.exportDir = FileUtil.getDirection( jpegFile );
					_atfGenerate.addEventListener( ATFGenerate.EVENT_GENERATE_COMPLETE, onGenerateComplete );
					_atfGenerate.generate( _pngFile, info );

				}
				else if ( !swfFile.exists )
				{
					onGenerateComplete( null );
				}
				else
				{
					createNewFrom( _curFileSetting );
				}
			}
			else
			{
				if ( !FileUtil.getFile( file, "swf" ).exists )
				{
					onGenerateComplete( null );
				}
				else
				{
					createNewFrom( _curFileSetting );
				}
			}
		}

		protected function onGenerateComplete( event : flash.events.Event ) : void
		{
			if ( _atfGenerate != null )
			{
				_atfGenerate.removeEventListener( ATFGenerate.EVENT_GENERATE_COMPLETE, onGenerateComplete );
				_atfGenerate = null;
			}
			var xmlFile : File = FileUtil.getFile( _pngFile, "xml" );
			var jpegFile : File = FileUtil.getFile( _pngFile, "jpeg" );
			createTextureAtlasSwf( xmlFile, jpegFile );
		}

		private function createTextureAtlasSwf( xmlFile : File, textureFile : File ) : void
		{
			var isJson : Boolean = xmlFile.extension == "json";

			var fs : FileStream = new FileStream();
			fs.open( xmlFile, FileMode.READ );
			var data : String = fs.readUTFBytes( fs.bytesAvailable );
			fs.close();

			var textureByteArray : ByteArray = new ByteArray();
			fs = new FileStream();
			fs.open( textureFile, FileMode.READ );
			fs.readBytes( textureByteArray, 0, fs.bytesAvailable );
			fs.close();

			var byteArray : ByteArray = new ByteArray();
			byteArray.endian = Endian.LITTLE_ENDIAN;
			byteArray.writeInt( 1 ); //version
			byteArray.writeInt( isJson ? 1 : 0 ); //1--json,0--xml

			var size : int = data.length;
			byteArray.writeInt( size );
			byteArray.writeUTFBytes( data );

			textureByteArray.position = 0;
			byteArray.writeBytes( textureByteArray, 0, textureByteArray.bytesAvailable );

			var newFile : File = new File( xmlFile.nativePath.slice( 0, xmlFile.nativePath.lastIndexOf( xmlFile.extension )) + "swf" );

			byteArray.position = 0;
			byteArray.compress();
			fs = new FileStream();
			fs.open( newFile, FileMode.WRITE );
			fs.writeBytes( byteArray, 0, byteArray.length );
			fs.close();

			createNewFrom( _curFileSetting );
		}

		private function continuePendingActions() : void
		{
			if ( _pendingActions.length )
			{
				var action : String = _pendingActions.pop();

				if ( hasOwnProperty( action ))
				{
					this[ action ]();
				}
				else
				{
					doCustomAction( action );
				}
			}
		}

		public function markDirty( value : Boolean ) : void
		{
			_isDirty = value;
		}

		public function customAction( customEventType : String ) : void
		{
			if ( isDirty())
			{
				actionForOldFile();
				_pendingActions.push( customEventType );
			}
			else
			{
				doCustomAction( customEventType );
			}
		}

		private function doCustomAction( customEventType : String ) : void
		{
			dispatchEventWith( customEventType );
		}

		private function setChange( url : String ) : void
		{
			dispatchEventWith( CHANGE, false, url );
		}

	}
}
