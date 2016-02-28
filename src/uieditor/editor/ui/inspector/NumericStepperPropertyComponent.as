package uieditor.editor.ui.inspector
{
	import feathers.controls.NumericStepper;
	
	import starling.events.Event;

	public class NumericStepperPropertyComponent extends BasePropertyComponent
	{
		private var _numericStepper:NumericStepper;
		public function NumericStepperPropertyComponent(propertyRetriever:IPropertyRetriever, param:Object)
		{
			super(propertyRetriever, param);
			
			var name : String = param.name;
			
			var min : Number = param[ "min" ];
			var max : Number = param[ "max" ];
			var default_value : Number = param[ "default" ];
			var step : Number = param[ "step" ];
			var component : String = param[ "component" ];
			
			if ( !isNaN( min ) && !isNaN( max ))
			{
				_numericStepper = new NumericStepper();
				_numericStepper.addEventListener( Event.CHANGE, function( event : Event ) : void {
					_oldValue = _propertyRetriever.get( name );
					_propertyRetriever.set( name, _numericStepper.value );
					setChanged();
				});
				_numericStepper.minimum = min;
				_numericStepper.maximum = max;
				_numericStepper.value = Number( _propertyRetriever.get( name ));
				
				addChild( _numericStepper );
				if ( !isNaN( step ))
					_numericStepper.step = step;
			}
			else
			{
				throw new Error( "Min and Max have to be defined!" )
			}
		}
		
		override public function update() : void
		{
			//Setting to NaN on slider will always dispatch a change, we need to do this workaround
			var value : Number = Number( _propertyRetriever.get( _param.name ));
			
			if ( !isNaN( value ))
			{
				_numericStepper.value = value;
			}
		}
	}
}