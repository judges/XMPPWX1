//
//  FriendListViewControlTableViewController.swift
//  XMPPWX
//
//  Created by Liuzhao on 15/4/11.
//  Copyright (c) 2015年 Liuzhao. All rights reserved.
//

import UIKit

class FriendListViewControlTableViewController: UITableViewController , MessageDL , StateDL ,SideMenuDelegate{
    
    @IBOutlet weak var sideBarItem: UIBarButtonItem!
    //未读消息数组声明
    var unreadMsgList = [Message]()
    //好友状态数组声明
    var stateList = [State]()
    //登陆标志
    var logged = false
    //当前聊天对象
    var currenFriendName = ""
    var currenNick = ""
    
    
    var sideMenu:SideMenu?
    func sideMenuDidSelectItemAtIndex(index: Int) {
        sideMenu?.toggleMenu()
        //添加好友
        if index == 1{
            self.performSegueWithIdentifier("toSearchSegue", sender: self)
        }else if index == 2{
            /*<iq from='hag66@shakespeare.lit/pda'
            id='disco2'
            to='ejabberd.liuzhao.com'
            type='get'>
            <query xmlns='http://jabber.org/protocol/disco#items'/>
            </iq>*/
            var iq = DDXMLElement.elementWithName("iq") as! DDXMLElement
            iq.addAttributeWithName("id", stringValue: allDL().xs!.generateUUID())
            iq.addAttributeWithName("from", stringValue: allDL().xs!.myJID.description)
            iq.addAttributeWithName("type", stringValue: "get")
            iq.addAttributeWithName("to", stringValue: "conference.ejabberd.liuzhao.com")
            
            var query = DDXMLElement.elementWithName("query") as! DDXMLElement
            query.addAttributeWithName("xmlns", stringValue: "http://jabber.org/protocol/disco#items")
            iq.addChild(query)
            //请求聊天室名单
            allDL().xs!.sendElement(iq)
            println()
            println(iq)
            self.performSegueWithIdentifier("toRoomsSegue", sender: self)
        }
    }
    
    @IBAction func toggleSideMenu(sender: AnyObject) {
        sideMenu?.toggleMenu()
    }
    
    var ad:AppDelegate?
    
    func allDL() -> AppDelegate{
        if ad == nil{
            ad = UIApplication.sharedApplication().delegate as? AppDelegate
        }
        return ad!
    }

    
    //收到离线或者未读消息
    func newMsg(aMsg: Message) {
        //如果消息有正文，加入未读消息组，并刷新
        if aMsg.body != "" {
            //加入
            unreadMsgList.append(aMsg)
            //刷新
            self.tableView.reloadData()
        }
    }

    var friends = [State]()
    //以下为四个状态的处理
    //init
    func initStates(items: [DDXMLElement]) {
        func set(str:String)->SubscribeType{
            switch str{
            case "none":
                return .none
            case "both":
                return .both
            case "from":
                return .from
            case "to":
                return .to
            default:
                return .none
            }
        }
        friends.removeAll(keepCapacity: false)
        //设置整体friends 和 stateList(将要显示的)
        for item in items{
            let jid = item.attributeStringValueForName("jid")
            let subt = item.attributeStringValueForName("subscription")
            var judge = true
            let count = stateList.count
            for var i = 0 ; i < count ; i++ {
                if stateList[i].name == jid{//有了就不加stateList，但是订阅类型得更新
                    judge = false
                    stateList[i].subscribeType = set(subt)
                    break
                }
            }
            var state_t = State()
            state_t.isOnline = false
            state_t.name = jid
            state_t.subscribeType = set(subt)
            //不管什么类型都加到friends中
            friends.append(state_t)
            //只显示我订阅的，和互相订阅的
            if(judge && state_t.subscribeType != .none && state_t.subscribeType != .from){
                stateList.append(state_t)
            }
        }
        self.tableView.reloadData()
    }
    //自己离线
    func meOff() {
        logoff()
    }
    //有人发来请求
    func isSubscribe(inout state: State) {
        //
        var isFind = false
        for (index ,oldState) in enumerate(friends) {
            if (state.name == oldState.name) {
                isFind = true
                //找到就更新订阅状态
                if friends[index].subscribeType == .to{
                    friends[index].subscribeType = .both
                }else{
                    friends[index].subscribeType = .from
                }
                //找到就退出
                break
            }
        }
        if !isFind{
            friends.append(state)
        }
    }
    //有人同意我的请求
    func isSubscribed(inout state: State) {
        //是否已经在朋友列表中了，但肯定不在状态列表中，因为之前没有或者是.none和.from
        var isFind = false
        for (index ,oldState) in enumerate(friends) {
            if (state.name == oldState.name) {
                isFind = true
                //找到就更新订阅状态
                if friends[index].subscribeType == .from{
                    friends[index].subscribeType = .both
                }else{//以前是none
                    friends[index].subscribeType = .to
                }
                //找到就退出
                break
            }
        }
        if !isFind{//根本就没有
            state.subscribeType = .to
            friends.append(state)
        }
        //同意我的请求，以前的状态可能是.none .from 都不会之前添加到要显示的列表
        stateList.append(state)
    }
    
    //上线状态处理
    func isOn(state: State) {
        //逐条查找旧的用户状态
        var isFind = false
        for (index ,oldState) in enumerate(stateList) {
            if (state.name == oldState.name) {
                isFind = true
                //找到就更新为上线
                stateList[index].isOnline = true
                //找到就退出
                break
            }
        }
        //添加新状态
        if !isFind{
            stateList.append(state)
        }
        //刷新
        self.tableView.reloadData()
    }
    //下线状态处理
    func isOff(state: State) {
        //逐条查找旧的用户状态
        var isFind = false
        for (index ,oldState) in enumerate(stateList) {
            if (state.name == oldState.name) {
                //找到就更新为离线
                isFind = true
                stateList[index].isOnline = false
                //找到就退出
                break
            }
        }
        //刷新
        self.tableView.reloadData()
    }
    
    //登陆
    func login(){
        if logged == true {
            return
        }
        //清空数组
        unreadMsgList.removeAll(keepCapacity: false)
        stateList.removeAll(keepCapacity: false)
    
        //连接调用xmpp的通信
        allDL().connect()
        logged = true
        
        //取用户名，并更新title
        var myName = NSUserDefaults.standardUserDefaults().stringForKey("wxID")
        self.title = myName! + "的好友"
        
        //更新表格数据
        self.tableView.reloadData()
    }
    
    //登出
    func logoff(){
        if logged == false {
            return
        }
        
        //清空数组
        unreadMsgList.removeAll(keepCapacity: false)
        stateList.removeAll(keepCapacity: false)
        
        allDL().disConnect()
        logged = false
        
        //更新表格数据
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {//只会加载一次
        super.viewDidLoad()
        sideMenu = SideMenu(sourceView: self.view, menuData: ["好友列表", "查找好友", "聊天室","其他功能2","其他功能3"])
        sideMenu!.delegate = self
        //取用户名
        let myID = NSUserDefaults.standardUserDefaults().stringForKey("wxID")
        //取自动登录
        let autoLogin = NSUserDefaults.standardUserDefaults().boolForKey("wxAutoLogin")
        //如果取到用户名或者自动登录，开始登陆
        if ( myID != nil && autoLogin ){
            self.login()
        }else{
            //跳转登陆视图
            self.performSegueWithIdentifier("toLoginSegue", sender: self)
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        //接管消息代理
        allDL().messageDL = self
        //接管状态代理
        allDL().stateDL = self
    }
    
    /*
    //不是每次出现就检测
    override func viewDidAppear(animated: Bool) {//每次出现执行一次
        //取用户名
        let myID = NSUserDefaults.standardUserDefaults().stringForKey("wxID")
        //取自动登录
        let autoLogin = NSUserDefaults.standardUserDefaults().boolForKey("wxAutoLogin")
        //如果取到用户名或者自动登录，开始登陆
        if ( myID != nil && autoLogin ){
            self.login()
            
        }else{
            //跳转登陆视图
            self.performSegueWithIdentifier("toLoginSegue", sender: self)
        }
        //接管消息代理
        allDL().messageDL = self
        //接管状态代理
        allDL().stateDL = self
    }
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    //表格组数
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //组内有多少行
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stateList.count
    }
    
    //单元格内容
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendListCell", forIndexPath: indexPath) as! UITableViewCell
        //好友的状态，并切换图像
        let isOnLine = stateList[indexPath.row].isOnline
        let isGroup = stateList[indexPath.row].isGroup
        if isGroup == true{
            cell.textLabel?.textColor = UIColor.blueColor()
        }else{
            if isOnLine == true  {
                cell.imageView?.image = UIImage(named: "on")
            }else{
                cell.imageView?.image = UIImage(named: "off")
            }
        }
        
        //好友的名称，并设置未读条数
        let name = stateList[indexPath.row].name
        let nick = stateList[indexPath.row].nick
        var unreadCount = 0
        for msg in unreadMsgList{
            if(name == msg.from){
                unreadCount++
            }
        }
        //单元格文本 liuz@localhost(5)
        cell.textLabel?.text = "[\(unreadCount)] " + name
        
        return cell
    }
    //点击单元格后跳转
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //保存好友用户名
        currenFriendName = stateList[indexPath.row].name
        currenNick = stateList[indexPath.row].nick
        //跳转到聊天界面
        self.performSegueWithIdentifier("toChatSegue", sender: self)
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            currenFriendName = stateList[indexPath.row].name
            deleteFriend(currenFriendName)
            //在要展示的列表中删除
            for (index1 ,oldState) in enumerate(stateList) {
                if (currenFriendName == oldState.name){
                    //找到就删除
                    stateList.removeAtIndex(index1)
                    //找到就退出
                    break
                }
            }
            //在好友列表中删除
            for (index2 ,oldState) in enumerate(friends) {
                if (currenFriendName == oldState.name) {
                    //找到就删除
                    friends.removeAtIndex(index2)
                    //找到就退出
                    break
                }
            }

            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    func deleteFriend(jidName:String){
        if jidName.hasSuffix("conference@ejabberd.liuzhao.com"){
            //退出一个聊天室
            /*
            <presence
            from='hag66@shakespeare.lit/pda'
            to='darkcave@chat.shakespeare.lit/thirdwitch'
            type='unavailable'/>
            */
            var presence = DDXMLElement.elementWithName("presence") as! DDXMLElement
            presence.addAttributeWithName("from", stringValue: allDL().xs!.myJID.description)
            presence.addAttributeWithName("to", stringValue: jidName)
            presence.addAttributeWithName("type", stringValue: "unavailable")
            allDL().xs!.sendElement(presence)
        }else{
            //删除一个好友
            var iq = DDXMLElement.elementWithName("iq") as! DDXMLElement
            iq.addAttributeWithName("from", stringValue: allDL().xs!.myJID.description)
            iq.addAttributeWithName("type", stringValue: "set")

            var query = DDXMLElement.elementWithName("query") as! DDXMLElement
            query.addAttributeWithName("xmlns", stringValue: "jabber:iq:roster")
            iq.addChild(query)
            var item = DDXMLElement.elementWithName("item") as! DDXMLElement
            item.addAttributeWithName("jid", stringValue:jidName)
            item.addAttributeWithName("subscription", stringValue:"remove")
            query.addChild(item)
            allDL().xs!.sendElement(iq)
            //同样可以
            //取消已经允许的来历别人的订阅请求<presence to='romeo@example.net' type='unsubscribed'/>
            //取消已经订阅的发给别人的订阅请求<presence to='juliet@example.com' type='unsubscribe'/>
        }
    }
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return "删除"
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return false
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //判断跳转到聊天
        if segue.identifier == "toChatSegue"{
            //获取聊天控制器
            let chatTableViewController = segue.destinationViewController as! ChatTableViewController
            //取得当前选择的聊天好友
            chatTableViewController.toFriendName = currenFriendName
            chatTableViewController.nick = currenNick
            //将消息传递到聊天界面
            for aMsg in unreadMsgList{
                if aMsg.from == currenFriendName{
                    chatTableViewController.msgList.append(aMsg)
                }
            }
            //将相应的未读消息移除，并刷新表格
            removeFromArray(currenFriendName, &unreadMsgList)
            self.tableView.reloadData()
        }else if segue.identifier == "toLoginSegue"{
            logoff()
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "wxAutoLogin")
        }
    }
    
    @IBAction func unwindToBList(segue: UIStoryboardSegue){
        //如果点击完成按钮，开始登陆
        let source = segue.sourceViewController as! LoginViewController
        
        if(source.isRequireLogin){
            //先注销之前用户后登陆
            self.logoff()
            self.login()
        }
    }
}
