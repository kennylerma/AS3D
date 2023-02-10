package as3d.loaders 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.net.URLVariables;

 /*
  * @author Kenny Lerma
  * @since 1.1.2011
  * @langversion 3.0
  * @playerversion Flash 10.1
  */
 	public class ImageLoader extends EventDispatcher
 	{
		private var _imgStrArr:Vector.<String>;
		private var _imgArr:Array;
		private var _percentArr:Array = [];
		private var _loadedCount:int = 0;
		private var _info:Object = new Object();
		
		public function ImageLoader() 
		{
			
  		}
		
		public function loadImages(paths:Vector.<String>, ids:Vector.<String> = null):void 
		{
			_imgStrArr = paths;
			_percentArr.length = paths.length;
			_imgArr = [];
			_imgArr.length = paths.length;
			
			for (var i:int = 0; i < _imgStrArr.length; i++)
			{
				var l:LoaderBase = new LoaderBase();
				l.info.id = (ids) ? ids[i] : i;
				l.contentLoaderInfo.addEventListener(Event.COMPLETE, HandleComplete);
				l.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, HandleProgress);
				l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
				var url:URLRequest = new URLRequest(_imgStrArr[i]);
				var vars:URLVariables = new URLVariables();
				vars.cache = new Date().getTime();
				url.data = vars;
				l.load(new URLRequest(_imgStrArr[i]));
			}
		}
		
		private function onError(e:IOErrorEvent):void 
		{
			dispatchEvent(e);
		}
		
		private function HandleProgress(event:ProgressEvent):void 
		{
			var percent:Number = event.bytesLoaded / event.bytesTotal;
			_percentArr[event.target.loader.info.id] = percent;
			
			var percentTotal:Number = 0;
			for each (var p:Number in _percentArr) 
			{
				percentTotal += p;
			}
			
			percentTotal = percentTotal / _percentArr.length;
			//trace("PercentTotal: " + percentTotal);
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, percentTotal, 1));
		}
		
		private function HandleComplete(event:Event):void 
		{
			_loadedCount++;
			_imgArr[event.target.loader.info.id] = event.target.content;
			if (_loadedCount == _imgStrArr.length) dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function get loadedImages():Array
		{
			return _imgArr;
		}
		
		public function get info():Object
		{
			return _info;
		}
 	}

}


import flash.display.Loader;

internal class LoaderBase extends Loader
{
	public var info:Object = new Object();
	
	public function LoaderBase() {}
}