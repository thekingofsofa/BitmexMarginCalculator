//
//  LastPriceViewController.swift
//  BitmexMarginCalculator
//
//  Created by Иван Барабанщиков on 19.03.2021.
//  Copyright © 2021 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

class LastPriceViewController: UIViewController {
    
    var lastPriceView = LastPriceView()
    private var activityIndicator = UIActivityIndicatorView()
    
    private var getChartTimer = Timer()
    private var getLastPriceTimer = Timer()
    private var candleStickChartValues = (values: [(close: Double, open: Double, high: Double, low: Double, volume: Double)](), dates: [String]())
    private let candlestickTimeIntervals = ["1m", "5m", "1h", "1d"]
    private var selectedTimeInterval = "1h"
//    private var bitmexSocketConnection: WebSocketTaskConnection!
//    private var currentSocketConnectedPair = String()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupLayout()
        activityIndicator.startAnimating()
        startFeedLastPriceWithData()
        
//        getLatestPriceData()
//        let selectedTraidingPair = Settings.shared.selectedTradingPair.rawValue
//        currentSocketConnectedPair = selectedTraidingPair
        
//        bitmexSocketConnection = WebSocketTaskConnection(url: URL(string: "wss://www.bitmex.com/realtime")!)
//        bitmexSocketConnection.delegate = self
//        bitmexSocketConnection.connect()
//        bitmexSocketConnection.send(text: "{\"op\": \"subscribe\", \"args\": [\"trade:\(selectedTraidingPair)\"]}")
    }
    
    // MARK: - Setup UI
    
    private func setupView() {
        
        lastPriceView.candlestickTimeIntervals = candlestickTimeIntervals
        lastPriceView.selectedTimeInterval = selectedTimeInterval
        lastPriceView.delegate = self
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        
        [lastPriceView, activityIndicator].forEach { view.addSubview($0) }
    }
    
    private func setupLayout() {
        
        lastPriceView.fillSuperview()
        activityIndicator.fillSuperview()
    }
    
    // MARK: - Actions
    
//    func changeSubscribeArgumentsForWebsocket() {
//        
//        bitmexSocketConnection.send(text: "{\"op\": \"unsubscribe\", \"args\": [\"trade:\(currentSocketConnectedPair)\"]}")
//        
//        let selectedTraidingPair = Settings.shared.selectedTradingPair.rawValue
//        currentSocketConnectedPair = selectedTraidingPair
//        
//        bitmexSocketConnection.send(text: "{\"op\": \"subscribe\", \"args\": [\"trade:\(selectedTraidingPair)\"]}")
//    }
    
    func restartFeeding() {
        
        if !lastPriceView.isCollapsed {
            startFeedChartWithData()
        } else {
            startFeedLastPriceWithData()
        }
    }
    
    private func startFeedChartWithData() {
        
        getChartTimer.invalidate()
        getChartTimer = Timer.scheduledTimer(timeInterval: 5.0,
                                             target: self,
                                             selector: #selector(getCandlestickChartData),
                                             userInfo: nil,
                                             repeats: true)
        activityIndicator.startAnimating()
        getCandlestickChartData()
    }
    
    private func startFeedLastPriceWithData() {

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
                self?.candleStickChartValues.values = values
                self?.candleStickChartValues.dates = dates
                self?.lastPriceView.chart.draw(values: values, dates: dates)
                
            case .failure(let error):

                if error.code == -1000 {
                    self?.tooManyRequest()
                } else if error.code == -1009 {
                    self?.noInternet()
                }
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
                self?.lastPriceView.statusIcon.image = UIImage(named: "ic_trending_up.png")
                UIView.animate(withDuration: 0.3, animations: {
                    self?.lastPriceView.priceLabel.alpha = 0.0
                }, completion: { (bool) in
                    let formatLiquidationStringStyle = Settings.shared.selectedTradingPair.formatStyle
                    let price = Double(truncating: NSDecimalNumber(decimal: data[0].price))
                    let priceString = String(format: formatLiquidationStringStyle, price)
                    self?.lastPriceView.priceLabel.text = "Last \(traidingPair.rawValue) price: " + priceString
                    UIView.animate(withDuration: 0.3, animations: {
                        self?.lastPriceView.priceLabel.alpha = 1.0
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
    
    private func noInternet() {
        
        DispatchQueue.main.async {
            self.lastPriceView.collapseView()
            if self.activityIndicator.isAnimating {
                self.activityIndicator.stopAnimating()
            }
            self.lastPriceView.priceLabel.text = "No internet connection"
            self.lastPriceView.statusIcon.image = UIImage(named: "no_connection.png")
        }
    }

    private func tooManyRequest() {
        
        DispatchQueue.main.async {
            self.lastPriceView.collapseView()
            if self.activityIndicator.isAnimating {
                self.activityIndicator.stopAnimating()
            }
            self.lastPriceView.priceLabel.text = "Too many requests, please wait a while"
            self.lastPriceView.statusIcon.image = UIImage(named: "no_connection.png")
        }
    }
}

// MARK: - WebSocketConnectionDelegate

extension LastPriceViewController: WebSocketConnectionDelegate {
    
    func onConnected(connection: WebSocketConnection) {
        print("Connected")
    }
    
    func onDisconnected(connection: WebSocketConnection, error: Error?) {
        print("Disconnected")
    }
    
    func onError(connection: WebSocketConnection, error: Error) {
        print(error)
    }
    
    func onMessage(connection: WebSocketConnection, text: String) {
        print(text)
        
        let decoder = JSONDecoder()
        
        if let lastTradesData: BitmexPricesResponse = try? decoder.decode(BitmexPricesResponse.self, from: text.data(using: .utf8) ?? Data()) {
            
            DispatchQueue.main.async {
                let formatLiquidationStringStyle = Settings.shared.selectedTradingPair.formatStyle
                let price = Double(truncating: NSDecimalNumber(decimal: lastTradesData.data.last?.price ?? 0))
                let priceString = String(format: formatLiquidationStringStyle, price)
                
                if !self.lastPriceView.isCollapsed {
                    
                    guard !self.candleStickChartValues.values.isEmpty else { return }
                    self.candleStickChartValues.values[0].close = price
                    self.lastPriceView.chart.draw(values: self.candleStickChartValues.values, dates: self.candleStickChartValues.dates)
                } else {
                    self.activityIndicator.stopAnimating()
                    let traidingPair = Settings.shared.selectedTradingPair
                    self.lastPriceView.setPriceLabel(traidingPairString: traidingPair.rawValue, priceString: priceString)
                }
            }
        }
    }
    
    func onMessage(connection: WebSocketConnection, data: Data) {
        print(data)
    }
}

// MARK: - LastPriceViewDelegate

extension LastPriceViewController: LastPriceViewDelegate {
    
    func collapseAction(isCollapsed: Bool) {
        
        if !isCollapsed {
            getLastPriceTimer.invalidate()
            startFeedChartWithData()
        } else {
            getChartTimer.invalidate()
            startFeedLastPriceWithData()
        }
    }
    
    func switchedTimeIntervalControl(timeInterval: String) {
        
        selectedTimeInterval = timeInterval
        getCandlestickChartData()
    }
}
