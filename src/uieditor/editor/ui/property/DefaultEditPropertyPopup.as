package uieditor.editor.ui.property
{
	import feathers.controls.LayoutGroup;
	import feathers.controls.PickerList;
	import feathers.data.ListCollection;
	import feathers.layout.VerticalLayout;
	
	import starling.events.Event;
	
	import uieditor.editor.UIEditorApp;
	import uieditor.editor.data.TemplateData;
	import uieditor.editor.ui.inspector.PropertyPanel;
	import uieditor.engine.util.ParamUtil;

	public class DefaultEditPropertyPopup extends AbstractPropertyPopup
	{
		private var _classPicker : PickerList;

		private var _propertyPanel : PropertyPanel;


		private var _supportedClass : Array = [];

		private var _paramDict : Object = {};

		public function DefaultEditPropertyPopup( owner : Object, target : Object, targetParam : Object, onComplete : Function )
		{
			super( owner, target, targetParam, onComplete );

			title = "Edit Property";
			buttons = [ "确定", "取消" ];

			addEventListener( Event.COMPLETE, onDialogComplete );
		}

		private function initClass( supportedClasses : Array ) : void
		{
			_supportedClass = [];

			for each ( var cls : String in supportedClasses )
			{
				if ( cls == null )
				{
					_supportedClass.push( "null" );
				}
				else
				{
					_supportedClass.push( cls );
				}
			}

			_paramDict = {};

			for each ( var clsName : String in _supportedClass )
			{
				var param : Object = ParamUtil.getParamByClassName( TemplateData.editor_template, clsName );
				_paramDict[ clsName ] = param;
			}
		}

		override protected function createContent( container : LayoutGroup ) : void
		{
			initClass( _targetParam.supportedClasses );

			container.layout = new VerticalLayout();

			_classPicker = new PickerList();
			_classPicker.dataProvider = new ListCollection( _supportedClass );

			var clsName : String = ParamUtil.getClassName( _target );

			if ( clsName == "" )
				clsName = "null";

			_classPicker.selectedIndex = _supportedClass.indexOf( clsName );
			_propertyPanel = new PropertyPanel( _target, _paramDict[ clsName ]);

			addChild( _classPicker );
			addChild( _propertyPanel );

			_classPicker.addEventListener( Event.CHANGE, onClassPicker );
		}

		private function onClassPicker( event : Event ) : void
		{
			var selected : String = _classPicker.selectedItem as String;

			if ( selected == "null" )
			{
				_target = null;
			}
			else
			{
				_target = UIEditorApp.instance.currentDocumentEditor.uiBuilder.createUIElement({ cls: selected, customParams: {}}).object;
			}

			_owner[ _targetParam.name ] = _target;
			_propertyPanel.reloadData( _target, _paramDict[ ParamUtil.getClassName( _target )]);
		}

		private function onDialogComplete( event : Event ) : void
		{
			var index : int = int( event.data );

			if ( index == 0 )
			{
				_onComplete( _target );
			}
			else
			{
				_owner[ _targetParam.name ] = _oldTarget;
				_onComplete = null;
			}
		}
	}
}
