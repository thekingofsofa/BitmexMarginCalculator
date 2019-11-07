//
//  SegmentedControlExtension.swift
//  BitMEXMarginCalculator
//
//  Created by Иван Барабанщиков on 9/20/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

extension UISegmentedControl {
    
    // create a 1x1 image with this color
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width:  1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
    
    func removeBackgroundColors() {
        self.setBackgroundImage(imageWithColor(color: .clear), for: .normal, barMetrics: .default)
        self.setBackgroundImage(imageWithColor(color: .clear), for: .selected, barMetrics: .default)
        self.setDividerImage(imageWithColor(color: UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
    
    struct viewPosition {
        let originX: CGFloat
        let originIndex: Int
    }
    
    func updateTintColor(firstSection: UIColor, secondSection: UIColor) {
        
        setDividerImage(imageWithColor(color: UIColor.black), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 8.0
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.masksToBounds = true
        let font = UIFont.systemFont(ofSize: 16)
        self.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        let titleColor = [NSAttributedString.Key.foregroundColor: UIColor.black]
        let selectedTitleColor = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.setTitleTextAttributes(titleColor as [NSAttributedString.Key : Any], for: .normal)
        self.setTitleTextAttributes(selectedTitleColor as [NSAttributedString.Key : Any], for: .selected)
        
        let views = self.subviews
        var positions = [viewPosition]()
        for (i, view) in views.enumerated() {
            let position = viewPosition(originX: view.frame.origin.x, originIndex: i)
            positions.append(position)
        }
        positions.sort(by: { $0.originX < $1.originX })
        
        for (i, position) in positions.enumerated() {
            let view = self.subviews[position.originIndex]
            if i == 0 {
                view.tintColor = firstSection
            } else if i == 1 {
                view.tintColor = secondSection
            }
        }
        ensureiOS12Style()
    }
}

extension UISegmentedControl {
    /// Tint color doesn't have any effect on iOS 13.
    func ensureiOS12Style() {
        if #available(iOS 13, *) {
            let tintColorImage = imageWithColor(color: tintColor)
            // Must set the background image for normal to something (even clear) else the rest won't work
            setBackgroundImage(imageWithColor(color: backgroundColor ?? .clear), for: .normal, barMetrics: .default)
            setBackgroundImage(tintColorImage, for: .selected, barMetrics: .default)
            setBackgroundImage(imageWithColor(color: tintColor.withAlphaComponent(0.2)), for: .highlighted, barMetrics: .default)
            setBackgroundImage(tintColorImage, for: [.highlighted, .selected], barMetrics: .default)
            setTitleTextAttributes([.foregroundColor: tintColor ?? .clear, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .regular)], for: .normal)
            
            setDividerImage(tintColorImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
            layer.borderWidth = 1
            layer.borderColor = tintColor.cgColor
        }
    }
}
