package as3d.primitives 
{
	import as3d.display.LinesMesh;
	import as3d.display.Mesh3D;
	import as3d.materials.ColorMaterial;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class Lines3D extends LinesMesh
	{
		
		private var _color:ColorMaterial = new ColorMaterial(0xFFFFFF);
		private var _size:Number = .05;
		private var _move:Vector3D = new Vector3D();
		private var _to:Vector3D = new Vector3D();
		
		public function Lines3D(name:String = "Lines3D") 
		{
			super(name, 6);
			
			//x, y, z
			vertices.push( -150, -_size, 0,  _color.red, _color.green, _color.blue,   150, -_size, 0,  _color.red, _color.green, _color.blue);  // down
			
			vertices.push( -150, _size, -_size,  _color.red, _color.green, _color.blue,   150, _size, -_size, _color.red, _color.green, _color.blue); // up and back
			
			vertices.push( -150, _size, _size,  _color.red, _color.green, _color.blue,   150, _size, _size,  _color.red, _color.green, _color.blue);  // up and forward
			
			indexes.push(0, 1, 2, 1, 3, 2, 		2,3,4, 3, 5, 4,	 	 4, 0, 5, 5, 0, 1);
			
			createBuffers();
			
			trace("Line Verts: " + vertices);
			trace("Line Indices: " + indexes);
		}
		
		public function moveTo(x:Number, y:Number, z:Number):void 
		{
			_move = new Vector3D(x, y, z);
		}
		
		public function lineTo(x:Number, y:Number, z:Number):void 
		{
			_to = new Vector3D(x, y, z);
			Draw();
		}
		
		private function Draw():void 
		{
			vertices.push( -150, -_size, 0,  _color.red, _color.green, _color.blue,   150, -_size, 0,  _color.red, _color.green, _color.blue);  // down
			
			vertices.push( -150, _size, -_size,  _color.red, _color.green, _color.blue,   150, _size, -_size, _color.red, _color.green, _color.blue); // up and back
			
			vertices.push( -150, _size, _size,  _color.red, _color.green, _color.blue,   150, _size, _size,  _color.red, _color.green, _color.blue);  // up and forward
			
			
			_move = _to;
		}
		
	}

}