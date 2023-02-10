package as3d.shaders 
{
	import com.barliesque.agal.EasyAGAL;
	import com.barliesque.agal.IRegister;
	import com.barliesque.agal.TextureFlag;
	/**
	 * Generates base shader program for all 3D objects using EasyAGAL.
	 * @author Kenny Lerma
	 */
	public class Program extends EasyAGAL
	{
		private var vertexUV:IRegister;
		private var vertexNormal:IRegister;
		private var vertexPos:IRegister;
		private var lightPos:IRegister;  
		
		public function Program() 
		{
			
		}
		
		override protected function _vertexShader():void
		{
			vertexPos = assign(VARYING[0], "vertexPos");
			mov(vertexPos, ATTRIBUTE[0]);
			m44(vertexPos, ATTRIBUTE[0], CONST[0]);
			
			vertexUV = assign(VARYING[0], "vertexUV");
			mov(vertexUV, ATTRIBUTE[1]);
			
			vertexNormal = assign(VARYING[1], "vertexNormal");
			mov(vertexNormal, ATTRIBUTE[2]);
		}

		override protected function _fragmentShader():void
		{
			/*// Compile our AGAL Code into ByteCode using the MiniAssembler 
			var vertexShader:ByteArray = assembler.assemble(Context3DProgramType.VERTEX, code);
			var textOptions:String = "";
			if (_useMipMap) {
				textOptions = "<2d,linear, miplinear, repeat>";
			} else {
				textOptions = "<2d,linear, nomip, repeat>";
			}
			
			code =  ""+
			"text ft0 v0, fs0 "+textOptions+"\n"+		// sample the texture (fs0) at the interpolated UV coordinates (v0) and put the color into ft0
			"dp3 ft1, fc2, v1 \n"+ 						// dot the transformed normal (v1) with light direction fc2 -&gt; This is the Lamberian Factor
			"neg ft1, ft1 \n"+ 							// Get the "opposite" vector. We could also have uploaded the opposite of the light direction to avoid this step
			"max ft1, ft1, fc0 \n"+ 					// clamp any negative values to 0 // ft1 = lamberian factor
			*/
			
			var textureRGB:IRegister = assign(TEMP[0], "textureRGB");
			tex(textureRGB, vertexUV, SAMPLER[0], [TextureFlag.TYPE_2D, TextureFlag.FILTER_LINEAR, TextureFlag.MIP_LINEAR, TextureFlag.MODE_REPEAT]);
			dp3(vertexNormal, CONST[2], VARYING[1]);
			neg(vertexNormal, vertexNormal);
			max(vertexNormal, vertexNormal, CONST[0]);
			
			/*
			"mul ft2, ft0, ft1 \n"+ 					//multiply fragment color (ft0) by light amount (ft1).
			"mul ft2, ft2, fc3 \n"+ 					//multiply fragment color (ft2) by light color (fc3).
			"add oc, ft2, fc1"; 
			//add ambient light and output the color*/
			// TODO: finish conversion to EasyAGAL
			//mul(
		}
	}

}