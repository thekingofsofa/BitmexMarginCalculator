//
//  LabelSegmentedView.swift
//  BitMEXMarginCalculator
//
//  Created by Иван Барабанщиков on 9/20/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

class LabelSegmentedView: UIView {
    
    var titleLabel = UILabel()
    var segmentedControl = UISegmentedControl()
    
    convenience init(titleText: String, segmentedOptions: [String]) {
        self.init(frame: CGRect())
        
        setupView(titleText: titleText, segmentedOptions: segmentedOptions)
    }
    
    func setupView(titleText: String, segmentedOptions: [String]) {
        
        titleLabel.text = titleText
        titleLabel.setScaledCustomFont(forFont: .RobotoRegular, textStyle: .body)
        
        segmentedControl = UISegmentedControl(items: segmentedOptions)
        segmentedControl.tintColor = .silver
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, segmentedControl])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 0
        self.addSubview(stackView)
        
        stackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
