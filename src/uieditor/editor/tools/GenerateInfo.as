package uieditor.editor.tools
{

	public class GenerateInfo
	{
		public var sourceDir : String; //源
		public var exportDir : String; //目标
		public var platform : String = "d"; //平台
		public var compress : Boolean = true; //是否压缩
		public var mips : Boolean = false; //是否启用
		public var quality : int = 0; //质量

		public var mipWidth : int = 16;
		public var mipHeight : int = 16;
		public var mipExt : String = "_mip";

		/**
		 * 导出后缀名
		 */
		public var exportExt : String = "jpeg";

		public function GenerateInfo()
		{
		}
	}
}
