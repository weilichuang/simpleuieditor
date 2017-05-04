// =================================================================================================
//
//	Starling Framework
//	Copyright Gamua GmbH. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.utils
{
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	import starling.core.starling_internal;
	import starling.display.DisplayObject;
	import starling.errors.AbstractClassError;
	import starling.rendering.IndexData;
	import starling.rendering.VertexData;

	use namespace starling_internal;

	/** A utility class that helps with tasks that are common when working with meshes. */
	public class MeshUtil
	{
		// helper objects
		private static var sPoint3D : Vector3D = new Vector3D();
		private static var sMatrix : Matrix = new Matrix();
		private static var sMatrix3D : Matrix3D = new Matrix3D();

		private static var p0 : Point = new Point();
		private static var p1 : Point = new Point();
		private static var p2 : Point = new Point();

		/** @private */
		public function MeshUtil()
		{
			throw new AbstractClassError();
		}

		/** Determines if a point is inside a mesh that is spawned up by the given
		 *  vertex- and index-data. */
		public static function containsPoint( vertexData : VertexData, indexData : IndexData, point : Point ) : Boolean
		{
			var i : int;
			var result : Boolean = false;
			var numIndices : int = indexData._numIndices;

			for ( i = 0; i < numIndices; i += 3 )
			{
				vertexData.getPoint( indexData.getIndex( i ), "position", p0 );
				vertexData.getPoint( indexData.getIndex( i + 1 ), "position", p1 );
				vertexData.getPoint( indexData.getIndex( i + 2 ), "position", p2 );

				if ( MathUtil.isPointInTriangle( point, p0, p1, p2 ))
				{
					result = true;
					break;
				}
			}

			return result;
		}

		/** Calculates the bounds of the given vertices in the target coordinate system. */
		public static function calculateBounds( vertexData : VertexData,
			sourceSpace : DisplayObject,
			targetSpace : DisplayObject,
			out : Rectangle = null ) : Rectangle
		{
			if ( out == null )
				out = new Rectangle();

			sourceSpace.getTransformationMatrix( targetSpace, sMatrix );
			vertexData.getBounds( "position", sMatrix, 0, -1, out );

			return out;
		}
	}
}
