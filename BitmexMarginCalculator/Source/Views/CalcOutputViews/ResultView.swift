//
//  ResultView.swift
//  BitMEXMarginCalculator
//
//  Created by Иван Барабанщиков on 9/20/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

class ResultView: UIView {
    
    var separatorLine = UIView()
    var quantityBTC = OutputLabelView(titleText: "Quantity BTC", resultText: "")
    var btcPriceChange = OutputLabelView(titleText: "Price change %", resultText: "")
    var profitLossBTC = OutputLabelView(titleText: "Profit/Loss in BTC", resultText: "")
    var profitLossUSD = OutputLabelView(titleText: "Profit/Loss in USD", resultText: "")
    var roe = OutputLabelView(titleText: "ROE %", resultText: "")
    var liquidationPrice = OutputLabelView(titleText: "Liquidation price", resultText: "")
    var fees = OutputLabelView(titleText: "Fee", resultText: "")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setupView() {
        self.layer.borderColor = UIColor.grayLight.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 8.0
        self.backgroundColor = .white
        
        // Make gray background for every second element in view
        var elements = [quantityBTC, btcPriceChange, profitLossBTC, profitLossUSD, roe, liquidationPrice, fees]
        elements = elements.enumerated().compactMap { index, element in
            index % 2 != 0 ? element : nil
        }
        elements.forEach {
            $0.backgroundColor = UIColor.silverAlpha }
        
        // Creating UIStackView
        let resultDataStackView = UIStackView(arrangedSubviews: [quantityBTC, btcPriceChange, profitLossBTC, profitLossUSD, roe, liquidationPrice, fees])
        resultDataStackView.distribution = .fillEqually
        resultDataStackView.axis = .vertical
        resultDataStackView.spacing = 0
        self.addSubview(resultDataStackView)
        
        // Creating center line to separate names from results
        self.addSubview(separatorLine)
        separatorLine.anchor(top: topAnchor, leading: nil, bottom: bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        separatorLine.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
        separatorLine.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        separatorLine.backgroundColor = .grayLight
        
        // Layout constraints
        resultDataStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        [quantityBTC, btcPriceChange, profitLossBTC, profitLossUSD, roe, liquidationPrice, fees].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }
    }
    
    func showHideFees() {
        fees.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
