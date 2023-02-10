package as3d.display 
{
	import flash.geom.Matrix3D;
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class Frame3D extends Matrix3D
	{
		private var _time:Number;
		
		public function Frame3D(floats:Vector.<Number>, time:Number) 
		{
			super(floats);
			_time = time;
		}
		
		public override function clone():flash.geom.Matrix3D
        {
            var frame:Frame3D = new Frame3D(rawData, _time);
            return frame;
        }
		
		public function get time():Number 
		{
			return _time;
		}
	}

}