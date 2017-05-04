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
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import org.taomee.shader.Buffer3DManager;
	import org.taomee.shader.BufferType;
	
	import starling.core.Starling;
	import starling.core.starling_internal;
	import starling.utils.execute;

	use namespace starling_internal;

	/** An effect encapsulates all steps of a Stage3D draw operation. It configures the
	 *  render context and sets up shader programs as well as index- and vertex-buffers, thus
	 *  providing the basic mechanisms of all low-level rendering.
	 *
	 *  <p><strong>Using the Effect class</strong></p>
	 *
	 *  <p>Effects are mostly used by the <code>MeshStyle</code> and <code>FragmentFilter</code>
	 *  classes. When you extend those classes, you'll be required to provide a custom effect.
	 *  Setting it up for rendering is done by the base class, though, so you rarely have to
	 *  initiate the rendering yourself. Nevertheless, it's good to know how an effect is doing
	 *  its work.</p>
	 *
	 *  <p>Using an effect always follows steps shown in the example below. You create the
	 *  effect, configure it, upload vertex data and then: draw!</p>
	 *
	 *  <listing>
	 *  // create effect
	 *  var effect:MeshEffect = new MeshEffect();
	 *
	 *  // configure effect
	 *  effect.mvpMatrix3D = painter.state.mvpMatrix3D;
	 *  effect.texture = getHeroTexture();
	 *  effect.color = 0xf0f0f0;
	 *
	 *  // upload vertex data
	 *  effect.uploadIndexData(indexData);
	 *  effect.uploadVertexData(vertexData);
	 *
	 *  // draw!
	 *  effect.render(0, numTriangles);</listing>
	 *
	 *  <p>Note that the <code>VertexData</code> being uploaded has to be created with the same
	 *  format as the one returned by the effect's <code>vertexFormat</code> property.</p>
	 *
	 *  <p><strong>Extending the Effect class</strong></p>
	 *
	 *  <p>The base <code>Effect</code>-class can only render white triangles, which is not much
	 *  use in itself. However, it is designed to be extended; subclasses can easily implement any
	 *  kinds of shaders.</p>
	 *
	 *  <p>Normally, you won't extend this class directly, but either <code>FilterEffect</code>
	 *  or <code>MeshEffect</code>, depending on your needs (i.e. if you want to create a new
	 *  fragment filter or a new mesh style). Whichever base class you're extending, you should
	 *  override the following methods:</p>
	 *
	 *  <ul>
	 *    <li><code>createProgram():Program</code> — must create the actual program containing
	 *        vertex- and fragment-shaders. A program will be created only once for each render
	 *        context; this is taken care of by the base class.</li>
	 *    <li><code>get programVariantName():uint</code> (optional) — override this if your
	 *        effect requires different programs, depending on its settings. The recommended
	 *        way to do this is via a bit-mask that uniquely encodes the current settings.</li>
	 *    <li><code>get vertexFormat():String</code> (optional) — must return the
	 *        <code>VertexData</code> format that this effect requires for its vertices. If
	 *        the effect does not require any special attributes, you can leave this out.</li>
	 *    <li><code>beforeDraw(context:Context3D):void</code> — Set up your context by
	 *        configuring program constants and buffer attributes.</li>
	 *    <li><code>afterDraw(context:Context3D):void</code> — Will be called directly after
	 *        <code>context.drawTriangles()</code>. Clean up any context configuration here.</li>
	 *  </ul>
	 *
	 *  <p>Furthermore, you need to add properties that manage the data you require on rendering,
	 *  e.g. the texture(s) that should be used, program constants, etc. I recommend looking at
	 *  the implementations of Starling's <code>FilterEffect</code> and <code>MeshEffect</code>
	 *  classes to see how to approach sub-classing.</p>
	 *
	 *  @see FilterEffect
	 *  @see MeshEffect
	 *  @see starling.rendering.MeshStyle
	 *  @see starling.filters.FragmentFilter
	 *  @see starling.utils.RenderUtil
	 */
	public class Effect
	{
		/** The vertex format expected by <code>uploadVertexData</code>:
		 *  <code>"position:float2"</code> */
		public static const VERTEX_FORMAT : VertexDataFormat =
			VertexDataFormat.fromString( "position:float2" );

		public var vertexBuffer : VertexBuffer3D;
		private var _vertexBufferSize : int; // in bytes
		public var indexBuffer : IndexBuffer3D;
		private var _indexBufferSize : int; // in number of indices
		private var _indexBufferUsesQuadLayout : Boolean;

		/** The MVP (modelview-projection) matrix transforms vertices into clipspace. */
		public var mvpMatrix3D : Matrix3D;

		private var _onRestore : Function;
		private var _programBaseName : String;
		protected var _programVariantName : uint = 0;

		protected var _resetBufferAndTextureIndex : Boolean = true;

		/** The data format that this effect requires from the VertexData that it renders:
		 *  <code>"position:float2"</code> */
		public var vertexFormat : VertexDataFormat;

		// helper objects
		public static var sProgramNameCache : Dictionary = new Dictionary();

		/** Creates a new effect. */
		public function Effect()
		{
			this.mvpMatrix3D = new Matrix3D();
			_programBaseName = getQualifiedClassName( this );

			// Handle lost context (using conventional Flash event for weak listener support)
			Starling.current.stage3D.addEventListener( Event.CONTEXT3D_CREATE,
				onContextCreated, false, 20, true );

			this.vertexFormat = VERTEX_FORMAT;
		}

		/** Purges the index- and vertex-buffers. */
		public function dispose() : void
		{
			if ( Starling.current.stage3D )
				Starling.current.stage3D.removeEventListener( Event.CONTEXT3D_CREATE, onContextCreated );

			purgeBuffers();

			_program = null;
			_programName = null;

			mvpMatrix3D = null;

			_onRestore = null;
		}

		private function onContextCreated( event : Event ) : void
		{
			purgeBuffers();
			_program = null;
			_programName = null;

			execute( _onRestore, this );
		}

		/** Purges one or both of the vertex- and index-buffers. */
		public function purgeBuffers( vertexBuffer : Boolean = true, indexBuffer : Boolean = true ) : void
		{
			// We wrap the dispose calls in a try/catch block to work around a stage3D problem.
			// Since they are not re-used later, that shouldn't have any evil side effects.

			if ( this.vertexBuffer && vertexBuffer )
			{
				try
				{
					Buffer3DManager.getInstance().disposeVertexBuffer( this.vertexBuffer, BufferType.TYPE_2D );
				}
				catch ( e : Error )
				{
				}
				this.vertexBuffer = null;
			}

			if ( this.indexBuffer && indexBuffer )
			{
				try
				{
					Buffer3DManager.getInstance().disposeIndexBuffer( this.indexBuffer, BufferType.TYPE_2D );
				}
				catch ( e : Error )
				{
				}
				this.indexBuffer = null;
			}
		}

		/** Uploads the given index data to the internal index buffer. If the buffer is too
		 *  small, a new one is created automatically.
		 *
		 *  @param indexData   The IndexData instance to upload.
		 *  @param bufferUsage The expected buffer usage. Use one of the constants defined in
		 *                     <code>Context3DBufferUsage</code>. Only used when the method call
		 *                     causes the creation of a new index buffer.
		 */
		public function uploadIndexData( indexData : IndexData,
			bufferUsage : String = "staticDraw" ) : void
		{
			var numIndices : int = indexData._numIndices;
			var isQuadLayout : Boolean = indexData.useQuadLayout;
			var wasQuadLayout : Boolean = _indexBufferUsesQuadLayout;

			if ( indexBuffer )
			{
				if ( numIndices <= _indexBufferSize )
				{
					if ( !isQuadLayout || !wasQuadLayout )
					{
						indexData.uploadToIndexBuffer( indexBuffer );
						_indexBufferUsesQuadLayout = isQuadLayout && numIndices == _indexBufferSize;
					}
				}
				else
					purgeBuffers( false, true );
			}
			if ( indexBuffer == null )
			{
				indexBuffer = indexData.createIndexBuffer( true, bufferUsage);
				_indexBufferSize = numIndices;
				_indexBufferUsesQuadLayout = isQuadLayout;
			}
		}

		/** Uploads the given vertex data to the internal vertex buffer. If the buffer is too
		 *  small, a new one is created automatically.
		 *
		 *  @param vertexData  The VertexData instance to upload.
		 *  @param bufferUsage The expected buffer usage. Use one of the constants defined in
		 *                     <code>Context3DBufferUsage</code>. Only used when the method call
		 *                     causes the creation of a new vertex buffer.
		 */
		public function uploadVertexData( vertexData : VertexData,
			bufferUsage : String = "staticDraw" ) : void
		{
			if ( vertexBuffer )
			{
				if ( vertexData.size <= _vertexBufferSize )
					vertexData.uploadToVertexBuffer( vertexBuffer );
				else
					purgeBuffers( true, false );
			}
			if ( vertexBuffer == null )
			{
				vertexBuffer = vertexData.createVertexBuffer( true, bufferUsage);
				_vertexBufferSize = vertexData.size;
			}
		}

		// rendering

		/** Draws the triangles described by the index- and vertex-buffers, or a range of them.
		 *  This calls <code>beforeDraw</code>, <code>context.drawTriangles</code>, and
		 *  <code>afterDraw</code>, in this order. */
		public function render( painter : Painter, firstIndex : int = 0, numTriangles : int = -1 ) : void
		{
			if ( numTriangles < 0 )
				numTriangles = _indexBufferSize / 3;
			if ( numTriangles == 0 )
				return;

			var context : Context3D = painter.context;

			beforeDraw( painter, context );

			//准备绘制前，清理没有使用的texture
//			painter.clearUnSetTextureAndBuffer();

			for ( var i : int = 0; i < Painter.MAX_TEXUTRE_COUNT; i++ )
			{
				if ( painter.curTextureIndices[ i ] == 0 && painter.preTextureIndices[ i ] > 0 )
				{
					context.setTextureAt( i, null );
					painter.boundTextures[ i ] = null;
				}

				painter.preTextureIndices[ i ] = painter.curTextureIndices[ i ];
			}

			for ( i = 0; i < Painter.MAX_VERTEX_BUFFER_COUNT; i++ )
			{
				if ( painter.curVertexBufferIndices[ i ] == 0 && painter.preVertexBufferIndices[ i ] > 0 )
				{
					context.setVertexBufferAt( i, null );
				}
				painter.preVertexBufferIndices[ i ] = painter.curVertexBufferIndices[ i ];
			}

			context.drawTriangles( indexBuffer, firstIndex, numTriangles );
		}

		/** This method is called by <code>render</code>, directly before
		 *  <code>readyDraw</code>. It activates the program and sets up
		 *  the context with the following constants and attributes:
		 *
		 *  <ul>
		 *    <li><code>vc0-vc3</code> — MVP matrix</li>
		 *    <li><code>va0</code> — vertex position (xy)</li>
		 *  </ul>
		 */
		protected function beforeDraw( painter : Painter, context : Context3D ) : void
		{
			//inline painter.resetBufferAndTextureIndex()

			if ( _resetBufferAndTextureIndex )
			{
				painter.curTextureIndices.length = 0;
				painter.curTextureIndices.length = Painter.MAX_TEXUTRE_COUNT;

				painter.curVertexBufferIndices.length = 0;
				painter.curVertexBufferIndices.length = Painter.MAX_VERTEX_BUFFER_COUNT;
			}

			activeProgram( painter, context );
			vertexFormat.setVertexBufferAt( painter, 0, vertexBuffer, "position" );
			context.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 0, mvpMatrix3D, true );
		}

		// program management

		/** Creates the program (a combination of vertex- and fragment-shader) used to render
		 *  the effect with the current settings. Override this method in a subclass to create
		 *  your shaders. This method will only be called once; the program is automatically stored
		 *  in the <code>Painter</code> and re-used by all instances of this effect.
		 *
		 *  <p>The basic implementation always outputs pure white.</p>
		 */
		protected function createProgram() : Program
		{
			var vertexShader : String = [
				"m44 op, va0, vc0", // 4x4 matrix transform to output clipspace
				"seq v0, va0, va0" // this is a hack that always produces "1"
				].join( "\n" );

			var fragmentShader : String =
				"mov oc, v0"; // output color: white

			return Program.fromSource( vertexShader, fragmentShader );
		}

		/** Override this method if the effect requires a different program depending on the
		 *  current settings. Ideally, you do this by creating a bit mask encoding all the options.
		 *  This method is called often, so do not allocate any temporary objects when overriding.
		 *
		 *  @default 0
		 */
		protected function get programVariantName() : uint
		{
			return _programVariantName;
		}

		/** Returns the base name for the program.
		 *  @default the fully qualified class name
		 */
		protected function get programBaseName() : String
		{
			return _programBaseName;
		}

		protected function set programBaseName( value : String ) : void
		{
			_programBaseName = value;
		}

		/** Returns the full name of the program, which is used to register it at the current
		 *  <code>Painter</code>.
		 *
		 *  <p>The default implementation efficiently combines the program's base and variant
		 *  names (e.g. <code>LightEffect#42</code>). It shouldn't be necessary to override
		 *  this method.</p>
		 */
		protected function get programName() : String
		{
			var baseName : String = this._programBaseName;
			var variantName : uint = this.programVariantName;
			var nameCache : Dictionary = sProgramNameCache[ baseName ];
			if ( nameCache == null )
			{
				nameCache = new Dictionary();
				sProgramNameCache[ baseName ] = nameCache;
			}

			var name : String = nameCache[ variantName ];

			if ( name == null )
			{
				if ( variantName )
					name = baseName + "#" + variantName.toString( 16 );
				else
					name = baseName;

				nameCache[ variantName ] = name;
			}

			return name;
		}

		public function validProgramVariantName() : void
		{
			_programVariantName = 0;
		}

		private var _programName : String;
		private var _program : Program;

		/** use the current program, either by creating a new one (via
		 *  <code>createProgram</code>) or by getting it from the <code>Painter</code>.
		 *  Do not override this method! Instead, implement <code>createProgram</code>. */
		protected function activeProgram( painter : Painter, context : Context3D ) : void
		{
			//TODO programName方法太耗时，修改
			var name : String = this.programName;
			if ( _programName == name && _program != null )
			{
				_program.activate( painter, context );
			}
			else
			{
				_program = painter.getProgram( name );
				if ( _program == null )
				{
					_program = createProgram();
					painter.registerProgram( name, _program );
				}
				_programName = name;
				_program.activate( painter, context );
			}
		}

		// properties

		/** The function that you provide here will be called after a context loss.
		 *  Call both "upload..." methods from within the callback to restore any vertex or
		 *  index buffers. The callback will be executed with the effect as its sole parameter. */
		public function get onRestore() : Function
		{
			return _onRestore;
		}

		public function set onRestore( value : Function ) : void
		{
			_onRestore = value;
		}

		/** The current size of the index buffer (in number of indices). */
		protected function get indexBufferSize() : int
		{
			return _indexBufferSize;
		}

		/** The current size of the vertex buffer (in blocks of 32 bits). */
		protected function get vertexBufferSize() : int
		{
			return _vertexBufferSize;
		}
	}
}
