package starling.text
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	
	import starling.rendering.MeshEffect;
	import starling.rendering.Painter;
	import starling.rendering.Program;
	import starling.rendering.VertexDataFormat;
	import starling.utils.RenderUtil;

	internal class SimpleTextEffect extends MeshEffect
	{
		public static const VERTEX_FORMAT : VertexDataFormat = SimpleTextStyle.VERTEX_FORMAT;

		private var sRenderConsts : Vector.<Number> = Vector.<Number>([ 0, 0, 0, 0 ]);
		public var positions : Vector.<Number>;
		public var colors : Vector.<Number>;

		public function SimpleTextEffect()
		{
			super();
			this.vertexFormat = VERTEX_FORMAT;
			sRenderConsts.fixed = true;
		}

		override protected function createProgram() : Program
		{
			var vertexShader : String =
				//position
				"mov vt0,va0\n" +
				"mov vt0.z,vc5.x\n" +
				"mul vt0.xy,vt0.xy,vc[va0.z].zw\n" + //先缩放
				"add vt0.xy,vt0.xy,vc[va0.z].xy\n" + //再位移
				"m44 op, vt0, vc0 \n" + // 4x4 matrix transform to output space

				//uv
				"mov vt0,va1\n" +
				"mul vt0.xy,vt0.xy,vc[va0.z+1].zw\n" + //先缩放
				"add vt0.xy,vt0.xy,vc[va0.z+1].xy\n" + //再位移
				"mov v0, vt0 \n";

			var fragmentShader : String =
				"tex ft0, v0, fs0" + RenderUtil.getTextureLookupFlags( texture.format, false, this.textureRepeat, this.textureSmoothing ) + "\n" +
				"mul ft0.xyz,ft0.xyz,fc0.xyz\n" +
				"mul ft0.w,ft0.w,fc0.w\n" +
				"mov oc,ft0";

			return Program.fromSource( vertexShader, fragmentShader );
		}

		override protected function useColor() : Boolean
		{
			return false;
		}

		override protected function beforeDraw( painter : Painter, context : Context3D ) : void
		{
			super.beforeDraw( painter, context );

			context.setProgramConstantsFromVector( Context3DProgramType.VERTEX, 5, sRenderConsts );
			context.setProgramConstantsFromVector( Context3DProgramType.VERTEX, 6, positions );
			context.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, 0, colors );
		}
	}
}
