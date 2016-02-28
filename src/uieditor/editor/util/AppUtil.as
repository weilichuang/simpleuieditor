package uieditor.editor.util
{
	import flash.desktop.NativeApplication;
	import adobe.utils.ProductManager;

	/**
	 * ...
	 * @author
	 */
	public class AppUtil
	{

		public static function reboot() : void
		{
			var app : NativeApplication = NativeApplication.nativeApplication;

			var mgr : ProductManager =
				new ProductManager( "airappinstaller" );

			mgr.launch( "-launch " +
				app.applicationID + " " +
				app.publisherID );

			app.exit();
		}

	}

}
