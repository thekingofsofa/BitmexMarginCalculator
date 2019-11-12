//
//  BuckedData.swift
//  BitmexMarginCalculator
//
//  Created by Иван Барабанщиков on 11/12/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import Foundation

struct BuckedData: Codable {
    
    var timestamp: String
    var symbol: String
    var open: Double
    var high: Double
    var low: Double
    var close: Double
    var volume: Double
}
