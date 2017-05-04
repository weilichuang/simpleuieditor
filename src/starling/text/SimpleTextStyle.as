package starling.text
{
	import starling.display.Mesh;
	import starling.rendering.MeshEffect;
	import starling.rendering.RenderState;
	import starling.rendering.VertexDataFormat;
	import starling.styles.MeshStyle;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	
	internal class SimpleTextStyle extends MeshStyle
	{
		public static const VERTEX_FORMAT : VertexDataFormat = VertexDataFormat.fromString("position:float3,texCoords:float2");

		private var _color:uint = 0xffffff;
		
		public function SimpleTextStyle()
		{
			super();
			this.textureSmoothing = TextureSmoothing.BILINEAR;
		}
		
		/** Changes the color of all vertices to the same value.
		 *  The getter simply returns the color of the first vertex. */
		override public function get color():uint
		{
			return _color;
		}
		
		override public function set color(value:uint):void
		{
			_color = value;
		}
		
		override public function set texture(value:Texture):void
		{
			if (value != _texture)
			{
				_texture = value;
				_textureBase = value ? value.base : null;
				setRequiresRedraw();
			}
		}
		
		override public function copyFrom( meshStyle : MeshStyle ) : void {
			super.copyFrom( meshStyle );
		}
		
		override public function createEffect() : MeshEffect {
			return new SimpleTextEffect();
		}
		
		override public function updateEffect( effect : MeshEffect, state : RenderState ) : void {
			super.updateEffect( effect, state );
		}
		
		override protected function onTargetAssigned( target : Mesh ) : void {
			setRequiresRedraw();
		}
		
		override public function get vertexFormat():VertexDataFormat
		{
			return VERTEX_FORMAT;
		}
	}
}