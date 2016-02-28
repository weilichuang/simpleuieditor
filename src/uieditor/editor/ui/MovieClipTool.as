package uieditor.editor.ui
{
	import feathers.controls.Button;
	import feathers.controls.LayoutGroup;

	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;

	import uieditor.editor.controller.IDocumentEditor;
	import uieditor.editor.feathers.FeathersUIUtil;

	public class MovieClipTool extends LayoutGroup
	{
		private var _movieClipTool : LayoutGroup;
		private var _playButton : Button;
		private var _stopButton : Button;

		private var _documentManager : IDocumentEditor;

		public function MovieClipTool()
		{
			initMovieClipTool();
		}
		
		public function setDocumentEditor(documentEditor:IDocumentEditor):void
		{
			_documentManager = documentEditor;
		}

		private function initMovieClipTool() : void
		{
			_movieClipTool = FeathersUIUtil.layoutGroupWithHorizontalLayout();

			_playButton = FeathersUIUtil.buttonWithLabel( "play", onPlayButton );
			_stopButton = FeathersUIUtil.buttonWithLabel( "stop", onStopButton );

			_movieClipTool.addChild( FeathersUIUtil.labelWithText( "MovieClip: " ))
			_movieClipTool.addChild( _playButton );
			_movieClipTool.addChild( _stopButton );

			addChild( _movieClipTool );
		}

		public function updateMovieClipTool() : void
		{
			var mv : MovieClip = _documentManager.selectedObject as MovieClip;

			_movieClipTool.visible = ( mv != null );
		}

		private function onPlayButton( event : Event ) : void
		{
			var mv : MovieClip = _documentManager.selectedObject as MovieClip;

			if ( mv )
			{
				Starling.current.juggler.add( mv );
				mv.play();
				_documentManager.setChanged();
			}
		}

		private function onStopButton( event : Event ) : void
		{
			var mv : MovieClip = _documentManager.selectedObject as MovieClip;

			if ( mv )
			{
				mv.stop();
				Starling.current.juggler.remove( mv );
				_documentManager.setChanged();
			}
		}
	}
}
