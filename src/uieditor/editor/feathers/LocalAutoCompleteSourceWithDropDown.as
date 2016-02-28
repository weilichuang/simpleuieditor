package uieditor.editor.feathers
{
	import feathers.data.ListCollection;
	import feathers.data.LocalAutoCompleteSource;

	import starling.events.Event;

	public class LocalAutoCompleteSourceWithDropDown extends LocalAutoCompleteSource
	{
		public function LocalAutoCompleteSourceWithDropDown( source : ListCollection = null )
		{
			super( source );
		}

		/**
		 *  This function is modified to always show the list
		 * @param textToMatch
		 * @param result
		 */
		override public function load( textToMatch : String, result : ListCollection = null ) : void
		{
			if ( result )
			{
				result.removeAll();
			}
			else
			{
				result = new ListCollection();
			}
			if ( !dataProvider )
			{
				this.dispatchEventWith( Event.COMPLETE, false, result );
				return;
			}

			for ( var i : int = 0; i < dataProvider.length; i++ )
			{
				var item : Object = dataProvider.getItemAt( i );
				result.push( item );
			}

			this.dispatchEventWith( Event.COMPLETE, false, result );
			return;
		}



	}
}
