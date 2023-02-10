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
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTriangleFace;
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class Model2 extends Mesh3D
	{
		private var _context3D:Context3D;
		private var _size:Number;
		private var _pos:Vector3D;
		private var _modelViewProjection:Matrix3D = new Matrix3D();
		private var _lightPos:Vector.<Number>;
		private var _useMipMap:Boolean = true;
		private var _hasDiffuse:Boolean;
		private var _hasNormal:Boolean;
		private var _hasSpecular:Boolean;
		private var _hasUV:Boolean;
		private var _defaultColor:ColorMaterial = new ColorMaterial(0x999999);
		
		private var lightPosition:Vector.<Number> = Vector.<Number>([0, 0, 50, 0.0]);
		private var ambient:Vector.<Number> = Vector.<Number>([0.6, 0.6, 0.6, 1.0]);
		private var specular:Vector.<Number> = Vector.<Number>([.4, .4, .4, 50.0]); // x,y,x = Level, W = Power
		
		[Embed(source = "../../../../AS3DEditor/bin/assets/Axe_diffuse_n.png")]
		private static const NormalBitmap:Class;
		
		private var _normalMap:Texture3D;
		
		public function Model2(name:String = "", data32:int = 3) 
		{
			super(name, data32);
			lightsEnabled = true;
			_context3D = Config.stage3d.context3D;
		}
		
		override public function createBuffers():void 
		{
			super.createBuffers();
			
			_normalMap = new Texture3D(new NormalBitmap() as Bitmap, true);
			
			
			_hasDiffuse = (textures.length > 0);
			_hasNormal = false;
			_hasUV = (uvs.length > 0);
			
			program = new ShaderBase(_hasDiffuse, _hasNormal).program;
		}
		
		override public function render():void
		{
			_context3D.setVertexBufferAt(0, null);
			_context3D.setVertexBufferAt(1, null);
			_context3D.setVertexBufferAt(2, null);
			_context3D.setVertexBufferAt(3, null);
			_context3D.setVertexBufferAt(4, null);
			_context3D.setTextureAt(0, null);
			_context3D.setTextureAt(1, null);
			_context3D.setTextureAt(2, null);
			_context3D.setTextureAt(3, null);
			
			_modelViewProjection.identity();					// RESET MATRIX3D
			_modelViewProjection.append(mat);					// MODEL
			_modelViewProjection.append(Config.camera.matrix);	// VIEW and PROJECTION
			
			if (lightsEnabled)
			{
				var p:Vector3D = Config.camera.position;
				_lightPos = Vector.<Number>([p.x, p.y, p.z, 0.0]);
				
				
				specular = Vector.<Number>([specularLevel, specularLevel, specularLevel, specularPower]);
			}	
			
			// render
			//_context3D.setDepthTest(true, Context3DCompareMode.LESS_EQUAL);
			_context3D.setCulling(Context3DTriangleFace.BACK);
			_context3D.setProgram(program);
			_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _modelViewProjection, true);
			_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, lightPosition);
			_context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 5, _lightPos);
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, material.rgb);
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, ambient);
			_context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, specular);
			_context3D.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);					// vertex coordinates
			_context3D.setVertexBufferAt(1, uvsBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);						// UV/textrue coordinates
			_context3D.setVertexBufferAt(2, normalBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);					// normals coordinates	
			
			if (_hasNormal)
			{
				_context3D.setVertexBufferAt(3, bitangentsBuffer,  0, Context3DVertexBufferFormat.FLOAT_3);	// va3 = binormal
				_context3D.setVertexBufferAt(4, tangentsBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);	// va4 = tangent
				_context3D.setTextureAt(1, _normalMap.texture);
			}
			
			if (_hasDiffuse) _context3D.setTextureAt(0, textures[0].texture); // diffuse map
			_context3D.drawTriangles(indexBuffer);			
		}
		
	}

}