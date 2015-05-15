//
//  SeachTableViewController.swift
//  XMPPWX
//
//  Created by Liuzhao on 15/4/21.
//  Copyright (c) 2015年 Liuzhao. All rights reserved.
//

import UIKit

protocol SearchDL{
    func initSearchList(items:[DDXMLElement])
}

class SearchTableViewController : UITableViewController, UISearchBarDelegate,SearchDL{
    //用于保存找到的好友列表
    var searchList = [String]()
    
    @IBOutlet weak var searchBar: UISearchBar!

    func initSearchList(items: [DDXMLElement]) {
        //
        for item in items{
            let str = item.attributeStringValueForName("jid")
            searchList.append(str)
        }
        self.tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        //
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //监听search点击事件，点击发送iq查询
        
        var iqType = "jabber:iq:search"
        /*<iq type='set'
        from='romeo@montague.net/home'
        to='characters.shakespeare.lit'
        id='search2'
        xml:lang='en'>
        <query xmlns='jabber:iq:search'>
        <last>Capulet</last>
        </query>
        </iq>*/
        var iq = DDXMLElement.elementWithName("iq") as! DDXMLElement
        iq.addAttributeWithName("from", stringValue: allDL().xs!.myJID.description)
        iq.addAttributeWithName("id", stringValue:allDL().xs!.generateUUID())
        iq.addAttributeWithName("type", stringValue: "get")
        //iq.addAttributeWithName("to", stringValue: "ejabberd.liuzhao.com")
        //iq.addAttributeWithName("xml:lang", stringValue: "zh-CN")
        
        var query = DDXMLElement.elementWithName("query") as! DDXMLElement
        query.addAttributeWithName("xmlns", stringValue: iqType)
        
       // var jid = DDXMLElement.elementWithName("jid") as! DDXMLElement
        //jid.setStringValue(searchBar.text)
        //jid.setStringValue("fangzy")//searchBar.text )
        //query.addChild(jid)
        
        iq.addChild(query)
        allDL().xs!.sendElement(iq)
        println(iq)
    }
    
    var ad:AppDelegate?
    
    func allDL() -> AppDelegate{
        if ad == nil{
            ad = UIApplication.sharedApplication().delegate as? AppDelegate
        }
        return ad!
    }
    
    override func viewDidLoad() {
        searchList.append("liuz@ejabberd.liuzhao.com")
        searchList.append("sunlx@ejabberd.liuzhao.com")
        searchList.append("zhuzb@ejabberd.liuzhao.com")
        super.viewDidLoad()
        searchBar.delegate = self
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //行数1
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchList.count
    }
    
    func addFriend(button:UIButton){
        /*<presence xmlns="jabber:client" from="liuz@ejabberd.liuzhao.com" to="fangzy@ejabberd.liuzhao.com/ios" type="subscribe"/>*/
        var friend = searchList[button.tag]
        /*
        var presence = DDXMLElement.elementWithName("presence") as! DDXMLElement
        presence.addAttributeWithName("xmlns", stringValue: "jabber:client")
        presence.addAttributeWithName("from", stringValue: allDL().xs!.myJID.description)
        presence.addAttributeWithName("to", stringValue: friend)
        presence.addAttributeWithName("type", stringValue: "subscribe")
        
        allDL().xs!.sendElement(presence)
        */
        var jid = XMPPJID.jidWithString(friend)
        allDL().xmppRoster?.addUser(jid, withNickname: friend)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //获得单元格
        var cell = tableView.dequeueReusableCellWithIdentifier("searchListCell") as! UITableViewCell
        
        var button = UIButton.buttonWithType(.ContactAdd) as! UIButton
        button.addTarget(self, action: "addFriend:", forControlEvents:UIControlEvents.TouchUpInside)
        button.tag = indexPath.row
        button.frame = CGRectMake(UIScreen.mainScreen().bounds.width-50, 4, 50, 35)
        button.titleLabel?.textColor = UIColor.blueColor()
        
        cell.addSubview(button)
        cell.textLabel!.text = searchList[indexPath.row]
        
        return cell
    }

}