package as3d.display 
{
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class Vertexes 
	{
		private var _list:Vector.<Number>;
		
		public function Vertexes(vertexes:Vector.<Number>) 
		{
			_list = vertexes;
		}
		
		public function swapYandZ():void 
		{
			var newVerts:Vector.<Number> = new Vector.<Number>(_list.length);
			var numVerts:int = _list.length;
			for (var i:int = 0; i < numVerts; i++) 
			{
				newVerts[i] = _list[i];
				newVerts[i + 1] = _list[i + 2] * -1;
				newVerts[i + 2] = _list[i + 1];
				i += 2;
			}
			
			_list = newVerts;
		}
		
		public function swapXandY():void 
		{
			var newVerts:Vector.<Number> = new Vector.<Number>(_list.length);
			var numVerts:int = _list.length;
			for (var i:int = 0; i < numVerts; i++) 
			{
				newVerts[i] = _list[i + 1];
				newVerts[i + 1] = _list[i];
				newVerts[i + 2] = _list[i + 2];
				i += 2;
			}
			
			_list = newVerts;
		}
		
		public function swapXandZ():void 
		{
			var newVerts:Vector.<Number> = new Vector.<Number>(_list.length);
			var numVerts:int = _list.length;
			for (var i:int = 0; i < numVerts; i++) 
			{
				newVerts[i] = _list[i + 2];
				newVerts[i + 1] = _list[i + 1];
				newVerts[i + 2] = _list[i];
				i += 2;
			}
			
			_list = newVerts;
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
		
		/**
		 * list of vertexes
		 */
		public function get list():Vector.<Number> 
		{
			return _list;
		}
	}

}