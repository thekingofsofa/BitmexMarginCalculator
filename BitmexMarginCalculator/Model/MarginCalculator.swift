//
//  MarginCalculator.swift
//  BitMEXMarginCalculator
//
//  Created by Иван Барабанщиков on 9/20/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import Foundation

enum PositionSide {
    case long
    case short
}

enum FeeType {
    case twoLimits
    case enteredLimitClosedMarket
    case twoMarkets
    case enteredMarketClosedLimit
}

class MarginCalculator {
    
    // Entry Data
    var longShortSwitcher = PositionSide.long
    var quantityXBT = Double()
    var enterPrice = Double()
    var closePrice = Double()
    var leverageSize = Double()
    var feeType = FeeType.twoMarkets
    
    // Output Data
    var entryValue = Double()
    var initialBTC = Double()
    var initialBTCWith2xMarketFees = Double()
    var btcPriceChangePercentage = Double()
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
        
        // Calculate initial margin, entry value and single fees
        entryValue = quantityXBT / enterPrice
        initialBTC = ((quantityXBT / enterPrice) / leverageSize)
        
        oneMarketFee = entryValue * 0.00075 * (-1)
        oneLimitFee = entryValue * 0.00025
        initialBTCWith2xMarketFees = initialBTC - (2 * oneMarketFee)
        
        // Calculate Fees depending on type
        switch feeType {
        case .twoLimits:
            feesInBTC = oneLimitFee + oneLimitFee
            feesInUSD = enterPrice * oneLimitFee + closePrice * oneLimitFee
        case .enteredLimitClosedMarket:
            feesInBTC = oneLimitFee + oneMarketFee
            feesInUSD = enterPrice * oneLimitFee + closePrice * oneMarketFee
        case .twoMarkets:
            feesInBTC = oneMarketFee + oneMarketFee
            feesInUSD = enterPrice * oneMarketFee + closePrice * oneMarketFee
        case .enteredMarketClosedLimit:
            feesInBTC = oneMarketFee + oneLimitFee
            feesInUSD = enterPrice * oneMarketFee + closePrice * oneLimitFee
        }
        
        // Calculate btc price change
        btcPriceChangePercentage = ((closePrice - enterPrice) / enterPrice) * 100
        
        // Calculate roe price change and profit/loss
        profitLossBTC = (quantityXBT * ((1 / enterPrice) - (1 /  closePrice)))
        changedUSDValueOfBTCDeposit = ((initialBTC) * (closePrice - enterPrice))
        profitLossUSD = (profitLossBTC * closePrice) + changedUSDValueOfBTCDeposit
        // If show fees is ON, then adding to calculation fees
        if Settings.shared.showFees {
            profitLossBTC = profitLossBTC + feesInBTC
            profitLossUSD = profitLossUSD + feesInUSD
        }
        
        newBalanceInBTC = initialBTC + profitLossBTC
        roe = ((newBalanceInBTC - initialBTC) / initialBTC) * 100
        
        // Calculate liqudation and profit depending on position side
        if longShortSwitcher == PositionSide.long {
            liqudationPrice = (enterPrice - (enterPrice / (leverageSize + 1))) + (enterPrice - (enterPrice / (leverageSize + 1))) * 0.005
        } else {
            btcPriceChangePercentage = -btcPriceChangePercentage
            profitLossBTC = -profitLossBTC
            profitLossUSD = -profitLossUSD
            roe = -roe
            liqudationPrice = (enterPrice + (enterPrice / (leverageSize - 1))) - (enterPrice - (enterPrice / (leverageSize - 1))) * 0.005
        }
        
        saveEnteredData()
    }
    
    func saveEnteredData() {
        
        UserDefaults.standard.set(longShortSwitcher == .long ? true : false, forKey: "longShortSwitcher")
        UserDefaults.standard.set(quantityXBT, forKey: "quantityXBT")
        UserDefaults.standard.set(enterPrice, forKey: "entryPrice")
        UserDefaults.standard.set(closePrice, forKey: "exitPrice")
        UserDefaults.standard.set(leverageSize, forKey: "leverageSize")
        switch feeType {
        case .twoLimits:
            UserDefaults.standard.set(true, forKey: "entryLimit")
            UserDefaults.standard.set(true, forKey: "closeLimit")
        case .enteredLimitClosedMarket:
            UserDefaults.standard.set(true, forKey: "entryLimit")
            UserDefaults.standard.set(false, forKey: "closeLimit")
        case .twoMarkets:
            UserDefaults.standard.set(false, forKey: "entryLimit")
            UserDefaults.standard.set(false, forKey: "closeLimit")
        case .enteredMarketClosedLimit:
            UserDefaults.standard.set(false, forKey: "entryLimit")
            UserDefaults.standard.set(true, forKey: "closeLimit")
        }
    }
}
