package uieditor.engine {
	import flash.utils.Dictionary;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;

	public interface IUIBuilder {
		/**
		 *
		 * @param data
		 * layout file data
		 *
		 * @param trimLeadingSpace
		 * whether to trim the leading space on the top level elements
		 * set to True if load from the game, set to False if load from the editor
		 *
		 * @return
		 * An object with
		 * {container:Sprite, params:Dictionary, data:data};
		 *
		 * object
		 * the sprite to create,
		 *
		 * params
		 * A Dictionary of the mapping of every UIElement to its layout data
		 *
		 * data
		 * the as3 plain object format of the layout
		 *
		 */
		function load( data : Object, libraryDict : Dictionary = null, trimLeadingSpace : Boolean = false ) : Object;


		function loadLibrary( data : Object ) : Dictionary;


		/**
		 *
		 * @param container
		 * Display object container needed to export to layout
		 *
		 *
		 * @param paramsDict
		 * A Dictionary of the mapping of every UIElement to its layout data
		 *
		 *
		 * @param setting
		 * project setting like canvas size, background info used by the editor
		 *
		 * @return
		 * layout file data
		 */
		function save( container : DisplayObjectContainer, paramsDict : Object, librarys : Dictionary, atlas : String, setting : Object = null ) : Object;

		function saveLibrary( container : DisplayObjectContainer, paramsDict : Object, librarys : Dictionary ) : Object;

		/**
		 *
		 * @param data
		 * data in as3 plain object format
		 *
		 * @return
		 * starling display object
		 */
		function createUIElement( data : Object ) : Object;


		/**
		 *
		 * @param param of the display object
		 * @return if the object is a container recognized by ui editor
		 */
		function isContainer( param : Object ) : Boolean;

		/**
		 *
		 * @param obj
		 * @param paramsDict
		 * @return
		 */
		function copy( obj : Array, paramsDict : Object ) : String;


		/**
		 *
		 * @param string
		 * @return
		 */
		function paste( string : String, libraryDic : Dictionary ) : Object;

		/**
		 *
		 * @param root of the DisplayObject needs to be localize
		 * @param A Dictionary of the mapping of every UIElement to its layout data
		 */
		function localizeTexts( root : DisplayObject, paramsDict : Dictionary ) : void;
	}
}
