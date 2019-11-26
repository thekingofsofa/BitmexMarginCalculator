//
//  Router.swift
//  BitmexMarginCalculator
//
//  Created by Иван Барабанщиков on 10/11/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import Foundation

enum Router {
    case getBucketData(timeFrame: String, tradePair: String)
    case getLastPrice(tradePair: String)
    
    var scheme: String {
        switch self {
        case .getLastPrice, .getBucketData:
            return "https"
        }
    }
    var host: String {
        switch self {
        case .getLastPrice, .getBucketData:
            return "www.bitmex.com"
        }
    }
    var path: String {
        switch self {
        case .getLastPrice:
            return "/api/v1/trade"
        case .getBucketData:
            return "/api/v1/trade/bucketed"
        }
    }
    var method: String {
        switch self {
        case .getLastPrice, .getBucketData:
            return "GET"
        }
    }
    var parameters: [URLQueryItem] {
        switch self {
        case .getLastPrice(let tradePair):
            return [URLQueryItem(name: "symbol", value: tradePair),
                    URLQueryItem(name: "count", value: "1"),
                    URLQueryItem(name: "reverse", value: "true")]
        case .getBucketData(let timeFrame, let tradePair):
            return [URLQueryItem(name: "binSize", value: timeFrame),
                    URLQueryItem(name: "partial", value: "true"),
                    URLQueryItem(name: "symbol", value: tradePair),
                    URLQueryItem(name: "count", value: "300"),
                    URLQueryItem(name: "reverse", value: "true")]
        }
    }
}
