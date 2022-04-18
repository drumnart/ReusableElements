//
//  Bundle+Extensions.swift
//
//  Created by Sergey Gorin on 30/05/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import Foundation

extension Bundle {
    
    /// Current version
    var releaseVersion: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    /// Current Build Version
    var buildVersion: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    
    /// Checks if Developer Mode is enabled in Build Settings
    var isDevModeEnabled: Bool {
        if let configuration = object(forInfoDictionaryKey: "Developer Mode") as? String,
            configuration.range(of: "enabled") != nil {
            return true
        }
        return false
    }
}
