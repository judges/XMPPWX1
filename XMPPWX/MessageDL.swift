//
//  MessageDL.swift
//  XMPPWX
//
//  Created by Liuzhao on 15/4/14.
//  Copyright (c) 2015年 Liuzhao. All rights reserved.
//

import Foundation

//消息代理协议
protocol  MessageDL{
    func newMsg(aMsg:Message)
}