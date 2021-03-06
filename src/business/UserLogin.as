package business
{
	import mx.core.FlexGlobals;
	
	import events.MainEvent;
	import events.UserEvent;
	
	import model.EventModel;
	import model.UserInfo;
	
	import vo.LoginConst;

	/**
	 * 用户登录授权类
	 * 2015/7/22
	 * James
	 */
	public class UserLogin
	{
		private var userInfo:UserInfo;
		private var userEvent:UserEvent;
		private var mainEvent:MainEvent;
		private var tool:Tools;
		private var main:Main;
		
		public function UserLogin():void
		{
			main = new Main();
			mainEvent = new MainEvent();
			userEvent = new UserEvent();
			tool = new Tools();
			
			EventModel.dis.addEventListener(EventModel.USERSOCKETDATA,socketDataEvent);
			
			init();
		}
		
		/**
		 * 确认登录授权
		 */
		public function init():void
		{
			var userObj:Object = new Object();
			
			userObj = tool.getInfo();
			if(userObj != null){
				tool.updateLoadMsg("正在解析数据包，请稍后...");
				userSuccessful(userObj.data);
			}
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
				case LoginConst.LOGINSUSSFUL:
				{
					trace("成功连接游戏线路");
					main.init("assetsList.xml?v1.0");
					break;
				}
				case LoginConst.USERINFO: //用户信息
				{
					trace("成功获取登录用户信息");
					userInfo.USERID = dataReust.userid;
					userInfo.PROTOCOL = dataReust.protocol;
					userInfo.USERNAME = dataReust.data[0].name;
					userInfo.USERAWAYS = dataReust.data[0].aways;
					userInfo.USERFAILEDS = dataReust.data[0].faileds;
					userInfo.USERWONS = dataReust.data[0].wons;
					userInfo.USERMONEY = dataReust.data[0].points;
					userInfo.USERRATE = dataReust.data[0].rate;
					(FlexGlobals.topLevelApplication.HeadModule.child).setUserParam(userInfo);
					FlexGlobals.topLevelApplication.myInfo = userInfo;
					FlexGlobals.topLevelApplication.pageView.selectedIndex = 1;
				}
				default:
				{
					//默认事件
					break;
				}
			}
		}
		
		
		/**
		 * 用户授权成功连接
		 */
		public function userSuccessful(user:Object):void
		{
			userInfo = new UserInfo();
			userInfo.USERID = user.userid;
			userInfo.USERPORT = user.port;
			userInfo.USERIP = user.sip;
			userInfo.USERKEY = user.userkey;
			
			mainEvent.closeSocket();
			mainEvent.initSocket(userInfo.USERIP,userInfo.USERPORT);
		}
		
		/**
		 * 初次登陆用户信息
		 */
		public function getUserInfo():void
		{
			userInfo.PROTOCOL = LoginConst.SENDUSERINFO;
			userEvent.userLoginEvent(userInfo);
		}
	}
}