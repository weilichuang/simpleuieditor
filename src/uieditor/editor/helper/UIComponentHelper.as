package uieditor.editor.helper
{
	import feathers.core.PopUpManager;
	import starling.display.DisplayObject;
	import starling.textures.Texture;
	import uieditor.editor.data.TemplateData;
	import uieditor.editor.UIEditorApp;
	import uieditor.engine.util.ParamUtil;



	public class UIComponentHelper
	{
		public function UIComponentHelper()
		{
		}

		public static function createComponent( editorData : Object, createHandler : Function = null ) : void
		{
			var data : Object = createComponentData( editorData );

			var cls : Class = ParamUtil.getCreateComponentClass( TemplateData.editor_template, data.cls );
			if ( cls )
			{
				var popup : DisplayObject = new cls( data, function( data : Object ) : void
				{
					UIEditorApp.instance.currentDocumentEditor.createFromData( data, createHandler );
				});
				PopUpManager.addPopUp( popup );
			}
			else
			{
				UIEditorApp.instance.currentDocumentEditor.createFromData( data, createHandler );
			}
		}

		private static function onCreateComponentComplete( data : Object ) : void
		{
			UIEditorApp.instance.currentDocumentEditor.createFromData( data );
		}

		private static function createComponentData( editorData : Object ) : Object
		{
			var data : Object = { cls: editorData.cls, params: {}, customParams: {}};

			var constructorParams : Array = ParamUtil.getConstructorParams( TemplateData.editor_template, editorData.cls );

			data.params.name = editorData.name;

			setTextureName( constructorParams, editorData.textureName );

			//setScaleRatio( constructorParams, editorData.scaleData );

			setFontParams( data.params, editorData.fontName, editorData.text );

			setX( data.params, editorData.x );

			setY( data.params, editorData.y );

			setWidth( data.params, editorData.width );

			setHeight( data.params, editorData.height );

			if ( constructorParams && constructorParams.length )
				data.constructorParams = constructorParams;

			return data;
		}

		private static var textureClassNames : Array;

		private static function setTextureName( constructorParams : Array, textureName : String ) : void
		{
			if ( !textureName )
				return;

			if ( textureClassNames == null )
			{
				textureClassNames = ParamUtil.getClassNames([ Texture ]);
			}

			for each ( var param : Object in constructorParams )
			{
				if ( textureClassNames.indexOf( param.cls ) != -1 )
				{
					param.textureName = textureName;
				}
			}
		}

		private static function setFontParams( params : Object, fontName : String, text : String ) : void
		{
			if ( fontName )
				params.fontName = fontName;
			if ( text )
				params.text = text;
		}

		private static function setX( params : Object, value : String ) : void
		{
			if ( value )
				params.x = value;
		}

		private static function setY( params : Object, value : String ) : void
		{
			if ( value )
				params.y = value;
		}

		private static function setWidth( params : Object, value : String ) : void
		{
			if ( value )
				params.width = value;
		}

		private static function setHeight( params : Object, value : String ) : void
		{
			if ( value )
				params.height = value;
		}
	}
}
