package as3d.display
{
	import as3d.display.Camera3D;
	import as3d.primitives.Sphere;
	import as3d.textures.Texture3D;
	import com.adobe.utils.PerspectiveMatrix3D;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.events.Event;
	import flash.display3D.Context3DRenderMode;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.display3D.Context3DTextureFormat;
	import as3d.primitives.Cube;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DFillMode;
	
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class Scene3D extends EventDispatcher
	{
		private var _stage:Stage;
		private var _stage3D:Stage3D;
		private var _context3D:Context3D;
		private var _camera:Camera3DOrbit;
		private var _program:Program3D;
		private var _vertexBuffer:VertexBuffer3D;
		private var _vertexBuffer2:VertexBuffer3D;
		private var _indexBuffer:IndexBuffer3D;
		private var _postVertexBuffer:VertexBuffer3D;
		private var _postIndexBuffer:IndexBuffer3D;
		private var _texture:Texture;
		private var _children:Vector.<Object3D> = new Vector.<Object3D>();
		private var _numChildren:int = 0;
		
		private var _projectionMatrix:PerspectiveMatrix3D;
		private var _modelViewProjection:Matrix3D;
		private var _modelMatrix:Matrix3D;
		
		private var _lightPos:Vector.<Number>;
		private var _useMipMap:Boolean = false;
		
		private var _postProgram:Program3D;
		private var _sceneTexture:Texture;
		
		private var _rColor:Number = 0.5;
		private var _gColor:Number = 0.5;
		private var _bColor:Number = 0.5;
		private var _wireframe:Boolean = false;
		
		static public const SCENE_READY:String = "sceneReady";
		
		public function Scene3D(container:DisplayObjectContainer)
		{
			_stage = container.stage;
			_stage.align = StageAlign.TOP_LEFT;
			_stage.scaleMode = StageScaleMode.NO_SCALE;
			_stage.frameRate = 60;
			
			_stage3D = container.stage.stage3Ds[0];
			_stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			_stage3D.requestContext3D(Context3DRenderMode.AUTO);
			
			Config.stage = _stage;
			Config.stage3d = _stage3D;
			Config.scene = this;
			
			_camera = new Camera3DOrbit(10);
			Config.camera = _camera;
		}
		
		private function onContextCreated(e:Event):void
		{
			// Setup context
			_stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			
			_context3D = _stage3D.context3D;
			_context3D.configureBackBuffer(_stage.stageWidth, _stage.stageHeight, 4, true);
			_context3D.setCulling(Context3DTriangleFace.NONE); // TODO change to Context3DTriangleFace.BACK for performance
			_context3D.enableErrorChecking = true;
			
			/*var bmd:BitmapData = new BitmapData(1024, 1024, false);
			_sceneTexture = _context3D.createTexture(bmd.width, bmd.height, Context3DTextureFormat.BGRA, true);
			_sceneTexture.uploadFromBitmapData(bmd);
			
			createPostProcessingProgram();*/
			
			// Start scene render updates
			_stage.addEventListener(Event.ENTER_FRAME, render);
			
			dispatchEvent(new Event(SCENE_READY));
		}
		
		private function createPostProcessingProgram():void 
		{
			_postProgram = _context3D.createProgram();
			
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble
			( 
				Context3DProgramType.VERTEX,
				// Pass position through unchanged. It's already in clip space.
				"m44 op, va0, vc0\nmov v0, va1\n"
			);
			
			
			// A simple fragment shader which will use the vertex position as a color
			var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentShaderAssembler.assemble
			( 
				Context3DProgramType.FRAGMENT,
				// Sample scene texture
				"tex ft0, v0, fs0 <2d,clamp,linear>\n" +
				// Copy scene texture color to output
				"mov oc, ft0\n"
			);
			
			
			_postProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
			
			
			// Post filter full-screen quad vertex and index buffers
			_postVertexBuffer = _context3D.createVertexBuffer(4, 2);
			_postVertexBuffer.uploadFromVector(new <Number>[
																-1,  1, // TL
																 1,  1, // TR
																 1, -1, // BR
																-1, -1  // BL
																], 0, 4);
			_postIndexBuffer = _context3D.createIndexBuffer(6);
			_postIndexBuffer.uploadFromVector(new <uint>[
																0, 2, 3, // bottom tri (TL, BR, BL)
																0, 1, 2  // top tri (TL, TR, BR)
															], 0, 6);
		}
		
		private function render(e:Event):void
		{
			// clear everything before re-drawing.
			_context3D.clear(_rColor, _gColor, _bColor);
			
			// render to texture first for antialiasing.
			//_context3D.setRenderToTexture(_sceneTexture, true, 4);
			
			var numDraws:int = 0;
			
			for each (var child:Mesh3D in _children)
			{
				child.render();	
				numDraws++;
			}
			
			_context3D.present();
			
			// Now render the texture to the back buffer (the screen)
			/*_context3D.setProgram(_postProgram);
			_context3D.setRenderToBackBuffer();
			_context3D.setTextureAt(0, _sceneTexture);
			_context3D.clear(0.5, 0.5, 0.5);
			_context3D.setVertexBufferAt(0, _postVertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			_context3D.setVertexBufferAt(1, null);
			// other setup
			_context3D.drawTriangles(_postIndexBuffer);*/
		}
		
		public function get children():Vector.<Object3D> { return _children; }
		public function get numChildren():int { return _numChildren; }
		public function get camera():Camera3DOrbit { return _camera; }
		
		public function addChild(child:Object3D):void 
		{
			_children.push(child);
			_numChildren++;
		}
		
		public function removeChild(child:Object3D):void 
		{
			var index:int = _children.indexOf(child);
			if (index != -1)
			{
				_children.removeAt(index);
				_numChildren--;
			}
		}
		
		public function dispose():void 
		{
			for (var i:int = 0; i < _numChildren; i++) 
			{
				_children[i].dispose();
			}
		}
		
		public function bgColor(r:Number = 0.5, g:Number = 0.5, b:Number = 0.5):void 
		{
			_rColor = r;
			_gColor = g;
			_bColor = b;
		}
		
		public function set wireframe(value:Boolean):void 
		{
			_wireframe = value;
			// TODO wireframe currently for AIR only.
			_context3D.setFillMode((_wireframe) ? Context3DFillMode.WIREFRAME : Context3DFillMode.SOLID);
		}
		
		public function set x(value:Number):void 
		{
			_stage3D.x = value;
		}
		
		public function get x():Number 
		{
			return _stage3D.x
		}
		
		public function set y(value:Number):void 
		{
			_stage3D.y = value;
		}
		
		public function get y():Number 
		{
			return _stage3D.y;
		}
		
		public function get width():Number 
		{
			return (_context3D) ? _context3D.backBufferWidth : _stage.stageWidth;
		}
		
		public function get height():Number
		{
			return (_context3D) ? _context3D.backBufferHeight : _stage.stageHeight;
		}
	}

}