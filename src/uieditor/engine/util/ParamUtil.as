package uieditor.engine.util {
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import starling.display.DisplayObject;

	public class ParamUtil {
		public function ParamUtil() {
		}

		public static function getParams( template : Object, obj : Object ) : Array {
			var className : String = getClassName( obj );
			return getParamByClassName( template, className );
		}

		public static function getParamByClassName( template : Object, className : String ) : Array {
			var params : Array = template.default_component.params.concat();

			if ( getFlag( template, className, "tag" ) == "feathers" ) {
				params = params.concat( template.default_feathers_component.params );
			}

			for each ( var item : Object in template.supported_components ) {
				if ( item.cls == className ) {
					for each ( var param : Object in item.params ) {
						params.push( param );
					}

					break;
				}
			}

			return params;

		}

		public static function getClassName( obj : Object ) : String {
			if ( obj == null )
				return "";

			return getQualifiedClassName( obj ).replace( /::/g, "." );
		}

		public static function getClassNames( objects : Array ) : Array {
			var res : Array = [];
			for each ( var obj : Object in objects ) {
				res.push( getClassName( obj ));
			}
			return res;
		}

		public static function getCustomParams( template : Object ) : Array {
			return template.default_component.customParams as Array;
		}





		public static function getConstructorParams( template : Object, cls : String ) : Array {
			for each ( var item : Object in template.supported_components ) {
				if ( item.cls == cls ) {
					return ParamUtil.cloneObject( item.constructorParams ) as Array;
				}
			}

			return null;
		}

		/**
		 * 是否存在创建类型选择类
		 */
		public static function getCreateComponentClass( template : Object, cls : String ) : Class {
			for each ( var item : Object in template.supported_components ) {
				if ( item.cls == cls && item.createComponentClass ) {
					return getDefinitionByName( item.createComponentClass ) as Class;
				}
			}

			return null;
		}

		public static function hasFlag( template : Object, cls : String, flag : String ) : Boolean {
			for each ( var item : Object in template.supported_components ) {
				if ( item.cls == cls ) {
					if ( item.hasOwnProperty( flag ))
						return true;
					else
						return false;
				}
			}

			return false;

		}

		public static function getFlag( template : Object, cls : String, flag : String ) : String {
			for each ( var item : Object in template.supported_components ) {
				if ( item.cls == cls ) {
					if ( item.hasOwnProperty( flag ))
						return item[ flag ];
					else
						return null;
				}
			}

			return null;
		}

		public static function getDisplayObjectName( cls : String ) : String {
			var index : int = cls.lastIndexOf( "." ) + 1;
			return cls.substr( index, 1 ).toLocaleLowerCase() + cls.substr( index + 1 );
		}

		public static function createButton( template : Object, cls : String ) : Boolean {
			return hasFlag( template, cls, "createButton" );
		}

		public static function scale3Data( template : Object, cls : String ) : Boolean {
			return hasFlag( template, cls, "scale3Data" );
		}

		public static function scale9Data( template : Object, cls : String ) : Boolean {
			return hasFlag( template, cls, "scale9Data" );
		}

		public static function isContainer( template : Object, cls : String ) : Boolean {
			return hasFlag( template, cls, "container" );
		}

		public static function isLibraryItem( object : Object ) : Boolean {
			return (object is DisplayObject) && object.customData != null && object.customData.isLibrary;
		}
		
		public static function cloneObject( object : Object ) : Object {
			var clone : ByteArray = new ByteArray();
			clone.writeObject( object );
			clone.position = 0;
			return ( clone.readObject());
		}
	}
}
