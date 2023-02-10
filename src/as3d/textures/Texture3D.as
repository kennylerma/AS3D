package as3d.textures 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.textures.Texture;
	import flash.events.EventDispatcher;
	import flash.display3D.Context3DTextureFormat;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import Config;
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class Texture3D extends EventDispatcher
	{
		private var _texture:Texture;
		
		public function Texture3D(image:Bitmap, mipMap:Boolean = false) 
		{
			var bmd:BitmapData = image.bitmapData;
			_texture = Config.stage3d.context3D.createTexture(bmd.width, bmd.height, Context3DTextureFormat.BGRA, false);
			
			if (mipMap)
			{
				var w:int = bmd.width;
				var h:int = bmd.height;
				var miplevel:int = 0;
				while (w > 0) {
					_texture.uploadFromBitmapData(getResizedBitmapData(bmd, w, h, true, 0), miplevel);
					miplevel++;
					w = w * .5;
					h = h * .5;
				}
			}
			else
			{
				_texture.uploadFromBitmapData(bmd);
			}
			
			
		}
		
		private function getResizedBitmapData(bmp:BitmapData, width:uint, height:uint, smoothing:Boolean, color:int = 0x000000):BitmapData
		{
			var bmpData:BitmapData = new BitmapData(width, height, bmp.transparent, 0x00FFFFFF);
			var scaleMatrix:Matrix = new Matrix(width / bmp.width, 0, 0, height / bmp.height, 0, 0);
			bmpData.draw(bmp, scaleMatrix, new ColorTransform(1, 1, 1, 1, (color >> 16) & 0xFF, (color >> 8) & 0xFF, (color) & 0xFF ), null, null, smoothing);
			
			return bmpData;
		}
		
		public function get texture():Texture 
		{
			return _texture;
		}
		
	}

}