//
//  String+LocalizationManager.swift
//  LocalizationManager
//
//  Created by Tuan Tran on 9/3/19.
//

import Foundation

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
