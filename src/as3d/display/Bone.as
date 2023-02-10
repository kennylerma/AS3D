package as3d.display 
{
	import flash.geom.Matrix3D;
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class Bone extends Object3D
	{
		private var _weight:Number;
		private var _bindMatrix:Matrix3D;  //the original local matrix
		private var _inverseBindMatrix:Matrix3D;
		private var _worldMatrix:Matrix3D;
		private var _skinningMatrix:Matrix3D;
		private var _isRoot:Boolean;
		private var _parentBone:Bone;
		private var _index:int;
		
		public function Bone(name:String, index:int, isRoot:Boolean = false, parentBone:Bone = null) 
		{
			super(name);
			_index = 0;
			_isRoot = isRoot;
			_parentBone = parentBone;
		}
		
		public function get bindMatrix():Matrix3D 
		{
			return _bindMatrix;
		}
		
		public function set bindMatrix(value:Matrix3D):void 
		{
			_bindMatrix = value;
			/*if (!isRoot) 
			{
				var localMatrix:Matrix3D = _bindMatrix.clone();
				localMatrix.append(parentBone.worldMatrix);
				worldMatrix = localMatrix;
			}
			else
			{
				//root bone.  local matrix is also world matrix
				_worldMatrix = _bindMatrix.clone();
			}*/
			//trace("Bone " + name + ", bindMatrix: " + _bindMatrix.rawData);
			//trace("Bone " + name + ", worldMatrix: " + _worldMatrix.rawData);
		}
		
		public function updateWorldMatrix():void 
		{
			if (!isRoot) 
			{
				var localMatrix:Matrix3D = _bindMatrix.clone();
				localMatrix.append(parentBone.worldMatrix);
				worldMatrix = localMatrix;
			}
			else
			{
				//root bone.  local matrix is also world matrix
				_worldMatrix = _bindMatrix.clone();
			}
		}
		
		public function updateSkinningMatrix():void 
		{
			_worldMatrix.append(_inverseBindMatrix);
			_skinningMatrix = _worldMatrix;
		}
		
		public function get inverseBindMatrix():Matrix3D 
		{
			return _inverseBindMatrix;
		}
		
		public function set inverseBindMatrix(value:Matrix3D):void 
		{
			_inverseBindMatrix = value;
		}
		
		public function get worldMatrix():Matrix3D 
		{
			return _worldMatrix;
		}
		
		public function set worldMatrix(value:Matrix3D):void 
		{
			_worldMatrix = value;
		}
		
		public function get skinningMatrix():Matrix3D 
		{
			return _skinningMatrix;
		}
		
		public function set skinningMatrix(value:Matrix3D):void 
		{
			_skinningMatrix = value;
		}
		
		public function get isRoot():Boolean 
		{
			return _isRoot;
		}
		
		public function get parentBone():Bone 
		{
			return _parentBone;
		}
		
	}

}