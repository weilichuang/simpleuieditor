package starling.text
{
	import starling.core.starling_internal;
	import starling.display.Mesh;
	import starling.rendering.IndexData;
	import starling.rendering.Painter;
	import starling.rendering.VertexData;
	import starling.styles.MeshStyle;
	import starling.utils.MatrixUtil;

	use namespace starling_internal;

	/**
	 * 用于合并多个SimpleBitmapText一次渲染,所有文本将使用同一个颜色，使用第一个字符的颜色和透明度
	 * <p>支持最大字符数60</p>
	 * 所有SimpleBitmapText必须和SimpleBitmapTextGroup在同一个容器下，
	 * SimpleBitmapText不能有缩放、旋转和变形
	 * 必须使用同一套字体
	 */
	public class SimpleBitmapTextGroup extends Mesh
	{
		private var _textList : Vector.<SimpleBitmapText>;

		private var _effect : SimpleTextEffect;
		private var _vertexSyncRequired : Boolean;
		private var _indexSyncRequired : Boolean;
		private var _maxChar : int;

		/** 字符数量*/
		private var _numChar : int = 0;

		private var positionUVs : Vector.<Number> = new Vector.<Number>();
		private var colors : Vector.<Number> = Vector.<Number>([ 1, 1, 1, 1 ]);

		public function SimpleBitmapTextGroup( maxChar : int )
		{
			var vertexData : VertexData = new VertexData();
			var indexData : IndexData = new IndexData();

			super( vertexData, indexData, new SimpleTextStyle());

			_textList = new Vector.<SimpleBitmapText>();

			setMaxChar( maxChar );

			this.touchable = false;
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
				//常量只有128个，还有前6个shader需要使用，最多只支持60个
				_maxChar = Math.min( maxChar, 60 );

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

		/**
		 *
		 */
		public function addText( text : SimpleBitmapText ) : void
		{
			if ( _textList.indexOf( text ) == -1 )
			{
				text.group = this;
				text.alpha = 0;
				_textList[ _textList.length ] = text;
				composeText();
			}
		}

		public function setRequiresRecomposition() : void
		{
			var count : int = _textList.length;
			for ( var i : int = 0; i < count; i++ )
			{
				_textList[ i ].setRequiresRecomposition();
			}
		}

		private function checkCompose() : void
		{
			var requiresRecomposition : Boolean = false;
			var bitmapText : SimpleBitmapText;
			var count : int = _textList.length;
			for ( var i : int = 0; i < count; i++ )
			{
				bitmapText = _textList[ i ];
				if ( bitmapText.isRequiresRecomposition())
				{
					requiresRecomposition = true;
					break;
				}
			}

			if ( requiresRecomposition )
			{
				composeText();
			}
		}

		public function composeText() : void
		{
			var count : int = _textList.length;
			var bitmapText : SimpleBitmapText;
			var textBatch : SimpleTextBatch;
			var tx : Number;
			var ty : Number;
			_numChar = 0;
			var index : int = 0;
			for ( var i : int = 0; i < count; i++ )
			{
				bitmapText = _textList[ i ];
				if ( !bitmapText.visible )
					continue;

				if ( bitmapText.isRequiresRecomposition())
				{
					bitmapText.recompose();
				}

				textBatch = bitmapText._textBatch;

				if ( i == 0 )
				{
					_style.texture = textBatch.texture;
					colors[ 0 ] = textBatch.colors[ 0 ];
					colors[ 1 ] = textBatch.colors[ 1 ];
					colors[ 2 ] = textBatch.colors[ 2 ];
					colors[ 3 ] = textBatch.colors[ 3 ];
				}

				var numChar : int = textBatch._numChar;
				if ( numChar > 0 )
				{
					tx = bitmapText.x;
					ty = bitmapText.y;

					var textPositions : Vector.<Number> = textBatch.positionUVs;
					var c8 : int;
					for ( var c : int = 0; c < numChar; c++ )
					{
						c8 = c * 8;
						//修改坐标
						positionUVs[ index ] = tx + textPositions[ c8 ];
						positionUVs[ index + 1 ] = ty + textPositions[ c8 + 1 ];
						positionUVs[ index + 2 ] = textPositions[ c8 + 2 ];
						positionUVs[ index + 3 ] = textPositions[ c8 + 3 ];

						positionUVs[ index + 4 ] = textPositions[ c8 + 4 ];
						positionUVs[ index + 5 ] = textPositions[ c8 + 5 ];
						positionUVs[ index + 6 ] = textPositions[ c8 + 6 ];
						positionUVs[ index + 7 ] = textPositions[ c8 + 7 ];

						index += 8;
					}

					_numChar += numChar;
				}
			}

			//后面的全部置0
			if ( _numChar < _maxChar )
			{
				positionUVs.length = _numChar * 8;
				positionUVs.length = _maxChar * 8;
			}
		}

		public override function render( painter : Painter ) : void
		{
			checkCompose();

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

			if ( _style.texture != null )
			{
				_style.updateEffect( _effect, painter.state );
				_effect.positions = positionUVs;
				_effect.colors = colors;
				_effect.render( painter, 0, indexData._numTriangles );
			}
		}

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

		override public function set x( value : Number ) : void
		{
			super.x = 0;
		}

		override public function set y( value : Number ) : void
		{
			super.y = 0;
		}
	}
}
