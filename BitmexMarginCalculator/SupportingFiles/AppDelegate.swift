//
//  AppDelegate.swift
//  BitMEXMarginCalculator
//
//  Created by Иван Барабанщиков on 9/20/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        let mainViewController = MainViewController()
        let nc = UINavigationController(rootViewController: mainViewController)
        window!.rootViewController = nc
        window!.makeKeyAndVisible()
        
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().isTranslucent = false
        
        let defaults = UserDefaults.standard
        let selectedPair = TradingPair.XBTUSD.rawValue
        
        // updateXBTUSDDefault for comfort update to 1.1
        var updateXBTUSDDefault = true
        if let savedData = defaults.object(forKey: selectedPair) as? Data {
            let decoder = JSONDecoder()
            if (try? decoder.decode(CalculatorEntryData.self, from: savedData)) != nil {
                updateXBTUSDDefault = false
            }
        }
        
        if isAppAlreadyLaunchedOnce() == false || updateXBTUSDDefault == true {
            let XBTUSDDefault = CalculatorEntryData.init(longShortSwitcher: .long, quantity: 10000, enterPrice: 10000, closePrice: 10500, leverageSize: 10, feeType: .twoMarkets, btcPriceWhenEnter: 0, btcPriceWhenExit: 0)
            let XBTZ19Default = CalculatorEntryData.init(longShortSwitcher: .long, quantity: 10000, enterPrice: 10000, closePrice: 10500, leverageSize: 10, feeType: .twoMarkets, btcPriceWhenEnter: 0, btcPriceWhenExit: 0)
            let XBTH20Default = CalculatorEntryData.init(longShortSwitcher: .long, quantity: 10000, enterPrice: 10000, closePrice: 10500, leverageSize: 10, feeType: .twoMarkets, btcPriceWhenEnter: 0, btcPriceWhenExit: 0)
            let ADAZ19Default = CalculatorEntryData.init(longShortSwitcher: .long, quantity: 80000, enterPrice: 0.00000500, closePrice: 0.00000510, leverageSize: 10, feeType: .twoMarkets, btcPriceWhenEnter: 10000, btcPriceWhenExit: 10000)
            let BCHZ19Default = CalculatorEntryData.init(longShortSwitcher: .long, quantity: 30, enterPrice: 0.02800, closePrice: 0.02850, leverageSize: 10, feeType: .twoMarkets, btcPriceWhenEnter: 10000, btcPriceWhenExit: 10000)
            let EOSZ19Default = CalculatorEntryData.init(longShortSwitcher: .long, quantity: 5000, enterPrice: 0.0003800, closePrice: 0.0003850, leverageSize: 10, feeType: .twoMarkets, btcPriceWhenEnter: 10000, btcPriceWhenExit: 10000)
            let ETHUSDDefault = CalculatorEntryData.init(longShortSwitcher: .long, quantity: 50, enterPrice: 180, closePrice: 200, leverageSize: 10, feeType: .twoMarkets, btcPriceWhenEnter: 10000, btcPriceWhenExit: 10000)
            let ETHZ19Default = CalculatorEntryData.init(longShortSwitcher: .long, quantity: 50, enterPrice: 0.02200, closePrice: 0.02250, leverageSize: 10, feeType: .twoMarkets, btcPriceWhenEnter: 10000, btcPriceWhenExit: 10000)
            let LTCZ19Default = CalculatorEntryData.init(longShortSwitcher: .long, quantity: 100, enterPrice: 0.007000, closePrice: 0.007150, leverageSize: 10, feeType: .twoMarkets, btcPriceWhenEnter: 10000, btcPriceWhenExit: 10000)
            let TRXZ19Default = CalculatorEntryData.init(longShortSwitcher: .long, quantity: 100000, enterPrice: 0.00000200, closePrice: 0.00000220, leverageSize: 10, feeType: .twoMarkets, btcPriceWhenEnter: 10000, btcPriceWhenExit: 10000)
            let XRPZ19Default = CalculatorEntryData.init(longShortSwitcher: .long, quantity: 10000, enterPrice: 0.00003350, closePrice: 0.00003500, leverageSize: 10, feeType: .twoMarkets, btcPriceWhenEnter: 10000, btcPriceWhenExit: 10000)
            
            let encoder = JSONEncoder()
            let defaults = UserDefaults.standard
            if let encoded = try? encoder.encode(XBTUSDDefault) {
                defaults.set(encoded, forKey: TradingPair.XBTUSD.rawValue)
            }
            if let encoded = try? encoder.encode(XBTZ19Default) {
                defaults.set(encoded, forKey: TradingPair.XBTZ19.rawValue)
            }
            if let encoded = try? encoder.encode(XBTH20Default) {
                defaults.set(encoded, forKey: TradingPair.XBTH20.rawValue)
            }
            if let encoded = try? encoder.encode(ADAZ19Default) {
                defaults.set(encoded, forKey: TradingPair.ADAZ19.rawValue)
            }
            if let encoded = try? encoder.encode(BCHZ19Default) {
                defaults.set(encoded, forKey: TradingPair.BCHZ19.rawValue)
            }
            if let encoded = try? encoder.encode(EOSZ19Default) {
                defaults.set(encoded, forKey: TradingPair.EOSZ19.rawValue)
            }
            if let encoded = try? encoder.encode(ETHUSDDefault) {
                defaults.set(encoded, forKey: TradingPair.ETHUSD.rawValue)
            }
            if let encoded = try? encoder.encode(ETHZ19Default) {
                defaults.set(encoded, forKey: TradingPair.ETHZ19.rawValue)
            }
            if let encoded = try? encoder.encode(LTCZ19Default) {
                defaults.set(encoded, forKey: TradingPair.LTCZ19.rawValue)
            }
            if let encoded = try? encoder.encode(TRXZ19Default) {
                defaults.set(encoded, forKey: TradingPair.TRXZ19.rawValue)
            }
            if let encoded = try? encoder.encode(XRPZ19Default) {
                defaults.set(encoded, forKey: TradingPair.XRPZ19.rawValue)
            }
        } else {
            Settings.shared.showFees = UserDefaults.standard.bool(forKey: "showFees")
//            Settings.shared.showLastPrice = UserDefaults.standard.bool(forKey: "showLastPrice")
            Settings.shared.selectedTradingPair = TradingPair(rawValue: UserDefaults.standard.string(forKey: "tradingPair") ?? "") ?? .XBTUSD
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func isAppAlreadyLaunchedOnce() -> Bool{
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "isAppAlreadyLaunchedOnce"){
            print("App already launched")
            return true
        } else {
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("App launched first time")
            return false
        }
    }
}

