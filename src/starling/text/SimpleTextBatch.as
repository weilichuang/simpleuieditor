package starling.text
{
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import starling.core.starling_internal;
	import starling.display.IMeshBatch;
	import starling.display.Mesh;
	import starling.rendering.IndexData;
	import starling.rendering.Painter;
	import starling.rendering.VertexData;
	import starling.styles.MeshStyle;
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	import starling.utils.MatrixUtil;
	import starling.utils.MeshSubset;

	use namespace starling_internal;

	/**
	 * SimpleBitmapText专用,最多支持50个字符
	 */
	internal class SimpleTextBatch extends Mesh implements IMeshBatch
	{
		private var _effect : SimpleTextEffect;
		private var _vertexSyncRequired : Boolean;
		private var _indexSyncRequired : Boolean;
		private var _maxChar : int;

		/** 字符数量*/
		starling_internal var _numChar : int = 0;

		starling_internal var positionUVs : Vector.<Number> = new Vector.<Number>();
		starling_internal var colors : Vector.<Number> = Vector.<Number>([ 1, 1, 1, 1 ]);

		/**
		 * @param maxCount 最大文字数量
		 * @param style
		 */
		public function SimpleTextBatch( maxChar : int, style : SimpleTextStyle )
		{
			var vertexData : VertexData = new VertexData();
			var indexData : IndexData = new IndexData();

			super( vertexData, indexData, style );

			setMaxChar( maxChar );
		}

		public function setColor( color : uint, alpha : Number ) : void
		{
			colors[ 0 ] = ( color >> 16 & 0xff ) / 255.0;
			colors[ 1 ] = ( color >> 8 & 0xff ) / 255.0;
			colors[ 2 ] = ( color & 0xff ) / 255.0;
			colors[ 3 ] = alpha;
		}

		public function setMaxChar( maxChar : int ) : void
		{
			if ( _maxChar != maxChar )
			{
				_maxChar = Math.min( maxChar, 50 );

				setupVertices();
			}
		}

		/**
		 * 修改最大字符数量后，需要修改VertexData和IndexData
		 * 文本位置统一为0,0,大小为1,1
		 * uv为0-1
		 * 之后在shader中修改具体的位置和uv信息
		 */
		protected function setupVertices() : void
		{
			const posAttr : String = "position";
			const texAttr : String = "texCoords";

			indexData.numIndices = 0;
			vertexData.numVertices = _maxChar * 4;
			vertexData.trim();

			positionUVs.length = _maxChar * 8;

			var index : int = 0;
			//offset用于在Shader中查找具体位置大小和UV信息
			//offset+0 -->位置大小
			//offfset+1 -->uv信息
			var offset : int = 6; //前四位是矩阵，第5位放常量，从第六位开始
			for ( var i : int = 0; i < _maxChar; i++ )
			{
				indexData.addQuad( index, index + 1, index + 2, index + 3 );

				vertexData.setPoint3D( index, posAttr, 0, 0, offset );
				vertexData.setPoint3D( index + 1, posAttr, 1, 0, offset );
				vertexData.setPoint3D( index + 2, posAttr, 0, 1, offset );
				vertexData.setPoint3D( index + 3, posAttr, 1, 1, offset );

				vertexData.setPoint( index, texAttr, 0.0, 0.0 );
				vertexData.setPoint( index + 1, texAttr, 1.0, 0.0 );
				vertexData.setPoint( index + 2, texAttr, 0.0, 1.0 );
				vertexData.setPoint( index + 3, texAttr, 1.0, 1.0 );

				index += 4;
				offset += 2;
			}

			_vertexSyncRequired = true;
			_indexSyncRequired = true;
		}

		// display object overrides

		/** @inheritDoc */
		override public function dispose() : void
		{
			if ( _effect )
			{
				_effect.dispose();
				_effect = null;
			}
			super.dispose();
		}

		private function setVertexAndIndexDataChanged() : void
		{
			_vertexSyncRequired = _indexSyncRequired = true;
		}

		private function syncVertexBuffer() : void
		{
			_effect.uploadVertexData( vertexData );
			_vertexSyncRequired = false;
		}

		private function syncIndexBuffer() : void
		{
			_effect.uploadIndexData( indexData );
			_indexSyncRequired = false;
		}

		/**
		 * 重置当前位置,addMesh时会根据当前位置来添加
		 */
		public function clear() : void
		{
			_numChar = 0;
		}

		private var _invTextureWidth:Number;
		private var _invTextureHeight:Number;
		public function addMesh( mesh : Mesh, matrix : Matrix = null, alpha : Number = 1.0,
			subset : MeshSubset = null, ignoreTransformations : Boolean = false ) : void
		{
//			if ( !( mesh is SimpleBitmapImage ))
//				throw new Error( "SimpleTextBatch only support SimpleBitmapImage" );

			var image : SimpleBitmapImage = SimpleBitmapImage( mesh );

			var texture : Texture = image.textTexture;
			
			if(_numChar == 0)
			{
				_style.texture = texture;
				
				_invTextureWidth = 1 / texture.root.nativeWidth;
				_invTextureHeight = 1 / texture.root.nativeHeight;
			}

			var index : int = _numChar * 8;
			
			if(image.textScale != 0)
			{
				positionUVs[ index ] = image.textX;
				positionUVs[ index + 1 ] = image.textY;
				positionUVs[ index + 2 ] = image.textWidth;
				positionUVs[ index + 3 ] = image.textHeight;
				
				var region : Rectangle = SubTexture( texture ).region;
				var sx : Number = region.x * _invTextureWidth;
				var sy : Number = region.y * _invTextureHeight;
				var sw : Number = region.width * _invTextureWidth;
				var sh : Number = region.height * _invTextureHeight;
				
				positionUVs[ index + 4 ] = sx;
				positionUVs[ index + 5 ] = sy;
				positionUVs[ index + 6 ] = sw;
				positionUVs[ index + 7 ] = sh;
			}
			else
			{
				positionUVs[ index ] = 0;
				positionUVs[ index + 1 ] = 0;
				positionUVs[ index + 2 ] = 0;
				positionUVs[ index + 3 ] = 0;
				positionUVs[ index + 4 ] = 0;
				positionUVs[ index + 5 ] = 0;
				positionUVs[ index + 6 ] = 0;
				positionUVs[ index + 7 ] = 0;
			}

			_numChar++;
		}

		override public function render( painter : Painter ) : void
		{
			//没有文本添加进来
			if ( _numChar == 0 )
				return;

			if ( pixelSnapping )
				MatrixUtil.snapToPixels( painter.state.modelviewMatrix, painter.pixelSize );

			painter.finishMeshBatch();

			CONFIG::statistics
			{
				painter.drawCount += 1;
			}

			painter.prepareToDraw();
			painter.excludeFromCache( this );

			if ( _vertexSyncRequired )
				syncVertexBuffer();
			if ( _indexSyncRequired )
				syncIndexBuffer();

			_style.updateEffect( _effect, painter.state );
			_effect.positions = positionUVs;
			_effect.colors = colors;
			_effect.render( painter, 0, indexData._numTriangles );
		}

		/** @inheritDoc */
		override public function setStyle( meshStyle : MeshStyle = null,
			mergeWithPredecessor : Boolean = true ) : void
		{
			super.setStyle( meshStyle, mergeWithPredecessor );

			if ( _effect )
				_effect.dispose();

			_effect = style.createEffect() as SimpleTextEffect;
			_effect.onRestore = setVertexAndIndexDataChanged;
		}
	}
}

