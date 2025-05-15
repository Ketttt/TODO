//
//  UserDefaults+Extension.swift
//  TODO
//
//  Created by Katerina Ivanova on 11.05.2025.
//

import Foundation

extension UserDefaults {
    
    var isFirstLaunch: Bool {
        get {
            !bool(forKey: "hasLaunchedBefore")
        } set {
            set(!newValue, forKey: "hasLaunchedBefore")
        }
    }
}
