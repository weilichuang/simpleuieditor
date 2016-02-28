package uieditor.engine {
	import flash.utils.getDefinitionByName;
	import starling.textures.Texture;
	import uieditor.engine.util.ParamUtil;




	public class UIElementFactory {
		protected var _assetMediator : IAssetMediator;
		protected var _forEditor : Boolean;

		public function UIElementFactory( assetMediator : IAssetMediator, forEditor : Boolean = false ) {
			_assetMediator = assetMediator;
			_forEditor = forEditor;
		}

		protected function setDefaultParams( obj : Object, data : Object ) : void {
		}

		protected function setDirectParams( obj : Object, data : Object ) : void {
			var array : Array = [];
			var id : String;
			for ( id in data.params ) {
				array.push( id );
			}
			sortParams( array, PARAMS );

			for each ( id in array ) {
				var item : Object = data.params[ id ];

				if ( item && item.hasOwnProperty( "cls" )) {
					obj[ id ] = create( item );
				} else if ( obj.hasOwnProperty( id )) {
					obj[ id ] = item;
				}
			}
		}

		protected function setDefault( obj : Object, data : Object ) : void {
			setDefaultParams( obj, data );
			setDirectParams( obj, data );
		}

		private function createTexture( param : Object ) : Object {
			var texture : Texture;
			var scaleRatio : Array;

			if ( param.cls == ParamUtil.getClassName( Texture )) {
				texture = _assetMediator.getTexture( param.textureName );

				if ( texture == null )
					throw new Error( "Texture " + param.textureName + " not found" );

				return texture;
			} else if ( param.cls == ParamUtil.getClassName( Vector.<Texture> )) {
				return _assetMediator.getTextures( param.value );
			} else {
				return null;
			}
		}

		public function create( data : Object) : Object {
			var obj : Object;
			var constructorParams : Array = data.constructorParams as Array;

			var res : Object = createTexture( data );
			if ( res )
				return res;

			var cls : Class;

			if ( !_forEditor && data.customParams && data.customParams.customComponentClass && data.customParams.customComponentClass != "null" ) {
				try {
					cls = getDefinitionByName( data.customParams.customComponentClass ) as Class;
				} catch ( e : Error ) {
					trace( "Class " + data.customParams.customComponentClass + " can't be instantiated." );
				}
			}
 
			if ( !cls ) {
				cls = getDefinitionByName( data.cls ) as Class;
			}

			var args : Array = createArgumentsFromParams( constructorParams );

			try {
				obj = createObjectFromClass( cls, args );
			} catch ( e : Error ) {
				obj = createObjectFromClass( cls, []);
			}

			setDefault( obj, data );
			return obj;
		}



		private function createObjectFromClass( cls : Class, args : Array ) : Object {
			switch ( args.length ) {
				case 0:
					return new cls();
				case 1:
					return new cls( args[ 0 ]);
				case 2:
					return new cls( args[ 0 ], args[ 1 ]);
				case 3:
					return new cls( args[ 0 ], args[ 1 ], args[ 2 ]);
				case 4:
					return new cls( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ]);
				case 5:
					return new cls( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ], args[ 4 ]);
				case 6:
					return new cls( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ], args[ 4 ], args[ 5 ]);
				case 7:
					return new cls( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ], args[ 4 ], args[ 5 ], args[ 6 ]);
				case 8:
					return new cls( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ], args[ 4 ], args[ 5 ], args[ 6 ], args[ 7 ]);
				case 9:
					return new cls( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ], args[ 4 ], args[ 5 ], args[ 6 ], args[ 7 ], args[ 8 ]);
				default:
					throw new Error( "Number of arguments not supported!" );
			}
		}

		private function createArgumentsFromParams( params : Array ) : Array {
			var args : Array = [];

			for each ( var param : Object in params ) {
				if ( param.hasOwnProperty( "value" )) {
					args.push( param.value );
				} else {
					args.push( create( param ));
				}
			}

			return args;

		}

		public static const PARAMS : Object = { "x":1, "y":1, "width":2, "height":2, "scaleX":3, "scaleY":3, "rotation":4 };

		public static function sortParams( array : Array, params : Object ) : void {
			array.sort( function( e1 : Object, e2 : Object ) : int
			{
				return int( params[ e1 ]) - int( params[ e2 ]);
			});
		}
	}
}
