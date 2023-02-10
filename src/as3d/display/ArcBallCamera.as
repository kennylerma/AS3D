package as3d.display {

	import com.hurlant.crypto.symmetric.ECBMode;
	//import marcel.utils.MathUtils;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import com.adobe.utils.PerspectiveMatrix3D;
	import flash.events.Event;
	
	/**
	 * @author Nicolas CHESNE
	 */
	public class ArcBallCamera 
	{	
		private var _projectionMatrix:PerspectiveMatrix3D;
		private var _view:Matrix3D;
		private var _position:Vector3D;
		private var _target:Vector3D;
		private var _stage:Stage;
		private var _radius:Number;
		private var _mat:Matrix3D;
		private var _lastMouseX:Number;
		private var _lastMouseY:Number;
		private var _zoomSpeed:int = 5;
		private var _xRad:Number = 0;
		private var _yRad:Number = 0;
		private var _near:Number = 0.1;
		private var _far:Number = 10000;
		
		public function ArcBallCamera(stage:Stage, radius:Number = 10)
		{
			_radius = radius;
			_stage = stage;
			
			_projectionMatrix = new PerspectiveMatrix3D();
			_projectionMatrix.perspectiveFieldOfViewLH(45*Math.PI/180, stage.stageWidth/stage.stageHeight, _near, _far);
			
			_position = new Vector3D(0, 0, 0);
			_target = new Vector3D();
			_mat = new Matrix3D();
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			_stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			onMouseMove();
		}
		
		private function onMouseWheel(event:MouseEvent):void 
		{
			_zoomSpeed = Math.max(_radius*.5, 1);
			_radius += -(event.delta / 6) * _zoomSpeed;
			onMouseMove();
		}
		
		private function onDown(event:MouseEvent):void
		{
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
			_lastMouseX = _stage.mouseX;
			_lastMouseY = _stage.mouseY;
		}
		
		private function onMouseMove(event:MouseEvent = null):void 
		{
			var dx:Number;
			var dy:Number;
			if(event){
				dx =  _stage.mouseX - _lastMouseX; // left/right
				dy = _lastMouseY - _stage.mouseY; // up/down
				_lastMouseX = _stage.mouseX;
				_lastMouseY = _stage.mouseY;
			} else {
				dx = dy = 0;
			}
			
			_xRad = _xRad + dx*0.01;
			_yRad = _yRad + dy*0.01;
			
			var cy : Number = Math.cos(_yRad) * _radius;
			var x:Number = _target.x - Math.sin(_xRad) * cy;
			var y:Number = _target.y - Math.sin(_yRad) * _radius;
			var z:Number = _target.z - Math.cos(_xRad) * cy;
			
			//y = Math.abs(y);
			//trace("y: " + y);
			//trace("x: " + x);
			
			// View Matrix
			_position.setTo(x, y, z);
			_mat.identity();
			_mat.appendTranslation(x, y, z);
			_mat.pointAt(_target, Vector3D.Z_AXIS, new Vector3D(0, -1, 0));
			_view = _mat.clone();
			_mat.invert();
			
			// Perspective Matrix
			_mat.append(_projectionMatrix);
		}
		
		private function onUp(event:MouseEvent):void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		public function set near(value:Number):void 
		{
			_near = value;
			_projectionMatrix.perspectiveFieldOfViewLH(45*Math.PI/180, _stage.stageWidth/_stage.stageHeight, _near, _far);
		}
		
		public function set far(value:Number):void 
		{
			_far = value;
			_projectionMatrix.perspectiveFieldOfViewLH(45*Math.PI/180, _stage.stageWidth/_stage.stageHeight, _near, _far);
		}
		
		public function get matrix():Matrix3D
		{
			return _mat;
		}
		
		public function get zoomSpeed():int 
		{
			return _zoomSpeed;
		}
		
		public function set zoomSpeed(zoomSpeed:int):void 
		{
			_zoomSpeed = zoomSpeed;
		}
		
		public function get position():Vector3D
		{
			return _position.clone();
		}
		
		public function get projectionMatrix():PerspectiveMatrix3D 
		{
			return _projectionMatrix;
		}
		
		public function get view():Matrix3D 
		{
			return _view;
		}
	}
}
