package as3d.shaders 
{
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display3D.Program3D;
	import flash.display3D.Context3DProgramType;
	import Config;
	
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class ShaderBase
	{
		protected var _program:Program3D
		protected var _vertexShader:AGALMiniAssembler;
		protected var _fragmentShader:AGALMiniAssembler;
		
		protected var _hasNormal:Boolean;
		protected var _hasDiffuse:Boolean;
		
		public function ShaderBase(hasDiffuse:Boolean = false, hasNormal:Boolean = false) 
		{
			_hasDiffuse = hasDiffuse;
			_hasNormal = hasNormal;
			
			// When you call the createProgram method you are actually allocating some V-Ram space for your shader program.
			_program = Config.stage3d.context3D.createProgram();
			_vertexShader = new AGALMiniAssembler();
			_fragmentShader = new AGALMiniAssembler();
			
			init();
		}
		
		protected function init():void 
		{
			_vertexShader.assemble
			( 
				Context3DProgramType.VERTEX,
				// 4x4 matrix multiply to get camera angle
				"m44 op, va0, vc0 \n" +
				// UV coordinates
				"mov v0, va1 \n" +
				
				// normal map
				((_hasNormal) ? 
				// transform lightVec
				'sub vt1, vc4, va0 \n' +		// vt1 = lightPos - vertex (lightVec)					
				'dp3 vt3.x, vt1, va4 \n' +
				'dp3 vt3.y, vt1, va3 \n' +
				'dp3 vt3.z, vt1, va2 \n' +
				'mov v2, vt3.xyzx \n' +			// v2 = lightVec
				// transform viewVec
				'sub vt2, va0, vc5 \n' +		// vt2 = viewPos - vertex (viewVec)
				'dp3 vt4.x, vt2, va4 \n' +
				'dp3 vt4.y, vt2, va3 \n' +
				'dp3 vt4.z, vt2, va2 \n' +					
				'mov v3, vt4.xyzx \n' : "") +	// v3 = viewVec
				
				"mov v1, va2 \n" +				// v1 = normal
				"sub v2, vc4, va0 \n" +			// v2 = lightVec
				"sub v3, va0, vc5 \n" 			// v3 = viewVec
			);
			
			_fragmentShader.assemble
			( 
				Context3DProgramType.FRAGMENT,
				
				// diffuse map
				((_hasDiffuse) ? "tex ft0, v0, fs0 <2d,anisotropic8x,repeat,linear,miplinear> \n" : "mov ft0, fc0 \n") +
				// normal map
				((_hasNormal) ?
				'tex ft1, v0, fs1 <2d,anisotropic8x,repeat,linear,miplinear> \n' +	// ft1 = normalMap(v0)
				// 0..1 to -1..1
				'add ft1, ft1, ft1 \n' +			// ft1 *= 2
				'sub ft1, ft1, fc0.z \n' +			// ft1 -= 1
				'nrm ft1.xyz, ft1 \n' 				// normal ft1 = normalize(normal)
				
				: "nrm ft1.xyz, v1 \n") +			// if no normal map
				
				'nrm ft2.xyz, v2 \n' +				// lightVec	ft2 = normalize(lerp_lightVec)
				'nrm ft3.xyz, v3 \n' +				// viewVec	ft3 = normalize(lerp_viewVec)
				// calc reflect vec (ft4)
				'dp3 ft4.x, ft1.xyz ft3.xyz \n' +	// ft4 = dot(normal, viewVec)
				'mul ft4, ft1.xyz, ft4.x \n' +		// ft4 *= normal
				'add ft4, ft4, ft4 \n' +			// ft4 *= 2					
				'sub ft4, ft3.xyz, ft4 \n' +		// reflect	ft4 = viewVec - ft4
				// lambert shading
				'dp3 ft5.x, ft1.xyz, ft2.xyz \n' +	// ft5 = dot(normal, lightVec)
				'max ft5.x, ft5.x, fc0.x \n' +		// ft5 = max(ft5, 0.0)					
				'add ft5, fc1, ft5.x \n' +			// ft5 = ambient + ft5
				'mul ft0, ft0, ft5 \n'	+			// color *= ft5
				// phong shading
				'dp3 ft6.x, ft2.xyz, ft4.xyz \n' +	// ft6 = dot(lightVec, reflect)
				'max ft6.x, ft6.x, fc0.x \n' +		// ft6 = max(ft6, 0.0)
				'pow ft6.x, ft6.x, fc2.w \n' +		// ft6 = pow(ft6, specularPower)
				'mul ft6, ft6.x, fc2.xyz \n' +		// ft6 *= specularLevel
				'add ft0, ft0, ft6 \n' +			// color += ft6
				
				'mov oc, ft0 \n'
			);
			
			_program.upload(_vertexShader.agalcode, _fragmentShader.agalcode);
		}
		
		public function get program():Program3D 
		{
			return _program;
		}
		
	}

}