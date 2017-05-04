package uieditor.editor.ui.tabpanel
{
	import flash.utils.Dictionary;
	
	import feathers.controls.Button;
	import feathers.controls.LayoutGroup;
	import feathers.controls.ScrollContainer;
	import feathers.core.FeathersControl;
	import feathers.layout.VerticalLayout;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	
	import uieditor.editor.UIEditorApp;
	import uieditor.editor.UIEditorScreen;
	import uieditor.editor.controller.AbstractDocumentEditor;
	import uieditor.editor.controller.DocumentEditor;
	import uieditor.editor.controller.LibraryDocumentEditor;
	import uieditor.editor.data.TemplateData;
	import uieditor.editor.events.DocumentEventType;
	import uieditor.editor.history.ResetOperation;
	import uieditor.editor.themes.UIEditorStyleProvider;
	import uieditor.editor.ui.inspector.DefaultPropertyRetriever;
	import uieditor.editor.ui.inspector.IPropertyRetriever;
	import uieditor.editor.ui.inspector.PropertyPanel;
	import uieditor.editor.ui.inspector.UIMapperUtil;
	import uieditor.engine.util.ParamUtil;

	public class PropertyTab extends ScrollContainer
	{
		private var _propertyPanel : PropertyPanel;

		private var _rootPropertyPanel : PropertyPanel;

		private var _template : Object;

		private var _documentManager : AbstractDocumentEditor;

		private var _pivotTool : PivotTool;
		private var _movieClipTool : MovieClipTool;

		private var _paramCache : Dictionary;
		private var _propertyPanelCache : Dictionary;

		public function PropertyTab()
		{
			super();
			
			_paramCache = new Dictionary();
			_propertyPanelCache = new Dictionary();

			_template = TemplateData.editor_template;

			initUI();
			
			UIEditorApp.instance.notificationDispatcher.addEventListener( DocumentEventType.CHANGE_DOCUMENT_EDITOR, onChangeDocumentEditor );
			onChangeDocumentEditor(null);
		}
		
		private function onChangeDocumentEditor( event : Event ) : void
		{
			if ( _documentManager != null )
			{
				_documentManager.removeEventListener( DocumentEventType.CHANGE, onChange );
			}
			
			_documentManager = UIEditorApp.instance.currentDocumentEditor;
			_documentManager.addEventListener( DocumentEventType.CHANGE, onChange );
			
			_pivotTool.setDocumentEditor(_documentManager);
			_movieClipTool.setDocumentEditor(_documentManager);
			
			onChange(null);
		}

		private function initUI() : void
		{
			width = 300;
			
			var layout : VerticalLayout = new VerticalLayout();
			layout.paddingTop = 20;
			layout.gap = 5;
			layout.paddingLeft = 2;
			layout.paddingRight = 2;
			this.layout = layout;
			
			_propertyPanel = new PropertyPanel({}, [], displayObjectPropertyFactory );
			addChild( _propertyPanel );

			_rootPropertyPanel = new PropertyPanel( null, null, displayObjectPropertyFactory );

			_pivotTool = new PivotTool( );
			addChild( _pivotTool );

			_movieClipTool = new MovieClipTool( );
			addChild( _movieClipTool );

			_pivotTool.visible = false;
			_movieClipTool.visible = false;
		}

		private function displayObjectPropertyFactory( target : Object, param : Object ) : IPropertyRetriever
		{
			if ( param.name == "styleName" && target is FeathersControl )
			{
				param.options = getStyleNames( target as FeathersControl );
			}

			return new DefaultPropertyRetriever( target, param );
		}

		private function createButtons() : Array
		{
			return [
				{ label: "重置", triggered: onResetButtonClick },
//                {label:"readjust layout", triggered:onLayoutButtonClick},
				]
		}

		private function onResetButtonClick( event : Event ) : void
		{
			reset();
		}

		private function onButtonClick( event : Event ) : void
		{
			var button : Button = event.target as Button;

			switch ( button.label )
			{
				case "reset":
					reset();
					break;
				case "readjust layout":
					readjust( _documentManager );
					break;
			}
		}

		private function reset() : void
		{
			var obj : DisplayObject = _documentManager.selectedObject;

			if ( obj )
			{
				var oldValue : Object = { rotation: obj.rotation, scaleX: obj.scaleX, scaleY: obj.scaleY };

				obj.rotation = 0;
				obj.scaleX = 1;
				obj.scaleY = 1;
				_documentManager.setChanged();

				var newValue : Object = { rotation: obj.rotation, scaleX: obj.scaleX, scaleY: obj.scaleY };
				_documentManager.historyManager.add( new ResetOperation( obj, oldValue, newValue ));
			}

		}

		private var _rootParams : Array;

		private function getRootParams() : Array
		{
			var documentEditor:DocumentEditor = UIEditorApp.instance.documentEditor;
			_rootParams = [];
			_rootParams.push({ label: "名字", name: "rootName", default_value: documentEditor.rootName });
			_rootParams.push({ label: "宽度", name: "canvasWidth", component: "numericStepper", default_value: documentEditor.canvasWidth, min: 1, max: 10000, step: 1 });
			_rootParams.push({ label: "高度", name: "canvasHeight", component: "numericStepper", default_value: documentEditor.canvasHeight, min: 1, max: 10000, step: 1 });
			_rootParams.push({ label: "背景颜色", name: "backgroundColor", component: "colorPicker", default_value: 16777215 });
			_rootParams.push({ label: "缩放", name: "scale", component: "numericStepper", min: "0.1", max: "5", step: "0.1", default_value: documentEditor.scale });
			_rootParams.push({ label: "参考图", "name": "background", "component": "popup", "cls": true, "disable": true, "default_value": null, "editPropertyClass": "uieditor.editor.ui.property.ChooseFilePropertyPopup",
					"extension": [ "*.jpeg", "*.atf" ]});
			_rootParams.push({ label: "参考图x", name: "backgroundX", default_value: documentEditor.backgroundX, component: "numericStepper", min: 0, max: documentEditor.canvasWidth, step: 1 });
			_rootParams.push({ label: "参考图y", name: "backgroundY", default_value: documentEditor.backgroundY, component: "numericStepper", min: 0, max: documentEditor.canvasHeight, step: 1 });
			return _rootParams;
		}
		
		private var _libraryRootParams : Array;
		
		private function getLibraryParams() : Array
		{
			var documentEditor:LibraryDocumentEditor = UIEditorApp.instance.libraryDocumentEditor;
			_libraryRootParams = [];
			_libraryRootParams.push({ label: "链接名", name: "rootName", default_value: documentEditor.rootName });
			_libraryRootParams.push({ label: "宽度", name: "canvasWidth", component: "numericStepper", default_value: documentEditor.canvasWidth, min: 1, max: 10000, step: 1 });
			_libraryRootParams.push({ label: "高度", name: "canvasHeight", component: "numericStepper", default_value: documentEditor.canvasHeight, min: 1, max: 10000, step: 1 });
			_libraryRootParams.push({ label: "背景颜色", name: "backgroundColor", component: "colorPicker", default_value: 16777215 });
			_libraryRootParams.push({ label: "缩放", name: "scale", component: "numericStepper", min: "0.1", max: "5", step: "0.1", default_value: documentEditor.scale });
			_libraryRootParams.push({ label: "参考图", "name": "background", "component": "popup", "cls": true, "disable": true, "default_value": null, "editPropertyClass": "uieditor.editor.ui.property.ChooseFilePropertyPopup",
				"extension": [ "*.jpeg", "*.atf" ]});
			_libraryRootParams.push({ label: "参考图x", name: "backgroundX", default_value: documentEditor.backgroundX, component: "numericStepper", min: 0, max: documentEditor.canvasWidth, step: 1 });
			_libraryRootParams.push({ label: "参考图y", name: "backgroundY", default_value: documentEditor.backgroundY, component: "numericStepper", min: 0, max: documentEditor.canvasHeight, step: 1 });
			return _libraryRootParams;
		}

		private function onChange( event : Event ) : void
		{
			var obj : DisplayObject = _documentManager.selectedObject;
			if ( obj )
			{
				var params : Array = getObjectParams( obj );
				
				if(_propertyPanel != null)
				{
					_propertyPanel.removePropertyListener();
				}

				updatePropertyPanel( obj );

				//root特殊处理
				if (_documentManager.selectedObject == _documentManager.rootNode )
				{
					if(_documentManager is DocumentEditor)
					{
						params = getRootParams();
					}
					else
					{
						params = getLibraryParams();
					}
					obj = _documentManager;
					_pivotTool.visible = false;
				}
				else
				{
					_pivotTool.visible = true;
				}

				_propertyPanel.addPropertyListener();
				_propertyPanel.reloadData( obj, params );
			}
			else
			{
				if ( _propertyPanel )
				{
					_propertyPanel.removePropertyListener();
					_propertyPanel.removeFromParent();
					_propertyPanel = null;
				}
				_pivotTool.visible = false;
			}

			_movieClipTool.updateMovieClipTool();
		}

		private function updatePropertyPanel( target : Object ) : void
		{
			if ( target == _documentManager.rootNode )
			{
				if ( _propertyPanel == _rootPropertyPanel )
					return;

				if ( _propertyPanel )
					_propertyPanel.removeFromParent();

				_propertyPanel = _rootPropertyPanel;

				addChildAt( _propertyPanel, 0 );

				return;
			}

			if ( _propertyPanel === _propertyPanelCache[ target.constructor ])
				return;

			if ( _propertyPanel )
				_propertyPanel.removeFromParent();

			if ( !_propertyPanelCache[ target.constructor ])
			{
				var propertyPanel : PropertyPanel = new PropertyPanel( null, null, displayObjectPropertyFactory );
				_propertyPanelCache[ target.constructor ] = propertyPanel;
			}

			_propertyPanel = _propertyPanelCache[ target.constructor ];

			addChildAt( _propertyPanel, 0 );
		}

		private function getObjectParams( target : Object ) : Array
		{
			if ( target )
			{
				if ( target == _documentManager.rootNode )
				{
					return getRootParams();
				}

				if ( !_paramCache[ target.constructor ])
				{
					var params : Array = ParamUtil.getParams( _template, _documentManager.selectedObject );

					UIMapperUtil.processParamsWithFonts( params, UIEditorScreen.instance.getBitmapFontNames());

					_paramCache[ target.constructor ] = params;
				}

				return _paramCache[ target.constructor ];
			}
			else
			{
				return null;
			}
		}

		private function processParamsWithWidthAndHeight( params : Array ) : void
		{
			var i : int;

			var array : Array;
			var param : Object;

			for ( i = 0; i < params.length; ++i )
			{
				param = params[ i ];

				if ( param.name == "width" )
				{
					array = [ param ];
					params.splice( i, 1, array );
				}
			}

			for ( i = 0; i < params.length; ++i )
			{
				param = params[ i ];

				if ( param.name == "height" )
				{
					params.splice( i, 1 );
					array.push( param );
				}
			}
		}

		private function readjust( container : DisplayObjectContainer ) : void
		{
			for ( var i : int = 0; i < container.numChildren; ++i )
			{
				var child : DisplayObject = container.getChildAt( i );

				if ( child is LayoutGroup )
				{
					LayoutGroup( child ).readjustLayout();
				}
				else if ( child is ScrollContainer )
				{
					ScrollContainer( child ).readjustLayout();
				}

				if ( child is DisplayObjectContainer )
				{
					readjust( child as DisplayObjectContainer );
				}
			}
		}

		private function getStyleNames( fc : FeathersControl ) : Array
		{
			var array : Array = [];

			if ( fc.styleProvider is UIEditorStyleProvider )
			{
				var styleNameMap : Object = ( fc.styleProvider as UIEditorStyleProvider ).styleNameMap;

				for ( var name : String in styleNameMap )
				{
					array.push( name );
				}
			}

			return array;
		}


	}
}
