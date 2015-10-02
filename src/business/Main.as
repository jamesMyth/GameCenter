package business
{
	/**
	 * 逻辑主类
	 * 2015/9/14
	 * James
	 */
	import mx.core.FlexGlobals;
	import mx.events.ModuleEvent;
	
	import spark.modules.ModuleLoader;
	
	import assets.ImageLoader;
	
	import model.EventModel;
	
	public class Main
	{
		
		[Bindable]
		public var IL:ImageLoader;
		private var bytesLoadedObj:Object;
		private var bytesTotalObj:Object;
		private var loadedLength:int;
		private var userLogin:UserLogin;
		private var gameID:int;
		private var tool:Tools =  new Tools;
		
		/**
		 * 初始化
		 */
		public function Main()
		{
			bytesLoadedObj = new Object();   //实例化模块大小对象
			bytesTotalObj = new Object();
			
			loadedLength = 0;                   //已加载模块数量
			gameID = 2;                            //游戏ID  斗地主
			
			if(EventModel.dis.hasEventListener(EventModel.GAMESOCKETDATA) == false){
				EventModel.dis.addEventListener(EventModel.GAMESOCKETDATA,socketDataEvent);
			}
		}
		
		/**
		 * 初始化素材类
		 */
		public function init(urlName:String):void
		{
			FlexGlobals.topLevelApplication.pageView.selectedIndex = 0;
			FlexGlobals.topLevelApplication.HeadModule.unloadModule();
			FlexGlobals.topLevelApplication.FootModule.unloadModule();
			
			IL = new ImageLoader(urlName);
			tool.updateLoadMsg("加载UI素材中..");
		}
		
		/**
		 * 素材加载器完成
		 */
		public function ImageLoadDone(assObj:Object):void
		{
			FlexGlobals.topLevelApplication.assetsObject = assObj;
			switch(gameID){
				case 2: //加载斗地主游戏
					FlexGlobals.topLevelApplication.HeadModule.loadModule("view/ddz/GameHead.swf");
					FlexGlobals.topLevelApplication.FootModule.loadModule("view/ddz/GameFoot.swf");
				break;
			}
		}
		
		/**
		 * 模块加载进度
		 */
		public function Module_readyHandler(event:ModuleEvent):void
		{
			var loadID:String = (event.currentTarget as ModuleLoader).id;
			tool.updateLoadMsg(loadID + "模块加载完成！" + event.bytesTotal + "字节");
			
			loadedLength ++;
			trace(loadID + "模块加载完成！" + event.bytesTotal + "字节" + "*" + loadedLength);
			if(loadedLength == 2){
				initSocket();
				tool.updateLoadMsg("正在连接游戏服务器...");
				loadedLength = 0;
			}
		}
		
		/**
		 * 初始化用户授权类 
		 */
		private function initSocket():void
		{
			userLogin = new UserLogin();
		}
			
		/**
		 * 模块加载完成
		 */
		public function Module_progressHandler(event:ModuleEvent):void
		{
			var Mid:String = (event.currentTarget as ModuleLoader).id;
			bytesLoadedObj[Mid] = event.bytesLoaded;
			bytesTotalObj[Mid] = event.bytesTotal;
			
			var bytesLoaded:Number = Math.ceil((bytesLoadedObj.HeadModule  + bytesLoadedObj.FootModule)/1024);
			var bytesTotal:Number = Math.ceil((bytesTotalObj.HeadModule + bytesTotalObj.FootModule)/1024);
			tool.updateLoadMsg("加载模块中.." + bytesLoaded + "Kb / " + bytesTotal + "Kb");
		}
		
		/**
		 * Socket链接数据返回
		 */
		private function socketDataEvent(event:EventModel):void
		{
			var dataReust:Object = new Object();
			dataReust = event.data;
			switch(dataReust.protocol)
			{
				case "32899972": 	//日排行榜信息
					trace("获取到"+ (dataReust.ranking as Array).length + "条排行榜信息！");
				break;
				case "32834436": //周排行榜信息
				break;
				case "32768900": //房间信息
				break;
				default:
				{
					//默认事件
					break;
				}
			}
		}
		
		
	}
}