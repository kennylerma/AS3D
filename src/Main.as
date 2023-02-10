package
{
	import as3d.display.Scene3D;
	import as3d.loaders.DAELoader;
	import as3d.loaders.Max3DSLoader;
	import as3d.primitives.Cube;
	import as3d.primitives.Plane;
	import as3d.primitives.Sphere;
	import asd.AxeData;
	import flare.core.Pivot3D;
	import flash.display.Sprite;
	import flash.events.Event;
	import asd.ASDReader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class Main extends Sprite 
	{
		private var _scene:Scene3D;
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			_scene = new Scene3D(this);
			_scene.camera.near = 0.1;
			_scene.camera.far = 10000;
			_scene.addEventListener(Scene3D.SCENE_READY, onSceneReady);
		}
		
		private function onSceneReady(e:Event):void 
		{
			//_scene.addChild(new Sphere("My Sphere", 20, 20));
			//_scene.addChild(new Plane("My Plane", 100, 100));
			/*
			for (var i:int = 0; i < 4; i++) 
			{
				var cube:Cube = new Cube("My Cube", 20);
				cube.moveRight(25 * i);
				_scene.addChild(cube);
			}*/
			
			var daeLoader:DAELoader = new DAELoader("../assets/planeAni.dae");
			daeLoader.load();
			
			//var max3DSLoader:Max3DSLoader = new Max3DSLoader("../assets/AxeOnly.3ds");
			//max3DSLoader.load();
		}
		
	}
	
}