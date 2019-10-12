//
//  LastPrice.swift
//  BitmexMarginCalculator
//
//  Created by Иван Барабанщиков on 10/10/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import Foundation

struct LastPrice: Codable {
    var timestamp: String
    var symbol: String
    var price: Double
}
