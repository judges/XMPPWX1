//
//  LoginViewController.swift
//  XMPPWX
//  只用有传递数据，并不能处理数据
//  Created by Liuzhao on 15/4/11.
//  Copyright (c) 2015年 Liuzhao. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var serverTextField: UITextField!
    @IBOutlet weak var autoLoginSwith: UISwitch!
    @IBOutlet weak var registerButton: UIBarButtonItem!
    @IBOutlet weak var TLSLogin: UISwitch!
    var ad:AppDelegate?
    
    func allDL() -> AppDelegate{
        if ad == nil{
            ad = UIApplication.sharedApplication().delegate as? AppDelegate
        }
        return ad!
    }

    func userSyn(){
        NSUserDefaults.standardUserDefaults().setObject(userTextField.text, forKey: "wxID")
        NSUserDefaults.standardUserDefaults().setObject(pwdTextField.text, forKey: "wxPwd")
        NSUserDefaults.standardUserDefaults().setObject(serverTextField.text, forKey: "wxServer")
        //是否勾选自动登录
        NSUserDefaults.standardUserDefaults().setBool(self.autoLoginSwith.on, forKey: "wxAutoLogin")
        NSUserDefaults.standardUserDefaults().setBool(self.TLSLogin.on, forKey: "wxTLSLogin")
        //同步用户配置
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    @IBAction func isTLS(sender: UISwitch) {
        
    }
    @IBAction func registerAction(sender: UIBarButtonItem) {
        userSyn()        
        allDL().registerUser()        
    }
    //是否请求登陆
    var isRequireLogin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if sender as! UIBarButtonItem == self.doneButton {
            //放到字典中去
            userSyn()
            //需要登陆
            isRequireLogin = true
        }
    }
    
}
