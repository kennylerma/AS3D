package 
{
	import flare.basic.Scene3D;
	import flare.basic.Viewer3D;
	import flare.core.Surface3D;
	import flare.loaders.ColladaLoader;
	import flare.loaders.ColladaLoader2;
	import flare.modifiers.SkinModifier;
	import flash.display.Sprite;
	import flash.events.Event;
	import flare.core.Mesh3D;
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class ColladaParsing extends Sprite
	{
		private var _scene:Scene3D;
		private var _ld:ColladaLoader;
		private var _ld2:ColladaLoader2;
		
		public function ColladaParsing() 
		{
			_scene = new Viewer3D(this);
			_scene.camera.translateZ( -5);
			_scene.autoResize = true;
			_scene.physics.gravity.setTo( 0, -5, 0 );
			_scene.showLogo = false;
			
			_ld = new ColladaLoader("../assets/cubeAnim.dae");
			_ld.addEventListener(Event.COMPLETE, onColladaComplete);
			_ld.parent = _scene;
			_ld.load();
			
			/*_ld2 = new ColladaLoader2("../assets/IndieGuyNoMask.dae");
			_ld2.addEventListener(Event.COMPLETE, onColladaComplete2);
			_ld2.parent = _scene;
			_ld2.load();*/
		}
		
		private function onColladaComplete(e:Event):void 
		{
			trace("ColladaParsing.onColladaComplete()");
			
			var surfaces:Vector.<Surface3D> = _ld.getSurfaces();
			for (var i:int = 0; i < surfaces.length; i++) 
			{
				var surf:Surface3D = surfaces[i];
				//trace("Real Surface " + i + " Indexes: " + surf.indexVector + ", Verts: " + surf.vertexVector);
			}
			
			
			
			trace("Frames: " + _ld.children[0].frames.length);
			var mesh:Mesh3D = _ld.children[0] as Mesh3D;
			mesh.gotoAndStop(1);
			var skin:SkinModifier = mesh.modifier as SkinModifier;
			trace("Skin Bone index 0 Frame 2: " + skin.bones[0].name + ", Data: " + skin.bones[0].frames[0].rawData);
			trace("Skin Bone index 0 Frame 1: " + skin.bones[0].name + ", Data: " + skin.bones[0].frames[1].rawData);
			trace("Skin Bone index 0 Frame 2: " + skin.bones[0].name + ", Data: " + skin.bones[0].frames[2].rawData);
			
			trace("Skin Bone index 1 Frame 0: " + skin.bones[1].name + ", Data: " + skin.bones[1].frames[0].rawData);
			trace("Skin Bone index 1 Frame 1: " + skin.bones[1].name + ", Data: " + skin.bones[1].frames[1].rawData);
			trace("Skin Bone index 1 Frame 2: " + skin.bones[1].name + ", Data: " + skin.bones[1].frames[2].rawData);
			
			
		}
		
		private function onColladaComplete2(e:Event):void 
		{
			trace("ColladaParsing.onColladaComplete2()");
			
			var surfaces:Vector.<Surface3D> = _ld2.getSurfaces();
			for (var i:int = 0; i < surfaces.length; i++) 
			{
				var surf:Surface3D = surfaces[i];
				trace("Test Surface " + i + " Indexes: " + surf.indexVector + ", Verts: " + surf.vertexVector);
			}
			
		}
		
	}

}