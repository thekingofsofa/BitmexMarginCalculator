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
    // For altcoins
    var btcPriceWhenEnter = Double()
    var btcPriceWhenExit = Double()
}

class MarginCalculator {
    
    // Entry Data
    var calcEntryData = CalculatorEntryData()
    
    // Output Data
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
    var changedUSDValueOfDeposit = Double()
    
    func calculate() {
        
        print(contractValueBTC)
        print(calcEntryData)
        if Settings.shared.selectedTradingPair == .XBTUSD || Settings.shared.selectedTradingPair == .XBTZ19 || Settings.shared.selectedTradingPair == .XBTH20 {
            calcEntryData.btcPriceWhenEnter = calcEntryData.enterPrice
            calcEntryData.btcPriceWhenExit = calcEntryData.closePrice
        }
        
        // Calculate initial margin, entry value
        calcInitialMarginInBTC()
        
        // Calculate fees
        calcFees()
        
        // Calculate price change
        priceChangePercentage = ((calcEntryData.closePrice - calcEntryData.enterPrice) / calcEntryData.enterPrice) * 100
        
        // Calculate roe price change and profit/loss
        profitLossBTC = calcProfitLossInBTC()
        changedUSDValueOfDeposit = ((initialMarginBTC) * (calcEntryData.btcPriceWhenExit - calcEntryData.btcPriceWhenEnter))
        profitLossUSD = (profitLossBTC * calcEntryData.btcPriceWhenExit) + changedUSDValueOfDeposit
        
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
    
    // Calculate initial margin, entry value
    private func calcInitialMarginInBTC() {
        let traidingPair = Settings.shared.selectedTradingPair
        switch traidingPair {
        case .XBTUSD, .XBTZ19, .XBTH20:
            
            contractValueBTC = calcEntryData.quantity / calcEntryData.enterPrice
            initialMarginBTC = contractValueBTC / calcEntryData.leverageSize
            
        case .ADAZ19, .BCHZ19, .EOSZ19, .ETHZ19, .LTCZ19, .TRXZ19, .XRPZ19:
            
            contractValueBTC = calcEntryData.enterPrice * calcEntryData.quantity
            initialMarginBTC = (calcEntryData.enterPrice * calcEntryData.quantity) / calcEntryData.leverageSize
            
        case .ETHUSD:
            
            contractValueBTC = (calcEntryData.enterPrice * calcEntryData.quantity) / calcEntryData.btcPriceWhenEnter
            initialMarginBTC = ((calcEntryData.enterPrice * calcEntryData.quantity) / calcEntryData.leverageSize) / calcEntryData.btcPriceWhenEnter
        }
    }
    
    private func calcFees() {
        let traidingPair = Settings.shared.selectedTradingPair
        switch traidingPair {
        case .XBTUSD, .XBTZ19, .XBTH20:
            
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
        case .ADAZ19, .BCHZ19, .EOSZ19, .ETHZ19, .LTCZ19, .TRXZ19, .XRPZ19:
            
            
            // Single fee
            let limitFeeOnEnter = calcEntryData.enterPrice * calcEntryData.quantity * Settings.shared.selectedTradingPair.makerFee
            let limitFeeOnExit = calcEntryData.closePrice * calcEntryData.quantity * Settings.shared.selectedTradingPair.makerFee
            let marketFeeOnEnter = calcEntryData.enterPrice * calcEntryData.quantity * Settings.shared.selectedTradingPair.takerFee
            let marketFeeOnExit = calcEntryData.closePrice * calcEntryData.quantity * Settings.shared.selectedTradingPair.takerFee
            
            // Calculate Fees depending on type
            switch calcEntryData.feeType {
            case .twoLimits:
                feesInBTC = limitFeeOnEnter + limitFeeOnExit
                feesInUSD = limitFeeOnEnter * calcEntryData.btcPriceWhenEnter + limitFeeOnExit * calcEntryData.btcPriceWhenExit
            case .enteredLimitClosedMarket:
                feesInBTC = limitFeeOnEnter + marketFeeOnExit
                feesInUSD = limitFeeOnEnter * calcEntryData.btcPriceWhenEnter + marketFeeOnExit * calcEntryData.btcPriceWhenExit
            case .twoMarkets:
                feesInBTC = marketFeeOnEnter + marketFeeOnExit
                feesInUSD = marketFeeOnEnter * calcEntryData.btcPriceWhenEnter + marketFeeOnExit * calcEntryData.btcPriceWhenExit
            case .enteredMarketClosedLimit:
                feesInBTC = marketFeeOnEnter + limitFeeOnExit
                feesInUSD = marketFeeOnEnter * calcEntryData.btcPriceWhenEnter + limitFeeOnExit * calcEntryData.btcPriceWhenExit
            }
        case .ETHUSD:
            
            // Single fee
            let limitFeeOnEnter = ((calcEntryData.enterPrice * calcEntryData.quantity) / calcEntryData.btcPriceWhenEnter) * Settings.shared.selectedTradingPair.makerFee
            let limitFeeOnExit = ((calcEntryData.closePrice * calcEntryData.quantity) / calcEntryData.btcPriceWhenExit) * Settings.shared.selectedTradingPair.makerFee
            let marketFeeOnEnter = ((calcEntryData.enterPrice * calcEntryData.quantity) / calcEntryData.btcPriceWhenEnter) * Settings.shared.selectedTradingPair.takerFee
            let marketFeeOnExit = ((calcEntryData.closePrice * calcEntryData.quantity) / calcEntryData.btcPriceWhenExit) * Settings.shared.selectedTradingPair.takerFee
            
            // Calculate Fees depending on type
            switch calcEntryData.feeType {
            case .twoLimits:
                feesInBTC = limitFeeOnEnter + limitFeeOnExit
                feesInUSD = limitFeeOnEnter * calcEntryData.btcPriceWhenEnter + limitFeeOnExit * calcEntryData.btcPriceWhenExit
            case .enteredLimitClosedMarket:
                feesInBTC = limitFeeOnEnter + marketFeeOnExit
                feesInUSD = limitFeeOnEnter * calcEntryData.btcPriceWhenEnter + marketFeeOnExit * calcEntryData.btcPriceWhenExit
            case .twoMarkets:
                feesInBTC = marketFeeOnEnter + marketFeeOnExit
                feesInUSD = marketFeeOnEnter * calcEntryData.btcPriceWhenEnter + marketFeeOnExit * calcEntryData.btcPriceWhenExit
            case .enteredMarketClosedLimit:
                feesInBTC = marketFeeOnEnter + limitFeeOnExit
                feesInUSD = marketFeeOnEnter * calcEntryData.btcPriceWhenEnter + limitFeeOnExit * calcEntryData.btcPriceWhenExit
            }
        }
    }
    
    private func calcProfitLossInBTC() -> Double {
        
        let traidingPair = Settings.shared.selectedTradingPair
        switch traidingPair {
        case .XBTUSD, .XBTZ19, .XBTH20:
            
            return (calcEntryData.quantity * ((1 / calcEntryData.enterPrice) - (1 /  calcEntryData.closePrice)))
            
        case .ADAZ19, .BCHZ19, .EOSZ19, .ETHZ19, .LTCZ19, .TRXZ19, .XRPZ19:
            
            return (calcEntryData.closePrice - calcEntryData.enterPrice) * calcEntryData.quantity
            
        case .ETHUSD:
            
            return ((calcEntryData.closePrice - calcEntryData.enterPrice) * calcEntryData.quantity) / calcEntryData.btcPriceWhenExit
        }
    }
    
    func saveEnteredData() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(calcEntryData) {
            let defaults = UserDefaults.standard
            let selectedPair = Settings.shared.selectedTradingPair.rawValue
            defaults.set(encoded, forKey: selectedPair)
            defaults.synchronize()
        }
    }
}
