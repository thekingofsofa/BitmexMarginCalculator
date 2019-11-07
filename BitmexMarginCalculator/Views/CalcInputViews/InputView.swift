//
//  InputView.swift
//  BitmexMarginCalculator
//
//  Created by Иван Барабанщиков on 11/7/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

class InputView: UIView {
    
    var entryDataStackView: UIStackView!
    var longShortSwitcher = UISegmentedControl()
    var quantity = TextFieldView(textFieldName: "Quantity ($)")
    var entryPrice = TextFieldView(textFieldName: "Entry price")
    var exitPrice = TextFieldView(textFieldName: "Exit price")
    var leverageSize = TextFieldView(textFieldName: "Leverage")
    var enterOrder = LabelSegmentedView(titleText: "Enter order", segmentedOptions: ["Limit", "Market"])
    var closeOrder = LabelSegmentedView(titleText: "Close order", segmentedOptions: ["Limit", "Market"])
    var btcPriceWhenEnter = TextFieldView(textFieldName: "BTC price when entry")
    var btcPriceWhenExit = TextFieldView(textFieldName: "BTC price when exit")

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setupView() {
        // Setup long Short Switcher
        longShortSwitcher = UISegmentedControl(items: ["Long", "Short"])
        longShortSwitcher.updateTintColor(firstSection: UIColor(red:0.21, green:0.75, blue:0.00, alpha:1.0), secondSection: UIColor.red)
        
        // Setup StackView
        entryDataStackView = UIStackView(arrangedSubviews: [longShortSwitcher, quantity, entryPrice, exitPrice, leverageSize, enterOrder, closeOrder, btcPriceWhenEnter, btcPriceWhenExit])
        entryDataStackView.distribution = .fillEqually
        entryDataStackView.axis = .vertical
        entryDataStackView.spacing = 10
        self.addSubview(entryDataStackView)
        
        // Layout
        entryDataStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        [longShortSwitcher, quantity, entryPrice, exitPrice, leverageSize, enterOrder, closeOrder, btcPriceWhenEnter, btcPriceWhenExit].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
