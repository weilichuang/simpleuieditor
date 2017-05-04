// =================================================================================================
//
//	Starling Framework
//	Copyright Gamua GmbH. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.rendering
{
	import flash.display3D.Context3D;
	import flash.display3D.Program3D;
	import flash.events.Event;
	
	import org.taomee.shader.IProgram3DUser;
	import org.taomee.shader.ShaderCache;
	import org.taomee.shader.ProgramInfo;
	
	import starling.core.Starling;
	import starling.core.starling_internal;

	use namespace starling_internal;

	/** A Program represents a pair of a fragment- and vertex-shader.
	 *
	 *  <p>This class is a convenient replacement for Stage3Ds "Program3D" class. Its main
	 *  advantage is that it survives a context loss; furthermore, it makes it simple to
	 *  create a program from AGAL source without having to deal with the assembler.</p>
	 *
	 *  <p>It is recommended to store programs in Starling's "Painter" instance via the methods
	 *  <code>registerProgram</code> and <code>getProgram</code>. That way, your programs may
	 *  be shared among different display objects or even Starling instances.</p>
	 *
	 *  @see Painter
	 */
	public class Program implements IProgram3DUser
	{
		private var _vertexShader : String;
		private var _fragmentShader : String;

		private var _programId : int = -1;
		private var _program3D : Program3D;

		/** Creates a program from the given AGAL (Adobe Graphics Assembly Language) bytecode. */
		public function Program( vertexShader : String, fragmentShader : String )
		{
			_vertexShader = vertexShader;
			_fragmentShader = fragmentShader;

			// Handle lost context (using conventional Flash event for weak listener support)
			Starling.current.stage3D.addEventListener( Event.CONTEXT3D_CREATE,
				onContextCreated, false, 30, true );
		}

		/** Disposes the internal Program3D instance. */
		public function dispose() : void
		{
			Starling.current.stage3D.removeEventListener( Event.CONTEXT3D_CREATE, onContextCreated );
			disposeProgram();
		}

		/** Creates a new Program instance from AGAL assembly language. */
		public static function fromSource( vertexShader : String, fragmentShader : String ) : Program
		{
			return new Program( vertexShader, fragmentShader );
		}

		/** Activates the program on the given context. If you don't pass a context, the current
		 *  Starling context will be used. */
		public function activate( painter : Painter, context : Context3D ) : void
		{
			if(_program3D != null)
			{
				painter.setProgram( _program3D );
				return;
			}
			
			var programInfo : ProgramInfo = ShaderCache.getInstance().setProgram3D( context, this, _vertexShader, _fragmentShader );
			if ( programInfo )
				painter.setProgram( programInfo.program3D );
		}

		private function onContextCreated( event : Event ) : void
		{
			disposeProgram();
		}

		private function disposeProgram() : void
		{
			_program3D = null;

			ShaderCache.getInstance().freeProgram3D( _programId );
			_programId = -1;
		}

		public function getCurrentProgramIndex() : int
		{
			return _programId;
		}

		public function setCurrentProgram( context : Context3D, programId : int, program : Program3D ) : Boolean
		{
			_programId = programId;
			_program3D = program;
			return true;
		}
	}
}
