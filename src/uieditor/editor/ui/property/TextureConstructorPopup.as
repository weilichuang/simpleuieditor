package uieditor.editor.ui.property
{
	import uieditor.editor.UIEditorApp;

    public class TextureConstructorPopup extends TexturePropertyPopup
    {
        public function TextureConstructorPopup(owner:Object, target:Object, targetParam:Object, onComplete:Function)
        {
            super(owner, target, targetParam, onComplete);
        }

        override protected function setCustomParam(textureName:String):void
        {
            var param:Object = UIEditorApp.instance.currentDocumentEditor.extraParamsDict[_owner];

            var param1:Object = param.constructorParams[0];

            if (param1.textureName)
            {
                param1.textureName = textureName;
            }

            if (_owner.hasOwnProperty(_targetParam.name))
                _owner[_targetParam.name] = UIEditorApp.instance.assetManager.getTexture(textureName);

            if (_owner.hasOwnProperty("readjustSize"))
                _owner["readjustSize"]();

			UIEditorApp.instance.currentDocumentEditor.setChanged();
        }
    }
}
