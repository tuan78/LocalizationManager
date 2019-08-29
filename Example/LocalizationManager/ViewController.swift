//
//  ViewController.swift
//  LocalizationManager
//
//  Created by Tuan Tran on 08/28/2019.
//  Copyright (c) 2019 Tuan Tran. All rights reserved.
//

import UIKit
import LocalizationManager

class ViewController: UIViewController {
    
    @IBOutlet weak private var firstLabel: UILabel!
    @IBOutlet weak private var secondLabel: UILabel!
    
    private let defaultLanguageCode = "en"
    private let testLTRLanguageCode = "ar"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(languageDidChange),
                         name: .LMLanguageDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction private func changeLanguageButtonDidTouchUpInside() {
        let sharedLocalizationManager = LocalizationManager.shared
        if sharedLocalizationManager.currentLanguage != defaultLanguageCode {
            sharedLocalizationManager.currentLanguage = defaultLanguageCode
        } else {
            sharedLocalizationManager.currentLanguage = testLTRLanguageCode
        }
    }
    
    @objc private func languageDidChange() {
        var message = "LanguageDidChange:  \(NSLocalizedString("hello", comment: ""))"
        if LocalizationManager.shared.isRTL {
            message += " with RTL supports"
        }
        print(message)
        openMainViewController()
    }
    
    private func openMainViewController() {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        guard let rootViewController = window.rootViewController else {
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        vc?.view.frame = rootViewController.view.frame
        vc?.view.layoutIfNeeded()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = vc
        }, completion: nil)
    }
}
