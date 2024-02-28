//
//  GenTools.swift
//  AIPartnerDemo
//
//  Created by FanPengpeng on 2024/2/28.
//

import Foundation
import RTMTokenBuilder

class GenTools: NSObject {
    //    @objc static var RTC_UID: UInt = UInt(arc4random() % 100000) // 请修改uid 不要设置成0
        @objc static var RTC_UID: UInt {
            let key = "RTC_UID"
            var uid = UserDefaults.standard.integer(forKey: key)
            if uid == 0 {
                uid = Int(arc4random()) % 100000
                UserDefaults.standard.set(uid, forKey: key)
            }
            return UInt(uid)
        }
        
        @objc static let CHANNEL: String = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmmss"
            let currentTimeString = dateFormatter.string(from: Date())
            
            let randomNum = Int(arc4random_uniform(90)) + 10
            let randomNumString = String(randomNum)
            
            let finalString = currentTimeString + randomNumString
            print("KeyCenter.CHANNEL == \(finalString)")
            return finalString
        }()

        @objc static let RTM_UID: String = "\(RTC_UID)"
        @objc static var RTM_TOKEN: String {
            RTMTokenBuilder.TokenBuilder.buildRtmToken(KeyCenter.APP_ID, appCertificate: KeyCenter.APP_CERTIFICATE, userUuid: RTM_UID)
        }
        // 获取rtcToken
        static func rtcToken(channelID:String) ->String{
            RTMTokenBuilder.TokenBuilder.rtcToken2(KeyCenter.APP_ID, appCertificate: KeyCenter.APP_CERTIFICATE, uid: Int32(RTC_UID), channelName: channelID)
        }
}
