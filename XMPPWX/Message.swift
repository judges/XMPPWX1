//
//  Message.swift
//  XMPPWX
//
//  Created by Liuzhao on 15/4/11.
//  Copyright (c) 2015年 Liuzhao. All rights reserved.
//

import Foundation

//消息结构，结构可以不初始化
struct Message {
    var body:String = ""//正文内容
    var from:String = ""//来自哪里
    var isComposing:Bool = false//输入中
    var isDelay:Bool = false//离线文件
    var isMe:Bool = false//本人所发
}

//状态结构
struct State {
    var name:String = ""//用户名
    var subscribeType:SubscribeType = .none
    var isOnline:Bool = false//在线与否
}

//订阅类型
enum SubscribeType{
    case none
    case both
    case from
    case to
}

/*
//更间接地删除，泛型函数,Int和String 实现相等Equatable协议
func iR<T:Equatable>(value :T,inout aArray: [T]){
    var index = 0
    for (_,loc) in enumerate(aArray){
        if loc == value{
            aArray.removeAtIndex(index)
            index--
        }
        index++
    }
}
*/
//获取正确的删除索引，不用泛型是因为我们只针对信息结构
func getRemoveIndex(value :String,aArray: [Message])->[Int]{
    var indexArray = [Int]()
    var correctArray = [Int]()
    //获取指定值的索引并保存
    for (index, _) in enumerate(aArray){
        if value == aArray[index].from {
            indexArray.append(index)
        }
    }
    //计算正确的删除索引
    for (index, originIndex) in enumerate(indexArray){
        //正确的索引
        var y = 0
        //在原数组中的索引减去 索引数组的索引
        y = originIndex - index;
        //添加到正确的索引数组中
        correctArray.append(y)
    }
    
    return correctArray
}

func removeFromArray(value :String,inout aArray: [Message]){
    var willRemoveMsgs = [Int]()
    //取得删除的节点
    willRemoveMsgs = getRemoveIndex(value, aArray)
    //删除
    for index in willRemoveMsgs{
        aArray.removeAtIndex(index)
    }
}
