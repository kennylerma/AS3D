package as3d.display 
{
	import as3d.materials.ColorMaterial;
	import as3d.textures.Texture3D;
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class Mesh3D extends Object3D
	{
		private const MAX_VERTICES_PER_BUFFER:int = 65536;
		private const UVS:Vector.<Vector.<Number>> = new <Vector.<Number>>[new <Number>[0, 0], new <Number>[1, 0], new <Number>[1, 1],new <Number> [0, 1]];
		
		// 4 bytes minimum
		private var _dataPer32:int;
		private var _vertices:Vector.<Number> = new Vector.<Number>();
		private var _indexes:Vector.<uint> = new Vector.<uint>();
		private var _normals:Vector.<Number> = new Vector.<Number>();
		private var _uvs:Vector.<Number> = new Vector.<Number>();
		private var _tangents:Vector.<Number> = new Vector.<Number>();
		private var _bitangents:Vector.<Number> = new Vector.<Number>();
		
		private var _vertexBuffer:VertexBuffer3D;
		private var _indexBuffer:IndexBuffer3D
		private var _normalBuffer:VertexBuffer3D;
		private var _uvsBuffer:VertexBuffer3D;
		private var _tangentsBuffer:VertexBuffer3D;
		private var _bitangentsBuffer:VertexBuffer3D;
		
		private var _material:ColorMaterial;
		private var _materials:Vector.<ColorMaterial> = new Vector.<ColorMaterial>();
		
		private var _textures:Vector.<Texture3D> = new Vector.<Texture3D>();
		
		private var _doubleSided:Boolean = false;
		private var _isZup:Boolean = false;
		
		public function Mesh3D(name:String = "", dataPer32:int = 4) 
		{
			super(name);
			_dataPer32 = dataPer32;
		}
		
		public function createBuffers():void
		{
			// vertices
			var context:Context3D = Config.stage3d.context3D;
			_vertexBuffer = context.createVertexBuffer(_vertices.length/_dataPer32, _dataPer32);
			_vertexBuffer.uploadFromVector((skeleton) ? skeleton.posedVertices : _vertices, 0, _vertices.length / _dataPer32);
			
			//if (_uvs.length > 0  || _textures.length > 0)
			//{
				if (_uvs.length == 0) generateUVS();
				_uvsBuffer = context.createVertexBuffer(_uvs.length / 2, 2);
				_uvsBuffer.uploadFromVector(_uvs, 0, _uvs.length / 2);
			//}
			
			// normals
			if (_normals.length == 0) computeNormals();
			_normalBuffer = context.createVertexBuffer(_normals.length / _dataPer32, _dataPer32);
			_normalBuffer.uploadFromVector((skeleton) ? skeleton.posedNormals : _normals, 0, _normals.length / _dataPer32);
			
			if (_tangents.length != 0)
			{
				_tangentsBuffer = context.createVertexBuffer(_tangents.length / _dataPer32,  _dataPer32);
				_tangentsBuffer.uploadFromVector(_tangents, 0, _tangents.length / _dataPer32);
				_bitangentsBuffer = context.createVertexBuffer(_bitangents.length / _dataPer32, _dataPer32);
				_bitangentsBuffer.uploadFromVector(_bitangents, 0, _bitangents.length / _dataPer32);
			}
			
			// indexes
			if(_doubleSided){
				var i:Vector.<uint> = _indexes.concat();
				var r:Vector.<uint> = i.concat().reverse();
				_indexBuffer = context.createIndexBuffer(_indexes.length * 2);
				_indexBuffer.uploadFromVector(i.concat(r), 0, _indexes.length * 2);
			} else {
				_indexBuffer = context.createIndexBuffer(_indexes.length);
				_indexBuffer.uploadFromVector(_indexes, 0, _indexes.length);
			}
		}
		
		public function createModelBuffers():void 
		{
			addFakeW(_vertices); // corrects each vertice to 4 bytes x y z w by adding a fake w.
			var context:Context3D = Config.stage3d.context3D;
			_vertexBuffer = context.createVertexBuffer(_vertices.length/_dataPer32, _dataPer32);
			_vertexBuffer.uploadFromVector(_vertices, 0, _vertices.length / _dataPer32);
		}
		
		public function addFakeW(verts:Vector.<Number>):void 
		{
			var len:int = verts.length;
			for (var i:int = 0; i < verts.length; i+=3) 
			{
				verts.insertAt(i + 3, 1);
				i += 1;
			}
			//verts.push(1);
		}
		
		private function generateUVS():void 
		{
			var len:int = (_vertices.length / _dataPer32) + 1;
			var pos:int = 0;
			for (var i:int = 0; i < len; i++) 
			{
				_uvs = _uvs.concat(UVS[pos]);
				pos++;
				if (pos > 3) pos = 0;
			}
		}
		
		public function flipNormals():void 
		{
			// TODO flip normals coming from Blender.
		}
		
		public function computeNormals():void 
		{
			_normals = new Vector.<Number>((_vertices.length/_dataPer32)*3);
			var index:Vector.<uint> = indexes.concat();
			var r:Vector.<uint> = index.concat().reverse();
			
			if(_doubleSided) index = index.concat(r);
			
			var i:int, len:int;
			len = index.length;
			for(i = 0; i < len; i+=3) {
				var i1:int = index[i]*_dataPer32;
				var i2:int = index[i+1]*_dataPer32;
				var i3:int = index[i+2]*_dataPer32;
				var v1:Vector3D = new Vector3D(_vertices[i1], _vertices[i1+1], _vertices[i1+2]);
				var v2:Vector3D = new Vector3D(_vertices[i2], _vertices[i2+1], _vertices[i2+2]);
				var v3:Vector3D = new Vector3D(_vertices[i3], _vertices[i3+1], _vertices[i3+2]);
				
				
				var n:Vector3D = new Vector3D();
				var vn1:Vector3D = v3.subtract(v1);
				var vn2:Vector3D = v2.subtract(v1);
				n = vn1.crossProduct(vn2);
				n.normalize();
				n.negate();
				
				_normals[index[i]*3] = n.x;
				_normals[index[i]*3+1] = n.y;
				_normals[index[i]*3+2] = n.z;
				
				_normals[index[i+1]*3] = n.x;
				_normals[index[i+1]*3+1] = n.y;
				_normals[index[i+1]*3+2] = n.z;
				
				_normals[index[i+2]*3] = n.x;
				_normals[index[i+2]*3+1] = n.y;
				_normals[index[i+2]*3+2] = n.z;
			}
		}

		public function computeNormalizedVertices():void {
			_normals = new Vector.<Number>((_vertices.length/_dataPer32)*3);
			
			var i:int, len:int;
			len = _indexes.length;
			for(i = 0; i < len; i++) {
				var i1:int = _indexes[i]*_dataPer32;
				var n:Vector3D = new Vector3D(_vertices[i1], _vertices[i1+1], _vertices[i1+2]);

				n.normalize();
				
				_normals[_indexes[i]*3] = n.x;
				_normals[_indexes[i]*3+1] = n.y;
				_normals[_indexes[i]*3+2] = n.z;
			}
			
			
			if(_normalBuffer) _normalBuffer.uploadFromVector(_normals, 0, _normals.length/3);
		}
		
		public function setMaterial(material:ColorMaterial):void
		{
			_material = material;
		}
		
		public function addMaterial(materials:ColorMaterial):void
		{
			_materials.push(materials);
		}
		
		public function set vertices(values:Vector.<Number>):void
		{
			_vertices = values;
			
			if (_isZup) //lets swap y and z coordinates
			{
				var newVerts:Vector.<Number> = new Vector.<Number>(_vertices.length);
				var numVerts:int = _vertices.length;
				for (var i:int = 0; i < numVerts; i++) 
				{
					newVerts[i] = _vertices[i];
					newVerts[i + 1] = _vertices[i + 2];
					newVerts[i + 2] = _vertices[i + 1];
					i += 2;
				}
				
				_vertices = newVerts;
			}
		}
		
		public function set uvs(values:Vector.<Number>):void
		{
			_uvs = values;
		}
		
		public function set squares(values:Vector.<Number>):void
		{
			if(values.length%4 == 0){
				while(values.length > 0){
					var temp:Vector.<Number> = values.splice(0, 4);
					_indexes.push(parseInt(temp[0].toString()));
					_indexes.push(parseInt(temp[1].toString()));
					_indexes.push(parseInt(temp[3].toString()));
					_indexes.push(parseInt(temp[1].toString()));
					_indexes.push(parseInt(temp[2].toString()));
					_indexes.push(parseInt(temp[3].toString()));
				}
			}
		}
		
		public function set indexes(value:Vector.<uint>):void
		{ 
			_indexes = value; 
		}
		
		public function get vertices():Vector.<Number> { return _vertices; }
		public function get uvs():Vector.<Number> { return _uvs; }
		public function get indexes():Vector.<uint> { return _indexes; }
		public function get normals():Vector.<Number> { return _normals; }
		public function set normals(value:Vector.<Number>):void { _normals = value; }
		
		public function get vertexBuffer():VertexBuffer3D { return _vertexBuffer; }
		public function set vertexBuffer(value:VertexBuffer3D):void { _vertexBuffer = value; }
		public function get indexBuffer():IndexBuffer3D { return _indexBuffer; }
		public function set indexBuffer(value:IndexBuffer3D):void { _indexBuffer = value; }
		public function get normalBuffer():VertexBuffer3D { return _normalBuffer; }
		public function get uvsBuffer():VertexBuffer3D { return _uvsBuffer; }
		
		public function get material():ColorMaterial { return _material; }
		public function get textures():Vector.<Texture3D> { return _textures; }
		public function set textures(value:Vector.<Texture3D>):void { _textures = value; }
		
		public function get doubleSided():Boolean { return _doubleSided; }
		public function set doubleSided(value:Boolean):void { _doubleSided = value; }
		
		public function get isZup():Boolean { return _isZup; }
		public function set isZup(value:Boolean):void { _isZup = value; }
		
		public function get tangents():Vector.<Number> { return _tangents; }
		public function set tangents(value:Vector.<Number>):void { _tangents = value; }
		public function get tangentsBuffer():VertexBuffer3D { return _tangentsBuffer; }
		
		public function get bitangents():Vector.<Number> { return _bitangents; }
		public function set bitangents(value:Vector.<Number>):void { _bitangents = value; }
		public function get bitangentsBuffer():VertexBuffer3D { return _bitangentsBuffer; }
	}

}