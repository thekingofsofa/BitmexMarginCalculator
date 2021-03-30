//
//  TradingPairEnum.swift
//  BitmexMarginCalculator
//
//  Created by Иван Барабанщиков on 10/1/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import Foundation

enum TradingPair: String, CaseIterable {
    
    case XBTUSD
    case XBTH21
    case XBTM21
    case ETHUSD
    
    var takerFee: Double {
        switch self {
        case .XBTUSD:
            return -0.00075
        case .XBTH21:
            return -0.00075
        case .XBTM21:
            return -0.00075
        case .ETHUSD:
            return -0.0025
        }
    }
    
    var makerFee: Double {
        switch self {
        case .XBTUSD:
            return 0.00025
        case .XBTH21:
            return 0.00025
        case .XBTM21:
            return 0.00025
        case .ETHUSD:
            return 0.0005
        }
    }
    
    var maxLeverage: Int {
        switch self {
        case .XBTUSD:
            return 100
        case .XBTH21:
            return 100
        case .XBTM21:
            return 100
        case .ETHUSD:
            return 50
        }
    }
    
    var router: Router {
        switch self {
        case .XBTUSD, .XBTH21, .XBTM21, .ETHUSD:
            return .getLastPrice(tradePair: self.rawValue)
        }
    }
    
    var formatStyle: String {
        switch self {
        case .XBTUSD, .XBTH21, .XBTM21:
            return "%.2f"
        case .ETHUSD:
            return "%.2f"
//        case .XRPUSD:
//            return "%.8f"
        }
    }
}
