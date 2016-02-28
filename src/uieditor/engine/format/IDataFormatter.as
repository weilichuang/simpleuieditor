package uieditor.engine.format
{
    public interface IDataFormatter
    {
        function read(data:Object):Object;
        function write(data:Object):Object;
    }
}
