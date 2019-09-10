//
//  MethodSwizzleHelper+UIApplication.swift
//  LocalizationManager
//
//  Created by Tuan Tran on 9/3/19.
//

import Foundation

public extension MethodSwizzleHelper {
    
    static func applyApplicationMethodSwizzle() -> SwizzleMethods {
        let originalSelector = #selector(getter: UIApplication.userInterfaceLayoutDirection)
        let overrideSelector = #selector(getter: UIApplication.customUserInterfaceLayoutDirection)
        return applyMethodSwizzle(forClass: UIApplication.self,
                                  originalSelector: originalSelector,
                                  overrideSelector: overrideSelector)
    }
}

public extension UIApplication {
    
    @objc var customUserInterfaceLayoutDirection : UIUserInterfaceLayoutDirection {
        get {
            let sharedLocalizationManager = LocalizationManager.shared
            let currentLanguageCode = sharedLocalizationManager.currentLanguage
            return LocalizationManager.shared.layoutDirection(forLanguage: currentLanguageCode)
        }
    }
}
