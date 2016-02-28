package uieditor.editor.history
{
	public class NoSelectOperation extends AbstractHistoryOperation
	{
		public function NoSelectOperation(type:String, target:Object, beforeValue:Object, afterValue:Object)
		{
			super(type, target, beforeValue, afterValue);
		}
	}
}