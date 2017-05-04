package starling.display
{
	import flash.geom.Matrix;
	
	import starling.textures.Texture;
	import starling.utils.MeshSubset;

	public interface IMeshBatch
	{
		function clear():void;
		function get texture():Texture;
		function addMesh(mesh : Mesh, matrix : Matrix = null, alpha : Number = 1.0,
						 subset : MeshSubset = null, ignoreTransformations : Boolean = false):void;
	}
}