//
//  LabelWithInfoButton.swift
//  BitmexMarginCalculator
//
//  Created by Иван Барабанщиков on 9/30/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

class LabelWithInfoButton: UILabel {

    var infoButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func addInfoButton() {
        self.addSubview(infoButton)
        self.isUserInteractionEnabled = true
        infoButton.anchor(top: topAnchor, leading: nil, bottom: bottomAnchor, trailing: trailingAnchor)
        infoButton.setImage(UIImage(named: "more_info_btn"), for: .normal)
        infoButton.alpha = 0.6
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
