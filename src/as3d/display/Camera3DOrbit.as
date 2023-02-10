package as3d.display
{
	import com.adobe.utils.PerspectiveMatrix3D;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	/**
	 * @author Kenny Lerma
	 */
	public class Camera3DOrbit 
	{	
		private var _projectionMatrix:PerspectiveMatrix3D;
		private var _position:Vector3D;
		private var _stage:Stage;
		private var _radius:Number;
		private var _mat:Matrix3D;
		private var _lastMouseX:Number;
		private var _lastMouseY:Number;
		private var _zoomSpeed:int = 5;
		private var _near:Number = 0.1;
		private var _far:Number = 10000;
		
		private var camRot:Vector3D = new Vector3D(0, 0); //change for camera rotation from target.
		private var dragPos:Point;
		
		public function Camera3DOrbit(radius:Number = 10)
		{
			_radius = radius;
			_stage = Config.stage;
			
			_projectionMatrix = new PerspectiveMatrix3D();
			_projectionMatrix.perspectiveFieldOfViewLH(45*Math.PI/180, _stage.stageWidth/_stage.stageHeight, _near, _far);
			
			_position = new Vector3D(0, 0, 0);
			_mat = new Matrix3D();
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			_stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			updateView();
		}
		
		private function onMouseWheel(e:MouseEvent):void 
		{
			_zoomSpeed = Math.max(_radius*.5, 1);
			_radius += -(e.delta / 6) * _zoomSpeed;
			updateView(true);
		}
		
		private function onDown(e:MouseEvent):void
		{
			if (e.target is Stage)
			{
				_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				_stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
				dragPos = new Point(_stage.mouseX, _stage.mouseY);
			}
		}
		
		private function onUp(e:MouseEvent):void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
		}
		
		private function onMouseMove(event:MouseEvent):void 
		{
			updateView();
		}
		
		private function projMatrix(FOV:Number, aspect:Number, zNear:Number, zFar:Number):Matrix3D
		{
			var sy:Number = 1.0 / Math.tan(FOV * Math.PI / 360.0),
				sx:Number = sy / aspect;
			return new Matrix3D(Vector.<Number>([
					sx, 0.0, 0.0, 0.0,
					0.0, sy, 0.0, 0.0,
					0.0, 0.0, zFar / (zNear - zFar), -1.0,
					0.0, 0.0, (zNear * zFar) / (zNear - zFar), 0.0]));
		}
		
		private function updateView(zoomOnly:Boolean = false):void 
		{
			if (!zoomOnly  && dragPos)
			{
				camRot.x -= (_stage.mouseY - dragPos.y) * 0.5;
				camRot.y -= (_stage.mouseX - dragPos.x) * 0.5;					
				dragPos = new Point(_stage.mouseX, _stage.mouseY);
			}
			
			// camera
			var mView:Matrix3D = viewMatrix(camRot, _radius, 0.5);
			_mat.identity();
			_mat.append(mView);	
			_mat.append(_projectionMatrix);
			
			// We get the position of the observer from the form of the matrix
			mView.invert();
			_position = mView.position;
		}
		
		private function viewMatrix(rot:Vector3D, dist:Number, centerY:Number):Matrix3D
		{
			var m:Matrix3D = new Matrix3D();
			m.appendTranslation(0, -centerY, 0);
			m.appendRotation(rot.z, new Vector3D(0, 0, 1));
			m.appendRotation(rot.y, new Vector3D(0, 1, 0));			
			m.appendRotation(rot.x, new Vector3D(1, 0, 0));
			m.appendTranslation(0, 0, dist);
			return m;
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
			return _position;
		}
		
		public function get projectionMatrix():PerspectiveMatrix3D 
		{
			return _projectionMatrix;
		}
	}
}
