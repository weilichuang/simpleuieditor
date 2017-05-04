package uieditor.editor.ui.inspector
{
	import uieditor.engine.util.ObjectLocaterUtil;

	public class DefaultPropertyRetriever implements IPropertyRetriever
	{
		protected var _target : Object;
		protected var _param : Object;

		function DefaultPropertyRetriever( target : Object, param : Object = null ) : void
		{
			_target = target;
			_param = param;
		}
		
		public function dispose():void
		{
			_target = null;
			_param = null;
		}

		public function set( name : String, value : Object ) : void
		{
			value = formatType( name, value, false );

			ObjectLocaterUtil.set( _target, name, value );
		}

		public function get( name : String ) : Object
		{
			var value : Object = ObjectLocaterUtil.get( _target, name );

			return formatType( name, value, true );
		}

		//TODO: add more cases
		public function formatType( name : String, obj : Object, forRead:Boolean ) : Object
		{
			if ( isBoolean( name ) && obj is String )
			{
				return ( obj == "true" ? true : false );
			}
			else if ( isNumber( name ) && obj is String )
			{
				var value : Number = Number( obj );

				if ( isNaN( value ))
				{
					return NaN;
				}
				else
				{
					return value;
				}
			}
			else if (forRead && !ObjectLocaterUtil.hasProperty( _target, name ) && _param.hasOwnProperty( "default_value" ))
			{
				return _param.default_value;
			}
			else
			{
				return obj;
			}
		}

		private function isBoolean( name : String ) : Boolean
		{
			if ( _param && _param.data_type )
				return _param.data_type == "Boolean";

			return ObjectLocaterUtil.get(_target, name) is Boolean;
		}

		private function isNumber( name : String ) : Boolean
		{
			if ( _param && _param.data_type )
				return _param.data_type == "Number";

			return ObjectLocaterUtil.get(_target, name) is Number;
		}

		public function get target() : Object
		{
			return _target;
		}

		public function set target(value:Object):void
		{
			_target = value;
		}
	}
}
