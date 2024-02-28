//
//  ChatInfo.swift
//  AIPartnerDemo
//
//  Created by FanPengpeng on 2023/11/8.
//

import UIKit

class ChatInfo: NSObject {
    var chatId: String = ""
    var isAI = false
    var content = ""
    var name = ""
    var delay = 0
    
    init(chatId: String, isAI: Bool, content: String, name: String, delay: Int = 0) {
        self.chatId = chatId
        self.isAI = isAI
        self.content = content
        self.name = name
        self.delay = delay
    }
}
