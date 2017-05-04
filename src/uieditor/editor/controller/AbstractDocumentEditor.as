package uieditor.editor.controller
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	import feathers.controls.TextArea;
	import feathers.controls.TextInput;
	import feathers.core.FeathersControl;
	import feathers.core.FocusManager;
	import feathers.core.IFeathersControl;
	import feathers.core.IValidating;
	import feathers.data.ListCollection;
	import feathers.dragDrop.DragData;

	import starling.core.Starling;
	import starling.display.Canvas;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.AssetManager;

	import uieditor.editor.UIEditorApp;
	import uieditor.editor.data.TemplateData;
	import uieditor.editor.events.DocumentEventType;
	import uieditor.editor.feathers.popup.MsgBox;
	import uieditor.editor.helper.AssetMediator;
	import uieditor.editor.helper.DragHelper;
	import uieditor.editor.helper.InteractiveBoundingBox;
	import uieditor.editor.helper.MultiSelectBoundingBox;
	import uieditor.editor.helper.PixelSnapper;
	import uieditor.editor.helper.PixelSnapperData;
	import uieditor.editor.helper.SelectHelper;
	import uieditor.editor.helper.UIComponentHelper;
	import uieditor.editor.history.CreateOperation;
	import uieditor.editor.history.CutOperation;
	import uieditor.editor.history.DeleteOperation;
	import uieditor.editor.history.HistoryManager;
	import uieditor.editor.history.IHistoryOperation;
	import uieditor.editor.history.MoveLayerOperation;
	import uieditor.editor.history.MoveOperation;
	import uieditor.editor.history.MultiMoveOperation;
	import uieditor.editor.history.PasteOperation;
	import uieditor.editor.history.PropertyChangeOperation;
	import uieditor.editor.ui.tabpanel.DocumentPanel;
	import uieditor.editor.util.FileLoader;
	import uieditor.editor.util.UIAlignType;
	import uieditor.engine.IUIBuilder;
	import uieditor.engine.UIBuilder;
	import uieditor.engine.util.ParamUtil;

	public class AbstractDocumentEditor extends Sprite implements IDocumentEditor
	{
		protected var _assetManager : AssetManager;
		protected var _uiBuilder : IUIBuilder;
		protected var _assetMediator : AssetMediator;

		protected var _extraParamsDict : Dictionary;

		protected var _dataProvider : ListCollection; //

		protected var _dataProviderForList : ListCollection; //use for listing layout

		protected var _localizationManager : LocalizationManager;

		protected var _historyManager : HistoryManager;

		protected var _snapContainer : Sprite;

		protected var _layoutContainer : Sprite;

		protected var _root : DisplayObjectContainer;

		protected var _bgCanvas : Canvas;
		protected var _backgroundColor : uint = 0xffffff;
		protected var _backgroundContainer : Sprite;

		/**
		 * 选中框
		 */
		protected var _selectBoundingBox : InteractiveBoundingBox;

		protected var _selectedObject : DisplayObject;

		/**
		 * 鼠标经过框
		 */
		protected var _hoverBoundingBox : InteractiveBoundingBox;

		protected var _hoverObject : DisplayObject;

		protected var _mutliSelectBox : MultiSelectBoundingBox;

		protected var _snapPixel : Boolean = false;

		protected var _canvasSize : Point = new Point();

		protected var _documentPanel : DocumentPanel;

		protected var _showTextBorder : Boolean = false;

		//TODO 整理选择相关代码
		public function AbstractDocumentEditor( assetManager : AssetManager, localizationManager : LocalizationManager )
		{
			super();

			_assetManager = assetManager;

			_assetMediator = new AssetMediator( _assetManager );

			_localizationManager = localizationManager;

			_uiBuilder = new UIBuilder( _assetMediator, true, TemplateData.editor_template, _localizationManager.localization );

			_historyManager = new HistoryManager();

			_extraParamsDict = new Dictionary();

			_dataProvider = new ListCollection();
			_dataProviderForList = new ListCollection();

			initUI();
		}

		public function get assetManager() : AssetManager
		{
			return _assetManager;
		}

		public function get localizationManager() : LocalizationManager
		{
			return _localizationManager;
		}

		public function get bgCanvas() : Canvas
		{
			return _bgCanvas;
		}

		protected function reset() : void
		{

		}

		protected function removeFromParam( obj : DisplayObject, paramDict : Dictionary ) : void
		{
			if ( paramDict[ obj ])
				delete paramDict[ obj ];

			var container : DisplayObjectContainer = obj as DisplayObjectContainer;

			if ( container )
			{
				for ( var i : int = 0; i < container.numChildren; ++i )
				{
					removeFromParam( container.getChildAt( i ), paramDict );
				}
			}
		}

		protected function recreateFromParam( obj : DisplayObject, paramDict : Dictionary, newDict : Dictionary ) : void
		{
			if ( paramDict[ obj ])
			{
				newDict[ obj ] = paramDict[ obj ];
			}

			var container : DisplayObjectContainer = obj as DisplayObjectContainer;

			if ( container && !ParamUtil.isLibraryItem( container ))
			{
				for ( var i : int = 0; i < container.numChildren; ++i )
				{
					recreateFromParam( container.getChildAt( i ), paramDict, newDict );
				}
			}
		}

		protected function endSelect( obj : DisplayObject ) : void
		{
			SelectHelper.endSelect( obj );

			var container : DisplayObjectContainer = obj as DisplayObjectContainer;

			if ( container )
			{
				for ( var i : int = 0; i < container.numChildren; ++i )
				{
					SelectHelper.endSelect( container.getChildAt( i ));
				}
			}
		}

		public function removeTree( obj : DisplayObject ) : void
		{
			var parent : DisplayObjectContainer = obj.parent;

			selectObject( null );

			removeFromParam( obj, _extraParamsDict );

			obj.removeFromParent();

			endSelect( obj );

			setLayerChanged();

			selectParent( parent );

			setChanged();
		}

		protected function selectParent( parent : DisplayObjectContainer ) : void
		{
			while ( _extraParamsDict[ parent ] == null && parent.parent )
			{
				parent = parent.parent;
			}

			if ( parent === _root )
				selectObject( null );
			else
				selectObject( parent );
		}

		protected function setRoot( obj : DisplayObjectContainer, param : Object ) : void
		{
			if ( _root )
			{
				_root.removeFromParent( true );
			}

			_root = obj;
			_root.x = 0;
			_root.y = 0;
			_layoutContainer.addChild( _root );
			_extraParamsDict[ obj ] = param;
		}

		protected function initUI() : void
		{
			_bgCanvas = new Canvas();
			_bgCanvas.touchable = false;

			_backgroundContainer = new Sprite();
			_backgroundContainer.touchable = false;

			_layoutContainer = new Sprite();

			_snapContainer = new Sprite();
			_snapContainer.touchable = false;

			_selectBoundingBox = new InteractiveBoundingBox( 0x0066cc, this, true );
			_hoverBoundingBox = new InteractiveBoundingBox( 0xff0000, this, false );

			_mutliSelectBox = new MultiSelectBoundingBox( 0x0066cc, 1, 1 );

			this.addChild( _bgCanvas );
			this.addChild( _backgroundContainer );
			this.addChild( _layoutContainer );
			this.addChild( _snapContainer );
			this.addChild( _selectBoundingBox );
			this.addChild( _hoverBoundingBox );
			this.addChild( _mutliSelectBox );

			this.enableScaleBox = false;
		}

		public function createFromData( data : Object, createHandler : Function = null ) : void
		{
			var parent : DisplayObjectContainer = getParent();

			var result : Object = _uiBuilder.createUIElement( data );
			var paramDict : Dictionary = new Dictionary();

			var obj : DisplayObject = result.object;
			paramDict[ obj ] = result.params;

			_historyManager.add( new CreateOperation( obj, paramDict, parent ));

			addFrom( obj, result.params, parent );

			selectObject( obj );

			if ( createHandler != null )
			{
				createHandler( obj );
			}

			setLayerChanged();

			setChanged();
		}

		/**
		 * 刷新多选框
		 */
		public function refreshMultiSelect() : void
		{
			_mutliSelectBox.redraw();
		}

		public function alignUI( alignType : int ) : void
		{
			UIAlignType.alignUI( alignType, _mutliSelectBox.targets );
			_mutliSelectBox.redraw();
		}

		public function selectAll() : void
		{
			_mutliSelectBox.clean();
			if ( _root.touchable )
			{
				var count : int = _root.numChildren;
				for ( var i : int = 0; i < count; i++ )
				{
					var child : DisplayObject = _root.getChildAt( i );
					if ( child.touchable )
						_mutliSelectBox.addDisplayObject( child );
				}
			}
			_mutliSelectBox.redraw();
		}

		public function get hasFocus() : Boolean
		{
			return !( FocusManager.focus != null &&
				( FocusManager.focus is TextInput ||
				FocusManager.focus is TextArea ||
				FocusManager.focus is TextField ));
		}

		protected function getParent() : DisplayObjectContainer
		{
			if ( _selectedObject )
			{
				if ( !ParamUtil.isLibraryItem( _selectedObject ) && _uiBuilder.isContainer( _extraParamsDict[ _selectedObject ]))
				{
					return _selectedObject as DisplayObjectContainer;
				}
				else
				{
					return _selectedObject.parent;
				}
			}
			else
			{
				return _root;
			}
		}

		protected function getObjectsByPrefixTraversal( container : DisplayObjectContainer, paramDict : Dictionary, result : Array ) : void
		{
			result.push( container );

			if ( ParamUtil.isLibraryItem( container ))
			{
				return;
			}

			for ( var i : int = 0; i < container.numChildren; ++i )
			{
				var child : DisplayObject = container.getChildAt( i );

				if ( paramDict[ child ])
				{
					if ( _uiBuilder.isContainer( paramDict[ child ]))
					{
						getObjectsByPrefixTraversal( child as DisplayObjectContainer, paramDict, result );
					}
					else
					{
						result.push( child );
					}
				}
			}
		}

		protected function getLayer( container : DisplayObjectContainer, obj : DisplayObject, layer : int ) : int
		{
			for ( var i : int = 0; i < container.numChildren; ++i )
			{
				var child : DisplayObject = container.getChildAt( i );

				if ( child === obj )
				{
					return layer;
				}
				else if ( child is DisplayObjectContainer )
				{
					var l : int = getLayer( child as DisplayObjectContainer, obj, layer + 1 );
					if ( l >= 0 )
					{
						return l;
					}
				}
			}

			return -1;
		}

		protected function getPrefixFromObject( obj : DisplayObject ) : String
		{
			var layer : int = getLayer( _root, obj, 1 );

			var str : String = "";
			for ( var i : int = 0; i < layer; ++i )
			{
				str += "----";
			}

			return str;
		}

		protected function sortDataProvider() : void
		{
			var dict : Dictionary = new Dictionary();

			for ( var i : int = 0; i < _dataProvider.length; ++i )
			{
				var item : Object = _dataProvider.getItemAt( i );
				dict[ item.obj ] = item;
			}

			var result : Array = [];

			getObjectsByPrefixTraversalExpand( _root, _extraParamsDict, result, dict );

			_dataProviderForList = new ListCollection();
			for each ( var obj : DisplayObject in result )
			{
				_dataProviderForList.push( dict[ obj ]);
			}
		}

		protected function getObjectsByPrefixTraversalExpand( container : DisplayObjectContainer, paramDict : Dictionary, result : Array, dict : Dictionary ) : void
		{
			result.push( container );

			var itemInfo : Object = dict[ container ];
			if ( itemInfo && !itemInfo.expand )
				return;

			for ( var i : int = 0; i < container.numChildren; ++i )
			{
				var child : DisplayObject = container.getChildAt( i );

				if ( paramDict[ child ])
				{
					if ( _uiBuilder.isContainer( paramDict[ child ]))
					{
						getObjectsByPrefixTraversalExpand( child as DisplayObjectContainer, paramDict, result, dict );
					}
					else
					{
						result.push( child );
					}
				}
			}
		}

		public function isContainer( object : DisplayObject ) : Boolean
		{
			var param : Object = _extraParamsDict[ object ];
			if ( param == null )
			{
				return object is DisplayObjectContainer;
			}
			else
			{
				return _uiBuilder.isContainer( param )
			}
		}

		public function setDocumentPanel( documentPanel : DocumentPanel ) : void
		{
			_documentPanel = documentPanel;

			reset();
		}

		private var _active : Boolean = true;

		public function setActive( value : Boolean ) : void
		{
			_active = value;
			if ( _active )
			{
				Starling.current.stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
				Starling.current.nativeStage.addEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );
			}
			else
			{
				Starling.current.stage.removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
				Starling.current.nativeStage.removeEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );
			}
		}

		public function selectObject( obj : DisplayObject, ctrlKey : Boolean = false ) : void
		{
			if ( obj != null )
			{
				hoverObject( null );
				_mutliSelectBox.clean();
			}

			if ( _selectedObject === obj )
			{
				return;
			}
			else
			{
				if ( _selectedObject )
				{
					_selectedObject.removeEventListener( TouchEvent.TOUCH, onTouchSelectObject );
					_selectBoundingBox.target = null;
				}

				_selectedObject = obj;

				if ( _selectedObject != null )
				{
					if ( ParamUtil.isLibraryItem( _selectedObject ))
						_selectedObject.addEventListener( TouchEvent.TOUCH, onTouchSelectObject );

					if ( _selectedObject is FeathersControl )
					{
						FeathersControl( _selectedObject ).invalidate();
					}

					if ( _selectedObject != rootNode )
					{
						_selectBoundingBox.target = _selectedObject;
					}
				}

				//TODO 此处应该删除setChanged()
				setChanged();
				setSelectChanged();
			}
		}

		private function onTouchSelectObject( event : TouchEvent ) : void
		{
			var touch : Touch = event.getTouch( _selectedObject, TouchPhase.ENDED );
			if ( touch == null )
				return;

			if ( touch.tapCount >= 2 )
			{
				var linkage : String = ParamUtil.getLibraryName( _selectedObject );
				var libraryData : Object = UIEditorApp.instance.documentEditor.getLibrary( linkage );
				UIEditorApp.instance.notificationDispatcher.dispatchEventWith( DocumentEventType.EDIT_LIBRARY_ITEM, false, { label: linkage, data: libraryData });
			}
		}

		public function hoverObject( obj : DisplayObject ) : void
		{
			//已选中的不显示
			if ( _selectedObject != null && _selectedObject == obj )
			{
				obj = null;
			}

			if ( _hoverObject === obj )
			{
				return;
			}
			else
			{
				if ( _hoverObject )
				{
					_hoverBoundingBox.target = null;
				}

				_hoverObject = obj;

				if ( _hoverObject )
				{
					_hoverBoundingBox.target = _hoverObject;
				}
			}
		}

		public function selectObjectsByRect( rect : Rectangle ) : void
		{
			if ( _root == null )
				return;
			
			if ( rect.width == 0 || rect.height == 0 )
			{
				if ( rect.x < 0 || rect.y < 0 || rect.x > this.width || rect.y > this.height )
				{
					if ( _root.touchable )
						selectObject( _root );
				}
				_mutliSelectBox.clean();
				_mutliSelectBox.redraw();
				return;
			}
			
			var scale : Number = this.canvasScale;
			
			rect.x /= scale;
			rect.y /= scale;
			rect.width /= scale;
			rect.height /= scale;

			selectObject( null );
			hoverObject( null );

			_mutliSelectBox.clean();
			var targetRect : Rectangle = new Rectangle();
			if ( _root.touchable && _root.visible )
			{
				var count : int = _root.numChildren;
				for ( var i : int = 0; i < count; i++ )
				{
					var child : DisplayObject = _root.getChildAt( i );
					if ( child.touchable && child.visible )
					{
						child.getBounds( _root, targetRect );
						if ( rect.intersects( targetRect ))
						{
							_mutliSelectBox.addDisplayObject( child );
						}
					}
				}
			}
			_mutliSelectBox.redraw();

			//如果没有选中的目标，则选中root
			if ( !_mutliSelectBox.selected )
			{
				if ( _root.touchable )
					selectObject( _root );
			}
		}

		private function onMouseWheel( event : MouseEvent ) : void
		{
			if ( event.ctrlKey )
			{
				var delta : Number = event.delta;

				this.canvasScale += delta * 0.03;
			}
		}

		private function onKeyDown( event : KeyboardEvent ) : void
		{
			switch ( event.keyCode )
			{
				case Keyboard.UP:
					if ( hasFocus )
						move( 0, event.ctrlKey ? -10 : -1, true );
					break;
				case Keyboard.DOWN:
					if ( hasFocus )
						move( 0, event.ctrlKey ? 10 : 1, true );
					break;
				case Keyboard.LEFT:
					if ( hasFocus )
						move( event.ctrlKey ? -10 : -1, 0, true );
					break;
				case Keyboard.RIGHT:
					if ( hasFocus )
						move( event.ctrlKey ? 10 : 1, 0, true );
					break;
				case Keyboard.A:
					if ( hasFocus && event.ctrlKey )
						selectAll();
					break;
			}
		}

		public function move( dx : Number, dy : Number, ignoreSnapPixel : Boolean = false ) : Boolean
		{
			if ( _mutliSelectBox.selected )
			{
				_mutliSelectBox.move( dx, dy );
			}
			else
			{
				if ( !_selectedObject )
					return false;

				if ( _selectedObject == rootNode )
					return false;

				var data : PixelSnapperData;

				if ( snapPixel && !ignoreSnapPixel )
				{
					_snapContainer.removeChildren( 0, -1, true );

					data = PixelSnapper.snap( _selectedObject, _selectedObject.parent, this.parent, new Point( dx, dy ));

					if ( data )
					{
						dx = data.deltaX;
						dy = data.deltaY;
					}
				}

				_selectedObject.x += dx;
				_selectedObject.y += dy;

				recordMoveHistory( dx, dy );

				if ( data )
				{
					_snapContainer.x = _selectedObject.parent.x;
					_snapContainer.y = _selectedObject.parent.y;
					PixelSnapper.drawSnapLine( _snapContainer, data )
				}

				setChanged();
			}

			return !snapPixel || ( dx * dx + dy * dy > 0.5 );
		}

		public function onDropData( offset : Point, dragData : DragData ) : void
		{
			offset.x /= this.canvasScale;
			offset.y /= this.canvasScale;

			var parent : DisplayObjectContainer = getParent();
			if ( parent != null )
			{
				var point : Point = _root.localToGlobal( offset );
				parent.globalToLocal( point, offset );
			}

			var editorData : Object;
			if ( dragData.hasDataForFormat( DragFormat.FORMAT_ASSET ))
			{
				editorData = dragData.getDataForFormat( DragFormat.FORMAT_ASSET );

				editorData.x = Math.min( Math.max( offset.x - editorData.width / 2,
					0 ), this.width - editorData.width ); //keep within the bounds of the target
				editorData.y = Math.min( Math.max( offset.y - editorData.height / 2,
					0 ), this.height - editorData.height ); //keep within the bounds of the target

				UIComponentHelper.createComponent( editorData );
			}
			else if ( dragData.hasDataForFormat( DragFormat.FORMAT_COMPONENT ))
			{
				editorData = dragData.getDataForFormat( DragFormat.FORMAT_COMPONENT );

				editorData.x = offset.x;
				editorData.y = offset.y;

				UIComponentHelper.createComponent( editorData );
			}
			else if ( dragData.hasDataForFormat( DragFormat.FORMAT_LIBRARY ))
			{
				var linkage : String = dragData.getDataForFormat( DragFormat.FORMAT_LIBRARY ).label;

				createComponentFromLibrary( linkage, offset.x, offset.y );
			}
		}

		/**
		 * 从库中创建一个文件
		 */
		public function createComponentFromLibrary( linkage : String, x : Number, y : Number ) : void
		{
			var libraryItem : Object = ParamUtil.cloneObject( UIEditorApp.instance.documentEditor.getLibrary( linkage ));
			if ( libraryItem == null )
				return;

			var result : Object = _uiBuilder.load({ layout: libraryItem }, UIEditorApp.instance.documentEditor.librarys );

			var container : DisplayObjectContainer = result.object;
			container.touchGroup = true;
			container.customData = { isLibrary: true, linkage: linkage };

			container.x = x;
			container.y = y;

			addTree( container, result.params );
		}

		public function get rootName() : String
		{
			return _root.name;
		}

		public function set rootName( name : String ) : void
		{
			_root.name = name;
			setChanged();
		}

		public function get snapPixel() : Boolean
		{
			return _snapPixel;
		}

		public function set snapPixel( value : Boolean ) : void
		{
			_snapPixel = value;
		}

		public function get showTextBorder() : Boolean
		{
			return _showTextBorder;
		}

		public function set showTextBorder( value : Boolean ) : void
		{
			_showTextBorder = value;

			for ( var i : int = 0; i < _dataProvider.length; ++i )
			{
				var textField : TextField = _dataProvider.getItemAt( i ).obj as TextField;
				if ( textField )
					textField.border = value;
			}
		}

		public function expandChange() : void
		{
			sortDataProvider();
			dispatchEventWith( DocumentEventType.EXPAND_CHANGE );
		}

		public function setLayerChanged() : void
		{
			sortDataProvider();
		}

		public function setSelect( data : Object ) : void
		{
			setLayerChanged();
		}

		protected function isAncestorOf( child : DisplayObject, parent : DisplayObject ) : Boolean
		{
			var p : DisplayObject = child;
			while ( p )
			{
				p = p.parent;
				if ( p === parent )
					return true;
			}

			return false;
		}

		public function get selectedObject() : DisplayObject
		{
			return _selectedObject;
		}

		public function get historyManager() : HistoryManager
		{
			return _historyManager;
		}

		public function set canvasWidth( width : int ) : void
		{
			if ( _canvasSize.x != width )
			{
				canvasSize = new Point( width, _canvasSize.y );
			}
		}

		public function set canvasHeight( height : int ) : void
		{
			if ( _canvasSize.y != height )
			{
				canvasSize = new Point( _canvasSize.x, height );
			}
		}

		public function get canvasWidth() : int
		{
			return _canvasSize.x;
		}

		public function get canvasHeight() : int
		{
			return _canvasSize.y;
		}

		public function get canvasSize() : Point
		{
			return _canvasSize;
		}

		public function set canvasSize( value : Point ) : void
		{
			if ( _canvasSize.x != value.x || _canvasSize.y != value.y )
			{
				_canvasSize = value;
			}

			resize();

			_documentPanel.invalidate();

			dispatchEventWith( DocumentEventType.CANVAS_SIZE_CHANGE );
		}

		protected function exportSetting() : Object
		{
			var setting : Object = {};

			if ( canvasSize )
			{
				setting.canvasSize = { x: _canvasSize.x, y: _canvasSize.y };
			}

			setting.backgroundColor = backgroundColor;

			return setting;
		}

		protected function importSetting( setting : Object ) : void
		{
			if ( setting )
			{
				if ( setting.canvasSize )
				{
					canvasSize = new Point( setting.canvasSize.x, setting.canvasSize.y );
				}
				if ( setting.hasOwnProperty( "backgroundColor" ))
				{
					backgroundColor = setting.backgroundColor;

					this.backgroundColor = backgroundColor;
				}
			}

			setChanged();
		}

		public function resize() : void
		{
			this.mask = new Quad( canvasSize.x * _layoutContainer.scale, canvasSize.y * _layoutContainer.scale );

			_documentPanel.resizeBg();

			_bgCanvas.clear();
			_bgCanvas.beginFill( _backgroundColor, 1 );
			_bgCanvas.drawRectangle( 0, 0, canvasSize.x * _layoutContainer.scale, canvasSize.y * _layoutContainer.scale );
			_bgCanvas.endFill();

			this.x = int(( _documentPanel.width - _canvasSize.x * _layoutContainer.scaleX ) * 0.5 );
			this.y = int(( _documentPanel.height - _canvasSize.y * _layoutContainer.scaleY ) * 0.5 );
			if ( this.x < 0 )
				this.x = 0;
			if ( this.y < 0 )
				this.y = 0;
		}

		public function setSelectChanged() : void
		{
			dispatchEventWith( DocumentEventType.SELECT_CHANGE );
		}

		public function setChanged() : void
		{
			if ( _mutliSelectBox.selected )
			{
				_mutliSelectBox.redraw();
			}
		}

		public function get uiBuilder() : IUIBuilder
		{
			return _uiBuilder;
		}

		public function get rootNode() : DisplayObjectContainer
		{
			return _root;
		}

		public function get enableScaleBox() : Boolean
		{
			return _selectBoundingBox.enable;
		}

		public function set enableScaleBox( value : Boolean ) : void
		{
			_selectBoundingBox.enable = value;
			_hoverBoundingBox.enable = false;
		}

		public function get canvasScale() : Number
		{
			return _layoutContainer.scaleX;
		}

		public function set canvasScale( value : Number ) : void
		{
			if ( value < 0.1 )
				value = 0.1;

			if ( canvasScale != value )
			{
				_layoutContainer.scale = value;
				_backgroundContainer.scale = value;

				_mutliSelectBox.scale = value;

				_documentPanel.invalidate();

				resize();

				_selectBoundingBox.reload();
				_hoverBoundingBox.reload();

				dispatchEventWith( DocumentEventType.CANVAS_SIZE_CHANGE );

				setChanged();
			}
		}

		private var _backgroundFile : String;
		private var _backgroundImage : Image;
		private var _backgroundX : Number = 0;
		private var _backgroundY : Number = 0;

		public function set background( filePath : String ) : void
		{
			_backgroundContainer.removeChildren( 0, -1, true );
			_backgroundImage = null;

			_backgroundFile = filePath;
			if ( _backgroundFile == null || _backgroundFile == "" )
			{
				return;
			}

			var file : File = new File( _backgroundFile );
			if ( file == null || !file.exists )
			{
				return;
			}

			var backgroundImage : Image = null;
			if ( file.extension == "jpeg" || file.extension == "atf" )
			{
				var byteArray : ByteArray = FileLoader.getByteArray( file );
				var texture : Texture = Texture.fromAtfData( byteArray, 1, false );
				_backgroundImage = new Image( texture );
			}

			if ( _backgroundImage )
			{
				_backgroundImage.x = backgroundX;
				_backgroundImage.y = backgroundY;
				_backgroundContainer.addChild( _backgroundImage );
			}
		}

		public function get background() : String
		{
			return _backgroundFile;
		}

		public function get backgroundColor() : uint
		{
			return _backgroundColor;
		}

		public function set backgroundColor( value : uint ) : void
		{
			if ( _backgroundColor == value )
				return;

			var oldValue : uint = _backgroundColor;
			_backgroundColor = value;

			_bgCanvas.clear();
			_bgCanvas.beginFill( _backgroundColor, 1 );
			_bgCanvas.drawRectangle( 0, 0, canvasSize.x * _layoutContainer.scale, canvasSize.y * _layoutContainer.scale );
			_bgCanvas.endFill();

			dispatchEventWith( DocumentEventType.BACK_GROUND_COLOR_CHANGE );
		}

		public function set backgroundX( value : Number ) : void
		{
			if ( _backgroundX != value )
			{
				_backgroundX = value;
				if ( _backgroundImage )
				{
					_backgroundImage.x = _backgroundX;
				}
			}
		}

		public function get backgroundX() : Number
		{
			return _backgroundX;
		}

		public function set backgroundY( value : Number ) : void
		{
			if ( _backgroundY != value )
			{
				_backgroundY = value;
				if ( _backgroundImage )
				{
					_backgroundImage.y = _backgroundY;
				}
			}
		}

		public function get backgroundY() : Number
		{
			return _backgroundY;
		}

		public function useGameTheme( target : IFeathersControl ) : Boolean
		{
			//work around to fix theme pollution, not ideal
			var obj : DisplayObject = target as DisplayObject;
			while ( obj )
			{
				if ( obj is IFeathersControl && IFeathersControl( obj ).styleName.indexOf( "uieditor" ) != -1 )
					return false;
				obj = obj.parent;
			}

			var object : DisplayObject = target as DisplayObject;

			return ( object && object.stage == null ) || ( this.contains( object ));
		}

		public function get extraParamsDict() : Dictionary
		{
			return _extraParamsDict;
		}

		public function cut() : void
		{
			if ( !visible || !hasFocus )
				return;

			if ( _mutliSelectBox.selected )
			{
				copy();

				var newDict : Dictionary = new Dictionary();
				var targets : Array = _mutliSelectBox.targets.concat();
				for ( var i : int = 0; i < targets.length; i++ )
				{
					var target : DisplayObject = targets[ i ];

					recreateFromParam( target, _extraParamsDict, newDict );
				}

				_historyManager.add( new CutOperation( targets, newDict, this ));

				for ( i = 0; i < targets.length; i++ )
				{
					target = targets[ i ];
					removeTree( target );
				}

				_mutliSelectBox.clean();
				return;
			}

			if ( _selectedObject )
			{
				if ( _root == _selectedObject )
				{
					MsgBox.show( "警告", "不能移除主类" );
					return;
				}

				copy();
				newDict = new Dictionary();
				recreateFromParam( _selectedObject, _extraParamsDict, newDict );
				_historyManager.add( new CutOperation([ _selectedObject ], newDict, this ));
				removeTree( _selectedObject );
			}
		}

		public function copy() : void
		{
			if ( !visible || !hasFocus )
				return;

			if ( _mutliSelectBox.selected )
			{
				var targets : Array = _mutliSelectBox.targets.concat();
				Clipboard.generalClipboard.setData( ClipboardFormats.TEXT_FORMAT, _uiBuilder.copy( targets, _extraParamsDict ));
				return;
			}

			if ( _selectedObject )
				Clipboard.generalClipboard.setData( ClipboardFormats.TEXT_FORMAT, _uiBuilder.copy([ _selectedObject ], _extraParamsDict ));
		}

		public function paste() : void
		{
			if ( !visible || !hasFocus )
				return;
			try
			{
				var libraryDic : Dictionary = UIEditorApp.instance.documentEditor.librarys;
				var data : Object = _uiBuilder.paste( Clipboard.generalClipboard.getData( ClipboardFormats.TEXT_FORMAT ) as String, libraryDic );
				if ( data )
				{
					var result : Object;
					var root : DisplayObject;
					var paramDict : Dictionary;
					var parent : DisplayObjectContainer;
					if ( data is Array )
					{
						var array : Array = data as Array;
						for ( var i : int = 0; i < array.length; i++ )
						{
							result = _uiBuilder.load( array[ i ], libraryDic );
							root = result.object;
							paramDict = result.params;

							//root.x = root.y = 0;

							parent = getParent();
							_historyManager.add( new PasteOperation( root, paramDict, parent ));

							addTree( root, paramDict, parent, -1, false );
						}
					}
					else
					{
						result = _uiBuilder.load( data, libraryDic );
						root = result.object;
						paramDict = result.params;

						//root.x = root.y = 0;

						parent = getParent();
						_historyManager.add( new PasteOperation( root, paramDict, parent ));

						addTree( root, paramDict, parent, -1, false );
					}

				}
			}
			catch ( e : Error )
			{
				MsgBox.show( "警告", "不支持此类型" );
			}
		}

		public function addTree( rootNode : DisplayObject, paramDict : Dictionary, parent : DisplayObjectContainer = null, index : int = -1, selected : Boolean = true ) : void
		{
			if ( parent == null )
			{
				parent = getParent();
			}

			addFrom( rootNode, paramDict[ rootNode ], parent, index );

			if ( !ParamUtil.isLibraryItem( root ))
			{
				var container : DisplayObjectContainer = rootNode as DisplayObjectContainer;
				if ( container )
				{
					var objects : Array = [];
					getObjectsByPrefixTraversal( container, paramDict, objects );

					for each ( var obj : DisplayObject in objects )
					{
						if ( obj !== rootNode )
							addFrom( obj, paramDict[ obj ], null );
					}
				}
			}

			if ( selected )
				selectObject( rootNode );

			setLayerChanged();

			setChanged();
		}

		public function endMove() : void
		{
			_snapContainer.removeChildren( 0, -1, true );
		}

		public function moveLayerUp() : void
		{
			if ( !_selectedObject )
				return;

			var parent : DisplayObjectContainer = _selectedObject.parent;

			var index : int = parent.getChildIndex( _selectedObject );
			if ( index > 0 )
			{
				_historyManager.add( new MoveLayerOperation( _selectedObject, _selectedObject.parent, index, index - 1 ));

				parent.setChildIndex( _selectedObject, index - 1 );

				setLayerChanged()

				setChanged();
			}

		}

		public function moveLayerDown() : void
		{
			if ( !_selectedObject )
				return;

			var parent : DisplayObjectContainer = _selectedObject.parent;

			var index : int = parent.getChildIndex( _selectedObject );
			if ( index < parent.numChildren - 1 )
			{
				_historyManager.add( new MoveLayerOperation( _selectedObject, _selectedObject.parent, index, index + 1 ));

				parent.setChildIndex( _selectedObject, index + 1 );

				setLayerChanged();

				setChanged();
			}

		}

		protected function addFrom( obj : DisplayObject, param : Object, parent : DisplayObjectContainer = null, index : int = -1 ) : void
		{
			if (( ParamUtil.isLibraryItem( obj ) || !_uiBuilder.isContainer( param )) && obj != rootNode )
			{
				DragHelper.startDrag( obj,
					function( obj : DisplayObject, dx : Number, dy : Number ) : Boolean
					{

						dx /= scale;
						dy /= scale;
						return move( dx, dy );
					},
					function() : void
					{
						endMove();
					});

				SelectHelper.startSelect( obj,
					function( object : DisplayObject, ctrlKey : Boolean ) : void
					{
						if ( selectedObject != _root )
						{
							if ( !( selectedObject is DisplayObjectContainer ) ||
								!DisplayObjectContainer( selectedObject ).contains( object ))
								selectObject( object, ctrlKey );
						}
						else
						{
							selectObject( object, ctrlKey );
						}
					},
					function( object : DisplayObject ) : void
					{
						if ( _hoverObject == null ||
							!( _hoverObject is DisplayObjectContainer ) ||
							!DisplayObjectContainer( _hoverObject ).contains( object ))
							hoverObject( object );
					});
			}

			if ( obj is TextField )
			{
				TextField( obj ).border = showTextBorder;
			}

			if ( obj.hasOwnProperty( "scaleWhenDown" ) && obj[ "scaleWhenDown" ] is Number )
			{
				obj[ "scaleWhenDown" ] = 1;
			}

			if ( obj is IValidating )
			{
				IValidating( obj ).validate();
			}

			_extraParamsDict[ obj ] = param;


			if ( isAncestorOf( obj, _root ))
			{
				//do nothing
			}
			else if ( parent )
			{
				if ( index < 0 )
					parent.addChild( obj );
				else
					parent.addChildAt( obj, index );
			}

			var prefix : String = getPrefixFromObject( obj );

			var lock : Boolean = !obj.touchable;
			var hidden : Boolean = !obj.visible;

			var itemObj : Object = { label: obj.name, "hidden": hidden, "lock": lock, "expand": true, "obj": obj, "prefix": prefix };
			_dataProvider.push( itemObj );
			_dataProviderForList.push( itemObj );
		}

		public function duplicate() : void
		{
			if ( !visible )
				return;

			if ( _selectedObject == null || _selectedObject === _root )
			{
				MsgBox.show( "警告", "不能复制主类" );
				return;
			}

			copy();
			paste();
		}

		public function get dataProvider() : ListCollection
		{
			return _dataProviderForList;
		}

		public function refreshDataProvider() : void
		{
			for ( var i : int = 0; i < _dataProvider.length; ++i )
			{
				var item : Object = _dataProvider.getItemAt( i );

				updateHidden( item.obj, item.hidden );
				updateLock( item.obj, item.lock );
			}
		}

		protected function updateHidden( obj : DisplayObject, value : Boolean ) : void
		{
			obj.visible = !value;

			if ( selectedObject == obj )
			{
				selectObject( null );
			}
		}

		protected function updateLock( obj : DisplayObject, value : Boolean ) : void
		{
			obj.touchable = !value;

			if ( !obj.touchable && selectedObject == obj )
			{
				selectObject( null );
			}
		}

		protected function refreshLabels() : void
		{
			for ( var i : int = 0; i < _dataProviderForList.length; ++i )
			{
				var item : Object = _dataProviderForList.getItemAt( i );
				var obj : DisplayObject = item.obj;
				item.label = obj.name;
				_dataProviderForList.updateItemAt( i );
			}
		}

		public function selectObjectAtIndex( index : int ) : void
		{
			var item : Object = _dataProviderForList.getItemAt( index );

			var obj : DisplayObject = item.obj;
			if ( obj && !item.hidden && !item.lock )
			{
				selectObject( obj );
			}
		}

		public function get selectedIndex() : int
		{
			if ( _selectedObject )
			{
				for ( var i : int = 0; i < _dataProviderForList.length; ++i )
				{
					var item : Object = _dataProviderForList.getItemAt( i );

					if ( item && item.obj === _selectedObject )
					{
						return i;
					}
				}
			}

			return -1;
		}

		public function remove() : void
		{
			if ( _mutliSelectBox.selected )
			{
				var newDict : Dictionary = new Dictionary();
				var targets : Array = _mutliSelectBox.targets.concat();
				for ( var i : int = 0; i < targets.length; i++ )
				{
					var target : DisplayObject = targets[ i ];
					recreateFromParam( target, _extraParamsDict, newDict );
				}

				_historyManager.add( new DeleteOperation( targets, newDict, this ));

				for ( i = 0; i < targets.length; i++ )
				{
					target = targets[ i ];
					removeTree( target );
				}

				_mutliSelectBox.clean();
				return;
			}
			if ( _selectedObject )
			{
				if ( _root == _selectedObject )
				{
					MsgBox.show( "警告", "不能移除主类" );
					return;
				}

				newDict = new Dictionary();
				recreateFromParam( _selectedObject, _extraParamsDict, newDict );
				_historyManager.add( new DeleteOperation([ _selectedObject ], newDict, this ));
				removeTree( _selectedObject );
			}
		}

		protected function recordPropertyChangeHistory( data : Object ) : void
		{
			if ( data.hasOwnProperty( "oldValue" ))
			{
				var operation : IHistoryOperation = new PropertyChangeOperation( data.target, data.propertyName, data.oldValue, data.target[ data.propertyName ]);
				_historyManager.add( operation );
			}
		}

		public function recordMultiMoveHistory( dx : Number, dy : Number, targets : Array ) : void
		{
			var befores : Array = [];
			var afters : Array = [];
			for ( var i : int = 0; i < targets.length; i++ )
			{
				var target : Object = targets[ i ];
				befores[ i ] = new Point( target.x - dx, target.y - dy );
				afters[ i ] = new Point( target.x, target.y );
			}
			var operation : IHistoryOperation = new MultiMoveOperation( targets.concat(), befores, afters );
			_historyManager.add( operation );
		}

		protected function recordMoveHistory( dx : Number, dy : Number ) : void
		{
			var operation : IHistoryOperation = new MoveOperation( _selectedObject, new Point( _selectedObject.x - dx, _selectedObject.y - dy ), new Point( _selectedObject.x, _selectedObject.y ));
			_historyManager.add( operation );
		}
	}
}
