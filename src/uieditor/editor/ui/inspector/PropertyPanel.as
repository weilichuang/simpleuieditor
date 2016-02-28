package uieditor.editor.ui.inspector
{
	import feathers.controls.LayoutGroup;
	import feathers.controls.ScrollContainer;
	
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	import uieditor.editor.feathers.FeathersUIUtil;
	import uieditor.engine.util.ObjectLocaterUtil;
	import uieditor.engine.util.ParamUtil;

	public class PropertyPanel extends LayoutGroup
	{
		public static const DEFAULT_ROW_GAP:int = 10;
		
		public static var globalDispatcher : EventDispatcher = new EventDispatcher();

		protected var _container : ScrollContainer;

		protected var _target : Object;
		protected var _params : Array;

		protected var _propertyRetrieverFactory : Function;

		protected var _linkOperation:ILinkOperation;
		protected var _linkButton : LinkButton;

		protected var _setting : Object;

		public function PropertyPanel( target : Object = null, params : Array = null, propertyRetrieverFactory : Function = null, setting : Object = null )
		{
			_linkButton = new LinkButton();
			_linkOperation = new DefaultLinkOperation();

			_propertyRetrieverFactory = propertyRetrieverFactory;
			_setting = setting;

			_container = FeathersUIUtil.scrollContainerWithVerticalLayout();
			addChild( _container );

			if ( target && params )
				reloadData( target, params );

			globalDispatcher.addEventListener( UIMapperEventType.PROPERTY_CHANGE, onGlobalPropertyChange );
		}

		public function get rowGap() : int
		{
			return ( _setting && _setting.hasOwnProperty( "rowGap" )) ? _setting.rowGap : DEFAULT_ROW_GAP;
		}

		private function onGlobalPropertyChange( event : Event ) : void
		{
			if ( event.data.target === _target )
			{
				changeLinkedProperties( event );

				reloadTarget( _target );
			}
		}

		public function reloadTarget( target : Object = null, force : Boolean = false ) : void
		{
			if ( _target !== target || force )
			{
				_target = target;

				_container.removeChildren( 0, -1, true );

				for each ( var param : Object in _params )
				{
					if ( hasProperty( _target, param.name ))
					{
						var mapper : BasePropertyUIMapper = new BasePropertyUIMapper( _target, param, _propertyRetrieverFactory, _setting );
						_container.addChild( mapper );
					}
				}

				_container.validate();

				var index : int = -1;

				if ( _target && _params )
				{
					index = findFirstLinkedPropertyIndex();
				}

				if ( index >= 0 )
				{
					var obj : DisplayObject = _container.getChildAt( index );
					addChild( _linkButton );
					_linkButton.x = obj.x + obj.width + 3;
					_linkButton.y = obj.y + obj.height / 2 - 5;
				}
				else
				{
					_linkButton.removeFromParent();
				}
			}
			else
			{
				BasePropertyUIMapper.updateAll( this );
			}
		}

		public function reloadData( target : Object = null, params : Array = null ) : void
		{
			if ( target !== _target )
			{
				if ( params !== _params ) //both target and params change
				{
					_params = params;
					reloadTarget( target );
				}
				else //only target changes
				{
					_target = target;
					BasePropertyUIMapper.updateAll( this, _target );
				}
			}
			else
			{
				if ( params !== _params ) //only params changes
				{
					_params = params;
				}
				else //none of them change
				{
				}

				reloadTarget( target );
			}
		}

		public function reset() : void
		{
			_container.removeChildren( 0, -1, true );
			_target = null;
			_params = null;
		}

		private function hasProperty( target : Object, name : String ) : Boolean
		{
			//Always allow as3 plain object to visible even if property does not exist
			if ( ParamUtil.getClassName( target ) == "Object" )
				return true;

			return ObjectLocaterUtil.hasProperty( target, name );
		}

		override public function dispose() : void
		{
			globalDispatcher.removeEventListener( UIMapperEventType.PROPERTY_CHANGE, onGlobalPropertyChange );

			super.dispose();
		}

		private function findFirstLinkedPropertyIndex() : int
		{
			for (var i:int = 0; i < _params.length; ++i)
			{
				if (_params[i].hasOwnProperty("link"))
				{
					return i;
				}
			}
			
			return -1;
		}

		private function changeLinkedProperties( event : Event ) : void
		{
			var name:String = event.data.propertyName;
			
			if (_linkButton.isSelected)
			{
				for each (var param:Object in _params)
				{
					if (!param.hasOwnProperty("link")) continue;
					
					if (_target && _target.hasOwnProperty(name))
					{
						_linkOperation.update(_target, name, param.name);
					}
				}
			}
		}

		public function set linkOperation(value:ILinkOperation):void
		{
			_linkOperation = value;
		}
		
		public function get linkOperation():ILinkOperation
		{
			return _linkOperation;
		}
	}
}
