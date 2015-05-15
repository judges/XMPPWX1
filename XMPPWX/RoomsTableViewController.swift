//
//  RoomsTableViewController.swift
//  XMPPWX
//
//  Created by Liuzhao on 15/4/24.
//  Copyright (c) 2015年 Liuzhao. All rights reserved.
//

import UIKit

class RoomsTableViewController : UITableViewController, XMPPRoomDelegate,UIAlertViewDelegate,RoomsDL{
    //房间列表
    var roomList = [Room]()
    var ad:AppDelegate?
    var xmppRoom:XMPPRoom?
    var createAlertView:UIAlertView = UIAlertView()
    var joinAlertView:UIAlertView = UIAlertView()
    var nameAlert:UIAlertView = UIAlertView()
    
    func allDL() -> AppDelegate{
        if ad == nil{
            ad = UIApplication.sharedApplication().delegate as? AppDelegate
        }
        return ad!
    }
    //创建房间
    @IBAction func Build(sender: UIBarButtonItem) {
        createAlertView.title = "必要信息"
        createAlertView.tag = 0
        createAlertView.alertViewStyle = UIAlertViewStyle.LoginAndPasswordInput
        createAlertView.textFieldAtIndex(0)?.placeholder = "聊天室名称"
        createAlertView.textFieldAtIndex(1)?.placeholder = "您的昵称"
        createAlertView.textFieldAtIndex(1)?.secureTextEntry = false
        createAlertView.addButtonWithTitle("确定")
        createAlertView.addButtonWithTitle("取消")
        createAlertView.delegate = self
        createAlertView.show()
    }
    
    func initRooms(items:[DDXMLElement]) {
        //初始化房间信息
        roomList.removeAll(keepCapacity: false)
        for item in items {
            var room = Room()
            room.jid = item.attributeStringValueForName("jid")
            room.name = item.attributeStringValueForName("name")
            roomList.append(room)
        }
        self.tableView.reloadData()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        //创建聊天室的弹窗
        if alertView.tag == 0{
            if buttonIndex == 0{
            //创建并填写聊天室名称
                if alertView.textFieldAtIndex(0)?.text == nil || alertView.textFieldAtIndex(0)?.text == ""{
                    var a = UIAlertView()
                    a.title = "创建失败"
                    a.message = "录入聊天室名称不能为空"
                    a.addButtonWithTitle("OK")
                    a.show()
                    return
                }
                if alertView.textFieldAtIndex(1)?.text == nil || alertView.textFieldAtIndex(1)?.text == ""{
                    var a = UIAlertView()
                    a.title = "创建失败"
                    a.message = "录入昵称不能为空"
                    a.addButtonWithTitle("OK")
                    a.show()
                    return
                }
                var roomjid = XMPPJID.jidWithString(alertView.textFieldAtIndex(0)!.text! + "@conference.ejabberd.liuzhao.com")
                var xmppRoomCoreDataStorage = XMPPRoomCoreDataStorage.sharedInstance()
                xmppRoom = XMPPRoom(roomStorage: xmppRoomCoreDataStorage, jid:roomjid, dispatchQueue:dispatch_get_main_queue())
                xmppRoom!.activate(allDL().xs!)
                xmppRoom!.addDelegate(self, delegateQueue: dispatch_get_main_queue())
                xmppRoom!.joinRoomUsingNickname(alertView.textFieldAtIndex(1)?.text, history: nil)
                println("00")
                println(xmppRoom!.roomJID)
            }
        }else if alertView.tag == 1{
            //点击某聊天室的弹窗
            if buttonIndex == 0{
                //加入聊天室
                /*
                <presence
                from='hag66@shakespeare.lit/pda'
                to='darkcave@macbeth.shakespeare.lit/thirdwitch'/>
                */
                nameAlert.title = "您的昵称"
                nameAlert.alertViewStyle = UIAlertViewStyle.PlainTextInput
                nameAlert.addButtonWithTitle("确定")
                nameAlert.addButtonWithTitle("取消")
                nameAlert.delegate = self
                nameAlert.tag = 2
                nameAlert.show()
            }
        }else if alertView.tag == 2{
            //加入房间的昵称弹窗
            if buttonIndex == 0{
                if alertView.textFieldAtIndex(0)!.text == ""{
                    return
                }
                
                var presence = DDXMLElement.elementWithName("presence") as! DDXMLElement
                presence.addAttributeWithName("from", stringValue: allDL().xs!.myJID.description)
                var a:String = alertView.textFieldAtIndex(0)!.text
                presence.addAttributeWithName("to", stringValue: jid!+"/"+a)
                allDL().xs!.sendElement(presence)
                allDL().t = a
            }
        }
    }
    
    override func viewDidLoad() {
        //
        super.viewDidLoad()
        allDL().roomsDL = self
    }
    
    func xmppRoomDidJoin(sender: XMPPRoom!) {
        //
        println("ddd1")
    }
    
    func xmppRoomDidCreate(sender: XMPPRoom!) {
        //
        println("ddd2")
    }
    func xmppRoom(sender: XMPPRoom!, didReceiveMessage message: XMPPMessage!, fromOccupant occupantJID: XMPPJID!) {
        //
        println("zhende")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("roomTableViewCell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = roomList[indexPath.row].jid
        return cell
    }
    
    var jid:String?
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //joinAlertView
        //对于选中房间的操作
        jid = roomList[indexPath.row].jid
        joinAlertView.title = "操作"
        joinAlertView.addButtonWithTitle("加入")
        joinAlertView.addButtonWithTitle("成员")
        joinAlertView.addButtonWithTitle("取消")
        joinAlertView.delegate = self
        joinAlertView.tag = 1
        joinAlertView.show()
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //
        return roomList.count
    }
}