//
//  AppDelegate.swift
//  XMPPWX
//
//  Created by Liuzhao on 15/4/11.
//  Copyright (c) 2015年 Liuzhao. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, XMPPStreamDelegate {
    var window: UIWindow?

    //xmpp通道
    var xs:XMPPStream?
    //服务器是否开启，默认false
    var isOpen = false
    //密码
    var pwd = ""

    //状态代理
    var stateDL:StateDL?
    
    //消息代理
    var messageDL:MessageDL?
    
    //收到消息
    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {
        
        //如何知道，可以通过官方文档
        println(message)
        println()

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
            
            //添加到代理中
            messageDL?.newMsg(msg)
        }
        

    }
    
    //收到状态
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
        println(presence)
        println()
        
        //我自己的用户名
        let myUser = sender.myJID.user

        //好友的状态
        let user = presence.from().user
        
        //用户所在的域
        let domain = presence.from().domain
        
        //状态类型
        let pType = presence.type()
        
        //如果状态不是自己的
        if(user != myUser){
            //状态保存的结构
            var state = State()
            //取得并保存状态的完整用户名
            state.name = user + "@" + domain
            //上线
            if pType == "available"{
                state.isOnline = true
                stateDL?.isOn(state)
            }else if pType == "unavailable"{
                state.isOnline = false
                stateDL?.isOff(state)
            }
        }
        
    }
    
    var user:String?
    var passwd:String?
    var server:String?
    
    func registerUser(){
        //注册用户
        connect();
        if(user != nil && passwd != nil){
            xs!.myJID = XMPPJID.jidWithString(user!)
            xs!.registerWithPassword(passwd, error: nil)
        }
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
        }
        alert.addButtonWithTitle("ok")
        alert.show()
    }
    
    //连接成功
    func xmppStreamDidConnect(sender: XMPPStream!) {
        isOpen = true
        //验证密码
        xs!.authenticateWithPassword(pwd, error: nil)
    }
    
    //验证成功
    func xmppStreamDidAuthenticate(sender: XMPPStream!) {
        //上线
        goOnline()
    }
    
    //建立通道
    func buildStream(){
        xs = XMPPStream()
        xs?.addDelegate(self, delegateQueue: dispatch_get_main_queue())
    }
    
    //发送上线状态
    func goOnline(){
        var p = XMPPPresence()
        //发送任意内容表示上线
        xs!.sendElement(p)
    }
    
    //发送下线状态
    func goOffline(){
        var p = XMPPPresence(type: "unavailable")
        
        xs!.sendElement(p)
    }
    
    //连接服务器
    func connect()->Bool{
        //通道已经连接
        user = NSUserDefaults.standardUserDefaults().stringForKey("wxID")
        passwd = NSUserDefaults.standardUserDefaults().stringForKey("wxPwd")
        server = NSUserDefaults.standardUserDefaults().stringForKey("wxServer")
        
        if (xs != nil && xs!.isConnected()){
            return true
        }
        buildStream()
        //取得前台数据
        
        if user != nil && passwd != nil{
            //通道的用户名
            xs!.myJID = XMPPJID.jidWithString(user!)
            //指定host
            xs!.hostName = server!
            //密码备用
            self.pwd = passwd!
            //连接，设置超时
            xs!.connectWithTimeout(5000, error: nil)
            return true
        }
        
        return false
    }
    
    //断开连接
    func disConnect(){
        if xs != nil && xs?.isConnected() == true {
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

