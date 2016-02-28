package uieditor.engine {
	import starling.textures.Texture;

	/**
	 *  This class defines what the engine needs from whomever using it.
	 *  You should implement your AssetMediator in your game.
	 *  For more usage please check out the demo project.
	 */
	public interface IAssetMediator {
		/**
		 *  This method is used by Image based classes to retrieve texture.
		 *  It has the same signature of starling.utils.AssetManager.getTexture
		 * @param name
		 * @return
		 */
		function getTexture( name : String ) : Texture;

		/**
		 *  This method is used by MovieClip to retrieve textures with prefix.
		 *  It has the same signature of starling.utils.AssetManager.getTextures
		 *  You can make it simply return null if you don't use MovieClip in the editor.
		 * @param prefix
		 * @param result
		 * @return
		 */
		function getTextures( prefix : String = "", result : Vector.<Texture> = null ) : Vector.<Texture>;
	}
}
