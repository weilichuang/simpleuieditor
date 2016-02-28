package uieditor.engine {
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.textures.Texture;
	
	import uieditor.engine.format.DefaultDataFormatter;
	import uieditor.engine.format.IDataFormatter;
	import uieditor.engine.format.StableJSONEncoder;
	import uieditor.engine.localization.ILocalization;
	import uieditor.engine.util.ObjectLocaterUtil;
	import uieditor.engine.util.ParamUtil;
	import uieditor.engine.util.SaveUtil;

	public class UIBuilder implements IUIBuilder {
		public static const VERSION : String = "1.1";

		private var _assetMediator : IAssetMediator;

		private var _dataFormatter : IDataFormatter;

		private var _factory : UIElementFactory;

		private var _forEditor : Boolean;

		private var _template : Object;

		private var _localization : ILocalization;

		public function UIBuilder( assetMediator : IAssetMediator, forEditor : Boolean = false, template : Object = null, localization : ILocalization = null ) {
			_assetMediator = assetMediator;
			_dataFormatter = new DefaultDataFormatter();
			_factory = new UIElementFactory( _assetMediator, forEditor );
			_forEditor = forEditor;
			_template = template;
			_localization = localization;
			SupportedWidget;
		}

		public function loadLibrary( data : Object ) : Dictionary {
			if ( _dataFormatter )
				data = _dataFormatter.read( data );

			var libraryDict : Dictionary = new Dictionary();
			if ( data.library != null ) {
				var library : Array
				if ( !( data.library is Array )) {
					library = [];
				} else {
					library = data.library;
				}

				for ( var i : int = 0; i < library.length; i++ ) {
					libraryDict[ library[ i ].params.name ] = library[ i ];
				}
			}
			return libraryDict;
		}

		public function load( data : Object, libraryDict : Dictionary = null, trimLeadingSpace : Boolean = false ) : Object {
			if ( _dataFormatter )
				data = _dataFormatter.read( data );

			//没有指定库，则从当前文件中创建库
			if ( libraryDict == null ) {
				libraryDict = loadLibrary( data );
			}

			var paramsDict : Dictionary = new Dictionary();

			var root : DisplayObject = loadTree( data.layout, _factory, paramsDict, libraryDict );

			if ( trimLeadingSpace && root is DisplayObjectContainer )
				doTrimLeadingSpace( root as DisplayObjectContainer );

			localizeTexts( root, paramsDict );

			return { object: root, params: paramsDict, data: data };
		}

		private function loadTree( data : Object, factory : UIElementFactory, paramsDict : Dictionary, libraryDict : Dictionary ) : DisplayObject {

			var isLibrary : Boolean = false;
			if ( data.linkage ) {
				isLibrary = true;
				var libraryItem : Object = ParamUtil.cloneObject( libraryDict[ data.linkage ]);

				data.children = libraryItem.children;
				data.cls = libraryItem.cls;
				if ( libraryItem.customParams ) {
					data.customParams = libraryItem.customParams;
				}

				for ( var key : String in libraryItem.params ) {
					if ( !data.params[ key ])
						data.params[ key ] = libraryItem.params[ key ];
				}
			}

			var obj : DisplayObject = factory.create( data ) as DisplayObject;

			if ( isLibrary ) {
				obj.customData = { isLibrary:true,linkage:data.linkage };
			}

			paramsDict[ obj ] = data;

			var container : DisplayObjectContainer = obj as DisplayObjectContainer;
			if ( container ) {
				//编辑器中不能与库项目的子类交互
				if ( isLibrary && _forEditor )
					container.touchGroup = true;
				if ( data.children ) {
					for each ( var item : Object in data.children ) {
						if ( !_forEditor && item.customParams && item.customParams.forEditor )
							continue;

						container.addChild( loadTree( item, factory, paramsDict, libraryDict ));
					}
				}
			}

			return obj;
		}

		public function save( container : DisplayObjectContainer, paramsDict : Object, librarys : Dictionary, atlas : String, setting : Object = null ) : Object {
			if ( !_template ) {
				throw new Error( "template not found!" );
			}

			var data : Object = {};
			data.version = VERSION;
			data.library = saveLibrarys( librarys );
			data.layout = saveTree( container.getChildAt( 0 ), paramsDict );
			data.setting = ParamUtil.cloneObject( setting );
			data.atlas = atlas;

			if ( _dataFormatter ) {
				data = _dataFormatter.write( data );
			}

			return data;
		}

		public function saveLibrary( container : DisplayObjectContainer, paramsDict : Object, librarys : Dictionary ) : Object {
			var data : Object = saveTree( container.getChildAt( 0 ), paramsDict );
			return data;
		}

		public function isContainer( param : Object ) : Boolean {
			if ( param && ParamUtil.isContainer( _template, param.cls ) && !param.customParams.source ) {
				return true;
			} else {
				return false;
			}
		}

		public function copy( obj : Array, paramsDict : Object ) : String {
			if ( !_template ) {
				throw new Error( "template not found!" );
			}

			var trees : Array = [];
			for ( var i : int = 0; i < obj.length; i++ ) {
				trees[ i ] = saveTree( obj[ i ], paramsDict );
			}

			return StableJSONEncoder.stringify( trees );
		}

		public function paste( string : String, libraryDic : Dictionary ) : Object {
			var data : Object = JSON.parse( string );
			if ( data.linkage ) {
				data = updateObjectFromLibrary( data, libraryDic );
			}

			if ( data is Array ) {
				var array : Array = data as Array;
				var result : Array = [];
				for ( var i : int = 0; i < array.length; i++ ) {
					result.push({ layout:array[i]});
				}
				return result;
			} else {
				return { layout: data };
			}
		}

		private function saveLibrarys( librarys : Dictionary ) : Object {
			var result : Array = [];
			for each ( var libraryItem : * in librarys ) {
				result.push( libraryItem );
			}
			return result;
		}

		private function saveTree( object : DisplayObject, paramsDict : Object ) : Object {
			var item : Object = saveElement( object, ParamUtil.getParams( _template, object ), paramsDict[ object ]);

			var container : DisplayObjectContainer = object as DisplayObjectContainer;

			//如果当前对象是库文件则不需要保存children信息
			if ( container && !ParamUtil.isLibraryItem( object ) && isContainer( paramsDict[ object ])) {
				item.children = [];

				for ( var i : int = 0; i < container.numChildren; ++i ) {
					item.children.push( saveTree( container.getChildAt( i ), paramsDict ));
				}
			}

			return item;
		}

		private function updateObjectFromLibrary( data : Object, libraryDict : Dictionary ) : Object {
			if ( data.linkage ) {
				var libraryItem : Object = ParamUtil.cloneObject( libraryDict[ data.linkage ]);

				data.children = libraryItem.children;
				data.cls = libraryItem.cls;
				if ( libraryItem.customParams ) {
					data.customParams = libraryItem.customParams;
				}

				for ( var key : String in libraryItem.params ) {
					if ( !data.params[ key ])
						data.params[ key ] = libraryItem.params[ key ];
				}
			}
			return data;
		}

		//TODO 需要判断保存的对象是否是库中的文件
		private function saveElement( obj : Object, params : Array, paramsData : Object ) : Object {

			var item : Object = { params: {}, constructorParams: [], customParams: {}};

			var isLibraryItem : Boolean = ParamUtil.isLibraryItem( obj );

			//如果是库的话，使用链接名
			if ( isLibraryItem ) {
				item.linkage = obj.customData.linkage;
			} else {
				item.cls = ParamUtil.getClassName( obj );
			}

			if ( paramsData ) {
				item.constructorParams = ParamUtil.cloneObject( paramsData.constructorParams );
				item.customParams = ParamUtil.cloneObject( paramsData.customParams );

				removeDefault( item, ParamUtil.getCustomParams( _template ));
			}

			for each ( var param : Object in params ) {
				if ( willSaveProperty( obj, param, item )) {
					if ( param.hasOwnProperty( "cls" )) {
						if ( obj[ param.name ] is Texture ) //special case for saving texture
						{
							item.params[ param.name ] = ParamUtil.cloneObject( paramsData.params[ param.name ]);
						} else {
							var subObject : Object = obj[ param.name ];
							if ( subObject )
								item.params[ param.name ] = saveElement( subObject, ParamUtil.getParams( _template, subObject ), ParamUtil.cloneObject( paramsData.params[ param.name ]));
						}
					} else {
						saveProperty( item.params, obj, param.name );
					}
				}
			}

			return item;
		}

		private function saveProperty( target : Object, source : Object, name : String ) : void {
			var data : Object = source[ name ];
			if ( data is Number ) {
				data = roundToDigit( data as Number );
			}
			target[ name ] = data;
		}

		private function roundToDigit( value : Number, digit : int = 2 ) : Number {
			var a : Number = Math.pow( 10, digit );
			return Math.round( value * a ) / a;
		}

		private static function removeDefault( obj : Object, params : Array ) : void {
			for each ( var param : Object in params ) {
				if ( ObjectLocaterUtil.get( obj, param.name ) == param.default_value ) {
					ObjectLocaterUtil.del( obj, param.name );
				}
			}
		}

		private static function willSaveProperty( obj : Object, param : Object, item : Object ) : Boolean {
			if ( !obj.hasOwnProperty( param.name )) {
				return false;
			}

			//Won't save default NaN value, plus it's not supported in json format
			if ( param.default_value == "NaN" && isNaN( obj[ param.name ])) {
				return false;
			}

			if ( param.read_only ) {
				return false;
			}

			//Custom save rules go to here
			if ( !SaveUtil.willSave( obj, param, item )) {
				return false;
			}

			return param.default_value == undefined || param.default_value != obj[ param.name ];
		}

		private static function doTrimLeadingSpace( container : DisplayObjectContainer ) : void {
			var minX : Number = int.MAX_VALUE;
			var minY : Number = int.MAX_VALUE;

			var i : int;
			var obj : DisplayObject;

			for ( i = 0; i < container.numChildren; ++i ) {
				obj = container.getChildAt( i );

				var rect : Rectangle = obj.getBounds( container );

				if ( rect.x < minX ) {
					minX = rect.x;
				}

				if ( rect.y < minY ) {
					minY = rect.y;
				}
			}

			for ( i = 0; i < container.numChildren; ++i ) {
				obj = container.getChildAt( i );
				obj.x -= minX;
				obj.y -= minY;
			}
		}

		public function createUIElement( data : Object ) : Object {
			return { object: _factory.create( data ), params: data };
		}

		public function get dataFormatter() : IDataFormatter {
			return _dataFormatter;
		}

		public function set dataFormatter( value : IDataFormatter ) : void {
			_dataFormatter = value;
		}

		public function localizeTexts( root : DisplayObject, paramsDict : Dictionary ) : void {
			if ( _localization && _localization.locale ) {
				localizeTree( root, paramsDict );
			}
		}

		private function localizeTree( object : DisplayObject, paramsDict : Dictionary ) : void {
			var params : Object = paramsDict[ object ];

			if ( object.hasOwnProperty( "text" ) && params && params.customParams && params.customParams.localizeKey ) {
				var text : String = _localization.getLocalizedText( params.customParams.localizeKey );
				if ( text )
					object[ "text" ] = text;
			}

			var container : DisplayObjectContainer = object as DisplayObjectContainer;

			if ( container ) {
				for ( var i : int = 0; i < container.numChildren; ++i ) {
					localizeTree( container.getChildAt( i ), paramsDict );
				}
			}
		}

		/**
		 *  Helper function to find ui element
		 * @param container
		 * @param path can be separated by dot (e.g. bottom_container.layout.button1)
		 * @return
		 */
		public static function find( container : DisplayObjectContainer, path : String ) : DisplayObject {
			var array : Array = path.split( "." );

			var obj : DisplayObject;

			for each ( var name : String in array ) {
				if ( container == null )
					return null;

				obj = container.getChildByName( name );
				container = obj as DisplayObjectContainer;
			}

			return obj;
		}
	}
}
