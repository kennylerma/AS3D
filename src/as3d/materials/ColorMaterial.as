package as3d.materials {

	/**
	 * @author Kenny Lerma
	 */
	public class ColorMaterial {
		
		public var name:String;
		private var _red:Number;
		private var _green:Number;
		private var _blue:Number;
		private var _rgb:Vector.<Number>;
		
		public function ColorMaterial(color:Number = 0xFFFFFF) 
		{
			_red = ((color & 0xFF0000) >> 16);
			_green = ((color & 0x00FF00) >> 8);
			_blue = ((color & 0x0000FF));
			
			_rgb = new <Number>[_red / 255, _green / 255, _blue / 255, 1];
		}
		
		public function setRGB(red:Number, green:Number, blue:Number):void
		{
			_red = red;
			_green = green;
			_blue = blue;
			
			_rgb = new <Number>[_red, _green, _blue, 1];
		}
		
		public function get rgb():Vector.<Number> {
			return _rgb;
		}
		
		public function get red():Number {
			return _red;
		}
		
		public function get green():Number {
			return _green;
		}
		
		public function get blue():Number {
			return _blue;
		}
	}
}
