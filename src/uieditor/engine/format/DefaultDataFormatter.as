package uieditor.engine.format
{
    public class DefaultDataFormatter implements IDataFormatter
    {
        public function read(data:Object):Object
        {
            if (data is String)
            {
                return JSON.parse(data as String);
            }
            else
            {
                return data;
            }
        }

        public function write(data:Object):Object
        {
            //return JSON.stringify(data, null, 2);

            return StableJSONEncoder.stringify(data);
        }

    }
}
