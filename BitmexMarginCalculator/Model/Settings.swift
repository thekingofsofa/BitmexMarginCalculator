//
//  Settings.swift
//  BitMEXMarginCalculator
//
//  Created by Иван Барабанщиков on 9/20/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import Foundation

enum SettingsButtons: String {
    case showHideFees
    case aboutApp
    case aboutLiqudation
    case cancel
    case separator
    
    var title: String {
        switch self {
        case .showHideFees:
            return "Show with fees"
        case .aboutApp:
            return "About app"
        case .aboutLiqudation:
            return "How liqudation works?"
        case .cancel:
            return "Cancel"
        case .separator:
            return ""
        }
    }
}

class Settings {
    
    static let shared = Settings()
    
    var showFees = true
}
