//
//  LanguageManager.swift
//  AIPartnerDemo
//
//  Created by FanPengpeng on 2023/11/13.
//

import UIKit

class LanguageManager: NSObject {
    
    static let shared = LanguageManager()
    
    private override init() {
        self.current = LanguageManager.systemLang
    }
    
    static var systemLang: Language {
        guard let lang = NSLocale.preferredLanguages.first else {
            return .en
        }
        if lang.contains("zh") {
            return .zh
        }
        return .en
    }
    
    var current: Language
    
    func localized(_ key: String) -> String {
        let lang = LanguageManager.shared.current.rawValue
        
        guard let langPath = Bundle.main.path(forResource: lang, ofType: "lproj") , let detailBundle = Bundle(path: langPath) else {
            return key
        }
        let retStr = NSLocalizedString(key,tableName: "Localizable", bundle:detailBundle ,comment: "")
        return retStr
    }
}

extension LanguageManager {
    enum Language: String {
        case zh = "zh-Hans"
        case en = "en"
    }
}

extension String {
    var localized: String {
        return LanguageManager.shared.localized(self)
    }
}
