package uieditor.editor.ui.inspector
{
	import uieditor.engine.UIElementFactory;
	import uieditor.editor.feathers.FeathersUIUtil;

	import feathers.controls.Label;
	import feathers.controls.ScrollContainer;
	import feathers.layout.HorizontalLayout;

	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;

	public class BasePropertyUIMapper extends ScrollContainer implements IUIMapper
	{
		public static const DEFAULT_LABEL_WIDTH : int = 55;
		public static const DEFAULT_COLUMN_GAP : int = 5;

		protected var _target : Object;
		protected var _param : Object;
		protected var _propertyRetriever : IPropertyRetriever;

		protected var _factory : UIPropertyComponentFactory;
		protected var _setting : Object;

		public function BasePropertyUIMapper( target : Object, param : Object, propertyRetrieverFactory : Function = null, setting : Object = null )
		{
			_target = target;
			_param = param;
			_setting = setting;

			_factory = new UIPropertyComponentFactory();

			if ( propertyRetrieverFactory != null )
			{
				_propertyRetriever = propertyRetrieverFactory( target, param );
			}
			else
			{
				_propertyRetriever = new DefaultPropertyRetriever( _target, param );
			}

			var layout : HorizontalLayout = new HorizontalLayout();
			layout.gap = columnGap;
			this.layout = layout;

			var label : Label = FeathersUIUtil.labelWithText( _param.label ? _param.label : _param.name );
			label.width = 50;
			label.wordWrap = true;
			addChild( label );

			createComponents( param );
		}

		public function get labelWidth() : int
		{
			return ( _setting && _setting.hasOwnProperty( "labelWidth" )) ? _setting.labelWidth : DEFAULT_LABEL_WIDTH;
		}

		public function get columnGap() : int
		{
			return ( _setting && _setting.hasOwnProperty( "columnGap" )) ? _setting.columnGap : DEFAULT_COLUMN_GAP;
		}

		public function get propertyRetriever() : IPropertyRetriever
		{
			return _propertyRetriever;
		}

		public function set propertyRetriever( value : IPropertyRetriever ) : void
		{
			_propertyRetriever = value;
		}
		
		public function set target(value:Object):void
		{
			_target = value;
		}

		public function update() : void
		{

		}

		private static function getAll( array : Array, container : DisplayObjectContainer, cls : Class ) : void
		{
			for ( var i : int = 0; i < container.numChildren; ++i )
			{
				var child : DisplayObject = container.getChildAt( i );

				if ( child is cls )
				{
					array.push( child );
				}
				else if ( child is DisplayObjectContainer )
				{
					getAll( array, DisplayObjectContainer( child ), cls );
				}
			}
		}

		private function createComponents( param : Object ) : void
		{
			var items : Array = _factory.getItems( param.component );

			for each ( var item : String in items )
			{
				createComponent( item, param );
			}
		}

		private function createComponent( type : String, param : Object ) : void
		{
			var component : BasePropertyComponent;

			var cls : Class = _factory.getComponent( type );
			component = new cls( _propertyRetriever, param );
			component.addEventListener( Event.CHANGE, onChange );
			addChild( component );
		}

		private function onChange( event : Event ) : void
		{
			var data : Object = { target: _target, propertyName: _param.name };
			if ( event.data && event.data.hasOwnProperty( "oldValue" ))
				data.oldValue = event.data.oldValue;

			PropertyPanel.globalDispatcher.dispatchEventWith( UIMapperEventType.PROPERTY_CHANGE, false, data );
		}

		public static function sortBasePropertyComponent( array : Array, priorities : Object ) : void
		{
			array.sort( function( c1 : BasePropertyComponent, c2 : BasePropertyComponent ) : int
			{
				return int( priorities[ c1.param.name ]) - int( priorities[ c2.param.name ]);
			});
		}

		public function get factory() : UIPropertyComponentFactory
		{
			return _factory;
		}

		public static function updateAll( container : DisplayObjectContainer, target:Object = null ) : void
		{
			var array : Array = [];
			getAll( array, container, BasePropertyComponent );

			sortBasePropertyComponent( array, UIElementFactory.PARAMS );

			if ( target )
			{
				var array2 : Array = [];
				getAll( array2, container, BasePropertyUIMapper );

				for each ( var it : BasePropertyUIMapper in array2 )
				{
					if ( target )
					{
						it.target = target;
					}
				}
			}

			for each ( var item : IUIMapper in array )
			{
				if ( target )
				{
					item.target = target;
				}
				item.update();
			}
		}
	}
}
