//
//  Router.swift
//  BitmexMarginCalculator
//
//  Created by Иван Барабанщиков on 10/11/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import Foundation

enum Router {
    case getXBTUSD
    case getXBTZ19
    case getXBTH20
    case getETHUSD
    case getETHZ19
    case getADAZ19
    case getBCHZ19
    case getEOSZ19
    case getLTCZ19
    case getTRXZ19
    case getXRPZ19
    
    var scheme: String {
        switch self {
        case .getXBTUSD, .getXBTZ19, .getXBTH20, .getETHUSD, .getETHZ19, .getADAZ19, .getBCHZ19, .getEOSZ19, .getLTCZ19, .getTRXZ19, .getXRPZ19:
            return "https"
        }
    }
    var host: String {
        switch self {
        case .getXBTUSD, .getXBTZ19, .getXBTH20, .getETHUSD, .getETHZ19, .getADAZ19, .getBCHZ19, .getEOSZ19, .getLTCZ19, .getTRXZ19, .getXRPZ19:
            return "www.bitmex.com"
        }
    }
    var path: String {
        switch self {
        case .getXBTUSD, .getXBTZ19, .getXBTH20, .getETHUSD, .getETHZ19, .getADAZ19, .getBCHZ19, .getEOSZ19, .getLTCZ19, .getTRXZ19, .getXRPZ19:
            return "/api/v1/trade"
        }
    }
    var method: String {
        switch self {
        case .getXBTUSD, .getXBTZ19, .getXBTH20, .getETHUSD, .getETHZ19, .getADAZ19, .getBCHZ19, .getEOSZ19, .getLTCZ19, .getTRXZ19, .getXRPZ19:
            return "GET"
        }
    }
    var parameters: [URLQueryItem] {
        switch self {
        case .getXBTUSD:
            return [URLQueryItem(name: "symbol", value: "XBTUSD"),
                    URLQueryItem(name: "count", value: "1"),
                    URLQueryItem(name: "reverse", value: "true")]
        case .getXBTH20:
            return [URLQueryItem(name: "symbol", value: "XBTZ19"),
                    URLQueryItem(name: "count", value: "1"),
                    URLQueryItem(name: "reverse", value: "true")]
        case .getXBTZ19:
            return [URLQueryItem(name: "symbol", value: "XBTH20"),
                    URLQueryItem(name: "count", value: "1"),
                    URLQueryItem(name: "reverse", value: "true")]
        case .getETHUSD:
            return [URLQueryItem(name: "symbol", value: "ETHUSD"),
                    URLQueryItem(name: "count", value: "1"),
                    URLQueryItem(name: "reverse", value: "true")]
        case .getETHZ19:
            return [URLQueryItem(name: "symbol", value: "ETHXBT"),
                    URLQueryItem(name: "count", value: "1"),
                    URLQueryItem(name: "reverse", value: "true")]
        case .getADAZ19:
            return [URLQueryItem(name: "symbol", value: "ADAZ19"),
                    URLQueryItem(name: "count", value: "1"),
                    URLQueryItem(name: "reverse", value: "true")]
        case .getBCHZ19:
            return [URLQueryItem(name: "symbol", value: "BCHZ19"),
                    URLQueryItem(name: "count", value: "1"),
                    URLQueryItem(name: "reverse", value: "true")]
        case .getEOSZ19:
            return [URLQueryItem(name: "symbol", value: "EOSZ19"),
                    URLQueryItem(name: "count", value: "1"),
                    URLQueryItem(name: "reverse", value: "true")]
        case .getLTCZ19:
            return [URLQueryItem(name: "symbol", value: "LTCZ19"),
                    URLQueryItem(name: "count", value: "1"),
                    URLQueryItem(name: "reverse", value: "true")]
        case .getTRXZ19:
            return [URLQueryItem(name: "symbol", value: "TRXZ19"),
                    URLQueryItem(name: "count", value: "1"),
                    URLQueryItem(name: "reverse", value: "true")]
        case .getXRPZ19:
            return [URLQueryItem(name: "symbol", value: "XRPZ19"),
                    URLQueryItem(name: "count", value: "1"),
                    URLQueryItem(name: "reverse", value: "true")]
        }
    }
}
