//
//  BitmexPricesResponseModel.swift
//  BitmexMarginCalculator
//
//  Created by Иван Барабанщиков on 19.03.2021.
//  Copyright © 2021 Ivan Barabanshchykov. All rights reserved.
//

import Foundation

struct BitmexPricesResponse: Codable {
    
    let data: [LastPrice]
}
