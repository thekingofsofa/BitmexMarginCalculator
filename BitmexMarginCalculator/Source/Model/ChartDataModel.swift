//
//  ChartDataModel.swift
//  TestChart
//
//  Created by Иван Барабанщиков on 11/17/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import Foundation

struct ChartDataModel: Codable {
    
    let timestamp: String
    let symbol: String
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double
}
