package as3d.loaders 
{
	import as3d.display.Bone;
	import as3d.display.Frame3D;
	import as3d.display.Indexes;
	import as3d.display.Mesh3D;
	import as3d.display.Normals;
	import as3d.display.Skeleton;
	import as3d.display.Triangle3D;
	import as3d.display.UVs;
	import as3d.display.Vertexes;
	import as3d.materials.ColorMaterial;
	import as3d.primitives.Model;
	import as3d.primitives.Model2;
	import as3d.textures.Texture3D;
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display.Bitmap;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.display3D.Context3DProgramType;
	import flash.net.URLLoaderDataFormat;
	import asd.ASDReader;
	import flash.utils.Dictionary;
	import as3d.utils.MeshUtil;
	import as3d.utils.Matrix3DUtils;
	
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class DAELoader extends EventDispatcher
	{
		private var _xml:XML;
		private var _ld:URLLoader;
		private var _url:String;
		private var _imageLoader:ImageLoader;
		private var _model:Model;
		private var _texture:Texture;
		private var _meshes:Vector.<Mesh3D> = new Vector.<Mesh3D>();
		private var _children:Vector.<Model2> = new Vector.<Model2>();
		private var _imageIDs:Vector.<String> = new Vector.<String>();
		private var _materials:Dictionary = new Dictionary();
		
		public function DAELoader(url:String) 
		{
			_url = url;
		}
		
		public function load():void 
		{
			var req:URLRequest = new URLRequest(_url + "?cache=" + new Date().getTime());
			_ld = new URLLoader();
			_ld.dataFormat = URLLoaderDataFormat.TEXT;
			_ld.addEventListener(Event.COMPLETE, onXMLLoaded);
			_ld.addEventListener(IOErrorEvent.IO_ERROR, onXMLLoadError);
			_ld.load(req);
		}
		
		private function onXMLLoadError(e:IOErrorEvent):void 
		{
			trace("DAELoader.onXMLLoadError(): " + e.text);
		}
		
		private function onXMLLoaded(e:Event):void 
		{
			// TODO use regex to remove namespace.
			var data:String = String(_ld.data).replace(' xmlns="http://www.collada.org/2005/11/COLLADASchema" version="1.4.1"', "");
			data = data.replace("<triangles", "<polylist").replace("</triangles", "</polylist");
			data = data.replace("<polygons", "<polylist").replace("</polygons", "</polylist");
			_xml = XML(data);
			
			LoadTextures();
		}
		
		private function LoadTextures():void 
		{
			var imageList:XMLList = _xml.library_images.image;
			var images:Vector.<String> = new Vector.<String>();
			
			for each (var image:XML in imageList) 
			{
				var path:String = "";
				if (_url.lastIndexOf("/") != -1)
				{
					path = _url.substr(0, _url.lastIndexOf("/") +1);
				}
				else if (_url.lastIndexOf("\\") != -1)
				{
					path = _url.substr(0, _url.lastIndexOf("\\") +1);
				}
				
				//trace("Image Path: " + path + image.init_from.text());
				images.push(path + image.init_from.text());
				//trace("Texture: " + image.init_from.text());
				_imageIDs.push(image.@id);
			}
			
			if (images.length > 0)
			{
				_imageLoader = new ImageLoader();
				_imageLoader.addEventListener(Event.COMPLETE, HandleTexturesLoaded);
				_imageLoader.loadImages(images);
			}
			else
			{
				HandleTexturesLoaded();
			}
		}
		
		private function HandleTexturesLoaded(e:Event = null):void 
		{
			Parse();
			
			for each (var model:Model2 in _children) 
			{
				var material:Object = _materials[model.name];
				if (material)
				{
					var imageIndex:int = _imageIDs.indexOf(material.imageID);
					var image:Bitmap = _imageLoader.loadedImages[imageIndex];
					
					// Setup texture
					var tex:Texture3D = new Texture3D(image, true);
					model.textures.push(tex);
				}
				
				model.createBuffers(); // we have collected all data, now let's setup the shaders
				Config.scene.addChild(model);
				trace("Add Child: " + model.name);
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function Parse():void 
		{
			var isZup:Boolean = (_xml.asset.up_axis == "Z_UP");
			
			var geometry:XMLList = _xml.library_geometries.geometry;
			for each (var geom:XML in geometry) 
			{
				var id:String = geom.@id;
				var sourcesList:XMLList = geom.mesh.source;
				var positions:String;
				var norms:String;
				var verts:String;
				var uvs:String;
				
				var sources:Dictionary = new Dictionary();
				
				for each (var source:XML in sourcesList) 
				{
					var daeSource:Object = new Object();
					daeSource.stride = source.technique_common.accessor.@stride;
					daeSource.values = String(source.float_array.text()).split(" ");
					sources[String(source.@id)] = daeSource;
					
					if (String(source.@id).toLowerCase().indexOf("position") != -1) verts = source.float_array.text();
					if (String(source.@id).toLowerCase().indexOf("normal") != -1) norms = source.float_array.text();
					if (String(source.@id).toLowerCase().indexOf("map") != -1 || String(source.@id).toLowerCase().indexOf("uv")) uvs = source.float_array.text();
				}
				
				var vertexes:Vertexes = new Vertexes(Vector.<Number>(verts.split(" ")));
				var normals:Normals = new Normals(Vector.<Number>(norms.split(" ")), 3, 1, vertexes.list.length);
				var uvCoordinates:UVs = new UVs(Vector.<Number>(uvs.split(" ")));
				
				// handle polylist to get indexes for vertices, normals, uvs
				var polylist:XMLList = geom.mesh.polylist;
				var polyArray:Array = String(polylist.vcount.text()).split(" ");
				var polyTotal:int = int(polylist.@count);
				var polyInputs:XMLList = polylist.input;
				var polyIndexes:Vector.<Number> = Vector.<Number>(String(polylist.p.text()).split(" "));
				
				var material:Object = new Object();
				material.id = polylist.@material.toString();
				//trace("Material: " + material.id);
				for each (var meshMaterial:XML in _xml.library_materials.material) 
				{
					if (meshMaterial.@id == material.id)
					{
						var effectID:String = meshMaterial.instance_effect.@url.substr(1);
						for each (var effect:XML in _xml.library_effects.effect) 
						{
							if (effect.@id == effectID)
							{
								//trace("Effect ID " + effectID + ", " + effect.@id);
								material.effectID = effectID;
								for each (var newparam:XML in effect.profile_COMMON.newparam) 
								{
									if (newparam.surface != undefined)
									{
										//trace("Image ID " + newparam.surface.init_from.text());
										material.imageID = newparam.surface.init_from.text().toString();
										_materials[geom.@name.toString()] = material;
										break;
									}
								}
							}
						}
						break;
					}
				}
				
				var vertexIndexes:Vector.<Number> = new Vector.<Number>();
				var normalIndexes:Vector.<Number> = new Vector.<Number>();
				var uvIndexes:Vector.<Number> = new Vector.<Number>();
				
				// get offsets to parse re-index the vertices, normals and uvs
				for each (var polyInput:XML in polyInputs) 
				{
					if (polyInput.@semantic == "VERTEX")
					{
						if (geom.mesh.vertices.input.@semantic == "POSITION")
						{
							sources[geom.mesh.vertices.input.@source.substr(1)].offset = polyInput.@offset;
							sources[geom.mesh.vertices.input.@source.substr(1)].type = "POSITION";
						}
						else
						{
							sources[polyInput.@source.substr(1)].offset = polyInput.@offset;
							sources[polyInput.@source.substr(1)].type = "POSITION";
						}
					}
					
					if (polyInput.@semantic == "NORMAL") 
					{
						sources[polyInput.@source.substr(1)].offset = polyInput.@offset;
						sources[polyInput.@source.substr(1)].type = "NORMAL";
					}
					
					if (polyInput.@semantic == "TEXCOORD")
					{
						sources[polyInput.@source.substr(1)].offset = polyInput.@offset;
						sources[polyInput.@source.substr(1)].type = "TEXCOORD";
					}
				}
				
				var pushVertex:Function = function (index:int):void
				{
					index = index * polyInputs.length();
					var lastVertexExisted:Boolean = false;
					
					for each (var src:Object in sources) 
					{
						var inputValues:Array = src.values;
						var stride:int = src.stride;
						var offset:int = src.offset;
						var indexOffset:int = polyIndexes[index + offset] * stride;
						
						if (src.stride == 3) 
						{
							if (src.type == "POSITION") v.push(inputValues[indexOffset], inputValues[indexOffset + 2], inputValues[indexOffset + 1]);
							if (src.type == "NORMAL") n.push(inputValues[indexOffset], inputValues[indexOffset + 2], inputValues[indexOffset + 1]);
						}
						else if (src.stride == 2)
						{
							if (src.type == "TEXCOORD") u.push(inputValues[indexOffset], -inputValues[indexOffset + 1]);
						}
					}
				}
				
				/// parse consolidated
				var v:Vector.<Number> = new Vector.<Number>();
				var n:Vector.<Number> = new Vector.<Number>();
				var u:Vector.<Number> = new Vector.<Number>();
				var tris:Vector.<Triangle3D> = new Vector.<Triangle3D>();
				var indexVector:Vector.<uint> = new Vector.<uint>();
				var indexCount:int = 0;
				var indexPoly:int = 0;
				
				var len:int = polyIndexes.length / polyInputs.length();
				
				var l:int = 0;
				while (l < len) 
				{
					var count:int = polyArray[indexPoly];
					var m:int = 1;
					while (m < count - 1) 
					{
						pushVertex(l + m + 1);
                        pushVertex(l + m);
						pushVertex(l);
						m++;
						
						indexVector.push(indexCount++, indexCount++, indexCount++);
					}
					l += count;
					indexPoly++;
				}
				
				// reduce to unique vertices
				var consolidated:Array = MeshUtil.optimize(v, n, u);
				v = consolidated[0];
				n = consolidated[1];
				u = consolidated[2];
				indexVector = consolidated[3];
				tris = consolidated[4];
				
				// parse skeleton / bones
				var skeleton:Skeleton = new Skeleton();
				skeleton.vertices = v;
				skeleton.normals = n;
				var boneIndex:int = 0;
				var foundBones:Boolean = false;
				
				for each (var node:XML in _xml.library_visual_scenes.visual_scene.node) 
				{
					for each (var childNode:XML in node.node) 
					{
						//trace("Bone Data: " + node);
						if (childNode.@type == "JOINT")
						{
							foundBones = true;
							var rootBone:Bone = new Bone(childNode.@name, boneIndex, true);
							rootBone.bindMatrix = new Matrix3D(Vector.<Number>(String(childNode.matrix.text()).split(" ")));
							skeleton.addBone(rootBone);
							
							//trace("Root Bone: " + rootBone.name);
							
							var childBones:Vector.<Bone> = getChildBones(childNode, rootBone, boneIndex);
							skeleton.bones = skeleton.bones.concat(childBones);
							
							break;
						}
					}
					
					if (foundBones) break;
				}
				
				// parse bone names array, bone inverse bind matrix and bone weights for each vertex of model geometry
				var controllers:XMLList = _xml.library_controllers.controller;
				var boneNamesArr:Array;
				
				for each (var controller:XML in controllers) 
				{
					skeleton.bindShapeMatrix = new Matrix3D(Vector.<Number>(String(controller.skin.bind_shape_matrix.text()).split(" ")));
					skeleton.vcount = Vector.<Number>(String(controller.skin.vertex_weights.vcount.text()).split(" "));
					skeleton.v = Vector.<Number>(String(controller.skin.vertex_weights.v.text()).split(" "));
					
					for each (var skinSource:XML in controller.skin.source) 
					{
						var type:String = skinSource.technique_common.accessor.param.@name;
						if (type == "JOINT")
						{
							boneNamesArr = String(skinSource.Name_array.text()).split(" ");
							//trace("Bone Names: " + boneNamesArr);
						}
						
						if (type == "TRANSFORM")
						{
							var matrices:Vector.<Number> = Vector.<Number>(String(skinSource.float_array.text()).split(" "));
							var inverseMatrix:Vector.<Number> = new Vector.<Number>();
							var bIndex:int = 0;
							for (var k:int = 0; k < matrices.length; k++) 
							{
								inverseMatrix.push(matrices[k]);
								if (inverseMatrix.length == 16)
								{
									skeleton.bones[bIndex].inverseBindMatrix = new Matrix3D(inverseMatrix);
									//trace("inverseMatrix: " + skeleton.bones[bIndex].inverseBindMatrix.rawData);
									bIndex++;
									inverseMatrix = new Vector.<Number>();
								}
								
							}
						}
						
						if (type == "WEIGHT")
						{
							// the number of weights should alway equal the number vertices in the model.
							skeleton.weights = Vector.<Number>(String(skinSource.float_array.text()).split(" "));
							//trace("weights: " + skeleton.weights);
						}
					}
				}
				
				// parse animations
				boneIndex = 0;
				for each (var animation:XML in _xml.library_animations.animation) 
				{
					// get frame time data first.
					var frameTimes:Array;
					for each (var src:XML in animation.source) 
					{
						type = src.technique_common.accessor.param.@name;
						
						if (type == "TIME")
						{
							frameTimes = String(src.float_array.text()).split(" ");
							//trace("Frame Times: " + frameTimes);
							break;
						}
					}
					
					for each (src in animation.source) 
					{
						type = src.technique_common.accessor.param.@name;
						
						if (type == "TRANSFORM")
						{
							var floats:Array = String(src.float_array.text()).split(" ");
							var frameCount:int = int(src.technique_common.accessor.@count);
							var frameStride:int = int(src.technique_common.accessor.@stride);
							var pos:int = 0;
							//trace("	Floats: " + floats);
							//trace("Frame Count: " + frameCount + ", Stride: " + frameStride);
							for (var i:int = 0; i < frameCount; i++) 
							{
								var matrixFloats:Vector.<Number> = new Vector.<Number>();
								for (var j:int = 0; j < frameStride; j++) 
								{
									matrixFloats.push(floats[pos]);
									pos++;
								}
								
								var frame:Frame3D = new Frame3D(matrixFloats, frameTimes[i]);
								skeleton.bones[boneIndex].frames.push(frame);
								//trace("Bone: " + skeleton.bones[boneIndex].name + ", Time: " + frame.time + ", Frame: " + frame.rawData);
							}
							break;
						}
					}
					boneIndex++;
				}
				
				/*for each (var frame:Frame3D in skeleton.bones[1].frames) 
				{
					trace("Frame Matrix: " + frame.rawData);
				}*/
				
				var model:Model2 = new Model2(geom.@name, 3);
				model.vertices = v;
				model.normals = n;
				model.uvs = u;
				model.indexes = indexVector;
				if (model.uvs.length)
				{
					model.tangents = new Vector.<Number>(model.vertices.length);
					model.bitangents = new Vector.<Number>(model.vertices.length);
					for each (var tri:Triangle3D in tris) 
					{
						model.tangents[tri.indexes[0] * 3] = tri.tangents[0];
						model.tangents[(tri.indexes[0] * 3) + 1] = tri.tangents[1];
						model.tangents[(tri.indexes[0] * 3) + 2] = tri.tangents[2];
						
						model.tangents[tri.indexes[1] * 3] = tri.tangents[0];
						model.tangents[(tri.indexes[1] * 3) + 1] = tri.tangents[1];
						model.tangents[(tri.indexes[1] * 3) + 2] = tri.tangents[2];
						
						model.tangents[tri.indexes[2] * 3] = tri.tangents[0];
						model.tangents[(tri.indexes[2] * 3) + 1] = tri.tangents[1];
						model.tangents[(tri.indexes[2] * 3) + 2] = tri.tangents[2];
						
						model.bitangents[tri.indexes[0] * 3] = tri.bitangents[0];
						model.bitangents[(tri.indexes[0] * 3) + 1] = tri.bitangents[1];
						model.bitangents[(tri.indexes[0] * 3) + 2] = tri.bitangents[2];
						
						model.bitangents[tri.indexes[1] * 3] = tri.bitangents[0];
						model.bitangents[(tri.indexes[1] * 3) + 1] = tri.bitangents[1];
						model.bitangents[(tri.indexes[1] * 3) + 2] = tri.bitangents[2];
						
						model.bitangents[tri.indexes[2] * 3] = tri.bitangents[0];
						model.bitangents[(tri.indexes[2] * 3) + 1] = tri.bitangents[1];
						model.bitangents[(tri.indexes[2] * 3) + 2] = tri.bitangents[2];
					}
				}
				
				if (skeleton.bones.length > 0)
				{
					model.skeleton = skeleton;
					model.skeleton.gotoAndStop(0);
				}
				
				// transform matrix
				var matrixData:Vector.<Number> = getTransform(model.name)
				model.mat = new Matrix3D(matrixData);
				model.mat = Matrix3DUtils.swapYZ(model.mat); // correct transform matrix for Y up.
				
				var colorMat:ColorMaterial = new ColorMaterial();
				colorMat.setRGB(.5, .5, .5);
				var materialColor:String = getMaterialDiffuseColor(model.name);
				if (materialColor)
				{
					var colorArr:Array = materialColor.split(" ");
					colorMat.setRGB(colorArr[0], colorArr[1], colorArr[2]);
					trace("diffuse color: " + colorMat.rgb);
				}
				model.setMaterial(colorMat); // TODO get color from multiple materials if more than one.
				MeshUtil.getBounds(model);
				
				_children.push(model);
				
				////trace("id: " + id);
				//trace("vertices: " + model.vertices.length);
				//trace("normals: " + model.normals.length);
				//trace("indexes: " + model.indexes);
				//trace("uvs: " + model.uvs);
				//trace("tangents: " + model.tangents);
				//trace("bitangents: " + model.bitangents);
				//trace(model.name + " transform: " +model.mat.rawData);
			}
		}
		
		private function getTransform(name:String):Vector.<Number> 
		{
			var list:XMLList = _xml.library_visual_scenes.visual_scene.node as XMLList;
			for each (var node:XML in list) 
			{
				if (node.@id == name)
				{
					var tf:Array = node.matrix.text().split(" ");
					return Vector.<Number>(tf);
				}
			}
			return new Vector.<Number>();
		}
		
		private function getMaterialDiffuseColor(name:String):String 
		{
			var list:XMLList = _xml.library_visual_scenes.visual_scene.node as XMLList;
			for each (var node:XML in list) 
			{
				if (node.@id == name)
				{
					var materialId:String = node.instance_geometry.bind_material.technique_common.instance_material.@symbol
					var materials:XMLList = _xml.library_materials.material;
					for each (var mat:XML in materials) 
					{
						if (mat.@id == materialId)
						{
							var materialEffectID:String = String(mat.instance_effect.@url).replace("#", "");
							var effects:XMLList = _xml.library_effects.effect;
							for each (var effect:XML in effects) 
							{
								if (effect.@id == materialEffectID)
								{
									var diffuseColor:String = ".5 .5 .5 1";
									if (effect.profile_COMMON.technique.phong != undefined && effect.profile_COMMON.technique.phong.color != undefined)
									{
										diffuseColor = effect.profile_COMMON.technique.phong.diffuse.color.text();
									}
									else if (effect.profile_COMMON.technique.blinn != undefined && effect.profile_COMMON.technique.blinn.diffuse.color != undefined)
									{
										diffuseColor = effect.profile_COMMON.technique.blinn.diffuse.color.text();
									}
									
									trace("Material Diffuse Color: " + diffuseColor);
									return diffuseColor
								}
							}
							
						}
					}
				}
			}
			return null;
		}
		
		// recursive bone collector
		private function getChildBones(node:XML, parentBone:Bone, boneIndex:int):Vector.<Bone> 
		{
			var bones:Vector.<Bone> = new Vector.<Bone>();
			if (node.node != undefined)
			{
				for each (var child:XML in node.node) 
				{
					if (child.@type == "JOINT")
					{
						var bone:Bone = new Bone(child.@name, boneIndex++, false, parentBone);
						bone.bindMatrix = new Matrix3D(Vector.<Number>(String(child.matrix.text()).split(" ")));
						bones.push(bone);
						
						//trace("Child Bone: " + bone.name);
						
						if (child.node != undefined) getChildBones(child, bone, boneIndex);
					}
				}
				
			}
			else
			{
				return bones;
			}
			
			return bones;
		}
		
		public function get children():Vector.<Model2> { return _children; }
	}

}