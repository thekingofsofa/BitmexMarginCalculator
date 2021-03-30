//
//  LastPriceView.swift
//  BitMEXMarginCalculator
//
//  Created by Иван Барабанщиков on 10/10/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

protocol LastPriceViewDelegate {
    
    func switchedTimeIntervalControl(timeInterval: String)
    func collapseAction(isCollapsed: Bool)
}

class LastPriceView: UIView {
    
    var delegate: LastPriceViewDelegate?
    
    let chart = IBCandlestickChartView()
    let collapseButton = UIButton()
    let priceLabel = UILabel()
    var isCollapsed = true
    var collapseAction: (() -> Void)?
    
    let statusIcon = UIImageView()
    private var timeIntervalControl = UISegmentedControl()
    var candlestickTimeIntervals = ["1m", "5m", "1h", "1d"]
    var selectedTimeInterval = "1h"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    func checkIfCollapsed() {
        
        if isCollapsed {
            statusIcon.isHidden = false
            priceLabel.isHidden = false
            chart.isHidden = true
            timeIntervalControl.isHidden = true
            statusIcon.alpha = 1
            priceLabel.alpha = 1
            chart.alpha = 0
            timeIntervalControl.alpha = 0
        } else {
            statusIcon.isHidden = true
            priceLabel.isHidden = true
            chart.isHidden = false
            timeIntervalControl.isHidden = false
            statusIcon.alpha = 0
            priceLabel.alpha = 0
            chart.alpha = 1
            timeIntervalControl.alpha = 1
        }
    }
    
    func setPriceLabel(traidingPairString: String, priceString: String) {
        
        self.priceLabel.text = "Last \(traidingPairString) price: " + priceString
    }
    
    func collapseView() {
        if !isCollapsed {
            collapseButtonPressed()
        }
    }
    
    @objc private func collapseButtonPressed() {
        
        isCollapsed = !isCollapsed
        self.collapseAction?()
        UIView.animate(withDuration: 0.5) {
            self.collapseButton.imageView?.transform = self.collapseButton.imageView?.transform.rotated(by: 180 * CGFloat(Double.pi/180)) ?? CGAffineTransform()
            self.checkIfCollapsed()
        }
        self.delegate?.collapseAction(isCollapsed: isCollapsed)
    }
    
    @objc private  func switchTimeIntervalControl(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            selectedTimeInterval = candlestickTimeIntervals[3]
        case 1:
            selectedTimeInterval = candlestickTimeIntervals[2]
        case 2:
            selectedTimeInterval = candlestickTimeIntervals[1]
        case 3:
            selectedTimeInterval = candlestickTimeIntervals[0]
        default:
            break
        }
        delegate?.switchedTimeIntervalControl(timeInterval: selectedTimeInterval)
    }
    
    private func setupView() {
        
        self.backgroundColor = .white
        self.layer.borderColor = UIColor.grayLight.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 6.0
        
        [statusIcon, priceLabel, chart, collapseButton, timeIntervalControl].forEach {
            addSubview($0)
        }
        
        for timeInterval in candlestickTimeIntervals {
            timeIntervalControl.insertSegment(withTitle: timeInterval, at: 0, animated: false)
        }
        timeIntervalControl.addTarget(self, action: #selector(switchTimeIntervalControl), for: .valueChanged)
        timeIntervalControl.selectedSegmentIndex = 1
        timeIntervalControl.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: collapseButton.leadingAnchor, padding: .init(top: 12, left: 12, bottom: 12, right: 12))
        timeIntervalControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        collapseButton.setImage(UIImage(named: "arrow"), for: .normal)
        collapseButton.contentHorizontalAlignment = .fill
        collapseButton.contentVerticalAlignment = .fill
        collapseButton.imageView?.contentMode = .scaleAspectFit
        collapseButton.addTarget(self, action: #selector(collapseButtonPressed), for: .touchUpInside)
        
        collapseButton.anchor(top: topAnchor, leading: nil, bottom: nil, trailing: trailingAnchor, padding: .init(top: 12, left: 0, bottom: 0, right: 12))
        collapseButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        collapseButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        statusIcon.image = UIImage(named: "ic_trending_up.png")
        statusIcon.contentMode = .scaleAspectFit
        
        statusIcon.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: nil, padding: .init(top: 4, left: 24, bottom: 4, right: 0))
        statusIcon.widthAnchor.constraint(lessThanOrEqualToConstant: 24).isActive = true
        priceLabel.setScaledCustomFont(forFont: .robotoRegular, textStyle: .body)
        priceLabel.adjustsFontSizeToFitWidth = true
        priceLabel.anchor(top: self.topAnchor, leading: statusIcon.trailingAnchor, bottom: self.bottomAnchor, trailing: collapseButton.leadingAnchor, padding: .init(top: 4, left: 12, bottom: 4, right: 12))
        
        chart.anchor(top: timeIntervalControl.bottomAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor, padding: .init(top: 12, left: 0, bottom: 0, right: 0))
        
        checkIfCollapsed()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
