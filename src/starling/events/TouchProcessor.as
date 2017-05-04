// =================================================================================================
//
//	Starling Framework
//	Copyright Gamua GmbH. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.events
{
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;

	import starling.display.DisplayObject;
	import starling.display.Stage;
	import starling.utils.StarlingVectorUtil;

	/** The TouchProcessor is used to convert mouse and touch events of the conventional
	 *  Flash stage to Starling's TouchEvents.
	 *
	 *  <p>The Starling instance listens to mouse and touch events on the native stage. The
	 *  attributes of those events are enqueued (right as they are happening) in the
	 *  TouchProcessor.</p>
	 *
	 *  <p>Once per frame, the "advanceTime" method is called. It analyzes the touch queue and
	 *  figures out which touches are active at that moment; the properties of all touch objects
	 *  are updated accordingly.</p>
	 *
	 *  <p>Once the list of touches has been finalized, the "processTouches" method is called
	 *  (that might happen several times in one "advanceTime" execution; no information is
	 *  discarded). It's responsible for dispatching the actual touch events to the Starling
	 *  display tree.</p>
	 *
	 *  <strong>Subclassing TouchProcessor</strong>
	 *
	 *  <p>You can extend the TouchProcessor if you need to have more control over touch and
	 *  mouse input. For example, you could filter the touches by overriding the "processTouches"
	 *  method, throwing away any touches you're not interested in and passing the rest to the
	 *  super implementation.</p>
	 *
	 *  <p>To use your custom TouchProcessor, assign it to the "Starling.touchProcessor"
	 *  property.</p>
	 *
	 *  <p>Note that you should not dispatch TouchEvents yourself, since they are
	 *  much more complex to handle than conventional events (e.g. it must be made sure that an
	 *  object receives a TouchEvent only once, even if it's manipulated with several fingers).
	 *  Always use the base implementation of "processTouches" to let them be dispatched. That
	 *  said: you can always dispatch your own custom events, of course.</p>
	 */
	public class TouchProcessor
	{
		private var _stage : Stage;
		private var _root : DisplayObject;
		private var _elapsedTime : Number;
		private var _lastTaps : Vector.<Touch>;
		private var _shiftDown : Boolean = false;
		private var _ctrlDown : Boolean = false;
		private var _multitapTime : Number = 0.3;
		private var _multitapDistance : Number = 25;
		private var _multitapDistanceSquare : Number = 25 * 25;
		private var _touchEvent : TouchEvent;

		/** A vector of arrays with the arguments that were passed to the "enqueue"
		 *  method (the oldest being at the end of the vector). */
		protected var _queue : Vector.<Array>;

		/** The list of all currently active touches. */
		protected var _currentTouches : Vector.<Touch>;

		/** Helper objects. */
		private static var sUpdatedTouches : Vector.<Touch> = new <Touch>[];
		private static var sHoveringTouchData : Vector.<Object> = new <Object>[];
		private static var sHelperPoint : Point = new Point();

		/** Creates a new TouchProcessor that will dispatch events to the given stage. */
		public function TouchProcessor( stage : Stage )
		{
			_root = _stage = stage;
			_elapsedTime = 0.0;
			_currentTouches = new <Touch>[];
			_queue = new <Array>[];
			_lastTaps = new <Touch>[];
			_touchEvent = new TouchEvent( TouchEvent.TOUCH );

			_stage.addEventListener( KeyboardEvent.KEY_DOWN, onKey );
			_stage.addEventListener( KeyboardEvent.KEY_UP, onKey );
			//monitorInterruptions(true);
		}

		/** Removes all event handlers on the stage and releases any acquired resources. */
		public function dispose() : void
		{
			//monitorInterruptions(false);
			_stage.removeEventListener( KeyboardEvent.KEY_DOWN, onKey );
			_stage.removeEventListener( KeyboardEvent.KEY_UP, onKey );
		}

		/** Analyzes the current touch queue and processes the list of current touches, emptying
		 *  the queue while doing so. This method is called by Starling once per frame. */
		public function advanceTime( passedTime : Number ) : void
		{
			var i : int;
			var touch : Touch;

			_elapsedTime += passedTime;
			sUpdatedTouches.length = 0;

			// remove old taps
			var len : int = _lastTaps.length;
			if ( len > 0 )
			{
				for ( i = len - 1; i >= 0; --i )
				{
					if ( _elapsedTime - _lastTaps[ i ].timestamp > _multitapTime )
					{
						StarlingVectorUtil.removeTouchAt( _lastTaps, i );
					}
				}
			}

			while ( _queue.length > 0 )
			{
				// Set touches that were new or moving to phase 'stationary'.
				for each ( touch in _currentTouches )
				{
					if ( touch.phase == TouchPhase.BEGAN || touch.phase == TouchPhase.MOVED ||
						touch.phase == TouchPhase.RIGHT_BEGAN || touch.phase == TouchPhase.RIGHT_MOVED )
						touch.phase = TouchPhase.STATIONARY;
				}


				// analyze new touches, but each ID only once
				//如果有两个状态：触发鼠标弹起和over两个状态，检测鼠标弹起事件时需要检测当前目标是否有改变，有改变的话则抛出out事件
				var queueLen : int = _queue.length;
				while ( queueLen > 0 )
				{
					var touchArgs : Array = _queue.pop();
					queueLen--;

					//如果之前已经有了相同id
					if ( containsTouchWithID( sUpdatedTouches, touchArgs[ 0 ]))
					{
						var index : uint = sUpdatedTouches.length - 1;
						var oldTouch : Touch = sUpdatedTouches[ index ];
						var curPhase : String = touchArgs[ 1 ];

						//检查是否此时鼠标在点击对象范围外松开的
						if (( oldTouch.phase == TouchPhase.ENDED || oldTouch.phase == TouchPhase.RIGHT_ENDED ) &&
							curPhase == TouchPhase.HOVER )
						{
							sHelperPoint.setTo( touchArgs[ 2 ], touchArgs[ 3 ]);
							var object : DisplayObject = _root.hitTest( sHelperPoint );
							//目标不同时覆盖之前数据，否则不处理
							if ( oldTouch.target != object )
							{
								//覆盖之前ended或者right_ended事件
								touch = createOrUpdateTouch(
									touchArgs[ 0 ], touchArgs[ 1 ], touchArgs[ 2 ], touchArgs[ 3 ],
									touchArgs[ 4 ], touchArgs[ 5 ]);

								//replace last touch
								sUpdatedTouches[ index ] = touch;
							}
						}
					}
					else
					{
						touch = createOrUpdateTouch(
							touchArgs[ 0 ], touchArgs[ 1 ], touchArgs[ 2 ], touchArgs[ 3 ],
							touchArgs[ 4 ], touchArgs[ 5 ]);

						sUpdatedTouches[ sUpdatedTouches.length ] = touch; // avoiding 'push'
					}
				}

				// process the current set of touches (i.e. dispatch touch events)
				processTouches( sUpdatedTouches, _shiftDown, _ctrlDown );

				// remove ended touches
				for ( i = _currentTouches.length - 1; i >= 0; --i )
				{
					touch = _currentTouches[ i ];
					if ( touch.phase == TouchPhase.ENDED || touch.phase == TouchPhase.RIGHT_ENDED )
					{
						StarlingVectorUtil.removeTouchAt( _currentTouches, i );
					}
				}

				sUpdatedTouches.length = 0;
			}
		}

		/** Dispatches TouchEvents to the display objects that are affected by the list of
		 *  given touches. Called internally by "advanceTime". To calculate updated targets,
		 *  the method will call "hitTest" on the "root" object.
		 *
		 *  @param touches    a list of all touches that have changed just now.
		 *  @param shiftDown  indicates if the shift key was down when the touches occurred.
		 *  @param ctrlDown   indicates if the ctrl or cmd key was down when the touches occurred.
		 */
		protected function processTouches( touches : Vector.<Touch>, shiftDown : Boolean, ctrlDown : Boolean ) : void
		{
			var touch : Touch;

			sHoveringTouchData.length = 0;

			// the same touch event will be dispatched to all targets;
			// the 'dispatch' method makes sure each bubble target is visited only once.
			_touchEvent.resetTo( TouchEvent.TOUCH, _currentTouches, shiftDown, ctrlDown );

			// hit test our updated touches
			for each ( touch in touches )
			{
				// hovering touches need special handling (see below)
				if ( touch.phase == TouchPhase.HOVER && touch.target )
					sHoveringTouchData[ sHoveringTouchData.length ] = {
							touch: touch,
							target: touch.target,
							bubbleChain: touch.bubbleChain
						}; // avoiding 'push'

				if ( touch.phase == TouchPhase.HOVER || touch.phase == TouchPhase.BEGAN || touch.phase == TouchPhase.RIGHT_BEGAN )
				{
					sHelperPoint.setTo( touch.globalX, touch.globalY );
					touch.target = _root.hitTest( sHelperPoint );
				}
			}

			// if the target of a hovering touch changed, we dispatch the event to the previous
			// target to notify it that it's no longer being hovered over.
			for each ( var touchData : Object in sHoveringTouchData )
				if ( touchData.touch.target != touchData.target )
					_touchEvent.dispatch( touchData.bubbleChain );

			// dispatch events for the rest of our updated touches
			for each ( touch in touches )
				touch.dispatchEvent( _touchEvent );

			// clean up any references
			_touchEvent.resetTo( TouchEvent.TOUCH );
		}

		/** Enqueues a new touch our mouse event with the given properties. */
		public function enqueue( touchID : int, phase : String, globalX : Number, globalY : Number,
			width : Number = 1.0, height : Number = 1.0 ) : void
		{
			_queue.unshift( arguments );
		}

		/** Enqueues an artificial touch that represents the mouse leaving the stage.
		 *
		 *  <p>On OS X, we get mouse events from outside the stage; on Windows, we do not.
		 *  This method enqueues an artificial hover point that is just outside the stage.
		 *  That way, objects listening for HOVERs over them will get notified everywhere.</p>
		 */
		public function enqueueMouseLeftStage() : void
		{
			var mouse : Touch = getCurrentTouch( 0 );
			if ( mouse == null || mouse.phase != TouchPhase.HOVER )
				return;

			var offset : int = 1;
			var exitX : Number = mouse.globalX;
			var exitY : Number = mouse.globalY;
			var distLeft : Number = mouse.globalX;
			var distRight : Number = _stage.stageWidth - distLeft;
			var distTop : Number = mouse.globalY;
			var distBottom : Number = _stage.stageHeight - distTop;
			var minDist : Number = Math.min( distLeft, distRight, distTop, distBottom );

			// the new hover point should be just outside the stage, near the point where
			// the mouse point was last to be seen.

			if ( minDist == distLeft )
				exitX = -offset;
			else if ( minDist == distRight )
				exitX = _stage.stageWidth + offset;
			else if ( minDist == distTop )
				exitY = -offset;
			else
				exitY = _stage.stageHeight + offset;

			enqueue( 0, TouchPhase.HOVER, exitX, exitY );
		}

		/** Force-end all current touches. Changes the phase of all touches to 'ENDED' and
		 *  immediately dispatches a new TouchEvent (if touches are present). Called automatically
		 *  when the app receives a 'DEACTIVATE' event. */
		public function cancelTouches() : void
		{
			if ( _currentTouches.length > 0 )
			{
				// abort touches
				for each ( var touch : Touch in _currentTouches )
				{
					if ( touch.phase == TouchPhase.BEGAN || touch.phase == TouchPhase.MOVED ||
						touch.phase == TouchPhase.STATIONARY )
					{
						touch.phase = TouchPhase.ENDED;
						touch.cancelled = true;
					}
					else if ( touch.phase == TouchPhase.RIGHT_BEGAN || touch.phase == TouchPhase.RIGHT_MOVED )
					{
						touch.phase = TouchPhase.RIGHT_ENDED;
						touch.cancelled = true;
					}

				}

				// dispatch events
				processTouches( _currentTouches, _shiftDown, _ctrlDown );
			}

			// purge touches
			_currentTouches.length = 0;
			_queue.length = 0;
		}

		private function createOrUpdateTouch( touchID : int, phase : String,
			globalX : Number, globalY : Number,
			width : Number = 1.0, height : Number = 1.0 ) : Touch
		{
			var touch : Touch = getCurrentTouch( touchID );

			if ( touch == null )
			{
				touch = new Touch( touchID );
				addCurrentTouch( touch );
			}

			touch.globalX = globalX;
			touch.globalY = globalY;
			touch.phase = phase;
			touch.timestamp = _elapsedTime;
			touch.width = width;
			touch.height = height;

			if ( phase == TouchPhase.BEGAN )
				updateTapCount( touch );

			return touch;
		}

		private function updateTapCount( touch : Touch ) : void
		{
			var nearbyTap : Touch = null;
			var minSqDist : Number = _multitapDistanceSquare;

			for each ( var tap : Touch in _lastTaps )
			{
				var gx : Number = tap.globalX - touch.globalX;
				var gy : Number = tap.globalY - touch.globalY;

				var sqDist : Number = gx * gx + gy * gy;
				if ( sqDist <= minSqDist )
				{
					nearbyTap = tap;
					break;
				}
			}

			if ( nearbyTap )
			{
				touch.tapCount = nearbyTap.tapCount + 1;

				StarlingVectorUtil.removeTouchAt( _lastTaps, _lastTaps.indexOf( nearbyTap ));
			}
			else
			{
				touch.tapCount = 1;
			}

			_lastTaps[ _lastTaps.length ] = touch.clone(); // avoiding 'push'
		}

		private function addCurrentTouch( touch : Touch ) : void
		{
			for ( var i : int = _currentTouches.length - 1; i >= 0; --i )
				if ( _currentTouches[ i ].id == touch.id )
				{
					StarlingVectorUtil.removeTouchAt( _currentTouches, i );
				}

			_currentTouches[ _currentTouches.length ] = touch; // avoiding 'push'
		}

		private function getCurrentTouch( touchID : int ) : Touch
		{
			for each ( var touch : Touch in _currentTouches )
				if ( touch.id == touchID )
					return touch;

			return null;
		}

		private function containsTouchWithID( touches : Vector.<Touch>, touchID : int ) : Boolean
		{
			for each ( var touch : Touch in touches )
				if ( touch.id == touchID )
					return true;

			return false;
		}

		/** The time period (in seconds) in which two touches must occur to be recognized as
		 *  a multitap gesture. */
		public function get multitapTime() : Number
		{
			return _multitapTime;
		}

		public function set multitapTime( value : Number ) : void
		{
			_multitapTime = value;
		}

		/** The distance (in points) describing how close two touches must be to each other to
		 *  be recognized as a multitap gesture. */
		public function get multitapDistance() : Number
		{
			return _multitapDistance;
		}

		public function set multitapDistance( value : Number ) : void
		{
			_multitapDistance = value;
			_multitapDistanceSquare = value * value;
		}

		/** The base object that will be used for hit testing. Per default, this reference points
		 *  to the stage; however, you can limit touch processing to certain parts of your game
		 *  by assigning a different object. */
		public function get root() : DisplayObject
		{
			return _root;
		}

		public function set root( value : DisplayObject ) : void
		{
			_root = value;
		}

		/** The stage object to which the touch events are (per default) dispatched. */
		public function get stage() : Stage
		{
			return _stage;
		}

		/** Returns the number of fingers / touch points that are currently on the stage. */
		public function get numCurrentTouches() : int
		{
			return _currentTouches.length;
		}

		// keyboard handling

		private function onKey( event : KeyboardEvent ) : void
		{
			if ( event.keyCode == 17 || event.keyCode == 15 ) // ctrl or cmd key
			{
				_ctrlDown = event.type == KeyboardEvent.KEY_DOWN;
			}
			else if ( event.keyCode == 16 ) // shift key
			{
				_shiftDown = event.type == KeyboardEvent.KEY_DOWN;
			}
		}

		// interruption handling

		private function monitorInterruptions( enable : Boolean ) : void
		{
			// if the application moves into the background or is interrupted (e.g. through
			// an incoming phone call), we need to abort all touches.
			try
			{
				var nativeAppClass : Object = getDefinitionByName( "flash.desktop::NativeApplication" );
				var nativeApp : Object = nativeAppClass[ "nativeApplication" ];

				if ( enable )
					nativeApp.addEventListener( "deactivate", onInterruption, false, 0, true );
				else
					nativeApp.removeEventListener( "deactivate", onInterruption );
			}
			catch ( e : Error )
			{
			} // we're not running in AIR
		}

		private function onInterruption( event : Object ) : void
		{
			cancelTouches();
		}
	}
}
