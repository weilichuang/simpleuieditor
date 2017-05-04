package starling.styles
{
	import starling.display.Mesh;
	import starling.rendering.MeshEffect;
	import starling.rendering.RenderState;
	import starling.rendering.VertexDataFormat;

	public class GrayImageStyle extends MeshStyle
	{
		public static const VERTEX_FORMAT : VertexDataFormat = MeshEffect.VERTEX_FORMAT;
		
		public function GrayImageStyle()
		{
			super();
		}
		
		override public function copyFrom( meshStyle : MeshStyle ) : void {
			super.copyFrom( meshStyle );
		}
		
		override public function createEffect() : MeshEffect {
			return new GrayImageEffect();
		}
		
		override public function updateEffect( effect : MeshEffect, state : RenderState ) : void {
			super.updateEffect( effect, state );
		}
		
		override protected function onTargetAssigned( target : Mesh ) : void {
			setRequiresRedraw();
		}
		
		override public function get vertexFormat() : VertexDataFormat {
			return VERTEX_FORMAT;
		}
	}
}