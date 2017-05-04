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

	import avmplus.getQualifiedClassName;

	/** An effect drawing a mesh of textured, colored vertices.
	 *  This is the standard effect that is the base for all mesh styles;
	 *  if you want to create your own mesh styles, you will have to extend this class.
	 *
	 *  <p>For more information about the usage and creation of effects, please have a look at
	 *  the documentation of the root class, "Effect".</p>
	 *
	 *  @see Effect
	 *  @see FilterEffect
	 *  @see starling.rendering.MeshStyle
	 */
	public class MeshEffect extends FilterEffect
	{
		/** The vertex format expected by <code>uploadVertexData</code>:
		 *  <code>"position:float2, texCoords:float2, color:bytes4"</code> */
		public static const VERTEX_FORMAT : VertexDataFormat =
			FilterEffect.VERTEX_FORMAT.extend( "color:bytes4" );

		/** The alpha value of the object rendered by the effect. Must be taken into account
		 *  by all subclasses. */
		public var alpha : Number = 1.0;

		/** Indicates if the rendered vertices are tinted in any way, i.e. if there are vertices
		 *  that have a different color than fully opaque white. The base <code>MeshEffect</code>
		 *  class uses this information to simplify the fragment shader if possible. May be
		 *  ignored by subclasses. */
		public var tinted : Boolean = false;

		private var _optimizeIfNotTinted : Boolean;

		// helper objects
		private static var sRenderAlpha : Vector.<Number> = new Vector.<Number>( 4, true );

		/** Creates a new MeshEffect instance. */
		public function MeshEffect()
		{
			// Non-tinted meshes may be rendered with a simpler fragment shader, which brings
			// a huge performance benefit on some low-end hardware. However, I don't want
			// subclasses to become any more complicated because of this optimization (they
			// probably use much longer shaders, anyway), so I only apply this optimization if
			// this is actually the "MeshEffect" class.

			alpha = 1.0;
			_optimizeIfNotTinted = getQualifiedClassName( this ) == "starling.rendering::MeshEffect";
			this.vertexFormat = VERTEX_FORMAT;

			validProgramVariantName();
		}

		override public function validProgramVariantName() : void
		{
			super.validProgramVariantName();

			var noTinting : uint = uint( _optimizeIfNotTinted && !tinted && alpha == 1.0 );
			_programVariantName = _programVariantName | ( noTinting << 3 );
		}

		/** @private */
		override protected function createProgram() : Program
		{
			var vertexShader : String, fragmentShader : String;

			if ( texture )
			{
				if ( _optimizeIfNotTinted && !tinted && alpha == 1.0 )
					return super.createProgram();

				vertexShader =
					"m44 op, va0, vc0 \n" + // 4x4 matrix transform to output clip-space
					"mov v0, va1      \n" + // pass texture coordinates to fragment program
					"mul v1, va2, vc4 \n"; // multiply alpha (vc4) with color (va2), pass to fp

				fragmentShader =
					tex( "ft0", "v0", 0, texture, true, false, textureRepeat, textureSmoothing ) +
					"mul oc, ft0, v1  \n"; // multiply color with texel color
			}
			else
			{
				vertexShader =
					"m44 op, va0, vc0 \n" + // 4x4 matrix transform to output clipspace
					"mul v0, va2, vc4 \n"; // multiply alpha (vc4) with color (va2)

				fragmentShader =
					"mov oc, v0       \n"; // output color
			}

			return Program.fromSource( vertexShader, fragmentShader );
		}

		/** This method is called by <code>render</code>, directly before
		 *  <code>context.drawTriangles</code>. It activates the program and sets up
		 *  the context with the following constants and attributes:
		 *
		 *  <ul>
		 *    <li><code>vc0-vc3</code> — MVP matrix</li>
		 *    <li><code>vc4</code> — alpha value (same value for all components)</li>
		 *    <li><code>va0</code> — vertex position (xy)</li>
		 *    <li><code>va1</code> — texture coordinates (uv)</li>
		 *    <li><code>va2</code> — vertex color (rgba), using premultiplied alpha</li>
		 *    <li><code>fs0</code> — texture</li>
		 *  </ul>
		 */
		override protected function beforeDraw( painter : Painter, context : Context3D ) : void
		{
			super.beforeDraw( painter, context );

			if ( sRenderAlpha[ 0 ] != alpha )
			{
				sRenderAlpha[ 0 ] = sRenderAlpha[ 1 ] = sRenderAlpha[ 2 ] = sRenderAlpha[ 3 ] = alpha;
			}
			context.setProgramConstantsFromVector( Context3DProgramType.VERTEX, 4, sRenderAlpha );

			if ( useColor())
				vertexFormat.setVertexBufferAt( painter, 2, vertexBuffer, "color" );
		}

		protected function useColor() : Boolean
		{
			return ( tinted || alpha != 1.0 || !_optimizeIfNotTinted || texture == null );
		}
	}
}
