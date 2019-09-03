//
//  LocalizationManager.swift
//  LocalizationManager
//
//  Created by Tuan Tran on 8/28/19.
//

import Foundation
import UIKit

// MARK: - NSNotification

public extension NSNotification.Name {
    
    /// Notifcation whenever language changed.
    static let LMLanguageDidChange = Notification.Name("LMLanguageDidChange")
    
    /// Notification whenever layout direction changed. From RTL to LTR and vice versace.
    static let LMLayoutDirectionDidChange = Notification.Name("LMLayoutDirectionDidChange")
}

// MARK: - LocalizationManager

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
    
    /// Temporary language
    open var temporaryLanguage: String?
    
    /// Supported RTL Languages with ISO 639 code-1 format
    open var rtlLanguages: [String] = ["ar", "he", "fa", "ur"]
    
    /// isRTL boolean to check current layout direction
    open var isRTL: Bool {
        get {
            return layoutDirection(forLanguage: currentLanguage) == .rightToLeft
        }
    }
    
    /// Swizzle methods of Bundle,
    /// will be used later to undo method swizzle.
    private var bundleSwizzleMethods: SwizzleMethods?
    
    /// Swizzle methods of UIApplication,
    /// will be used later to undo method swizzle.
    private var applicationSwizzleMethods: SwizzleMethods?
    
    open func start() {
        applyMethodSwizzle()
    }
    
    open func stop() {
        undoMethodSwizzle()
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
    
    private func applyMethodSwizzle() {
        bundleSwizzleMethods = MethodSwizzleHelper.applyBundleMethodSwizzle()
        applicationSwizzleMethods = MethodSwizzleHelper.applyApplicationMethodSwizzle()
    }
    
    private func undoMethodSwizzle() {
        if let methods = bundleSwizzleMethods {
            MethodSwizzleHelper.undoMethodSwizzle(methods: methods)
            bundleSwizzleMethods = nil
        }
        if let methods = applicationSwizzleMethods {
            MethodSwizzleHelper.undoMethodSwizzle(methods: methods)
            applicationSwizzleMethods = nil
        }
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

// MARK: - Utilities

public func localized(_ key: String, quantity: Float? = nil, language: String? = nil) -> String {
    // Check for given language
    defer {
        LocalizationManager.shared.temporaryLanguage = nil
    }
    let locale: Locale
    if let `language` = language {
        LocalizationManager.shared.temporaryLanguage = language
        locale = Locale(identifier: language)
    } else {
        locale = Locale(identifier: LocalizationManager.shared.currentLanguage)
    }
    
    // Check for plural
    var mutableKey = key
    if let `quantity` = quantity {
        let pluralRule = PluralRuleClassifierFactory(locale: locale).rule(for: quantity)
        mutableKey.append(".\(pluralRule.rawValue)")
    }
    
    let translatedString = NSLocalizedString(mutableKey, comment: "")
    return translatedString
}
