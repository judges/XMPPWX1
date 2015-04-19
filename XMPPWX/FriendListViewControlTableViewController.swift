//
//  FriendListViewControlTableViewController.swift
//  XMPPWX
//
//  Created by Liuzhao on 15/4/11.
//  Copyright (c) 2015年 Liuzhao. All rights reserved.
//

import UIKit

class FriendListViewControlTableViewController: UITableViewController , MessageDL , StateDL {
    @IBOutlet weak var myState: UIBarButtonItem!
    
    //未读消息数组声明
    var unreadMsgList = [Message]()
    //好友状态数组声明
    var stateList = [State]()
    //登陆标志
    var logged = false
    //当前聊天对象
    var currenFriendName = ""
    
    //根据当前在线状态调整图片，并进行上下线操作
    @IBAction func logStateChangAction(sender: UIBarButtonItem) {
        if logged {
            //下线
            logoff()
            //更改图片
            sender.image = UIImage(named: "off")
        }else{
            //上线
            login()
            //更改图片
            sender.image = UIImage(named: "on")
        }

    }
    
    func allDL() -> AppDelegate{
        return UIApplication.sharedApplication().delegate as! AppDelegate
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
    
    //以下为三个状态的处理
    //自己离线
    func meOff() {
        logoff()
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
        if !isFind{
            stateList.append(state)
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
        
        //图片改为上线状态
        myState.image = UIImage(named:"on")
        
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
        //图片改为下线状态
        myState.image = UIImage(named:"off")
        
        logged = false
        
        //更新表格数据
        self.tableView.reloadData()
    }
    
    
    override func viewDidLoad() {//只会加载一次
        super.viewDidLoad()
        
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
        //allDL().messageDL = self
        //接管状态代理
        allDL().stateDL = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        allDL().messageDL = self
    }
    /*
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
        allDL().massageDL = self
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
        if isOnLine == true  {
            cell.imageView?.image = UIImage(named: "on")
        }else{
            cell.imageView?.image = UIImage(named: "off")
        }
        
        //好友的名称，并设置未读条数
        let name = stateList[indexPath.row].name
        var unreadCount = 0
        for msg in unreadMsgList{
            if(name == msg.from){
                unreadCount++
            }
        }
        
        //单元格文本 liuz@localhost(5)
        cell.textLabel?.text = name + "(\(unreadCount))"

        return cell
    }
    //点击单元格后跳转
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //保存好友用户名
        currenFriendName = stateList[indexPath.row].name
        //跳转到聊天界面
        self.performSegueWithIdentifier("toChatSegue", sender: self)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //判断跳转到聊天
        if segue.identifier == "toChatSegue"{
            //获取聊天控制器
            let chatTableViewController = segue.destinationViewController as! ChatTableViewController
            //取得当前选择的聊天好友
            chatTableViewController.toFriendName = currenFriendName
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
