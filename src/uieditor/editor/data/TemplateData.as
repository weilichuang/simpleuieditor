package uieditor.editor.data
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class TemplateData
	{
		public function TemplateData()
		{
		}

		public static var editor_template_string : String;

		public static var editor_template : Object;

		public static function load( customTemplate : String = null ) : void
		{
			editor_template_string = mergeCustomTemplate( customTemplate );
			parseToTemplate( editor_template_string );
		}

		public static function getSupportedComponent( tag : String = null ) : Array
		{
			var array : Array = [];

			for each ( var item : Object in editor_template.supported_components )
			{
				if ( tag == null || item.tag == tag )
				{
					array.push( item.cls );
				}
			}

			return array;
		}

		public static function getSupportedComponentAndIcon( tag : String = null ) : Array
		{
			var array : Array = [];

			for each ( var item : Object in editor_template.supported_components )
			{
				if ( tag == null || item.tag == tag )
				{
					array.push({ cls: item.cls, icon: item.icon });
				}
			}

			return array;
		}

		public static function loadExternalTemplate( fileUrl : String ) : void
		{
			var file : File = new File( fileUrl );
			if ( !file.exists )
				return;

			var fs2 : FileStream = new FileStream();
			fs2.open( file, FileMode.READ );
			var data : String = fs2.readUTFBytes( fs2.bytesAvailable );
			fs2.close();
			var template : Object = JSON.parse( data );

			//if file not exist or revision property not exists or external template older than the default template, then overwrite it
			//otherwise use the external template
			//if (!template.hasOwnProperty('revision') || !editor_template.hasOwnProperty('revision') || template.revision < editor_template.revision)
			//{
			//var fs:FileStream = new FileStream();
			//fs.open(file, FileMode.WRITE);
			//fs.writeUTFBytes(editor_template_string);
			//fs.close();
			//}
			//else
			//{
			parseToTemplate( data );
			//}
		}

		private static function mergeCustomTemplate( customTemplate : String ) : String
		{
			var file : File = new File( File.applicationDirectory.resolvePath( "assets/settings/editor_template.json" ).nativePath );

			var fs2 : FileStream = new FileStream();
			fs2.open( file, FileMode.READ );
			var data : String = fs2.readUTFBytes( fs2.bytesAvailable );
			fs2.close();

			if ( customTemplate == null )
			{
				return data;
			}
			else
			{
				customTemplate = stripCustomTemplate( customTemplate );
				var index : int = data.lastIndexOf( "}" ) - 1;
				return data.substring( 0, index ) + ",\n" + customTemplate + data.substring( index );
			}
		}

		private static function stripCustomTemplate( customTemplate : String ) : String
		{
			var start : int = customTemplate.indexOf( '{' ) + 1;
			var end : int = customTemplate.lastIndexOf( '}' );
			return customTemplate.substring( start, end );
		}

		private static function parseToTemplate( data : String ) : void
		{
			editor_template = JSON.parse( data );

			for each ( var item : Object in editor_template.custom_components )
			{
				editor_template.supported_components.push( item );
			}
		}


	}
}
