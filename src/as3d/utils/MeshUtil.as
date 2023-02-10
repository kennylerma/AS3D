package as3d.utils 
{
	import as3d.display.Bounds3D;
	import as3d.display.Mesh3D;
	import as3d.display.Object3D;
	import as3d.display.Triangle3D;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class MeshUtil 
	{
		
		public static function optimize(vertices:Vector.<Number>, normals:Vector.<Number>, uvs:Vector.<Number>):Array
		{
			var consolidated:Array = [];
			var v:Vector.<Number> = vertices;
			var n:Vector.<Number> = normals;
			var u:Vector.<Number> = uvs;
			
			// consolidate
			var uniques:Dictionary = new Dictionary();
			var uniqueIndexes:Vector.<uint> = new Vector.<uint>();
			var uniIndex:int = 0;
			var uniV:Vector.<Number> = new Vector.<Number>();
			var uniN:Vector.<Number> = new Vector.<Number>();
			var uniUV:Vector.<Number> = new Vector.<Number>();
			var triangles:Vector.<Triangle3D> = new Vector.<Triangle3D>();
			
			for (var o:int = 0; o < v.length / 3; o++) 
			{
				var uniqueVert:String = v[(o * 3)] + "," + v[(o * 3) + 1] + "," + v[(o * 3) + 2];
				var uniqueNorm:String = n[(o * 3)] + "," + n[(o * 3) + 1] + "," + n[(o * 3) + 2];
				if (u.length > 0) var uniqueUV:String = u[o * 2] + "," + u[(o * 2) + 1];
				
				if (uniques[uniqueVert] == undefined)
				{
					uniques[uniqueVert] = uniIndex;
					uniV.push(v[(o * 3)], v[(o * 3) + 1], v[(o * 3) + 2]);
					uniN.push(n[(o * 3)], n[(o * 3) + 1], n[(o * 3) + 2]);
					if (u.length > 0) uniUV.push(u[o * 2], u[(o * 2) + 1]);
					uniqueIndexes.push(uniIndex);
					uniIndex++;
				}
				else
				{
					var existingIndex:int = uniques[uniqueVert];
					if ((uniN[(existingIndex*3)].toString() + "," + uniN[(existingIndex*3)+1].toString() + "," + uniN[(existingIndex*3) + 2].toString() != uniqueNorm) 
					|| (uniUV.length > 0 && uniUV[(existingIndex*2)].toString() + "," + uniUV[(existingIndex*2)+1].toString() != uniqueUV))
					{
						//trace("norm compare: " + uniN[(existingIndex * 3)].toString() + "," + uniN[(existingIndex * 3) + 1].toString() + uniN[(existingIndex * 3) + 2].toString() + "    " + uniqueNorm);
						//trace("uv compare: " + uniUV[(existingIndex*2)].toString() + "," + uniUV[(existingIndex*2)+1].toString() + "    " + uniqueUV);
						
						uniques[uniqueVert] = uniIndex;
						uniV.push(v[(o * 3)], v[(o * 3) + 1], v[(o * 3) + 2]);
						uniN.push(n[(o * 3)], n[(o * 3) + 1], n[(o * 3) + 2]);
						if (u.length > 0) uniUV.push(u[o * 2], u[(o * 2) + 1]);
						uniqueIndexes.push(uniIndex);
						uniIndex++;
					}
					else
					{
						uniqueIndexes.push(existingIndex);
					}
					//trace("Existing: " + existingIndex);
				}
			}
			
			
			var index:int;
			for (var i:int = 0; i < uniqueIndexes.length; i+=3) 
			{
				var i1:int = uniqueIndexes[i];
				var i2:int = uniqueIndexes[i + 1];
				var i3:int = uniqueIndexes[i + 2];
				
				var vIndex1:int = i1 * 3;
				var vIndex2:int = i2 * 3;
				var vIndex3:int = i3 * 3;
				
				var uIndex1:int = i1 * 2;
				var uIndex2:int = i2 * 2;
				var uIndex3:int = i3 * 2;
				
				var v1:Vector.<Number> = new <Number>[uniV[vIndex1], uniV[vIndex1 + 1], uniV[vIndex1 + 2]];
				var v2:Vector.<Number> = new <Number>[uniV[vIndex2], uniV[vIndex2 + 1], uniV[vIndex2 + 2]];
				var v3:Vector.<Number> = new <Number>[uniV[vIndex3], uniV[vIndex3 + 1], uniV[vIndex3 + 2]];
				
				var n1:Vector.<Number> = new <Number>[uniN[vIndex1], uniN[vIndex1 + 1], uniN[vIndex1 + 2]];
				var n2:Vector.<Number> = new <Number>[uniN[vIndex1], uniN[vIndex1 + 1], uniN[vIndex1 + 2]];
				var n3:Vector.<Number> = new <Number>[uniN[vIndex1], uniN[vIndex1 + 1], uniN[vIndex1 + 2]];
				
				if (uniUV.length > 0)
				{
					var u1:Vector.<Number> = new <Number>[uniUV[uIndex1], uniUV[uIndex1 + 1]];
					var u2:Vector.<Number> = new <Number>[uniUV[uIndex2], uniUV[uIndex2 + 1]];
					var u3:Vector.<Number> = new <Number>[uniUV[uIndex3], uniUV[uIndex3 + 1]];
				}
				
				var tri:Triangle3D = new Triangle3D(v1, v2, v3, n1, n2, n3, u1, u2, u3, i1, i2, i3);
				triangles.push(tri);
			}
			
			consolidated.push(uniV, uniN, uniUV, uniqueIndexes, triangles);
			
			trace("MeshUtil.optimize() Original Vcount: " + (v.length / 3) + ", Consolidated Count: " + (uniV.length / 3) + ", Triangles: " + triangles.length);
			return consolidated;
		}
		
		public static function getBounds(obj:Mesh3D):Bounds3D 
		{
			var vertices:Vector.<Number> = obj.vertices;
			var min:Vector3D = new Vector3D(vertices[0], vertices[1], vertices[2]);
			var max:Vector3D = new Vector3D(vertices[0], vertices[1], vertices[2]);
			
			var len:int = vertices.length;
			for (var i:int = 3; i < len; i += 3)
			{
				var vert:Vector3D = new Vector3D(vertices[i], vertices[i + 1], vertices[i + 2]);
				if ( vert.x < min.x ) min.x = vert.x;
				if ( vert.y < min.y ) min.y = vert.y;
				if ( vert.z < min.z ) min.z = vert.z;
				if ( vert.x > max.x ) max.x = vert.x;
				if ( vert.y > max.y ) max.y = vert.y;
				if ( vert.z > max.z ) max.z = vert.z;
			}
			
			var bounds:Bounds3D = new Bounds3D();
			bounds.min = min;
			bounds.max = max;
			
			return bounds;
		}
		
	}

}