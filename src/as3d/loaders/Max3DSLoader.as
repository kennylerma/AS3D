package as3d.loaders 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class Max3DSLoader 
	{
		private var _url:String;
		private var _ld:URLLoader;
		private var _3DSBytes:ByteArray;
		private var _currentMaterialEnd:*;
		
		public function Max3DSLoader(url:String) 
		{
			_url = url;
		}
		
		public function load():void 
		{
			var req:URLRequest = new URLRequest(_url + "?cache=" + new Date().getTime());
			_ld = new URLLoader();
			_ld.dataFormat = URLLoaderDataFormat.BINARY;
			_ld.addEventListener(Event.COMPLETE, onBytesLoaded);
			_ld.load(req);
		}
		
		private function onBytesLoaded(e:Event):void 
		{
			_3DSBytes = _ld.data as ByteArray;
			_3DSBytes.position = 0;
			_3DSBytes.endian = Endian.LITTLE_ENDIAN;
			
			Parse();
		}
		
		private function Parse():void 
		{
			while (_3DSBytes.bytesAvailable)
			{
				var cid:uint;
				var len:uint;
				var end:uint;
				
				cid = _3DSBytes.readUnsignedShort();
				len = _3DSBytes.readUnsignedInt();
				end = _3DSBytes.position + (len - 6);
				
				//trace("CID: " + cid.toString());
				
				switch (cid)
				{
					case 0x4D4D: // MAIN3DS
					case 0x3D3D: // EDIT3DS
					case 0xB000: // KEYF3DS
						// This types are "container chunks" and contain only
						// sub-chunks (no data on their own.) This means that
						// there is nothing more to parse at this point, and 
						// instead we should progress to the next chunk, which
						// will be the first sub-chunk of this one.
						continue;
						break;
					
					case 0xAFFF: // MATERIAL
						_currentMaterialEnd = end;
						parseMaterial();
						break;
					
					case 0x4000: // EDIT_OBJECT
						//_cur_obj_end = end;
						//_cur_obj = new ObjectVO();
						//_cur_obj.name = readNulTermString();
						//_cur_obj.materials = new Vector.<String>();
						//_cur_obj.materialFaces = {};
						trace("Name: " + readNulTermString());
						break;
					
					case 0x4100: // OBJ_TRIMESH 
						//_cur_obj.type = AssetType.MESH;
						trace("Found Mesh!");
						break;
					
					case 0x4110: // TRI_VERTEXL
						trace("Vertices: " + parseVertexList());
						break;
					
					case 0x4120: // TRI_FACELIST
						trace("Indices: " + parseIndicesList());
						break;
					
					case 0x4140: // TRI_MAPPINGCOORDS
						trace("UVs: " + parseUVList());
						break;
						
					case 0x4170: // TRI_MAPPINGSTANDARDS
						trace("TRI_MAPPINGSTANDARDS");
						break;
					
					case 0x4130: // Face materials
						trace("Face Materials: " + parseFaceMaterialList());
						break;
					
					case 0x4160: // Transform
						trace("Transform: " + readTransform());
						break;
					
					case 0xB002: // Object animation (including pivot)
						parseObjectAnimation(end);
						break;
					
					case 0x4150: // Smoothing groups
						//parseSmoothingGroups();
						break;
					
					default:
						// Skip this (unknown) chunk
						_3DSBytes.position += (len - 6);
						break;
				}
			}
		}
		
		private function parseVertexList():Vector.<Number>
		{
			var i:uint;
			var len:uint;
			var count:uint;
			
			count = _3DSBytes.readUnsignedShort();
			var verts:Vector.<Number> = new Vector.<Number>(count*3, true);
			
			i = 0;
			len = verts.length;
			while (i < len)
			{
				verts[i++] = _3DSBytes.readFloat(); //x
				verts[i++] = _3DSBytes.readFloat(); //y
				verts[i++] = _3DSBytes.readFloat(); //z
			}
			return verts;
		}
		
		private function parseIndicesList():Vector.<uint>
		{
			var i:uint;
			var len:uint;
			var count:uint;
			
			count = _3DSBytes.readUnsignedShort();
			var indices:Vector.<uint> = new Vector.<uint>(count*3, true);
			
			i = 0;
			len = indices.length;
			while (i < len) 
			{
				var i0:uint, i1:uint, i2:uint;
				
				i0 = _3DSBytes.readUnsignedShort();
				i1 = _3DSBytes.readUnsignedShort();
				i2 = _3DSBytes.readUnsignedShort();
				
				indices[i++] = i0;
				indices[i++] = i2;
				indices[i++] = i1;
				
				// Skip "face info", irrelevant in Away3D
				_3DSBytes.position += 2;
			}
			
			//_cur_obj.smoothingGroups = new Vector.<uint>(count, true);
			return indices;
		}
		
		private function parseUVList():Vector.<Number>
		{
			var i:uint;
			var len:uint;
			var count:uint;
			
			count = _3DSBytes.readUnsignedShort();
			var uvs:Vector.<Number> = new Vector.<Number>(count*2, true);
			
			i = 0;
			len = uvs.length;
			while (i < len)
			{
				uvs[i++] = _3DSBytes.readFloat();
				uvs[i++] = 1.0 - _3DSBytes.readFloat();
			}
			return uvs;
		}
		
		private function parseMaterial():MovieClip
		{	
			var mat:MovieClip = new MovieClip();  // TODO make material class
			
			while (_3DSBytes.position < _currentMaterialEnd) {
				var cid:uint;
				var len:uint;
				var end:uint;
				
				cid = _3DSBytes.readUnsignedShort();
				len = _3DSBytes.readUnsignedInt();
				end = _3DSBytes.position + (len - 6);
				
				switch (cid) 
				{
					case 0xA000: // Material name
						mat.name = readNulTermString();
						trace("Material name: " + mat.name);
						break;
					
					case 0xA010: // Ambient color
						mat.ambientColor = readColor();
						break;
					
					case 0xA020: // Diffuse color
						mat.diffuseColor = readColor();
						break;
					
					case 0xA030: // Specular color
						mat.specularColor = readColor();
						break;
					
					case 0xA081: // Two-sided, existence indicates "true"
						mat.twoSided = true;
						break;
					
					case 0xA200: // Main (color) texture 
						mat.colorMap = parseTexture(end);
						break;
					
					case 0xA204: // Specular map
						mat.specularMap = parseTexture(end);
						break;
					
					default:
						_3DSBytes.position = end;
						break;
				}
			}
			
			return mat;
		}
		
		private function parseFaceMaterialList():MovieClip
		{
			var mat:String;
			var count:uint;
			var i:uint;
			var faces:Vector.<uint>;
			
			var materials:MovieClip = new MovieClip();
			
			mat = readNulTermString();
			count = _3DSBytes.readUnsignedShort();
			
			faces = new Vector.<uint>(count, true);
			i = 0;
			while (i < faces.length)
				faces[i++] = _3DSBytes.readUnsignedShort();
			
			
			materials[mat] = faces;
			return materials;
		}
		
		private function parseObjectAnimation(end:Number):void
		{
			//var vo:ObjectVO;
			//var obj:ObjectContainer3D;
			var pivot:Vector3D;
			var name:String;
			var hier:int;
			
			// Pivot defaults to origin
			pivot = new Vector3D;
			
			while (_3DSBytes.position < end) {
				var cid:uint;
				var len:uint;
				
				cid = _3DSBytes.readUnsignedShort();
				len = _3DSBytes.readUnsignedInt();
				
				switch (cid) {
					case 0xb010: // Name/hierarchy
						name = readNulTermString();
						_3DSBytes.position += 4;
						hier = _3DSBytes.readShort();
						break;
					
					case 0xb013: // Pivot
						pivot.x = _3DSBytes.readFloat();
						pivot.z = _3DSBytes.readFloat();
						pivot.y = _3DSBytes.readFloat();
						break;
					
					default:
						_3DSBytes.position += (len - 6);
						break;
				}
			}
			
			// If name is "$$$DUMMY" this is an empty object (e.g. a container)
			// and will be ignored in this version of the parser
			// TODO: Implement containers in 3DS parser.
			
			trace("parseObjectAnimation() Name: " + name);
			
			/*if (name != '$$$DUMMY' && _unfinalized_objects.hasOwnProperty(name)) {
				vo = _unfinalized_objects[name];
				obj = constructObject(vo, pivot);
				
				if (obj)
					finalizeAsset(obj, vo.name);
				
				delete _unfinalized_objects[name];
			}*/
		}
		
		private function readColor():uint
		{
			var cid:uint;
			var len:uint;
			var r:uint, g:uint, b:uint;
			
			cid = _3DSBytes.readUnsignedShort();
			len = _3DSBytes.readUnsignedInt();
			
			switch (cid) {
				case 0x0010: // Floats
					r = _3DSBytes.readFloat()*255;
					g = _3DSBytes.readFloat()*255;
					b = _3DSBytes.readFloat()*255;
					break;
				case 0x0011: // 24-bit color
					r = _3DSBytes.readUnsignedByte();
					g = _3DSBytes.readUnsignedByte();
					b = _3DSBytes.readUnsignedByte();
					break;
				default:
					_3DSBytes.position += (len - 6);
					break;
			}
			
			return (r << 16) | (g << 8) | b;
		}
		
		private function parseTexture(end:uint):MovieClip
		{
			var tex:MovieClip;
			
			tex = new MovieClip
			
			while (_3DSBytes.position < end) {
				var cid:uint;
				var len:uint;
				
				cid = _3DSBytes.readUnsignedShort();
				len = _3DSBytes.readUnsignedInt();
				
				switch (cid) {
					case 0xA300:
						tex.url = readNulTermString();
						trace("texture url: " + tex.url);
						break;
					
					default:
						// Skip this unknown texture sub-chunk
						_3DSBytes.position += (len - 6);
						break;
				}
			}
			
			//_textures[tex.url] = tex;
			//addDependency(tex.url, new URLRequest(tex.url));
			
			return tex;
		}
		
		private function readNulTermString():String
		{
			var chr:uint;
			var str:String = new String();
			
			while ((chr = _3DSBytes.readUnsignedByte()) > 0)
				str += String.fromCharCode(chr);
			
			return str;
		}
		
		private function readTransform():Vector.<Number>
		{
			var data:Vector.<Number>;
			
			data = new Vector.<Number>(16, true);
			
			// X axis
			data[0] = _3DSBytes.readFloat(); // X
			data[2] = _3DSBytes.readFloat(); // Z
			data[1] = _3DSBytes.readFloat(); // Y
			data[3] = 0;
			
			// Z axis
			data[8] = _3DSBytes.readFloat(); // X
			data[10] = _3DSBytes.readFloat(); // Z
			data[9] = _3DSBytes.readFloat(); // Y
			data[11] = 0;
			
			// Y Axis
			data[4] = _3DSBytes.readFloat(); // X 
			data[6] = _3DSBytes.readFloat(); // Z
			data[5] = _3DSBytes.readFloat(); // Y
			data[7] = 0;
			
			// Translation
			data[12] = _3DSBytes.readFloat(); // X
			data[14] = _3DSBytes.readFloat(); // Z
			data[13] = _3DSBytes.readFloat(); // Y
			data[15] = 1;
			
			return data;
		}
		
	}

}