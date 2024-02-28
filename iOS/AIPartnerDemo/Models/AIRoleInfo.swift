//
//  AIRoleInfo.swift
//  AIPartnerDemo
//
//  Created by FanPengpeng on 2023/11/7.
//

import UIKit

enum MateAvatarName: String {
    case mina = "mina"
    case kda = "kda"
}


class AIRoleInfo: NSObject {
    
    enum RoleId: String, CaseIterable {
        case yunibobo_zh = "yunibobo-zh-CN"
        case jingxiang_zh = "jingxiang-zh-CN"
        case wendy_en = "Wendy-en-US"
        case cindy_en = "Cindy-en-US"
        case foodie_en = "yunibobo-en-US"
        
        var ttsVenderId: String {
            switch self {
            case .yunibobo_zh:
                return "microsoft-zh-CN-xiaoxiao-cheerful"
            case .jingxiang_zh:
                return "microsoft-zh-CN-xiaoyi-gentle"
            case .wendy_en:
                return "microsoft-en-US-Jenny-cheerful"
            case .cindy_en:
                return "microsoft-en-US-Jenny-cheerful"
            case .foodie_en:
                return "microsoft-en-US-Jenny-gentle"
            }
        }
        
        var avatarName: MateAvatarName {
            switch self {
            case .yunibobo_zh, .wendy_en, .cindy_en, .foodie_en:
                return .mina
            default:
                return .kda
            }
        }
    }
    
    enum Gender {
        case male
        case female
    }
    
    var nickname: String = ""
    var desc: String = ""
    var gender: Gender = .female
    var isSelected = false
    var roleId: RoleId = .yunibobo_zh
    
    var avatarName: MateAvatarName {
        roleId.avatarName
    }
    
    var avatarIcon: String {
        get{
            switch roleId {
            case .yunibobo_zh, .foodie_en:
                return "avatar_static_1"
            case .jingxiang_zh, .wendy_en:
                return "avatar_static_2"
            case .cindy_en:
                return "avatar_static_3"
            }
        }
    }
    
    init(nickname: String, desc: String, roleId: String, gender: Gender = .female, isSelected:Bool = false) {
        self.nickname = nickname
        self.desc = desc
        self.gender = gender
        self.isSelected = isSelected
        self.roleId = RoleId(rawValue: roleId) ?? .yunibobo_zh
    }
}
