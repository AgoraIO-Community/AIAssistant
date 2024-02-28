//
//  String+extension.swift
//  AIPartnerDemo
//
//  Created by FanPengpeng on 2023/11/13.
//

import UIKit

extension String {
    
    static func buildNonce() -> String {
        let SYMBOLS = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var nonceChars: [Character] = []
        for _ in 0..<16 {
            let index = Int.random(in: 0..<SYMBOLS.count)
            let symbolIndex = SYMBOLS.index(SYMBOLS.startIndex, offsetBy: index)
            nonceChars.append(SYMBOLS[symbolIndex])
        }
        return String(nonceChars)
    }
}

extension Data {
    func base64URLEncodedString() -> String {
        let base64String = self.base64EncodedString()
        let urlSafeString = base64String
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
        return urlSafeString
    }
}
