package as3d.primitives 
{
	import as3d.display.Mesh3D;
	import as3d.materials.ColorMaterial;
	import as3d.textures.Texture3D;
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display.Bitmap;
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class Sphere extends Mesh3D
	{
		private var _context3D:Context3D;
		private var _modelViewProjection:Matrix3D = new Matrix3D();;
		private var _lightPos:Vector.<Number>;
		private var _useMipMap:Boolean = true;
		private var _texture:Texture;
		
		private var positions:VertexBuffer3D;
		private var texCoords:VertexBuffer3D;
		private var tris:IndexBuffer3D;
		
		[Embed(source="../../../assets/earthmap.jpg")]
		private static const KENNYJPG:Class;
		
		
		/** Minimum number of horizontal slices any sphere can have */
		private static const MIN_SLICES:uint = 3;
 
		/** Minimum number of vertical stacks any sphere can have */
		private static const MIN_STACKS:uint = 3;
		
		
		public function Sphere(name:String = "", slices:uint = 100, stacks:uint = 100) 
		{
			super(name, 3);
			
			_context3D = Config.stage3d.context3D;
			doubleSided = false;
			
			// Cap parameters
			if (slices < MIN_SLICES)
			{
				slices = MIN_SLICES;
			}
			if (stacks < MIN_STACKS)
			{
				stacks = MIN_STACKS;
			}
			
			// Pre-compute many constants used in tesselation
			const stepTheta:Number = (2.0*Math.PI) / slices;
			const stepPhi:Number = Math.PI / stacks;
			const stepU:Number = 1.0 / slices;
			const stepV:Number = 1.0 / stacks;
			const verticesPerStack:uint = slices + 1;
			const numVertices:uint = verticesPerStack * (stacks + 1);
			
			// Allocate the vectors of data to tesselate into
			var positions:Vector.<Number> = new Vector.<Number>(numVertices*3);
			var texCoords:Vector.<Number> = new Vector.<Number>(numVertices*2);
			var tris:Vector.<uint> = new Vector.<uint>(slices * stacks * 6);
			
			// Pre-compute half the sin/cos of thetas
			var halfCosThetas:Vector.<Number> = new Vector.<Number>(verticesPerStack);
			var halfSinThetas:Vector.<Number> = new Vector.<Number>(verticesPerStack);
			var curTheta:Number = 0;
			for (var slice:uint; slice < verticesPerStack; ++slice)
			{
				halfCosThetas[slice] = Math.cos(curTheta) * 0.5;
				halfSinThetas[slice] = Math.sin(curTheta) * 0.5;
				curTheta += stepTheta;
			}
 
			// Generate positions and texture coordinates
			var curV:Number = 1.0;
			var curPhi:Number = Math.PI;
			var posIndex:uint;
			var texCoordIndex:uint;
			for (var stack:uint = 0; stack < stacks+1; ++stack)
			{
				var curU:Number = 1.0;
				var curY:Number = Math.cos(curPhi) * 0.5;
				var sinCurPhi:Number = Math.sin(curPhi);
				for (slice = 0; slice < verticesPerStack; ++slice)
				{
					positions[posIndex++] = halfCosThetas[slice]*sinCurPhi;
					positions[posIndex++] = curY;
					positions[posIndex++] = halfSinThetas[slice] * sinCurPhi;
 
					texCoords[texCoordIndex++] = curU;
					texCoords[texCoordIndex++] = curV;
					curU -= stepU;
				}
 
				curV -= stepV;
				curPhi -= stepPhi;
			}
 
			// Generate tris
			var lastStackFirstVertexIndex:uint = 0;
			var curStackFirstVertexIndex:uint = verticesPerStack;
			var triIndex:uint;
			for (stack = 0; stack < stacks; ++stack)
			{
				for (slice = 0; slice < slices; ++slice)
				{
					// Bottom tri of the quad
					tris[triIndex++] = lastStackFirstVertexIndex + slice + 1;
					tris[triIndex++] = curStackFirstVertexIndex + slice;
					tris[triIndex++] = lastStackFirstVertexIndex + slice;
 
					// Top tri of the quad
					tris[triIndex++] = lastStackFirstVertexIndex + slice + 1;
					tris[triIndex++] = curStackFirstVertexIndex + slice + 1;
					tris[triIndex++] = curStackFirstVertexIndex + slice;
				}
 
				lastStackFirstVertexIndex += verticesPerStack;
				curStackFirstVertexIndex += verticesPerStack;
			}
			
			// Setup texture
			var tex:Texture3D = new Texture3D(new KENNYJPG() as Bitmap, true);
			_texture = tex.texture;
			textures.push(tex);
			
			vertices = positions;
			uvs = texCoords;
			indexes = tris.reverse();
			
			createBuffers();
			setMaterial(new ColorMaterial(0xFF00FF));
			setupProgram();
			
			// TODO remove this scale and add size property
			scale(50);
		}
		
		override protected function setupProgram():void
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
			code += "mov v1, va2\n";			// Interpolate the normal (va1) into variable register v1
									 
			// Compile our AGAL Code into ByteCode using the MiniAssembler 
			var vertexShader:ByteArray = assembler.assemble(Context3DProgramType.VERTEX, code);
			var textOptions:String = "";
			if (_useMipMap) {
				textOptions = "<2d, anisotropic8x, miplinear, repeat>";
			} else {
				textOptions = "<2d, anisotropic8x, linear, nomip, repeat>";
			}
			
			code =  ""+
			"text ft0 v0, fs0 "+textOptions+"\n"+		// sample the texture (fs0) at the interpolated UV coordinates (v0) and put the color into ft0
			"dp3 ft1, fc2, v1 \n"+ 						// dot the transformed normal (v1) with light direction fc2 -&gt; This is the Lamberian Factor
			"neg ft1, ft1 \n"+ 							// Get the "opposite" vector. We could also have uploaded the opposite of the light direction to avoid this step
			"max ft1, ft1, fc0 \n"+ 					// clamp any negative values to 0 // ft1 = lamberian factor
			 
			"mul ft2, ft0, ft1 \n"+ 					//multiply fragment color (ft0) by light amount (ft1).
			"mul ft2, ft2, fc3 \n"+ 					//multiply fragment color (ft2) by light color (fc3).
			"add oc, ft2, fc1"; 						//add ambient light and output the color
			
			// Compile our AGAL Code into Bytecode using the MiniAssembler
			var fragmentShader:ByteArray = assembler.assemble(Context3DProgramType.FRAGMENT, code);
			
			program.upload(vertexShader, fragmentShader);
		}
		
		override public function render():void 
		{
			_context3D.setTextureAt(0, _texture);
			_context3D.setProgram(program);
			
			_modelViewProjection.identity();					// RESET MATRIX3D
			_modelViewProjection.append(mat);					// MODEL
			_modelViewProjection.append(Config.camera.matrix);	// VIEW and PROJECTION	
			
			_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _modelViewProjection, true); // pass in object3D matrix3D for positioning
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([0,0,0,0])); //fc0, for clamping negative values to zero
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, Vector.<Number>([0.1,0.1,0.1,0])); //fc1, ambient lighting (1/4 of full intensity)
			
			var showLights:Boolean = true;
			if (showLights)
			{
				var p:Vector3D = Config.camera.position;
				p.normalize();
				p.negate();
				_lightPos = Vector.<Number>([p.x,p.y,p.z,1]);
			}
			
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, _lightPos); // Light Direction
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, Vector.<Number>([1,1,1,1])); // Light Color
			
			_context3D.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			_context3D.setVertexBufferAt(1, uvsBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			_context3D.setVertexBufferAt(2, normalBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, material.rgb); // mesh color
			_context3D.drawTriangles(indexBuffer);
		}
		
	}

}