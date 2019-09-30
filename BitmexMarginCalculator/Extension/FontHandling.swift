//
//  FontHandling.swift
//  BitMEXMarginCalculator
//
//  Created by Иван Барабанщиков on 9/20/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

enum FontName: String {
    
    case RobotoBold             = "Roboto-Bold"
    case RobotoLight            = "Roboto_Light"
    case RobotoMedium           = "Roboto-Medium"
    case RobotoRegular          = "Roboto-Regular"
}

extension UIView {
    
    func getScaledFont(forFont name: FontName, textStyle: UIFont.TextStyle) -> UIFont {
        
        let userFont =  UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
        let pointSize = userFont.pointSize
        guard let customFont = UIFont(name: name.rawValue, size: pointSize) else {
            fatalError("""
                Failed to load the "\(name)" font.
                Make sure the font file is included in the project and the font name is spelled correctly.
                """
            )
        }
        return UIFontMetrics.default.scaledFont(for: customFont, maximumPointSize: 24)
    }
}

extension UILabel {
    
    func setScaledCustomFont(forFont name: FontName, textStyle: UIFont.TextStyle) {
        self.font = getScaledFont(forFont: name, textStyle: textStyle)
        self.adjustsFontForContentSizeCategory = true
    }
}

extension UITextView {
    
    func setScaledCustomFont(forFont name: FontName, textStyle: UIFont.TextStyle) {
        self.font = getScaledFont(forFont: name, textStyle: textStyle)
        self.adjustsFontForContentSizeCategory = true
    }
}
