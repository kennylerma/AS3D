package as3d.display 
{
	import as3d.display.Frame3D;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.display3D.Program3D;
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class Object3D extends EventDispatcher
	{
		private var _x:Number = 0;
		private var _y:Number = 0;
		private var _z:Number = 0;
		private var _rotationX:Number = 0;
		private var _rotationY:Number = 0;
		private var _rotationZ:Number = 0;
		private var _scaleX:Number = 1;
		private var _scaleY:Number = 1;
		private var _scaleZ:Number = 1;
		private var _specularPower:Number = 50;
		private var _specularLevel:Number = 1;
		private var _dirty:Boolean = false;
		private var _mat:Matrix3D;
		private var _name:String;
		private var _numChildren:int = 0;
		
		private var _skeleton:Skeleton;
		private var _lightsEnabled:Boolean = true;
		private var _transparent:Boolean = false;
		
		private var _frames:Vector.<Frame3D> = new Vector.<Frame3D>();
		private var _children:Vector.<Object3D> = new Vector.<Object3D>();
		private var _program:Program3D;
		
		public function Object3D(name:String = "") 
		{
			_name = name;
			_mat = new Matrix3D();
			_mat.appendScale(0.05, 0.05, 0.05);
		}
		
		public function get name():String { return _name; }
		public function get numChildren():int { return _numChildren; }
		
		public function get mat():Matrix3D { return _mat; }
		public function set mat(value:Matrix3D):void 
		{ 
			_mat = value;
			updateValuesFromMatrix();
		}
		public function get program():Program3D { return _program; }
		public function set program(value:Program3D):void { _program = value; }
		public function get frames():Vector.<Frame3D> { return _frames; }
		public function set frames(value:Vector.<Frame3D>):void { _frames = value; }
		
		public function get skeleton():Skeleton { return _skeleton; }
		public function set skeleton(value:Skeleton):void { _skeleton = value; }
		
		public function get lightsEnabled():Boolean { return _lightsEnabled; }
		public function set lightsEnabled(value:Boolean):void { _lightsEnabled = value; }
		
		public function get transparent():Boolean { return _transparent; }
		public function set transparent(value:Boolean):void { _transparent = value; }
		
		public function get children():Vector.<Object3D> { return _children; }
		
		public function get x():Number 
		{ 
			if (_dirty) updateValuesFromMatrix();
			return _x; 
		}
		
		public function set x(value:Number):void 
		{
			_x = value;
			_dirty = true;
			updateMatrix();
		}
		
		public function get y():Number 
		{ 
			if (_dirty) updateValuesFromMatrix();
			return _y; 
		}
		
		public function set y(value:Number):void
		{ 
			_y = value;
			_dirty = true;
			updateMatrix();
		}
		
		public function get z():Number 
		{ 
			if (_dirty) updateValuesFromMatrix();
			return _mat.position.z; 
		}
		
		public function set z(value:Number):void 
		{ 
			_z = value; 
			_dirty = true;
			updateMatrix();
		}
		
		public function get rotationX():Number 
		{ 
			if (_dirty) updateValuesFromMatrix();
			return _rotationX; 
		}
		
		public function set rotationX(value:Number):void 
		{ 
			_rotationX = value; 
			_dirty = true;
			updateMatrix();
		}
		
		public function get rotationY():Number
		{ 
			if (_dirty) updateValuesFromMatrix();
			return _rotationY; 
		}
		
		public function set rotationY(value:Number):void
		{ 
			_rotationY = value; 
			_dirty = true;
			updateMatrix();
		}
		
		public function get rotationZ():Number
		{ 
			if (_dirty) updateValuesFromMatrix();
			return _rotationZ; 
		}
		
		public function set rotationZ(value:Number):void
		{ 
			_rotationZ = value; 
			_dirty = true;
			updateMatrix();
		}
		
		public function get scaleX():Number
		{ 
			if (_dirty) updateValuesFromMatrix();
			return _scaleX; 
		}
		
		public function set scaleX(value:Number):void 
		{ 
			_scaleX = (value == 0) ? .00001 : value;
			_dirty = true;
			updateMatrix();
		}
		
		public function get scaleY():Number
		{ 
			if (_dirty) updateValuesFromMatrix();
			return _scaleY; 
		}
		
		public function set scaleY(value:Number):void
		{ 
			_scaleY = (value == 0) ? .00001 : value;
			_dirty = true;
			updateMatrix();
		}
		
		public function get scaleZ():Number
		{ 
			if (_dirty) updateValuesFromMatrix();
			return _scaleZ; 	
		}
		
		public function set scaleZ(value:Number):void
		{ 
			_scaleZ = (value == 0) ? .00001 : value; 
			_dirty = true;
			updateMatrix();
		}
		
		public function get specularPower():Number 
		{
			return _specularPower;
		}
		
		public function set specularPower(value:Number):void 
		{
			_specularPower = value;
		}
		
		public function get specularLevel():Number 
		{
			return _specularLevel;
		}
		
		public function set specularLevel(value:Number):void 
		{
			_specularLevel = value;
		}
		
		public function scale(value:Number):void 
		{
			_scaleX = _scaleY = _scaleZ = value;
			_dirty = true;
			updateMatrix();
		}
		
		public function rotateX(degrees:Number):void 
		{
			_rotationX += degrees;
			_dirty = true;
			updateMatrix();
		}
		
		public function rotateY(degrees:Number):void 
		{
			_rotationY += degrees;
			_dirty = true;
			updateMatrix();
		}
		
		public function rotateZ(degrees:Number):void 
		{
			_rotationZ += degrees;
			_dirty = true;
			updateMatrix();
		}
		
		public function moveLeft(value:Number):void
		{
			var axis:Vector3D = Vector3D.X_AXIS;
			x = axis.x, y = axis.y, z = axis.z;
			var len:Number = -value/Math.sqrt(x*x + y*y + z*z);
			
			_mat.prependTranslation(x*len, y*len, z*len);
		}
		
		public function moveRight(value:Number):void
		{
			var axis:Vector3D = Vector3D.X_AXIS;
			x = axis.x, y = axis.y, z = axis.z;
			var len:Number = value/Math.sqrt(x*x + y*y + z*z);
			
			_mat.prependTranslation(x*len, y*len, z*len);
		}
		
		public function moveForward(value:Number):void
		{
			var axis:Vector3D = Vector3D.Z_AXIS;
			x = axis.x, y = axis.y, z = axis.z;
			var len:Number = value/Math.sqrt(x*x + y*y + z*z);
			
			_mat.prependTranslation(x*len, y*len, z*len);
		}
		
		public function moveBack(value:Number):void
		{
			var axis:Vector3D = Vector3D.Z_AXIS;
			x = axis.x, y = axis.y, z = axis.z;
			var len:Number = -value/Math.sqrt(x*x + y*y + z*z);
			
			_mat.prependTranslation(x*len, y*len, z*len);
		}
		
		public function moveUp(value:Number):void
		{
			var axis:Vector3D = Vector3D.Y_AXIS;
			x = axis.x, y = axis.y, z = axis.z;
			var len:Number = value/Math.sqrt(x*x + y*y + z*z);
			
			_mat.prependTranslation(x*len, y*len, z*len);
		}
		
		public function moveDown(value:Number):void
		{
			var axis:Vector3D = Vector3D.Y_AXIS;
			x = axis.x, y = axis.y, z = axis.z;
			var len:Number = -value/Math.sqrt(x*x + y*y + z*z);
			
			_mat.prependTranslation(x*len, y*len, z*len);
		}
		
		private function updateMatrix():void 
		{
			_mat.identity();
			
			// rotations
			_mat.appendRotation(_rotationX, Vector3D.X_AXIS);
			_mat.appendRotation(_rotationY, Vector3D.Y_AXIS);
			_mat.appendRotation(_rotationZ, Vector3D.Z_AXIS);
			
			// scale
			_mat.appendScale(_scaleX, _scaleY, _scaleZ);
			
			// position
			_mat.appendTranslation(_x, _y, _z);
			
			// reset flag
			_dirty = false;
		}
		
		private function updateValuesFromMatrix():void
		{
			var d:Vector.<Vector3D> = _mat.decompose();
			
			var position:Vector3D = d[0];
			_x = position.x;
			_y = position.y;
			_z = position.z;
			
			var rotation:Vector3D = d[1];
			_rotationX = rotation.x;
			_rotationY = rotation.y;
			_rotationZ = rotation.z;
			
			var scl:Vector3D = d[2];
			_scaleX = scl.x;
			_scaleY = scl.y;
			_scaleZ = scl.z;
			
			trace("scale: " + scl);
			
			_dirty = false;
		}
		
		public function addChild(child:Object3D):void 
		{
			_children.push(child);
			_numChildren++;
		}
		
		public function removeChild(child:Object3D):void 
		{
			var index:int = _children.indexOf(child);
			if (index != -1)
			{
				_children.removeAt(index);
				_numChildren--;
			}
		}
		
		public function render():void 
		{
			
		}
		
		public function dispose():void 
		{
			
		}
	}

}