package uieditor.editor.persist
{
	import uieditor.editor.util.ObjectUtil;

	import flash.net.SharedObject;
	import flash.utils.getQualifiedClassName;

	public class DefaultPersistableObject implements IPersistableObject
	{
		private var _defaultName : String = "persistable";

		public function DefaultPersistableObject( defaultName : String = null )
		{
			if ( defaultName )
				_defaultName = defaultName;

			recover();
		}

		public function persist() : void
		{
			var data : Object = save();
			var sharedObject : SharedObject = SharedObject.getLocal( _defaultName );
			sharedObject.setProperty( getQualifiedClassName( this ), data );
		}

		private function recover() : void
		{
			var sharedObject : SharedObject = SharedObject.getLocal( _defaultName );
			load( sharedObject.data[ getQualifiedClassName( this )]);
		}

		public function load( data : Object ) : void
		{
			if ( data )
				ObjectUtil.fromJSONObject( this, data );
		}

		public function save() : Object
		{
			return ObjectUtil.toJSONObject( this );
		}
	}
}
