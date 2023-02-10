package as3d.primitives 
{
	import as3d.display.Mesh3D;
	import as3d.materials.ColorMaterial;
	import as3d.shaders.ShaderBase;
	import as3d.textures.Texture3D;
	import as3d.utils.Matrix3DUtils;
	import com.adobe.utils.AGALMiniAssembler;
	import com.adobe.utils.PerspectiveMatrix3D;
	import flash.geom.*;
	import Config;
	import flash.display.Bitmap;
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.utils.ByteArray;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.Context3DTriangleFace;
	
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class Model extends Mesh3D
	{
		private var _context3D:Context3D;
		private var _size:Number;
		private var _pos:Vector3D;
		private var _modelViewProjection:Matrix3D = new Matrix3D();
		private var _lightPos:Vector.<Number>;
		private var _useMipMap:Boolean = true;
		private var _hasTextures:Boolean;
		private var _hasUV:Boolean;
		private var _defaultColor:ColorMaterial = new ColorMaterial(0x999999);
		
		public function Model(name:String = "", data32:int = 3) 
		{
			super(name, data32);
			lightsEnabled = true;
			_context3D = Config.stage3d.context3D;
		}
		
		override public function createBuffers():void 
		{
			super.createBuffers();
			
			_hasTextures = (textures.length > 0);
			_hasUV = (uvs.length > 0);
			
			program = new ShaderBase(_hasTextures).program;
			
			//setupProgram();
		}
		
		/*override protected function setupProgram():void 
		{
			// When you call the createProgram method you are actually allocating some V-Ram space for your shader program.
			program = _context3D.createProgram();
			
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble
			( 
				Context3DProgramType.VERTEX,
				// 4x4 matrix multiply to get camera angle	
				"m44 op, va0, vc0 \n" +
				// tell fragment shader about XYZ
				"mov v0, va0 \n" +
				// tell fragment shader about UV
				((_hasUV) ? "mov v1, va1 \n" : "") +
				// tell fragment shader about Normals
				"mov v2, va2 \n"
			);
			
			// A simple fragment shader which will use the vertex position as a color
			var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentShaderAssembler.assemble
			( 
				Context3DProgramType.FRAGMENT,
				// grab the texture color from texture fs0 using the UV coordinates stored in v1 or set material color from constant fc4
				((_hasTextures) ? "tex ft4, v1, fs0 <2d,anisotropic8x,repeat,miplinear> \n" : "mov ft4, fc4 \n") +	
				
				((lightsEnabled) ?
				// PHONG LIGHT!!!!!!!!!!
				// normalize normal from v2
				"nrm ft0.xyz, v2 \n" +
				// set w to 1 using half angle fragment constant Vector3d(0,0,0, 1), zeros should be set to the light direction
				"mov ft0.w, fc0.w \n" +
				// dot product to get percentage of light hitting faces
				"dp3 ft0.x, ft0, fc0 \n" +
				// clamp negative values to zero
				"sat ft0.x, ft0.x \n" +
				// dot product to power using w from specular color
				"pow ft1.x, ft0.x, fc3.w \n" +
				// multiply diffuse color by the dotproduct percentage using x for each x(red),y(green) and z(blue) of diffuse color
				"mul ft2.xyz, fc2.xyz, ft0.xxx \n" +
				// add the ambient color to the diffuse color on ft2
				"add ft2.xyz, fc1, ft2.xyz \n" +
				// multiply specular color from fc3 by dot product power
				"mul ft3.xyz, fc3, ft1.xxx \n" +
				// add ambient and specular and output
				"add ft5, ft2.xyz, ft3.xyz \n" +
				// add color to texture
				"mul oc, ft4.xyz, ft5.xyz \n"
				
				
				// move texture or color value to the output
				: "mov oc, ft4 \n")
			);
			
			program.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
		}*/
		
		override public function render():void
		{
			_context3D.setCulling(Context3DTriangleFace.BACK);
			_context3D.setProgram(program);
			(_hasTextures) ? _context3D.setTextureAt(0, textures[0].texture) : _context3D.setTextureAt(0, null);
			
			_modelViewProjection.identity();					// RESET MATRIX3D
			_modelViewProjection.append(mat);					// MODEL
			_modelViewProjection.append(Config.camera.matrix);	// VIEW and PROJECTION
			
			_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _modelViewProjection, true); // pass in object3D matrix3D for positioning
			
			
			_context3D.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);					// vertex coordinates
			_context3D.setVertexBufferAt(1, (_hasUV) ? uvsBuffer : null, 0, Context3DVertexBufferFormat.FLOAT_2);	// UV/textrue coordinates
			_context3D.setVertexBufferAt(2, normalBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);					// normals coordinates
			
			if (lightsEnabled)
			{
				var p:Vector3D = Config.camera.position;
				p.normalize();
				p.negate();
				_lightPos = Vector.<Number>([p.x, p.y, p.z, 1]);
			
				_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _lightPos); //fc0, half angle vector with w set to 1
				_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, Config.ambientColor); //fc1, ambient color (white)
				_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, Vector.<Number>([.6, .6, .6, .6])); //fc2, diffuse color (blue)
				_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, Vector.<Number>([1, 1, 1, 1])); //fc3, specular color (red)
			}
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, (material) ? material.rgb : _defaultColor.rgb); 	// mesh color
			_context3D.drawTriangles(indexBuffer);
		}
		
	}

}