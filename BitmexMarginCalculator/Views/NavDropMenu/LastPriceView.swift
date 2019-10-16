//
//  LastPriceView.swift
//  BitMEXMarginCalculator
//
//  Created by Иван Барабанщиков on 10/10/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

class LastPriceView: UIView {
    
    let statusIcon = UIImageView()
    let priceLabel = UILabel()
    let bottomBorder = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        
        [statusIcon, priceLabel, bottomBorder].forEach {
            addSubview($0)
        }
        
        statusIcon.image = UIImage(named: "ic_trending_up.png")
        statusIcon.contentMode = .scaleAspectFit
        
        statusIcon.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: nil, padding: .init(top: 4, left: 24, bottom: 4, right: 0))
        statusIcon.widthAnchor.constraint(lessThanOrEqualToConstant: 24).isActive = true
        priceLabel.setScaledCustomFont(forFont: .RobotoRegular, textStyle: .body)
        priceLabel.anchor(top: self.topAnchor, leading: statusIcon.trailingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor, padding: .init(top: 4, left: 12, bottom: 4, right: 12))
        bottomBorder.backgroundColor = UIColor(red:0.68, green:0.68, blue:0.68, alpha:1.0)
        bottomBorder.anchor(top: nil, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor)
        bottomBorder.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
