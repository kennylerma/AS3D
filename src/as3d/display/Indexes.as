package as3d.display 
{
	/**
	 * Holds the indexes that determine the order the vertices are drawn.
	 * @author Kenny Lerma
	 */
	public class Indexes 
	{
		private var _list:Vector.<uint>;
		
		public function Indexes(indexes:Vector.<uint>) 
		{
			_list = indexes;
		}
		
		/**
		 * list of indexes
		 */
		public function get list():Vector.<uint> 
		{
			return _list;
		}
		
		public function orderIncrementAscending():Vector.<uint> 
		{
			var numIndexes:int = _list.length;
			var newList:Vector.<uint> = new Vector.<uint>(numIndexes);
			for (var i:int = 0; i < numIndexes; i++) 
			{
				newList[i] = i;
			}
			_list = newList;
			return _list;
		}
		
		/**
		 * reverses the order of the indexes
		 */
		public function reverse():void 
		{
			_list.reverse();
		}
		
	}

}