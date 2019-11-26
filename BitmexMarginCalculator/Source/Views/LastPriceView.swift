//
//  LastPriceView.swift
//  BitMEXMarginCalculator
//
//  Created by Иван Барабанщиков on 10/10/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

class LastPriceView: UIView {
    
    let chart = IBCandlestickChartView()
    let collapseButton = UIButton()
    let priceLabel = UILabel()
    var isCollapsed = true
    var collapseAction: (() -> Void)?
    
    private let statusIcon = UIImageView()
    private var timeIntervalControl = UISegmentedControl()
    private var activityIndicator = UIActivityIndicatorView()
    private let candlestickTimeIntervals = ["1m", "5m", "1h", "1d"]
    private var selectedTimeInterval = "1h"
    private var getLastPriceTimer = Timer()
    private var getChartTimer = Timer()
    
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
            startFeedLastPriceWithData()
        } else {
            statusIcon.isHidden = true
            priceLabel.isHidden = true
            chart.isHidden = false
            timeIntervalControl.isHidden = false
            statusIcon.alpha = 0
            priceLabel.alpha = 0
            chart.alpha = 1
            timeIntervalControl.alpha = 1
            startFeedChartWithData()
        }
    }
    
    @objc func collapseButtonPressed() {
        isCollapsed = !isCollapsed
        self.collapseAction?()
        UIView.animate(withDuration: 0.5) {
            self.collapseButton.imageView?.transform = self.collapseButton.imageView?.transform.rotated(by: 180 * CGFloat(Double.pi/180)) ?? CGAffineTransform()
            self.checkIfCollapsed()
        }
    }
    
    @objc func switchTimeIntervalControl(_ sender: UISegmentedControl) {
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
        startFeedChartWithData()
    }
    
    private func setupView() {
        
        self.backgroundColor = .white
        self.layer.borderColor = UIColor.grayLight.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 6.0
        
        [statusIcon, priceLabel, chart, collapseButton, timeIntervalControl, activityIndicator].forEach {
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
        priceLabel.setScaledCustomFont(forFont: .RobotoRegular, textStyle: .body)
        priceLabel.adjustsFontSizeToFitWidth = true
        priceLabel.anchor(top: self.topAnchor, leading: statusIcon.trailingAnchor, bottom: self.bottomAnchor, trailing: collapseButton.leadingAnchor, padding: .init(top: 4, left: 12, bottom: 4, right: 12))
        
        chart.anchor(top: timeIntervalControl.bottomAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor, padding: .init(top: 12, left: 0, bottom: 0, right: 0))
        
        activityIndicator.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        
        checkIfCollapsed()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Networking
extension LastPriceView {
    
    func startFeedChartWithData() {
        getChartTimer.invalidate()
        getLastPriceTimer.invalidate()
        getChartTimer = Timer.scheduledTimer(timeInterval: 5.0,
                                             target: self,
                                             selector: #selector(getCandlestickChartData),
                                             userInfo: nil,
                                             repeats: true)
        activityIndicator.startAnimating()
        getCandlestickChartData()
    }
    
    func startFeedLastPriceWithData() {
        getChartTimer.invalidate()
        getLastPriceTimer.invalidate()
        getLastPriceTimer = Timer.scheduledTimer(timeInterval: 5.0,
                                                 target: self,
                                                 selector: #selector(getLatestPriceData),
                                                 userInfo: nil,
                                                 repeats: true)
        activityIndicator.startAnimating()
        getLatestPriceData()
    }
    
    @objc private func getCandlestickChartData() {
        let traidingPair = Settings.shared.selectedTradingPair
        let router = Router.getBucketData(timeFrame: selectedTimeInterval, tradePair: traidingPair.rawValue)
        let network = ServiceLayer()
        network.request(router: router) { [weak self] (result: Result<[ChartDataModel]>) in
            if self?.activityIndicator.isAnimating ?? false {
                self?.activityIndicator.stopAnimating()
            }
            switch result {
            case .success(let data):
                var values = [(close: Double, open: Double, high: Double, low: Double, volume: Double)]()
                var dates = [String]()
                for value in data {
                    values.append((close: value.close, open: value.open, high: value.high, low: value.low, volume: value.volume))
                    dates.append(value.timestamp)
                }
                self?.chart.draw(values: values, dates: dates)
            case .failure(let error):
                
                if error.code == -1000 {
                    self?.tooManyRequest()
                } else if error.code == -1009 {
                    self?.noInternet()
                }
                print(result)
            }
        }
    }
    
    @objc private func getLatestPriceData() {
        
        let traidingPair = Settings.shared.selectedTradingPair
        let network = ServiceLayer()
        network.request(router: traidingPair.router) { [weak self] (result: Result<[LastPrice]>) in
            if self?.activityIndicator.isAnimating ?? false {
                self?.activityIndicator.stopAnimating()
            }
            switch result {
            case .success(let data):
                self?.statusIcon.image = UIImage(named: "ic_trending_up.png")
                UIView.animate(withDuration: 0.3, animations: {
                    self?.priceLabel.alpha = 0.0
                }, completion: { (bool) in
                    let formatLiquidationStringStyle = Settings.shared.selectedTradingPair.formatStyle
                    let price = Double(truncating: NSDecimalNumber(decimal: data[0].price))
                    let priceString = String(format: formatLiquidationStringStyle, price)
                    self?.priceLabel.text = "Last \(traidingPair.rawValue) price: " + priceString
                    UIView.animate(withDuration: 0.3, animations: {
                        self?.priceLabel.alpha = 1.0
                    })
                })
            case .failure(let error):
                if error.code == -1000 {
                    self?.tooManyRequest()
                } else if error.code == -1009 {
                    self?.noInternet()
                }
                print(result)
            }
        }
    }
    
    func noInternet() {
        DispatchQueue.main.async {
            if !self.isCollapsed {
                self.collapseButtonPressed()
            }
            if self.activityIndicator.isAnimating {
                self.activityIndicator.stopAnimating()
            }
            self.priceLabel.text = "No internet connection"
            self.statusIcon.image = UIImage(named: "no_connection.png")
        }
    }
    
    func tooManyRequest() {
        DispatchQueue.main.async {
            if !self.isCollapsed {
                self.collapseButtonPressed()
            }
            if self.activityIndicator.isAnimating {
                self.activityIndicator.stopAnimating()
            }
            self.priceLabel.text = "Too many requests, please wait a while"
            self.statusIcon.image = UIImage(named: "no_connection.png")
        }
    }
}
