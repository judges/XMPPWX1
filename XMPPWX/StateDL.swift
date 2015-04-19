//
//  StatueDL.swift
//  XMPPWX
//
//  Created by Liuzhao on 15/4/14.
//  Copyright (c) 2015年 Liuzhao. All rights reserved.
//

import Foundation

//状态代理协议
protocol StateDL {
    func isOn(state:State)
    func isOff(state:State)
    func meOff()
}