package uieditor.engine.localization
{
    public interface ILocalization
    {
        function getLocalizedText(key:String):String;

        function getLocales():Array;

        function getKeys():Array;

        function get locale():String;

        function set locale(value:String):void;
    }
}
