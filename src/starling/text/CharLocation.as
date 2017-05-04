package starling.text
{
	public class CharLocation
	{
		public var char:BitmapChar;
		public var scale:Number;
		public var x:Number;
		public var y:Number;
		
		public function CharLocation(char:BitmapChar)
		{
			reset(char);
		}
		
		private function reset(char:BitmapChar):CharLocation
		{
			this.char = char;
			return this;
		}
		
		// pooling
		
		private static var sInstancePool:Vector.<CharLocation> = new <CharLocation>[];
		private static var sVectorPool:Array = [];
		
		private static var sInstanceLoan:Vector.<CharLocation> = new <CharLocation>[];
		private static var sVectorLoan:Array = [];
		
		public static function instanceFromPool(char:BitmapChar):CharLocation
		{
			var instance:CharLocation = sInstancePool.length > 0 ?
				sInstancePool.pop() : new CharLocation(char);
			
			instance.reset(char);
			sInstanceLoan[sInstanceLoan.length] = instance;
			
			return instance;
		}
		
		public static function vectorFromPool():Vector.<CharLocation>
		{
			var vector:Vector.<CharLocation> = sVectorPool.length > 0 ?
				sVectorPool.pop() : new <CharLocation>[];
			
			vector.length = 0;
			sVectorLoan[sVectorLoan.length] = vector;
			
			return vector;
		}
		
		public static function rechargePool():void
		{
			var instance:CharLocation;
			var vector:Vector.<CharLocation>;
			
			while (sInstanceLoan.length > 0)
			{
				instance = sInstanceLoan.pop();
				instance.char = null;
				sInstancePool[sInstancePool.length] = instance;
			}
			
			while (sVectorLoan.length > 0)
			{
				vector = sVectorLoan.pop();
				vector.length = 0;
				sVectorPool[sVectorPool.length] = vector;
			}
		}
	}
}