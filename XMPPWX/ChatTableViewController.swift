//
//  TableViewController.swift
//  XMPPWX
//
//  Created by Liuzhao on 15/4/11.
//  Copyright (c) 2015年 Liuzhao. All rights reserved.
//

import UIKit

class ChatTableViewController: UITableViewController, MessageDL {
    //聊天好友名称
    var toFriendName = ""
    //消息列表
    var msgList = [Message]()
    //录入文本框
    @IBOutlet weak var aMessageText: UITextField!
    //文本框正在输入
    @IBAction func aMessageTextEditChanged(sender: UITextField) {
        //构建消息元素
        var XMLMessage = DDXMLElement.elementWithName("message") as! DDXMLElement
        //增加三个属性
        XMLMessage.addAttributeWithName("to",stringValue:toFriendName)
        XMLMessage.addAttributeWithName("from",stringValue:NSUserDefaults.standardUserDefaults().stringForKey("wxID"))
        
        //构建正在输入，并加入到消息中
        var composing =  DDXMLElement.elementWithName("composing") as! DDXMLElement
        composing.addAttributeWithName("xmlns", stringValue: "http://jabber.org/protocol/chatstates")
        XMLMessage.addChild(composing)

        //通过通道发送
        allDL().xs!.sendElement(XMLMessage)
    }
    //发送
    @IBAction func sendAction(sender: UIBarItem) {
        //获取文本
        let msgStr = aMessageText.text
        
        //如果文本不为空
        if !msgStr.isEmpty{
            //构建消息元素
            var XMLMessage = DDXMLElement.elementWithName("message") as! DDXMLElement
            //增加三个属性
            XMLMessage.addAttributeWithName("type",stringValue:"chat")
            XMLMessage.addAttributeWithName("to",stringValue:toFriendName)
            XMLMessage.addAttributeWithName("from",stringValue:NSUserDefaults.standardUserDefaults().stringForKey("wxID"))
            //构建正文，并加入到消息中
            var body =  DDXMLElement.elementWithName("body") as! DDXMLElement
            body.setStringValue(msgStr)
            XMLMessage.addChild(body)
            
            //通过通道发送
            allDL().xs!.sendElement(XMLMessage)
            //清空
            aMessageText.text = ""
            //保存自己发送的消息
            var aMsg = Message()
            aMsg.body = msgStr
            aMsg.isMe = true
            //加入到聊天记录
            msgList.append(aMsg)
            //刷新
            self.tableView.reloadData()
        }
    }

    func allDL() -> AppDelegate{
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    //收到消息
    func newMsg(aMsg: Message) {
        if aMsg.isComposing{
            //对方正在输入
            self.title="对方正在输入..."
            //self.navigationController?.title = "对方正在输入..."
        }else if aMsg.body != "" {
            //如果消息有正文，显示聊天对象，加入未读消息组，并刷新
            self.title = toFriendName
            //self.navigationController?.title = toFriendName
            //加入
            msgList.append(aMsg)
            //刷新
            self.tableView.reloadData()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //接管代理
        allDL().messageDL =  self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //行数1
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return msgList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //获得单元格
        let cell = tableView.dequeueReusableCellWithIdentifier("chatTableViewCell", forIndexPath: indexPath) as! UITableViewCell
        //去的对应消息
        let msg = msgList[indexPath.row]
        //对单元格格式调整
        if msg.isMe{
            //自己发的
            cell.textLabel?.textAlignment = .Right
            cell.textLabel?.textColor = UIColor.grayColor()
        }else{
            //好友发的，自己收的
            cell.textLabel?.textColor = UIColor.blueColor()
        }
        //设定单元格文本
        cell.textLabel?.text = msg.body
        
        return cell
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
}
