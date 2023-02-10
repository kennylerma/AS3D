package as3d.shaders 
{
	import flash.display3D.Context3DProgramType;
	
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class LineShader extends ShaderBase
	{
		
		public function LineShader() 
		{
			super();
		}
		
		override protected function init():void 
		{
			_vertexShader.assemble
			( 
				Context3DProgramType.VERTEX,
				// 4x4 matrix multiply to get camera angle	
				"m44 vt1, va0, vc0 \n" +
				// force z coordinate to Zero
				//"sub vt1.z, vt1.z, vt1.z \n" +
				// move modifed vertices to output
				"mov op, vt1 \n" +
				// tell fragment shader about rgb color
				"mov v0, va1 \n"
			);
			
			_fragmentShader.assemble
			( 
				Context3DProgramType.FRAGMENT,	
				// move this value to the output color
				"mov oc, v0 \n"
			);
			
			_program.upload(_vertexShader.agalcode, _fragmentShader.agalcode);
		}
		
	}

}