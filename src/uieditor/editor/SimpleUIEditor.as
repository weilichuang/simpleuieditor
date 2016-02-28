/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package uieditor.editor
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Sine;

	import flash.display.Loader;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DProfile;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Timer;

	import starling.core.Starling;

	import uieditor.editor.feathers.popup.MsgBox;
	import uieditor.editor.util.AppUpdater;


	[SWF( frameRate = 60, width = 1280, height = 960, backgroundColor = "#000" )]
	public class SimpleUIEditor extends Sprite
	{
		private var _viewport : Rectangle;
		private var _starling : Starling;

		private var _appUpdater : AppUpdater;

		private var mainWindow : NativeWindow;

		private var splashWindow : NativeWindow;

		private var splashTimer : Timer;

		private var launchImage : Loader;


		public function SimpleUIEditor()
		{
			this.addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );

			_appUpdater = new AppUpdater();
		}

		private function _start( e : Event ) : void
		{
			_starling.start();
		}

		private function addedToStageHandler( event : Event ) : void
		{
			this.removeEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );

			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;

			mainWindow = this.stage.nativeWindow;

			var splashWindowinitOptions : NativeWindowInitOptions = new NativeWindowInitOptions();
			splashWindowinitOptions.transparent = true; //启动屏幕背景透明
			splashWindowinitOptions.systemChrome = NativeWindowSystemChrome.NONE; //无标题栏，状态栏
			splashWindowinitOptions.type = NativeWindowType.UTILITY; //实用程序窗口
			splashWindow = new NativeWindow( splashWindowinitOptions );
			splashWindow.stage.scaleMode = 'noScale';
			splashWindow.stage.align = 'topLeft';

			var file : File = File.applicationDirectory.resolvePath( "assets/Splash.png" );
			var bytes : ByteArray = new ByteArray();
			var stream : FileStream = new FileStream();
			stream.open( file, FileMode.READ );
			stream.readBytes( bytes, 0, stream.bytesAvailable );
			stream.close();
			launchImage = new Loader();
			launchImage.loadBytes( bytes );
			splashWindow.stage.addChild( launchImage ); //添加启动画面
			splashWindow.x = ( Screen.mainScreen.visibleBounds.width - 520 ) / 2;
			splashWindow.y = ( Screen.mainScreen.visibleBounds.height - 520 ) / 2;
			splashWindow.orderInFrontOf( mainWindow );
			splashWindow.activate();

			splashTimer = new Timer( 500, 1 );
			splashTimer.addEventListener( TimerEvent.TIMER_COMPLETE, removeSplash );
			splashTimer.start();
		}

		private function removeSplash( e : TimerEvent ) : void
		{
			//激活主程序窗口 
			mainWindow.x = ( Screen.mainScreen.visibleBounds.width - mainWindow.width ) / 2;
			mainWindow.y = ( Screen.mainScreen.visibleBounds.height - mainWindow.height ) / 2;

			mainWindow.activate();

			init();

			this.stage.addEventListener( Event.RESIZE, stage_resizeHandler, false, int.MAX_VALUE, true );
			this.stage.addEventListener( Event.DEACTIVATE, stage_deactivateHandler, false, 0, true );

			TweenLite.to( launchImage, 0.5, { alpha: 0, ease: Sine.easeInOut, onComplete: onFadeComplete });
		}

		private function onFadeComplete() : void
		{
			launchImage.unloadAndStop( true );
			splashWindow.stage.removeChild( launchImage );
			splashWindow.close();
			splashWindow = null;
			launchImage = null;

			splashTimer.stop();
			splashTimer.removeEventListener( TimerEvent.TIMER_COMPLETE, removeSplash );
			splashTimer = null;
		}

		private function init() : void
		{
			_viewport = new Rectangle( 0, 0, stage.stageWidth, stage.stageHeight );

			_starling = new Starling( UIEditorApp, stage, _viewport, null, Context3DRenderMode.AUTO, Context3DProfile.BASELINE );

			_starling.enableErrorChecking = false;

			_starling.stage3D.addEventListener( Event.CONTEXT3D_CREATE, _start );

			loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
		}

		private function stage_resizeHandler( event : Event ) : void
		{
			_starling.stage.stageWidth = stage.stageWidth;
			_starling.stage.stageHeight = stage.stageHeight;

			var viewPort : Rectangle = _starling.viewPort;
			viewPort.width = stage.stageWidth;
			viewPort.height = stage.stageHeight;
			try
			{
				_starling.viewPort = viewPort;
			}
			catch ( error : Error )
			{
			}
		}

		private function stage_deactivateHandler( event : Event ) : void
		{
			_starling.stop( true );
			stage.addEventListener( Event.ACTIVATE, stage_activateHandler, false, 0, true );
		}

		private function stage_activateHandler( event : Event ) : void
		{
			stage.removeEventListener( Event.ACTIVATE, stage_activateHandler );
			_starling.start();
		}

		private function onUncaughtError( event : UncaughtErrorEvent ) : void
		{
			var message : String;

			if ( event.error is Error )
			{
				message = Error(event.error).message;
			}
			else
			{
				message = event.error.toString();
			}

			MsgBox.show( "错误", message );
		}
	}
}
