//
//  OutputLabelView.swift
//  BitMEXMarginCalculator
//
//  Created by Иван Барабанщиков on 9/20/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

class OutputLabelView: UIView {

    var titleLabel = UILabel()
    var resultLabel = LabelWithInfoButton()
    
    convenience init(titleText: String, resultText: String) {
        self.init(frame: CGRect())
        setupView(titleText: titleText, resultText: resultText)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    func setupView(titleText: String, resultText: String) {
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, resultLabel])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 12
        
        self.addSubview(stackView)
        
        stackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 12, bottom: 0, right: 12))
        
        titleLabel.setScaledCustomFont(forFont: .robotoRegular, textStyle: .body)
        resultLabel.setScaledCustomFont(forFont: .robotoRegular, textStyle: .body)
        titleLabel.text = titleText
        titleLabel.adjustsFontSizeToFitWidth = true
        resultLabel.text = resultText
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
