package starling.styles
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	
	import starling.rendering.MeshEffect;
	import starling.rendering.Painter;
	import starling.rendering.Program;
	import starling.rendering.VertexDataFormat;
	
	public class GrayImageEffect extends MeshEffect
	{
		public static const VERTEX_FORMAT : VertexDataFormat = GrayImageStyle.VERTEX_FORMAT;
		
		private var _rfactor : Number = 0.3;
		private var _gfactor : Number = 0.59;
		private var _bfactor : Number = 0.11;
		
		private var _factorVector:Vector.<Number>;
		
		public function GrayImageEffect()
		{
			super();
			this.vertexFormat = VERTEX_FORMAT;
			_factorVector = Vector.<Number>([_rfactor,_gfactor,_bfactor,0]);
		}
		
		override protected function createProgram() : Program
		{
			var vertexShader : String, fragmentShader : String;
			
			if ( texture )
			{
				vertexShader =
					"m44 op, va0, vc0 \n" + // 4x4 matrix transform to output clip-space
					"mov v0, va1      \n" + // pass texture coordinates to fragment program
					"mul v1, va2, vc4 \n"; // multiply alpha (vc4) with color (va2), pass to fp

				fragmentShader =
					tex( "ft0", "v0", 0, texture, true, false, textureRepeat, textureSmoothing ) +
					"mul ft1.xyz, ft0.xyz, fc0.xyz\n" +
					"add ft1.w, ft1.x, ft1.y\n" +
					"add ft1.w, ft1.w, ft1.z\n" +
					"mov ft0.xyz, ft1.w\n" +
					"mov ft0.w, v1.w\n" +
					"mov oc,ft0";
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
		
		override protected function beforeDraw( painter : Painter, context : Context3D ) : void {
			super.beforeDraw( painter, context );

			context.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, 0, _factorVector );
		}
	}
}