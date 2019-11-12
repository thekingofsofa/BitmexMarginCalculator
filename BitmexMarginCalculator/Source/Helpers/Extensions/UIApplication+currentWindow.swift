//
//  UIApplication+currentWindow.swift
//  BitmexMarginCalculator
//
//  Created by Иван Барабанщиков on 11/11/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

extension UIApplication {
    var currentWindow: UIWindow? {
        connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first
    }
}
