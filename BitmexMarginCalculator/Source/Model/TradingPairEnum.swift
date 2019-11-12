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
    case XBTZ19
    case XBTH20
    case ADAZ19
    case BCHZ19
    case EOSZ19
    case ETHUSD
    case ETHZ19
    case LTCZ19
    case TRXZ19
    case XRPZ19
    
    var takerFee: Double {
        switch self {
        case .XBTUSD:
            return -0.00075
        case .XBTZ19:
            return -0.00075
        case .XBTH20:
            return -0.00075
        case .ADAZ19:
            return -0.0025
        case .BCHZ19:
            return -0.0025
        case .EOSZ19:
            return -0.0025
        case .ETHUSD:
            return -0.0025
        case .ETHZ19:
            return -0.0025
        case .LTCZ19:
            return -0.0025
        case .TRXZ19:
            return -0.0025
        case .XRPZ19:
            return -0.0025
        }
    }
    
    var makerFee: Double {
        switch self {
        case .XBTUSD:
            return 0.00025
        case .XBTZ19:
            return 0.00025
        case .XBTH20:
            return 0.00025
        case .ADAZ19:
            return 0.0005
        case .BCHZ19:
            return 0.0005
        case .EOSZ19:
            return 0.0005
        case .ETHUSD:
            return 0.0005
        case .ETHZ19:
            return 0.0005
        case .LTCZ19:
            return 0.0005
        case .TRXZ19:
            return 0.0005
        case .XRPZ19:
            return 0.0005
        }
    }
    
    var maxLeverage: Int {
        switch self {
        case .XBTUSD:
            return 100
        case .XBTZ19:
            return 100
        case .XBTH20:
            return 100
        case .ADAZ19:
            return 20
        case .BCHZ19:
            return 20
        case .EOSZ19:
            return 20
        case .ETHUSD:
            return 50
        case .ETHZ19:
            return 50
        case .LTCZ19:
            return 33
        case .TRXZ19:
            return 20
        case .XRPZ19:
            return 20
        }
    }
    
    var router: Router {
        switch self {
        case .XBTUSD, .XBTZ19, .XBTH20, .ADAZ19, .BCHZ19, .EOSZ19, .ETHUSD, .ETHZ19, .LTCZ19, .TRXZ19, .XRPZ19:
            return .getLastPrice(tradePair: self.rawValue)
        }
    }
    
    var formatStyle: String {
        switch self {
        case .XBTUSD, .XBTH20, .XBTZ19:
            return "%.2f"
        case .ADAZ19:
            return "%.8f"
        case .BCHZ19:
            return "%.5f"
        case .EOSZ19:
            return "%.7f"
        case .ETHUSD:
            return "%.2f"
        case .ETHZ19:
            return "%.5f"
        case .LTCZ19:
            return "%.6f"
        case .TRXZ19:
            return "%.8f"
        case .XRPZ19:
            return "%.8f"
        }
    }
}
