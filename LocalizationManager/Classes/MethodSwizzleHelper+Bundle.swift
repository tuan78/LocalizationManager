//
//  MethodSwizzleHelper+Bundle.swift
//  LocalizationManager
//
//  Created by Tuan Tran on 9/3/19.
//

import Foundation

public extension MethodSwizzleHelper {
    
    static func applyBundleMethodSwizzle() -> SwizzleMethods {
        let originalSelector = #selector(Bundle.localizedString(forKey:value:table:))
        let overrideSelector = #selector(Bundle.customLocalizedString(forKey:value:table:))
        return applyMethodSwizzle(forClass: Bundle.self,
                                  originalSelector: originalSelector,
                                  overrideSelector: overrideSelector)
    }
}

public extension Bundle {
    
    @objc func customLocalizedString(forKey key: String,
                                     value: String?,
                                     table tableName: String?) -> String {
        if self == Bundle.main {
            return bundleForCurrentLanguage
                .customLocalizedString(forKey: key,
                                       value: value,
                                       table: tableName)
        } else {
            return self.customLocalizedString(forKey: key,
                                        value: value,
                                        table: tableName)
        }
    }
    
    var bundleForCurrentLanguage: Bundle {
        let localizationManager = LocalizationManager.shared
        let currentLanguage = localizationManager.temporaryLanguage
            ?? localizationManager.currentLanguage
        
        let mainBundle = Bundle.main
        let bundlePath: String = mainBundle.path(forResource: currentLanguage, ofType: "lproj")
            ?? mainBundle.path(forResource: "Base", ofType: "lproj") ?? ""
        
        if let currentLanguageBundle = Bundle(path: bundlePath) {
            return currentLanguageBundle
        }
        return self
    }
}
