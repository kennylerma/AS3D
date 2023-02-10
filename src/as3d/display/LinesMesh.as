package as3d.display 
{
	import as3d.shaders.LineShader;
	import flash.display3D.Context3D;
	import flash.geom.Matrix3D;
	import Config;
	import flash.display3D.Context3DTriangleFace;
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class LinesMesh extends Mesh3D
	{
		private var _context3D:Context3D;
		private var _modelViewProjection:Matrix3D = new Matrix3D();
		
		public function LinesMesh(name:String, data32:int = 3) 
		{
			super(name, data32);
			_context3D = Config.stage3d.context3D;
			
			program = new LineShader().program;
		}
		
		override public function render():void
		{
			_context3D.setCulling(Context3DTriangleFace.NONE);
			_context3D.setProgram(program);
			_context3D.setTextureAt(0, null); // remove texture binding
			
			// get the reverse of the camera rotation to keep the line pointed at the camera.  use for billboards
			//var cameraReverseRotation:Matrix3D = Config.camera.matrix.clone();
			//cameraReverseRotation.invert();
			//mat.pointAt(cameraReverseRotation.position, Vector3D.Y_AXIS, Vector3D.Y_AXIS);
			
			_modelViewProjection.identity();					// RESET MATRIX3D
			_modelViewProjection.append(mat);					// MODEL
			_modelViewProjection.append(Config.camera.matrix);	// VIEW and PROJECTION
			
			_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _modelViewProjection, true); // pass in object3D matrix3D for positioning
			
			_context3D.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);		// vertex coordinates
			_context3D.setVertexBufferAt(1, vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_3);		// color rgb
			_context3D.setVertexBufferAt(2, null); // remove stream 2 binding
			_context3D.drawTriangles(indexBuffer);
		}
	}

}