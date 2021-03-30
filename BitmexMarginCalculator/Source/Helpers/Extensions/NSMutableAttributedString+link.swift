//
//  NSMutableAttributedString+link.swift
//  BitMEXMarginCalculator
//
//  Created by Иван Барабанщиков on 9/20/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
    
    public func setAsLink(textToFind: String, linkURL: String) {
        
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: foundRange)
        }
    }
}
