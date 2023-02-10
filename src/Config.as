package 
{
	import as3d.display.ArcBallCamera;
	import as3d.display.Camera3DOrbit;
	import as3d.display.Scene3D;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class Config 
	{
		public static var stage:Stage;
		public static var stage3d:Stage3D;
		public static var camera:Camera3DOrbit;
		public static var scene:Scene3D;
		
		// ambient light...default white
		public static var ambientColor:Vector.<Number> = new <Number>[1, 1, 1, .1]; // rgb and intensity
	}

}