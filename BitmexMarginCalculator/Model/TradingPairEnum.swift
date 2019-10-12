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
            return 0.005
        case .BCHZ19:
            return 0.005
        case .EOSZ19:
            return 0.005
        case .ETHUSD:
            return 0.005
        case .ETHZ19:
            return 0.005
        case .LTCZ19:
            return 0.005
        case .TRXZ19:
            return 0.005
        case .XRPZ19:
            return 0.005
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
}
