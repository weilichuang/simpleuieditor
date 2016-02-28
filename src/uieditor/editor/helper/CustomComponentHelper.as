package uieditor.editor.helper
{
	import uieditor.editor.data.TemplateData;

	import flash.display.Loader;
	import flash.filesystem.File;

	import starling.utils.AssetManager;

	public class CustomComponentHelper
	{
		public static const NAME : String = "EmbeddedComponents";

		public function CustomComponentHelper()
		{

		}

		public static function load( assetManager : AssetManager, workspace : File, onComplete : Function ) : void
		{
			LoadSwfHelper.load( NAME, assetManager, onLoaderComplete );

			function onLoaderComplete( loader : Loader ) : void
			{
				if ( loader )
				{
					var cls : Class = loader.contentLoaderInfo.applicationDomain.getDefinition( NAME ) as Class;
					var template : String = new cls[ "custom_component_template" ]().toString();
					TemplateData.load( template, workspace );
				}
				else
				{
					TemplateData.load( null, workspace );
				}

				onComplete();
			}


		}


	}
}
