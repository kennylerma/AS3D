package as3d.display 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class Triangle3D 
	{
		private var _v1:Vector.<Number>;
		private var _v2:Vector.<Number>;
		private var _v3:Vector.<Number>;
		private var _uv1:Vector.<Number>;
		private var _uv2:Vector.<Number>;
		private var _uv3:Vector.<Number>;
		private var _indexes:Vector.<Number>;
		
		private var _tangents:Vector.<Number> = new Vector.<Number>();
		private var _bitangents:Vector.<Number> = new Vector.<Number>();
		
		public function Triangle3D(v1:Vector.<Number>, v2:Vector.<Number>, v3:Vector.<Number>, 
									n1:Vector.<Number>, n2:Vector.<Number>, n3:Vector.<Number>,
									uv1:Vector.<Number>, uv2:Vector.<Number>, uv3:Vector.<Number>,
									index1:int, index2:int, index3:int)
		{
			_v1 = v1;
			_v2 = v2;
			_v3 = v3;
			_uv1 = uv1;
			_uv2 = uv2;
			_uv3 = uv3;
			
			_indexes = new <Number>[index1, index2, index3];
			
			if (uv1 && uv2 && uv3) CalculateTangentAndBitangent();
		}
		
		private function CalculateTangentAndBitangent():void 
		{
			// Edges of the triangle : postion delta
			var deltaPos1:Vector3D = subVector(_v2, _v1);
			var deltaPos2:Vector3D = subVector(_v3, _v1);
			
			// UV delta
			var deltaUV1:Vector3D = subVector(_uv2, _uv1);
			var deltaUV2:Vector3D = subVector(_uv3, _uv1);
			
			
			var r:Number = 1 / (deltaUV1.x * deltaUV2.y - deltaUV1.y * deltaUV2.x);
			var tangent:Vector3D = mulVector3D((subVector3D(mulVector3D(deltaPos1, deltaUV2.y), mulVector3D(deltaPos2, deltaUV1.y))), r);
			var bitangent:Vector3D = mulVector3D((subVector3D(mulVector3D(deltaPos2, deltaUV1.x), mulVector3D(deltaPos1, deltaUV2.x))), r);
			
			_tangents.push(tangent.x, tangent.y, tangent.z);
			_bitangents.push(bitangent.x, bitangent.y, bitangent.z);
		}
		
		private function subVector(a:Vector.<Number>, b:Vector.<Number>):Vector3D 
		{
			if (a.length == 3)
			{
				return new Vector3D(a[0] - b[0], a[1] - b[1], a[2] - b[2]);
			}
			else
			{
				return new Vector3D(a[0] - b[0], a[1] - b[1]);
			}
		}
		
		private function subVector3D(a:Vector3D, b:Vector3D):Vector3D 
		{
			return new Vector3D(a.x - b.x, a.y - b.y, a.z - b.z);
		}
		
		private function mulVector3D(vec:Vector3D, value:Number):Vector3D
		{
			return new Vector3D(vec.x * value, vec.y * value, vec.z * value);
		}
		
		public function get tangents():Vector.<Number> 
		{
			return _tangents;
		}
		
		public function get bitangents():Vector.<Number> 
		{
			return _bitangents;
		}
		
		public function get indexes():Vector.<Number> 
		{
			return _indexes;
		}
		
	}

}