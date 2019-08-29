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
            defer {
                NotificationCenter.default.post(name: .LMLanguageDidChange, object: nil)
            }
            setCurrentAppleLanguage(value)
            checkAndApplyGlobalLayoutDirection(forLanguage: value)
        }
    }
    
    /// Supported RTL Languages with ISO 639 code-1 format
    open var rtlLanguages: [String] = ["ar", "he", "fa", "ur"]
    
    /// isRTL boolean to check current layout direction
    open var isRTL: Bool {
        get {
            return layoutDirection(forLanguage: currentLanguage) == .rightToLeft
        }
    }
    
    open func start() {
        swizzlingLocalizationMethod()
        swizzlingUILayoutDirectionMethod()
    }
    
    /// Layout direction for given language code.
    open func layoutDirection(forLanguage language: String) -> UIUserInterfaceLayoutDirection {
        let twoLettersCode = language.twoLettersLanguageCode
        for rtlLanguageCode in rtlLanguages {
            if rtlLanguageCode == twoLettersCode {
                return .rightToLeft
            }
        }
        return .leftToRight
    }
    
    // MARK: Semantic Content Attribute
    
    open var currentSemanticContentAttribute: UISemanticContentAttribute {
        return UIView.appearance().semanticContentAttribute
    }
    
    open func semanticContentAttribute(forLayoutDirection direction: UIUserInterfaceLayoutDirection) -> UISemanticContentAttribute {
        return direction == .rightToLeft ? .forceRightToLeft : .forceLeftToRight
    }
    
    open func setGlobalLayoutDirection(_ direction: UIUserInterfaceLayoutDirection) {
        let contentAttribute = semanticContentAttribute(forLayoutDirection: direction)
        UIView.appearance().semanticContentAttribute = contentAttribute
        UINavigationBar.appearance().semanticContentAttribute = contentAttribute
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
    
    private func checkAndApplyGlobalLayoutDirection(forLanguage language: String) {
        let oldContentAttribute = currentSemanticContentAttribute
        let newDirection = layoutDirection(forLanguage: language)
        if oldContentAttribute != semanticContentAttribute(forLayoutDirection: newDirection) {
            defer {
                NotificationCenter.default.post(name: .LMLayoutDirectionDidChange, object: nil)
            }
            setGlobalLayoutDirection(newDirection)
        }
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

// MARK: - String - Extension

public extension String {
    
    /// Get first two letters from language code
    ///
    /// Example: will get zh from zh-Hans (Chinese Simplified)
    var twoLettersLanguageCode: String {
        if self.count > 2 {
            return String(self.prefix(2))
        }
        return self
    }
}

// MARK: - NSNotification

public extension NSNotification.Name {
    
    /// Notifcation whenever language changed.
    static let LMLanguageDidChange = Notification.Name("LMLanguageDidChange")
    
    /// Notification whenever layout direction changed. From RTL to LTR and vice versace.
    static let LMLayoutDirectionDidChange = Notification.Name("LMLayoutDirectionDidChange")
}

// MARK: - Application - Extension

public extension UIApplication {
    
    @objc var customUserInterfaceLayoutDirection : UIUserInterfaceLayoutDirection {
        get {
            let sharedLocalizationManager = LocalizationManager.shared
            let currentLanguageCode = sharedLocalizationManager.currentLanguage
            return LocalizationManager.shared.layoutDirection(forLanguage: currentLanguageCode)
        }
    }
}

// MAKR: - UIView - Extension

public extension UIView {
    
    func updateCurrentLayoutDirection() {
        semanticContentAttribute = LocalizationManager.shared.currentSemanticContentAttribute
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
