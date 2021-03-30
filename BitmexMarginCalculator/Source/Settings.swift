//
//  Settings.swift
//  BitMEXMarginCalculator
//
//  Created by Иван Барабанщиков on 9/20/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import Foundation

class Settings {
    
    static let shared = Settings()
    
    var showFees = true
    var showLastPrice = true
    let listOfAllTradingPairs: [String] = {
        var array = [String]()
        TradingPair.allCases.forEach {
            array.append($0.rawValue)
        }
        return array
    }()
    
    var selectedTradingPair = TradingPair.XBTUSD
}

enum SettingsButtons: String {
    case showHideLastPrice
    case showHideFees
    case aboutApp
    case aboutLiquidation
    case feesInfo
    case cancel
    case separator
    
    var title: String {
        switch self {
        case .showHideLastPrice:
            return "Show BTC last price"
        case .showHideFees:
            return "Calculate fees"
        case .aboutApp:
            return "About app"
        case .aboutLiquidation:
            return "How liquidation works?"
        case .cancel:
            return "Cancel"
        case .separator:
            return ""
        case .feesInfo:
            return "Fees"
        }
    }
}
