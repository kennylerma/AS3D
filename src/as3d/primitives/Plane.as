package as3d.primitives 
{
	import as3d.display.Mesh3D;
	import as3d.materials.ColorMaterial;
	import as3d.textures.Texture3D;
	import com.adobe.utils.AGALMiniAssembler;
	import com.barliesque.agal.IRegister;
	import flash.display.Bitmap;
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class Plane extends Mesh3D
	{
		private var _context3D:Context3D;
		private var _modelViewProjection:Matrix3D = new Matrix3D();;
		private var _lightPos:Vector.<Number>;
		private var _useMipMap:Boolean = true;
		private var _texture:Texture;
		
		[Embed(source="../../../assets/Kenny.jpg")]
		private static const KENNYJPG:Class;
		
		public function Plane(name:String = "", w:Number = 50, h:Number = 50, orientVertical:Boolean = false) 
		{
			super(name, 3);
			
			_context3D = Config.stage3d.context3D;
			doubleSided = false;
			
			w *= .5
            h *= .5
			
			if (!orientVertical)
			{
				// flat to bottom
				vertices = new <Number>[
					-w, 0, w, // x, y, z
					 w, 0, w,
					 w, 0, -w,
					-w, 0, -w
				];
			}
			else
			{
				// facing forward
				vertices = new <Number>[
					-w, w, 0, // x, y, z
					 w, w, 0,
					 w,-w, 0,
					-w,-w, 0
				];
			}
			
			squares = new <Number>[0, 1, 2, 3];
			
			// Setup texture
			var tex:Texture3D = new Texture3D(new KENNYJPG() as Bitmap, true)
			_texture = tex.texture;
			textures.push(tex);
			
			createBuffers();
			
			setMaterial(new ColorMaterial(0xFF00FF));
			setupProgram();
			
			/*trace("Vertices: " + vertices);
			trace("UVs: " + uvs);
			trace("Normals: " + normals);
			trace("Indexes: " + indexes);*/
		}
		
		protected function setupProgram():void
		{
			// // // CREATE SHADER PROGRAM // //
			// When you call the createProgram method you are actually allocating some V-Ram space
			// for your shader program.
			program = _context3D.createProgram();
			
			// Create an AGALMiniAssembler.
			// The MiniAssembler is an Adobe tool that uses a simple
			// Assembly-like language to write and compile your shader into bytecode
			var assembler:AGALMiniAssembler = new AGALMiniAssembler();
			
			// VERTEX SHADER
			var code:String = "";
			code += "mov vt0, va0\n";			// mov vertex pos into vt0
			code += "m44 op, vt0, vc0\n"; 		// m44 to output point
			
			code += "mov v0, va1\n";			// Interpolate the UVs (va0) into variable register v1
			code += "mov v1, va2\n";			// Interpolate the Normals (va1) into variable register v1
									 
			// Compile our AGAL Code into ByteCode using the MiniAssembler 
			var vertexShader:ByteArray = assembler.assemble(Context3DProgramType.VERTEX, code);
			var textOptions:String = "";
			if (_useMipMap) {
				textOptions = "<2d, anisotropic8x, miplinear, repeat>";
			} else {
				textOptions = "<2d, anisotropic8x, linear, nomip, repeat>";
			}
			
			code = ""+
			"text ft0 v0, fs0 "+textOptions+"\n" +		// sample the texture (fs0) at the interpolated UV coordinates (v0) and put the color into ft0
			"dp3 ft1, fc2, v1 \n" + 					// dot the transformed normal (v1) with light direction fc2 -&gt; This is the Lamberian Factor
			"neg ft1, ft1 \n" + 						// Get the "opposite" vector. We could also have uploaded the opposite of the light direction to avoid this step
			"sat ft1, ft1 \n" + 						// clamp any negative values to 0 // ft1 = lamberian factor
			 
			"mul ft2, ft0, ft1 \n" + 					//multiply fragment color (ft0) by light amount (ft1) dot product.
			"mul ft2, ft2, fc3 \n" + 					//multiply fragment color (ft2) by light color (fc3).
			"add oc, ft2.xyz, fc3.www"; 				//add ambient light and output the color
			
			// Compile our AGAL Code into Bytecode using the MiniAssembler
			var fragmentShader:ByteArray = assembler.assemble(Context3DProgramType.FRAGMENT, code);
			
			program.upload(vertexShader, fragmentShader);
		}
		
		override public function render():void 
		{
			//_context3D.setCulling("back");
			_context3D.setTextureAt(0, _texture);
			_context3D.setProgram(program);
			
			_modelViewProjection.identity();					// RESET MATRIX3D
			_modelViewProjection.append(mat);					// MODEL
			_modelViewProjection.append(Config.camera.matrix);	// VIEW and PROJECTION
			
			if (lightsEnabled)
			{
				var p:Vector3D = Config.camera.position;
				p.normalize();
				p.negate();
				_lightPos = Vector.<Number>([p.x, p.y, p.z, 1]);
			}
			
			_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _modelViewProjection, true); 	// pass in object3D matrix3D for positioning
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, _lightPos); 					// Light Direction
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, Config.ambientColor); 		// white Light Color and w used for intensity
			
			_context3D.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			_context3D.setVertexBufferAt(1, uvsBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			_context3D.setVertexBufferAt(2, normalBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, material.rgb); 				// mesh color
			_context3D.drawTriangles(indexBuffer);
		}
		
	}

}