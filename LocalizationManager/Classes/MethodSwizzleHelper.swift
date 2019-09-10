//
//  MethodSwizzleHelper.swift
//  LocalizationManager
//
//  Created by Tuan Tran on 9/3/19.
//

import Foundation

public typealias SwizzleMethods = (originalMethod: Method?, overrideMethod: Method?)

open class MethodSwizzleHelper {
    
    public static func applyMethodSwizzle(forClass classType: AnyClass, originalSelector: Selector, overrideSelector: Selector) -> SwizzleMethods {
        
        guard let originalMethod = class_getInstanceMethod(classType, originalSelector) else {
            return (nil, nil)
        }
        
        guard let overrideMethod = class_getInstanceMethod(classType, overrideSelector) else {
            return (originalMethod, nil)
        }
        
        if class_addMethod(classType, originalSelector,
                           method_getImplementation(overrideMethod),
                           method_getTypeEncoding(overrideMethod)) {
            
            class_replaceMethod(classType, overrideSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, overrideMethod)
        }
        
        return (originalMethod, overrideMethod)
    }
    
    public static func undoMethodSwizzle(methods: SwizzleMethods) {
        guard let originalMethod = methods.originalMethod else {
            return
        }
        guard let overrideMethod = methods.overrideMethod else {
            return
        }
        undoMethodSwizzle(originalMethod: originalMethod, overrideMethod: overrideMethod)
    }
    
    public static func undoMethodSwizzle(originalMethod: Method, overrideMethod: Method) {
        method_exchangeImplementations(overrideMethod, originalMethod)
    }
}
