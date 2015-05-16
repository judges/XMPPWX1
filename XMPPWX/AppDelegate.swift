//
//  AppDelegate.swift
//  XMPPWX
//
//  Created by Liuzhao on 15/4/11.
//  Copyright (c) 2015年 Liuzhao. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, XMPPStreamDelegate,UIAlertViewDelegate, XMPPRosterDelegate{
    var window: UIWindow?

    //var oi:integer_t?
    //var router = XMPPRouter(xs?)
    //xmpp通道
    var xs:XMPPStream?
    //服务器是否开启，默认false
    var isOpen = false
    //状态代理
    var stateDL:StateDL?
    
    //消息代理
    var messageDL:MessageDL?
    
    //查询代理
    var searchDL:SearchDL?
    
    //房间代理
    var roomsDL:RoomsDL?

    func xmppStream(sender: XMPPStream!, didReceiveP2PFeatures streamFeatures: DDXMLElement!) {
    //
        println("000000000000000")
        println(streamFeatures)
    }

    func xmppStream(sender: XMPPStream!, didSendIQ iq: XMPPIQ!) {
        println(iq)
        println("上边是我发送的iq")
    }
    
    func xmppStream(sender: XMPPStream!, didSendPresence presence: XMPPPresence!) {
        println(presence)
        println("上边是我发送的presence")
    }
    func xmppStream(sender: XMPPStream!, didFailToSendMessage message: XMPPMessage!, error: NSError!) {
        println(error)
        println("上边是我发送失败的message")
    }

    func xmppStream(sender: XMPPStream!, didFailToSendIQ iq: XMPPIQ!, error: NSError!) {
        //ok
        println(error)
        println("上边是我发送失败的iq")
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        //
        var buttontitle = alertView.buttonTitleAtIndex(buttonIndex)
        if alertView.title == "好友申请"{
            println(buttonIndex)
            //if 0 表示同意 1 同意并订阅 2 不同意 3 取消
            if buttontitle == "同意"{
                //   <presence to='romeo@example.net' type='subscribed'/>
                var presence = DDXMLElement.elementWithName("presence") as! DDXMLElement
                presence.addAttributeWithName("to", stringValue: state!.name)
                presence.addAttributeWithName("type", stringValue: "subscribed")
                xs!.sendElement(presence)
                stateDL?.isSubscribe(&state!)
            }else if buttontitle == "同意并订阅" {
                //同意
                var presence0 = DDXMLElement.elementWithName("presence") as! DDXMLElement
                presence0.addAttributeWithName("to", stringValue: state!.name)
                presence0.addAttributeWithName("type", stringValue: "subscribed")
                xs!.sendElement(presence0)
                //请求定义<presence xmlns="jabber:client" from="liuz@ejabberd.liuzhao.com" to="fangzy@ejabberd.liuzhao.com/ios" type="subscribe"/>
                var presence = DDXMLElement.elementWithName("presence") as! DDXMLElement
                presence.addAttributeWithName("xmlns", stringValue: "jabber:client")
                presence.addAttributeWithName("from", stringValue: xs!.myJID.description)
                presence.addAttributeWithName("to", stringValue: state!.name)
                presence.addAttributeWithName("type", stringValue: "subscribe")
                xs!.sendElement(presence)
                stateDL?.isSubscribe(&state!)
            }else if buttontitle == "不同意" {
                //<presence to='user@example.com' type='unsubscribed'/>
                var presence = DDXMLElement.elementWithName("presence") as! DDXMLElement
                presence.addAttributeWithName("to", stringValue: state!.name)
                presence.addAttributeWithName("type", stringValue: "unsubscribed")
                xs!.sendElement(presence)
            }
        }
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveIQ iq: XMPPIQ!) -> Bool {
        println(iq)
        println("上边是我收到的iq")
        if iq.type() == "result" && iq.childCount() != 0{
            var query = iq.childElement() as DDXMLElement
            if query.name() == "query" {
                if query.xmlns() == "jabber:iq:roster" {
                    //好友列表
                    var friend1 = query.children() as! [DDXMLElement]
                    stateDL?.initStates(friend1)
                    return true
                }else if query.xmlns() == "jabber:iq:search" {
                    //查询用户列表
                    var friend2 = query.children() as! [DDXMLElement]
                    searchDL?.initSearchList(friend2)
                    return true
                }else if query.xmlns() == "http://jabber.org/protocol/disco#items"{
                    //聊天室列表
                    var rooms = query.children() as! [DDXMLElement]
                    roomsDL?.initRooms(rooms)
                    return true
                }
            }
        }else if iq.type() == "get" && iq.childCount() > 0{
            var query = iq.childElement() as DDXMLElement
            if query.name() == "query" {
                if query.xmlns() == "http://jabber.org/protocol/disco#info"{
                    println("收到了查询http://jabber.org/protocol/disco#info的iq")
                }
            }
        }
        /*else if iq.type() == "set" && iq.childCount() != 0{
            var query = iq.childElement() as DDXMLElement
            if query.name() == "query" {
                if query.xmlns() == "jabber:iq:roster" {
                    var friend1 = query.children() as! [DDXMLElement]
                    stateDL?.initStates(friend1)
                    return true
                }
            }
        }*/
        return false
    }
    
    //收到消息
    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {
        
        //如何知道，可以通过官方文档
        println(message)
        println("上边是我收到message")

        //如果是聊天文本消息
        if(message.isChatMessage()){
            var msg = Message()
            
            //对方正在输入
            if(message.elementsForName("composing") != nil){
                msg.isComposing = true
            }
            
            if(message.elementsForName("paused") != nil){
                msg.isComposing = false
            }
            
            //离线消息
            if(message.elementsForName("delay") != nil){
                msg.isDelay = true
            }
            
            //消息正文
            if let body = message.elementForName("body"){
                msg.body =  body.stringValue()
            }
            
            //完整用户名
            msg.from = message.from().user + "@" + message.from().domain

            msg.nick = message.from().user
            //添加到代理中
            messageDL?.newMsg(msg)
        }else if(message.type() == "groupchat"){
            //其他信息
            var msg = Message()
            msg.isGroup = true

            if let body = message.elementForName("body"){
                msg.body =  body.stringValue()
            }
            
            if(message.elementsForName("delay") != nil){
                msg.isDelay = true
            }
            
            msg.from = message.from().user + "@" + message.from().domain

            msg.nick = message.fromStr().lastPathComponent
            
            messageDL?.newMsg(msg)
        }

    }
    var state:State?
    var t:String?
    //收到状态
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
        println(presence)
        println("上边是我收到的presence")
        
        //我自己的用户名
        let myUser = sender.myJID.user

        //好友的状态
        let user = presence.from().user
        
        //用户所在的域
        let domain = presence.from().domain
        
        //状态类型
        let pType = presence.type()
        
        //如果是群聊的状态
        if domain.hasPrefix("conference"){
            //收到某人退群的消息
            /*<presence xmlns="jabber:client" from="gggaaa@conference.ejabberd.liuzhao.com/liuz" to="fangzy@ejabberd.liuzhao.com/ios" type="unavailable"><priority>0</priority><x xmlns="http://jabber.org/protocol/muc#user"><item affiliation="none" role="none"/></x></presence>*/
            if presence.type() != nil && presence.type() == "unavailable"{
                var amsg = Message()
                amsg.nick = "通知："+presence.fromStr().lastPathComponent
                amsg.isGroup = true
                amsg.from = user + "@" + domain
                amsg.body = "退出了群聊"
                messageDL?.newMsg(amsg)
            }else{
                
                state = State()
                state!.name = user + "@" + domain
                state!.isGroup = true
                state!.nick = t!
                stateDL?.isOn(state!)
                
                var amsg = Message()
                amsg.nick = "通知："+presence.fromStr().lastPathComponent
                amsg.isGroup = true
                amsg.from = user + "@" + domain
                amsg.body = "加入了群聊"
                messageDL?.newMsg(amsg)
            }
        }
        //如果状态不是自己的
        else if(user != myUser){
            //状态保存的结构
            state = State()
            //取得并保存状态的完整用户名
            state!.name = user + "@" + domain
            //上线
            if pType == "available"{
                state!.isOnline = true
                stateDL?.isOn(state!)
            }else if pType == "unavailable"{
                state!.isOnline = false
                stateDL?.isOff(state!)
            }else if pType == "subscribe"{
                var alert = UIAlertView()
                alert.title = "好友申请"
                alert.delegate = self
                alert.message = state!.name + "申请订阅您的信息"
                alert.addButtonWithTitle("同意")
                alert.addButtonWithTitle("同意并订阅")
                alert.addButtonWithTitle("不同意")
                alert.addButtonWithTitle("取消")
                alert.show()
                stateDL?.isSubscribe(&state!)
            }else if pType == "subscribed"{
                var alert = UIAlertView()
                alert.message = user+"同意了您的订阅"
                alert.addButtonWithTitle("好的")
                alert.show()
                stateDL?.isSubscribed(&state!)
                //请求disco#infor 但是iMessage回应503
                /*var iq = DDXMLElement.elementWithName("iq") as! DDXMLElement
                iq.addAttributeWithName("xmlns", stringValue: "jabber:client")
                iq.addAttributeWithName("from", stringValue: xs!.myJID.description)
                iq.addAttributeWithName("to", stringValue: state!.name)
                iq.addAttributeWithName("id", stringValue:xs!.generateUUID())
                iq.addAttributeWithName("type", stringValue: "get")
                
                var query = DDXMLElement.elementWithName("query") as! DDXMLElement
                query.addAttributeWithName("xmlns", stringValue: "http://jabber.org/protocol/disco#infor")
                
                iq.addChild(query)
                xs!.sendElement(iq)
                println(iq)*/
            }else if pType == "unsubscribed"{
                var alert = UIAlertView()
                alert.message = user+"关闭了您的订阅"
                alert.addButtonWithTitle("好的")
                alert.show()
            }else{
                println("ptype="+pType)
            }
        }
        
    }
    
    var user:String?
    var passwd:String?
    var server:String?
    var isReg = false
    func registerUser(){
        //注册用户
        //设置注册状态
        isReg = true
        connect()
    }
    func xmppStreamDidRegister(sender: XMPPStream!) {
        //注册成功
        var alert = UIAlertView()
        alert.message = "success to register"
        alert.addButtonWithTitle("ok")
        alert.show()
    }
    
    func xmppStream(sender: XMPPStream!, didNotRegister error: DDXMLElement!) {
        //注册不成功
        var alert = UIAlertView()
        println(error)
        var err = error.elementForName("error")
        if err.attributeForName("code").stringValue() == "403"{
            alert.message = "forbidden 403"
        }else if err.attributeForName("code").stringValue() == "500"{
            alert.message = err.elementForName("text").stringValue()
        }else if err.attributeForName("code").stringValue() == "409"{
            alert.message = "用户名已经注册"
        }
        alert.addButtonWithTitle("ok")
        alert.show()
    }
    
    //连接成功
    func xmppStreamDidConnect(sender: XMPPStream!) {
        isOpen = true
        //验证密码
        println("++++++++++")
        var error:NSError?
        if(!isReg){
            xs!.authenticateWithPassword(passwd, error: &error)
        }else//要注册，就不会通过验证，就注册
            if(xs!.supportsInBandRegistration() && user != nil && passwd != nil){
                var error:NSError?
                xs!.registerWithPassword(passwd, error: &error)
                println("--------------------")
                println(error)
                isReg = false
                return
        }
        println(error)
    }
    
    //验证成功
    func xmppStreamDidAuthenticate(sender: XMPPStream!) {
        //上线
        let autologin = NSUserDefaults.standardUserDefaults().boolForKey("wxAutoLogin")
        if autologin == true{
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "wxAutoLogin")
        }
        println("ssssssssss")
        goOnline()
        //用于使用xmppRoster之后关联xmppStream
        xmppRoster?.activate(xs!)
    }
    
    func xmppStream(sender:XMPPStream!, didNotAuthenticate error:DDXMLElement!){
        println("ffffffffffff")
        println(error)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "wxAutoLogin")
    }

    func xmppRosterDidEndPopulating(sender:XMPPRoster){
        var count = sender.accessibilityElementCount()
        println("xmppRosterDidEndPopulating")
//        for var i = 0 ; i < count ; i++ {
//            var obj = sender.accessibilityElementAtIndex(i)
//        }
    }
    func xmppRosterDidBeginPopulating(sender: XMPPRoster!) {
        //
        println("xmppRosterDidBeginPopulating")
    }
    
    var xmppRosterDataStorage:XMPPRosterCoreDataStorage?
    var xmppRoster:XMPPRoster?
    //建立通道
    func buildStream(){
        xs = XMPPStream()
        xs?.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        //以下是后来使用xmpproster添加的初始化
        xmppRosterDataStorage = XMPPRosterCoreDataStorage.sharedInstance()
        xmppRoster = XMPPRoster(rosterStorage: xmppRosterDataStorage, dispatchQueue: dispatch_get_main_queue())
        xmppRoster!.addDelegate(self, delegateQueue: dispatch_get_main_queue())
    }
    
    //发送上线状态
    func goOnline(){
        var p = XMPPPresence()
        //发送任意内容表示上线
        xs!.sendElement(p)
        queryFriends()
        xmppRoster?.fetchRoster()
    }
    
    //发送下线状态
    func goOffline(){
        var p = XMPPPresence(type: "unavailable")
        xs!.sendElement(p)
    }
    
    //查询好友
    func queryFriends(){
        var iq = DDXMLElement.elementWithName("iq") as! DDXMLElement
        iq.addAttributeWithName("from", stringValue: xs!.myJID.description)
        //iq.addAttributeWithName("to", stringValue: xs!.myJID.domain)不能加
        iq.addAttributeWithName("id", stringValue:xs!.generateUUID())
        iq.addAttributeWithName("type", stringValue: "get")
        
        var query = DDXMLElement.elementWithName("query") as! DDXMLElement
        query.addAttributeWithName("xmlns", stringValue: "jabber:iq:roster")
        
        iq.addChild(query)
        xs!.sendElement(iq)
        println(iq)
    }

    //连接服务器
    func connect()->Bool{
        //通道已经连接
        user = NSUserDefaults.standardUserDefaults().stringForKey("wxID")
        passwd = NSUserDefaults.standardUserDefaults().stringForKey("wxPwd")
        server = NSUserDefaults.standardUserDefaults().stringForKey("wxServer")
        var TLSLogin = NSUserDefaults.standardUserDefaults().boolForKey("wxTLSLogin")

        
        buildStream()
        //取得前台数据
        
        if user != nil && passwd != nil{
            //通道的用户名
            xs!.myJID = XMPPJID.jidWithString(user!, resource: "ios")
            //指定host
            xs!.hostName = server!
            if TLSLogin == true{
                xs!.startTLSPolicy = XMPPStreamStartTLSPolicy.Required
            }else{
                xs!.startTLSPolicy = XMPPStreamStartTLSPolicy.Allowed
            }
            //连接，设置超时
            var error:NSError?
            println(xs!.connectWithTimeout(500, error: &error).description)
            println("===============")
            println(error)
            return true
        }
        return false
    }
    
    //断开连接
    func disConnect(){
        if xs != nil && xs?.isConnected() == true {
            isOpen = false
            goOffline()
            xs!.disconnect()
        }
    }
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

