package uieditor.editor.helper
{
	import flash.geom.Rectangle;
	
	import starling.display.Canvas;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.Event;
	
	import uieditor.editor.UIEditorApp;

	/**
	 *多选框
	 */
	public class MultiSelectBoundingBox extends Sprite
	{
		private var _targets : Array;

		private var _canvas : Canvas;

		private var _color : uint;
		private var _alpha : Number;
		private var _thickness : Number;

		public function MultiSelectBoundingBox( color : uint, alpha : Number = 0.5, thickness : Number = 1 )
		{
			_color = color;
			_alpha = alpha;
			_thickness = thickness;

			_canvas = new Canvas();
			this.addChild( _canvas );

			_canvas.touchable = true;

			_targets = [];

			DragHelper.startDrag( _canvas, onDrag, onComplete );
		}

		private function onPropertyChange( event : Event ) : void
		{
			this.redraw();
		}

		public function get targets() : Array
		{
			return _targets;
		}

		public function set targets( targets : Array ) : void
		{
			_targets = targets.concat();
			redraw();
		}

		public function get selected() : Boolean
		{
			return _targets.length > 0;
		}

		public function clean() : void
		{
			_targets.length = 0;
			redraw();
		}

		public function addDisplayObject( object : DisplayObject ) : void
		{
			_targets.push( object );
		}

		public function redraw() : void
		{
			_canvas.clear();

			for ( var i : int = 0; i < _targets.length; i++ )
			{
				var target : DisplayObject = _targets[ i ];

				var rect : Rectangle = target.getBounds( target.parent );

				_canvas.beginFill( 0x0, 0 );
				_canvas.drawRectangle( rect.x, rect.y, rect.width, rect.height );
				_canvas.endFill();

				_canvas.beginFill( _color, _alpha );
				_canvas.drawRectangle( rect.x, rect.y, rect.width, _thickness );
				_canvas.drawRectangle( rect.x, rect.y + rect.height - _thickness, rect.width, _thickness );
				_canvas.drawRectangle( rect.x, rect.y, _thickness, rect.height );
				_canvas.drawRectangle( rect.x + rect.width - _thickness, rect.y, _thickness, rect.height );
				_canvas.endFill();
			}
		}

		private function onDrag( object : DisplayObject, dx : Number, dy : Number ) : Boolean
		{
			dx /= UIEditorApp.instance.documentEditor.scale;
			dy /= UIEditorApp.instance.documentEditor.scale;

			move( dx, dy );

			return ( dx * dx + dy * dy > 0.5 );
		}

		public function move( dx : Number, dy : Number ) : void
		{
			if ( dx == 0 && dy == 0 )
				return;

			for ( var i : int = 0; i < _targets.length; i++ )
			{
				var target : DisplayObject = _targets[ i ];

				target.x += dx;
				target.y += dy;
			}

			this.redraw();

			UIEditorApp.instance.documentEditor.recordMultiMoveHistory( dx, dy, _targets );
			UIEditorApp.instance.documentEditor.setChanged();
		}

		private function onComplete() : void
		{
			_canvas.x = 0;
			_canvas.y = 0;
		}

		override public function dispose() : void
		{
			super.dispose();
		}
	}
}

