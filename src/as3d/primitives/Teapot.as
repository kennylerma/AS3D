package as3d.primitives 
{
	import flash.display3D.Context3D;
	import Config;
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class Teapot extends Model2
	{
		
		
		private var _context3D:Context3D;
		
		public function Teapot() 
		{
			_context3D = Config.stage3d.context3D;
			
			
		}
		
	}

}