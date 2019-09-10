//
//  UIView+LocalizationManager.swift
//  LocalizationManager
//
//  Created by Tuan Tran on 9/3/19.
//

import Foundation
import UIKit

public extension UIView {
    
    func updateCurrentLayoutDirection() {
        semanticContentAttribute = LocalizationManager.shared.currentSemanticContentAttribute
    }
}
