// =================================================================================================
//
//	Starling Framework
//	Copyright Gamua GmbH. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.rendering
{
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	import starling.display.BlendMode;
	import starling.textures.Texture;
	import starling.utils.MathUtil;
	import starling.utils.MatrixUtil;
	import starling.utils.Pool;
	import starling.utils.RectangleUtil;

	/** The RenderState stores a combination of settings that are currently used for rendering.
	 *  This includes modelview and transformation matrices as well as context3D related settings.
	 *
	 *  <p>Starling's Painter instance stores a reference to the current RenderState.
	 *  Via a stack mechanism, you can always save a specific state and restore it later.
	 *  That makes it easy to write rendering code that doesn't have any side effects.</p>
	 *
	 *  <p>Beware that any context-related settings are not applied on the context
	 *  right away, but only after calling <code>painter.prepareToDraw()</code>.
	 *  However, the Painter recognizes changes to those settings and will finish the current
	 *  batch right away if necessary.</p>
	 *
	 *  <strong>Matrix Magic</strong>
	 *
	 *  <p>On rendering, Starling traverses the display tree, constantly moving from one
	 *  coordinate system to the next. Each display object stores its vertex coordinates
	 *  in its local coordinate system; on rendering, they must be moved to a global,
	 *  2D coordinate space (the so-called "clip-space"). To handle these calculations,
	 *  the RenderState contains a set of matrices.</p>
	 *
	 *  <p>By multiplying vertex coordinates with the <code>modelviewMatrix</code>, you'll get the
	 *  coordinates in "screen-space", or in other words: in stage coordinates. (Optionally,
	 *  there's also a 3D version of this matrix. It comes into play when you're working with
	 *  <code>Sprite3D</code> containers.)</p>
	 *
	 *  <p>By feeding the result of the previous transformation into the
	 *  <code>projectionMatrix</code>, you'll end up with so-called "clipping coordinates",
	 *  which are in the range <code>[-1, 1]</code> (just as needed by the graphics pipeline).
	 *  If you've got vertices in the 3D space, this matrix will also execute a perspective
	 *  projection.</p>
	 *
	 *  <p>Finally, there's the <code>mvpMatrix</code>, which is short for
	 *  "modelviewProjectionMatrix". This is simply a combination of <code>modelview-</code> and
	 *  <code>projectionMatrix</code>, combining the effects of both. Pass this matrix
	 *  to the vertex shader and all your vertices will automatically end up at the right
	 *  position.</p>
	 *
	 *  @see Painter
	 *  @see starling.display.Sprite3D
	 */
	public class RenderState
	{
		private static const CULLING_VALUES : Vector.<String> = new <String>
			[ Context3DTriangleFace.NONE, Context3DTriangleFace.FRONT,
			Context3DTriangleFace.BACK, Context3DTriangleFace.FRONT_AND_BACK ];

		/** The current, cumulated alpha value. Beware that, in a standard 'render' method,
		 *  this already includes the current object! The value is the product of current object's
		 *  alpha value and all its parents. @default 1.0
		 */
		public var alpha : Number;

		/** The texture that is currently being rendered into, or <code>null</code>
		 *  to render into the back buffer. On assignment, calls <code>setRenderTarget</code>
		 *  with its default parameters. */
		public var renderTarget : Texture;

		/** @private */
		internal var _blendMode : String;
		/** @private */
		internal var _modelviewMatrix : Matrix;

		private var _miscOptions : uint;
		private var _clipRect : Rectangle;
		private var _onDrawRequired : Function;

		private var _projectionMatrix3D : Matrix3D;
		private var _projectionMatrix3DRev : uint;
		private var _mvpMatrix3D : Matrix3D;

		// helper objects
		private static var sMatrix3D : Matrix3D = new Matrix3D();
		private static var sProjectionMatrix3DRev : uint = 0;

		/** Creates a new render state with the default settings. */
		public function RenderState()
		{
			reset();
		}

		/** Duplicates all properties of another instance on the current instance. */
		public function copyFrom( renderState : RenderState ) : void
		{
			if ( _onDrawRequired != null )
			{
				var currentTarget : TextureBase = renderTarget ? renderTarget.base : null;
				var nextTarget : TextureBase = renderState.renderTarget ? renderState.renderTarget.base : null;
				var cullingChanges : Boolean = ( _miscOptions & 0xf00 ) != ( renderState._miscOptions & 0xf00 );
				var clipRectChanges : Boolean = _clipRect || renderState._clipRect ?
					!RectangleUtil.compare( _clipRect, renderState._clipRect ) : false;

				if ( _blendMode != renderState._blendMode ||
					currentTarget != nextTarget || clipRectChanges || cullingChanges )
				{
					_onDrawRequired();
				}
			}

			this.alpha = renderState.alpha;
			_blendMode = renderState._blendMode;
			renderTarget = renderState.renderTarget;
			_miscOptions = renderState._miscOptions;

//			_modelviewMatrix.copyFrom( renderState._modelviewMatrix );
			var omvm : Matrix = renderState._modelviewMatrix;
			_modelviewMatrix.a = omvm.a;
			_modelviewMatrix.b = omvm.b;
			_modelviewMatrix.c = omvm.c;
			_modelviewMatrix.d = omvm.d;
			_modelviewMatrix.tx = omvm.tx;
			_modelviewMatrix.ty = omvm.ty;

			if ( _projectionMatrix3DRev != renderState._projectionMatrix3DRev )
			{
				_projectionMatrix3DRev = renderState._projectionMatrix3DRev;
				_projectionMatrix3D.copyFrom( renderState._projectionMatrix3D );
			}

			if ( _clipRect || renderState._clipRect )
				this.clipRect = renderState._clipRect;
		}

		/** Resets the RenderState to the default settings.
		 *  (Check each property documentation for its default value.) */
		public function reset() : void
		{
			this.alpha = 1.0;
			this.blendMode = BlendMode.NORMAL;
			this.culling = Context3DTriangleFace.NONE;
			this.renderTarget = null;
			this.clipRect = null;
			_projectionMatrix3DRev = 0;

			if ( _modelviewMatrix )
				_modelviewMatrix.identity();
			else
				_modelviewMatrix = new Matrix();

			if ( _projectionMatrix3D )
				_projectionMatrix3D.identity();
			else
				_projectionMatrix3D = new Matrix3D();

			if ( _mvpMatrix3D == null )
				_mvpMatrix3D = new Matrix3D();
		}

		// matrix methods / properties

		/** Prepends the given matrix to the 2D modelview matrix. */
		public function transformModelviewMatrix( matrix : Matrix ) : void
		{
			MatrixUtil.prependMatrix( _modelviewMatrix, matrix );
		}

		/** Creates a perspective projection matrix suitable for 2D and 3D rendering.
		 *
		 *  <p>The first 4 parameters define which area of the stage you want to view (the camera
		 *  will 'zoom' to exactly this region). The final 3 parameters determine the perspective
		 *  in which you're looking at the stage.</p>
		 *
		 *  <p>The stage is always on the rectangle that is spawned up between x- and y-axis (with
		 *  the given size). All objects that are exactly on that rectangle (z equals zero) will be
		 *  rendered in their true size, without any distortion.</p>
		 *
		 *  <p>If you pass only the first 4 parameters, the camera will be set up above the center
		 *  of the stage, with a field of view of 1.0 rad.</p>
		 */
		public function setProjectionMatrix( x : Number, y : Number, width : Number, height : Number,
			stageWidth : Number = 0, stageHeight : Number = 0,
			cameraPos : Vector3D = null ) : void
		{
			_projectionMatrix3DRev = ++sProjectionMatrix3DRev;
			MatrixUtil.createPerspectiveProjectionMatrix(
				x, y, width, height, stageWidth, stageHeight, cameraPos, _projectionMatrix3D );
		}

		/** This method needs to be called whenever <code>projectionMatrix3D</code> was changed
		 *  other than via <code>setProjectionMatrix</code>.
		 */
		public function setProjectionMatrixChanged() : void
		{
			_projectionMatrix3DRev = ++sProjectionMatrix3DRev;
		}

		/** Changes the modelview matrices (2D and, if available, 3D) to identity matrices.
		 *  An object transformed an identity matrix performs no transformation.
		 */
		public function setModelviewMatricesToIdentity() : void
		{
			_modelviewMatrix.identity();
		}

		/** Returns the current 2D modelview matrix.
		 *  CAUTION: Use with care! Each call returns the same instance.
		 *  @default identity matrix */
		public function get modelviewMatrix() : Matrix
		{
			return _modelviewMatrix;
		}

		public function set modelviewMatrix( value : Matrix ) : void
		{
			_modelviewMatrix.copyFrom( value );
		}

		/** Returns the current projection matrix. You can use the method 'setProjectionMatrix3D'
		 *  to set it up in an intuitive way.
		 *  CAUTION: Use with care! Each call returns the same instance. If you modify the matrix
		 *           in place, you have to call <code>setProjectionMatrixChanged</code>.
		 */
		public function get projectionMatrix3D() : Matrix3D
		{
			return _projectionMatrix3D;
		}

		public function set projectionMatrix3D( value : Matrix3D ) : void
		{
			setProjectionMatrixChanged();
			_projectionMatrix3D.copyFrom( value );
		}

		/** Calculates the product of modelview and projection matrix and stores it in a 3D matrix.
		 *  CAUTION: Use with care! Each call returns the same instance. */
		public function get mvpMatrix3D() : Matrix3D
		{
			_mvpMatrix3D.copyFrom( _projectionMatrix3D );

//			_mvpMatrix3D.prepend( MatrixUtil.convertTo3D( _modelviewMatrix, sMatrix3D ));
			var sRawData : Vector.<Number> = MatrixUtil.sRawData;
			sRawData[ 0 ] = _modelviewMatrix.a;
			sRawData[ 1 ] = _modelviewMatrix.b;
			sRawData[ 4 ] = _modelviewMatrix.c;
			sRawData[ 5 ] = _modelviewMatrix.d;
			sRawData[ 12 ] = _modelviewMatrix.tx;
			sRawData[ 13 ] = _modelviewMatrix.ty;
			sMatrix3D.copyRawDataFrom( sRawData );

			_mvpMatrix3D.prepend( sMatrix3D );

			return _mvpMatrix3D;
		}

		// other methods

		/** Changes the the current render target.
		 *
		 *  @param target     Either a texture or <code>null</code> to render into the back buffer.
		 *  @param enableDepthAndStencil  Indicates if depth and stencil testing will be available.
		 *                    This parameter affects only texture targets.
		 *  @param antiAlias  The anti-aliasing quality (range: <code>0 - 16</code>).
		 *                    This parameter affects only texture targets. Note that at the time
		 *                    of this writing, AIR supports anti-aliasing only on Desktop.
		 */
		public function setRenderTarget( target : Texture, enableDepthAndStencil : Boolean = true, antiAlias : int = 0 ) : void
		{
			var currentTarget : TextureBase = renderTarget ? renderTarget.base : null;
			var newTarget : TextureBase = target ? target.base : null;
			var newOptions : uint = MathUtil.min( antiAlias, 16 ) | uint( enableDepthAndStencil ) << 4;
			var optionsChange : Boolean = newOptions != ( _miscOptions & 0xff );

			if ( currentTarget != newTarget || optionsChange )
			{
				if ( _onDrawRequired != null )
					_onDrawRequired();

				renderTarget = target;
				_miscOptions = ( _miscOptions & 0xffffff00 ) | newOptions;
			}
		}

		// other properties

		/** The blend mode to be used on rendering. A value of "auto" is ignored, since it
		 *  means that the mode should remain unchanged.
		 *
		 *  @default BlendMode.NORMAL
		 *  @see starling.display.BlendMode
		 */
		public function get blendMode() : String
		{
			return _blendMode;
		}

		public function set blendMode( value : String ) : void
		{
			if ( value != BlendMode.AUTO && _blendMode != value )
			{
				if ( _onDrawRequired != null )
					_onDrawRequired();
				_blendMode = value;
			}
		}

		/** @private */
		internal function get renderTargetBase() : TextureBase
		{
			return renderTarget ? renderTarget.base : null;
		}

		/** Sets the triangle culling mode. Allows to exclude triangles from rendering based on
		 *  their orientation relative to the view plane.
		 *  @default Context3DTriangleFace.NONE
		 */
		public function get culling() : String
		{
			var index : int = ( _miscOptions & 0xf00 ) >> 8;
			return CULLING_VALUES[ index ];
		}

		public function set culling( value : String ) : void
		{
			if ( this.culling != value )
			{
				if ( _onDrawRequired != null )
					_onDrawRequired();

				var index : int = CULLING_VALUES.indexOf( value );
				if ( index == -1 )
					throw new ArgumentError( "Invalid culling mode" );

				_miscOptions = ( _miscOptions & 0xfffff0ff ) | ( index << 8 );
			}
		}

		/** The clipping rectangle can be used to limit rendering in the current render target to
		 *  a certain area. This method expects the rectangle in stage coordinates. To prevent
		 *  any clipping, assign <code>null</code>.
		 *
		 *  @default null
		 */
		public function get clipRect() : Rectangle
		{
			return _clipRect;
		}

		public function set clipRect( value : Rectangle ) : void
		{
			if ( !RectangleUtil.compare( _clipRect, value ))
			{
				if ( _onDrawRequired != null )
					_onDrawRequired();
				if ( value )
				{
					if ( _clipRect == null )
						_clipRect = Pool.getRectangle();
					_clipRect.copyFrom( value );
				}
				else if ( _clipRect )
				{
					Pool.putRectangle( _clipRect );
					_clipRect = null;
				}
			}
		}

		/** The anti-alias setting used when setting the current render target
		 *  via <code>setRenderTarget</code>. */
		public function get renderTargetAntiAlias() : int
		{
			return _miscOptions & 0xf;
		}

		/** Indicates if the render target (set via <code>setRenderTarget</code>)
		 *  has its depth and stencil buffers enabled. */
		public function get renderTargetSupportsDepthAndStencil() : Boolean
		{
			return ( _miscOptions & 0xf0 ) != 0;
		}

		/** @private
		 *
		 *  This callback is executed whenever a state change requires a draw operation.
		 *  This is the case if blend mode, render target, culling or clipping rectangle
		 *  are changing. */
		internal function get onDrawRequired() : Function
		{
			return _onDrawRequired;
		}

		internal function set onDrawRequired( value : Function ) : void
		{
			_onDrawRequired = value;
		}
	}
}
