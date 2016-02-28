package uieditor.editor.ui.inspector
{
    public interface ILinkOperation
    {
        function update(target:Object, changedPropertyName:String, propertyName:String):void;
    }
}
