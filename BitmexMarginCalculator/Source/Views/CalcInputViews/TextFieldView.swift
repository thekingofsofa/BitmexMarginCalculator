//
//  TextFieldView.swift
//  BitMEXMarginCalculator
//
//  Created by Иван Барабанщиков on 9/20/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

class TextFieldView: UIView {

    var textFieldNameLabel = UILabel()
    var textFieldInputView = UITextFieldWithDoneButton()
    
    convenience init(textFieldName: String) {
        self.init(frame: CGRect())
        setupView(textFieldName: textFieldName)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setupView(textFieldName: String) {
        
        let stackView = UIStackView(arrangedSubviews: [textFieldNameLabel, textFieldInputView])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 0
        self.addSubview(stackView)
        stackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        
        textFieldNameLabel.text = textFieldName
        textFieldNameLabel.adjustsFontSizeToFitWidth = true
        textFieldNameLabel.setScaledCustomFont(forFont: .RobotoRegular, textStyle: .body)
        
        textFieldInputView.font = textFieldNameLabel.font
        textFieldInputView.backgroundColor = .orangeLightAlpha
        textFieldInputView.keyboardType = .decimalPad
        textFieldInputView.returnKeyType = .done
        textFieldInputView.layer.masksToBounds = true
        textFieldInputView.layer.cornerRadius = 8.0
        textFieldInputView.layer.borderColor = UIColor.grayLight.cgColor
        textFieldInputView.layer.borderWidth = 1
        
        let leftPaddingView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 6.0, height: 2.0))
        textFieldInputView.leftView = leftPaddingView
        textFieldInputView.leftViewMode = .always
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
