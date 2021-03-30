//
//  BitmexMarginCalculatorTests.swift
//  BitmexMarginCalculatorTests
//
//  Created by Иван Барабанщиков on 10/20/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import XCTest
@testable import BitmexMarginCalculator

class BitmexMarginCalculatorTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMarginCalculatorBTC() {
        Settings.shared.selectedTradingPair = .XBTUSD
        let calc = MarginCalculator()
        calc.calcEntryData = CalculatorEntryData.init(longShortSwitcher: .long,
                                                      quantity: 10000, enterPrice: 8000,
                                                      closePrice: 8800, leverageSize: 10,
                                                      feeType: .twoLimits, btcPriceWhenEnter: 0,
                                                      btcPriceWhenExit: 0)
        calc.calculate()
        XCTAssertEqual(String(format: "%.4f", calc.initialMarginBTC), "0.1250")
        XCTAssertEqual(String(format: "%.2f", calc.priceChangePercentage)  + "%", "10.00%")
        XCTAssertEqual(String(format: "%.2f", calc.feesInUSD) + "$", "5.25$")
        XCTAssertEqual(String(format: "%.4f", calc.profitLossBTC), "0.1143")
        XCTAssertEqual(String(format: "%.2f", calc.profitLossUSD) + "$", "1105.25$")
        XCTAssertEqual(String(format: "%.2f", calc.roe) + "%", "91.41%")
        XCTAssertEqual(String(format: "%.2f", calc.liquidationPrice), "7309.09")
    }

//    func testBitcoinLastPriceResponse() {
//        let traidingPair = Settings.shared.selectedTradingPair
//        let sessionLastPriceExpectation = expectation(description: "Session")
//        let mainController = MainViewController()
//        mainController.loadViewIfNeeded()
//
//        let network = ServiceLayer()
//        network.request(router: Router.getLastPrice(tradePair: "XBTUSD")) { (result: Result<[LastPrice]>) in
//            switch result {
//            case .success(let data):
//                XCTAssert(data[0].price > 0)
//                XCTAssertEqual(mainController.lastPriceView.priceLabel.text, "Last \(traidingPair.rawValue) price: \(data[0].price)")
//                sessionLastPriceExpectation.fulfill()
//            case .failure:
//                XCTFail()
//            }
//        }
//        waitForExpectations(timeout: 8, handler: nil)
//    }
}
