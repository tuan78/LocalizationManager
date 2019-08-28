//
//  LocalizationManager.swift
//  LocalizationManager
//
//  Created by Tuan Tran on 8/28/19.
//

import Foundation
import UIKit

open class LocalizationManager {
    
    public static let shared = LocalizationManager()
    
    /// App current language
    open var currentLanguage: String {
        get {
            return getCurrentAppleLanguage()
        }
        set(value) {
            setCurrentAppleLanguage(value)
            setGlobalViewAppearanceDirection()
            NotificationCenter.default.post(name: .LanguageDidChange, object: nil, userInfo: nil)
        }
    }
    
    /// RTL Languages, mutable array which can edit anytime
    open var rtlLanguages: [String] = ["ar"]
    
    /// isRTL boolean which is to check layout direction
    open var isRTL: Bool {
        get {
            return UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
        }
    }
    
    open func start() {
        swizzlingLocalizationMethod()
        swizzlingUILayoutDirectionMethod()
    }
    
    // MARK: Private Functions
    
    private func swizzlingUILayoutDirectionMethod() {
        let originalSelector = #selector(getter: UIApplication.userInterfaceLayoutDirection)
        let overrideSelector = #selector(getter: UIApplication.customUserInterfaceLayoutDirection)
        MethodSwizzleGivenClassName(UIApplication.self,
                                    originalSelector: originalSelector,
                                    overrideSelector: overrideSelector)
    }
    
    private func swizzlingLocalizationMethod() {
        let originalSelector = #selector(Bundle.localizedString(forKey:value:table:))
        let overrideSelector = #selector(Bundle.customLocalizedString(forKey:value:table:))
        MethodSwizzleGivenClassName(Bundle.self,
                                    originalSelector: originalSelector,
                                    overrideSelector: overrideSelector)
    }
    
    private func setGlobalViewAppearanceDirection() {
        UIView.appearance().semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
        UINavigationBar.appearance().semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
    }
}

// MARK: - Update Apple Languages

public extension LocalizationManager {
    static let appleLanguagesKey = "AppleLanguages"
    
    private func setCurrentAppleLanguage(_ language: String) {
        let userDefault = UserDefaults.standard
        userDefault.set([language, currentLanguage], forKey: LocalizationManager.appleLanguagesKey)
        userDefault.synchronize()
    }
    
    private func getCurrentAppleLanguage() -> String {
        let userDefault = UserDefaults.standard
        let languages = userDefault.object(forKey: LocalizationManager.appleLanguagesKey) as? Array<Any>
        return languages?.first as? String ?? ""
    }
}

// MARK: - NSNotification

public extension NSNotification.Name {
    static let LanguageDidChange = Notification.Name("LanguageDidChange")
}

// MARK: - Application - Extension

public extension UIApplication {
    
    @objc var customUserInterfaceLayoutDirection : UIUserInterfaceLayoutDirection {
        get {
            let sharedLocalizationManager = LocalizationManager.shared
            let currentLanguageCode = sharedLocalizationManager.currentLanguage
            for rtlLanguageCode in sharedLocalizationManager.rtlLanguages {
                if rtlLanguageCode == currentLanguageCode {
                    return .rightToLeft
                }
            }
            return .leftToRight
        }
    }
}

// MARK: - Bundle - Extension

public extension Bundle {
    
    @objc func customLocalizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        return bundleForCurrentLanguage.customLocalizedString(forKey: key,
                                                              value: value,
                                                              table: tableName)
    }
    
    var bundleForCurrentLanguage: Bundle {
        let sharedLocalizationManager = LocalizationManager.shared
        let currentLanguage = sharedLocalizationManager.currentLanguage
        
        let mainBundle = Bundle.main
        let bundlePath: String = mainBundle.path(forResource: currentLanguage, ofType: "lproj")
            ?? mainBundle.path(forResource: "Base", ofType: "lproj") ?? ""
        
        if let currentLanguageBundle = Bundle(path: bundlePath) {
            return currentLanguageBundle
        }
        return self
    }
}

//var bundleKey: UInt8 = 0
//
//public class BundleEx: Bundle {
//
//    public override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
//        guard let path = objc_getAssociatedObject(self, &bundleKey) as? String,
//            let bundle = Bundle(path: path) else {
//                return super.localizedString(forKey: key, value: value, table: tableName)
//        }
//
//        return bundle.localizedString(forKey: key, value: value, table: tableName)
//    }
//}
//
//public extension Bundle {
//
//    class func setLanguage(_ language: String) {
//        defer {
//            object_setClass(Bundle.main, BundleEx.self)
//        }
//
//        objc_setAssociatedObject(Bundle.main, &bundleKey, Bundle.main.bundleForCurrentLanguage, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//    }
//}

// MARK: - Private Functions

private func MethodSwizzleGivenClassName(_ clazz: AnyClass, originalSelector: Selector, overrideSelector: Selector) {
    
    guard let originalMethod = class_getInstanceMethod(clazz, originalSelector) else {
        return
    }
    
    guard let overrideMethod = class_getInstanceMethod(clazz, overrideSelector) else {
        return
    }
    
    if class_addMethod(clazz, originalSelector,
                       method_getImplementation(overrideMethod),
                       method_getTypeEncoding(overrideMethod)) {
        
        class_replaceMethod(clazz, overrideSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod))
    } else {
        method_exchangeImplementations(originalMethod, overrideMethod)
    }
}
