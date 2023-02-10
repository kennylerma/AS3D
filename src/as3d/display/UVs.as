package as3d.display 
{
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class UVs 
	{
		private var _list:Vector.<Number>;
		
		public function UVs(uvs:Vector.<Number>) 
		{
			_list = uvs;
		}
		
		public function get list():Vector.<Number> 
		{
			return _list;
		}
		
		public function orderByIndexes(indexes:Vector.<Number>):void 
		{
			var newList:Vector.<Number> = new Vector.<Number>(_list.length);
			var pos:int = 0;
			for (var i:int = 0; i < indexes.length; i++) 
			{
				var index:int = indexes[i];
				newList[pos] = _list[index * 2];
				newList[pos + 1] = _list[(index * 2) + 1];
				
				pos += 2;
			}
			_list = newList;
		}
		
		public function reverse():void 
		{
			var numNormals:int = _list.length;
			var newList:Vector.<Number> = new Vector.<Number>(numNormals);
			
			for (var i:int = 1; i <= numNormals; i++) 
			{
				newList[i - 1] = _list[numNormals - 1 - i];
				newList[i] = _list[numNormals - i];
				i++;
			}
			_list = newList;
		}
		
	}

}