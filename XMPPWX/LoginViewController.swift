//
//  LoginViewController.swift
//  XMPPWX
//
//  Created by Liuzhao on 15/4/11.
//  Copyright (c) 2015年 Liuzhao. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var userTexeField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var serverTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if sender as! NSObject == self.doneButton {
            NSUserDefaults.standardUserDefaults().setObject(userTexeField, forKey: "wxID")
            
        }
    }
    
}
