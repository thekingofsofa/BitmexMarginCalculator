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
    case getETHUSD
    case getETHBTC
    case getADABTC
    case getBCHBTC
    case getEOSBTC
    case getLTCBTC
    case getTRXBTC
    case getXRPBTC
    
    var scheme: String {
        switch self {
        case .getXBTUSD, .getETHUSD, .getETHBTC, .getADABTC, .getBCHBTC, .getEOSBTC, .getLTCBTC, .getTRXBTC, .getXRPBTC:
            return "https"
        }
    }
    var host: String {
        switch self {
        case .getXBTUSD, .getETHUSD, .getETHBTC, .getADABTC, .getBCHBTC, .getEOSBTC, .getLTCBTC, .getTRXBTC, .getXRPBTC:
            return "www.bitmex.com"
        }
    }
    var path: String {
        switch self {
        case .getXBTUSD, .getETHUSD, .getETHBTC, .getADABTC, .getBCHBTC, .getEOSBTC, .getLTCBTC, .getTRXBTC, .getXRPBTC:
            return "/api/v1/trade"
        }
    }
    var method: String {
        switch self {
        case .getXBTUSD, .getETHUSD, .getETHBTC, .getADABTC, .getBCHBTC, .getEOSBTC, .getLTCBTC, .getTRXBTC, .getXRPBTC:
            return "GET"
        }
    }
    var parameters: [URLQueryItem] {
        switch self {
        case .getXBTUSD:
            return [URLQueryItem(name: "symbol", value: "XBT"),
                    URLQueryItem(name: "count", value: "1"),
                    URLQueryItem(name: "reverse", value: "true")]
        case .getETHUSD:
            return [URLQueryItem(name: "symbol", value: "ETH"),
                    URLQueryItem(name: "count", value: "1"),
                    URLQueryItem(name: "reverse", value: "true")]
        case .getETHBTC:
            return [URLQueryItem(name: "symbol", value: "ETHXBT"),
                    URLQueryItem(name: "count", value: "1"),
                    URLQueryItem(name: "reverse", value: "true")]
        case .getADABTC:
            return [URLQueryItem(name: "symbol", value: "ADA"),
                    URLQueryItem(name: "count", value: "1"),
                    URLQueryItem(name: "reverse", value: "true")]
        case .getBCHBTC:
            return [URLQueryItem(name: "symbol", value: "BCH"),
                    URLQueryItem(name: "count", value: "1"),
                    URLQueryItem(name: "reverse", value: "true")]
        case .getEOSBTC:
            return [URLQueryItem(name: "symbol", value: "EOS"),
                    URLQueryItem(name: "count", value: "1"),
                    URLQueryItem(name: "reverse", value: "true")]
        case .getLTCBTC:
            return [URLQueryItem(name: "symbol", value: "LTC"),
                    URLQueryItem(name: "count", value: "1"),
                    URLQueryItem(name: "reverse", value: "true")]
        case .getTRXBTC:
            return [URLQueryItem(name: "symbol", value: "TRX"),
                    URLQueryItem(name: "count", value: "1"),
                    URLQueryItem(name: "reverse", value: "true")]
        case .getXRPBTC:
            return [URLQueryItem(name: "symbol", value: "XRP"),
                    URLQueryItem(name: "count", value: "1"),
                    URLQueryItem(name: "reverse", value: "true")]
        }
    }
}
