package as3d.display 
{
	/**
	 * Stores and modifies object3D normals
	 * @author Kenny Lerma
	 */
	public class Normals 
	{
		private var _list:Vector.<Number>
		
		public function Normals(normals:Vector.<Number>, stride:int, count:int, verticesTotal:int) 
		{
			_list = new Vector.<Number>();
			
			/*if ((stride * count) != verticesTotal)
			{
				for (var i:int = 0; i <= verticesTotal; i++) 
				{
					_list = _list.concat(normals);
					i += stride;
				}
			}
			else
			{*/
				_list = normals;
			//}
			
		}
		
		public function orderByIndexes(indexes:Vector.<Number>):void 
		{
			var newList:Vector.<Number> = new Vector.<Number>(_list.length);
			var pos:int = 0;
			for (var i:int = 0; i < indexes.length; i++) 
			{
				var index:int = indexes[i];
				newList[pos] = _list[index * 3];
				newList[pos + 1] = _list[(index * 3) + 1];
				newList[pos + 2] = _list[(index * 3) + 2];
				
				pos += 3;
			}
			_list = newList;
		}
		
		public function flipNormals():void 
		{
			var numNormals:int = _list.length;
			var newList:Vector.<Number> = new Vector.<Number>(numNormals);
			for (var i:int = 0; i < numNormals; i++) 
			{
				newList[i] = -_list[i];
			}
			
			_list = newList;
		}
		
		public function get list():Vector.<Number> 
		{
			return _list;
		}
		
	}

}