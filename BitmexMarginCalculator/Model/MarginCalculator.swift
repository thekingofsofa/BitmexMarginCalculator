//
//  MarginCalculator.swift
//  BitMEXMarginCalculator
//
//  Created by Иван Барабанщиков on 9/20/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import Foundation

enum PositionSide: String, Codable {
    case long
    case short
}

enum FeeType: String, Codable {
    case twoLimits
    case enteredLimitClosedMarket
    case twoMarkets
    case enteredMarketClosedLimit
}

struct CalculatorEntryData: Codable {
    var longShortSwitcher = PositionSide.long
    var quantity = Double()
    var enterPrice = Double()
    var closePrice = Double()
    var leverageSize = Double()
    var feeType = FeeType.twoMarkets
}

class MarginCalculator {
    
    // Entry Data
    var calcEntryData = CalculatorEntryData()
    
    // Output Data
    var contractValue = Double()
    var initialMargin = Double()
    
    var contractValueBTC = Double()
    var initialMarginBTC = Double()
    var priceChangePercentage = Double()
    var profitLossBTC = Double()
    var profitLossUSD = Double()
    var newBalanceInBTC = Double()
    var roe = Double()
    var liqudationPrice = Double()
    var oneMarketFee = Double()
    var oneLimitFee = Double()
    var feesInBTC = Double()
    var feesInUSD = Double()
    var changedUSDValueOfBTCDeposit = Double()
    
    func calculate() {
        
        // Calculate initial margin, entry value
        contractValueBTC = calcEntryData.quantity / calcEntryData.enterPrice
        initialMarginBTC = ((calcEntryData.quantity / calcEntryData.enterPrice) / calcEntryData.leverageSize)
        
        // Single fee
        oneMarketFee = contractValueBTC * Settings.shared.selectedTradingPair.takerFee
        oneLimitFee = contractValueBTC * Settings.shared.selectedTradingPair.makerFee
        
        // Calculate Fees depending on type
        switch calcEntryData.feeType {
        case .twoLimits:
            feesInBTC = oneLimitFee + oneLimitFee
            feesInUSD = calcEntryData.enterPrice * oneLimitFee + calcEntryData.closePrice * oneLimitFee
        case .enteredLimitClosedMarket:
            feesInBTC = oneLimitFee + oneMarketFee
            feesInUSD = calcEntryData.enterPrice * oneLimitFee + calcEntryData.closePrice * oneMarketFee
        case .twoMarkets:
            feesInBTC = oneMarketFee + oneMarketFee
            feesInUSD = calcEntryData.enterPrice * oneMarketFee + calcEntryData.closePrice * oneMarketFee
        case .enteredMarketClosedLimit:
            feesInBTC = oneMarketFee + oneLimitFee
            feesInUSD = calcEntryData.enterPrice * oneMarketFee + calcEntryData.closePrice * oneLimitFee
        }
        
        // Calculate btc price change
        priceChangePercentage = ((calcEntryData.closePrice - calcEntryData.enterPrice) / calcEntryData.enterPrice) * 100
        
        // Calculate roe price change and profit/loss
        profitLossBTC = (calcEntryData.quantity * ((1 / calcEntryData.enterPrice) - (1 /  calcEntryData.closePrice)))
        changedUSDValueOfBTCDeposit = ((initialMarginBTC) * (calcEntryData.closePrice - calcEntryData.enterPrice))
        profitLossUSD = (profitLossBTC * calcEntryData.closePrice) + changedUSDValueOfBTCDeposit
        // If show fees is ON, then adding to calculation fees
        if Settings.shared.showFees {
            profitLossBTC = profitLossBTC + feesInBTC
            profitLossUSD = profitLossUSD + feesInUSD
        }
        
        newBalanceInBTC = initialMarginBTC + profitLossBTC
        roe = ((newBalanceInBTC - initialMarginBTC) / initialMarginBTC) * 100
        
        // Calculate liqudation and profit depending on position side
        if calcEntryData.longShortSwitcher == PositionSide.long {
            liqudationPrice = (calcEntryData.enterPrice - (calcEntryData.enterPrice / (calcEntryData.leverageSize + 1))) + (calcEntryData.enterPrice - (calcEntryData.enterPrice / (calcEntryData.leverageSize + 1))) * 0.005
        } else {
            priceChangePercentage = -priceChangePercentage
            profitLossBTC = -profitLossBTC
            profitLossUSD = -profitLossUSD
            roe = -roe
            liqudationPrice = (calcEntryData.enterPrice + (calcEntryData.enterPrice / (calcEntryData.leverageSize - 1))) - (calcEntryData.enterPrice - (calcEntryData.enterPrice / (calcEntryData.leverageSize - 1))) * 0.005
        }
        
        saveEnteredData()
    }
    
    // Calculate initial margin in BTC
    func calcInitialMarginInBTC() {
        let traidingPair = Settings.shared.selectedTradingPair
        switch traidingPair {
        case .XBTUSD, .XBTZ19, .XBTH20:
            print("1")
        case .ADAZ19, .BCHZ19, .EOSZ19, .ETHZ19, .LTCZ19, .TRXZ19, .XRPZ19:
            print("2")
        case .ETHUSD:
            print("3")
        }
    }
    
    func saveEnteredData() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(calcEntryData) {
            let defaults = UserDefaults.standard
            let selectedPair = Settings.shared.selectedTradingPair.rawValue
            defaults.set(encoded, forKey: selectedPair)
        }
    }
}
