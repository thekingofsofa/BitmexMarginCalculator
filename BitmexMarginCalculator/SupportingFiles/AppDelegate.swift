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
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        let mainViewController = MainViewController()
        let nc = UINavigationController(rootViewController: mainViewController)
        window?.rootViewController = nc
        window?.makeKeyAndVisible()
        
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().isTranslucent = false
        
        setDefaults()
        
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
    
    func isAppAlreadyLaunchedOnce() -> Bool {
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "isAppAlreadyLaunchedOnce") {
            print("App already launched")
            return true
        } else {
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("App launched first time")
            return false
        }
    }
    
    func setDefaults() {
        
        let defaults = UserDefaults.standard
        let selectedPair = TradingPair.XBTUSD.rawValue
        
        if isAppAlreadyLaunchedOnce() == false {
            
            let XBTUSDDefault = CalculatorEntryData.init(longShortSwitcher: .long,
                                                         quantity: 50000,
                                                         enterPrice: 50000,
                                                         closePrice: 50500,
                                                         leverageSize: 10,
                                                         feeType: .twoMarkets,
                                                         btcPriceWhenEnter: 0,
                                                         btcPriceWhenExit: 0)
            let ETHUSDDefault = CalculatorEntryData.init(longShortSwitcher: .long,
                                                         quantity: 50,
                                                         enterPrice: 180,
                                                         closePrice: 200,
                                                         leverageSize: 10,
                                                         feeType: .twoMarkets,
                                                         btcPriceWhenEnter: 50000,
                                                         btcPriceWhenExit: 50500)
            
            let encoder = JSONEncoder()
            let defaults = UserDefaults.standard
            if let encoded = try? encoder.encode(XBTUSDDefault) {
                defaults.set(encoded, forKey: TradingPair.XBTUSD.rawValue)
            }
            if let encoded = try? encoder.encode(XBTUSDDefault) {
                defaults.set(encoded, forKey: TradingPair.XBTH21.rawValue)
            }
            if let encoded = try? encoder.encode(XBTUSDDefault) {
                defaults.set(encoded, forKey: TradingPair.XBTM21.rawValue)
            }
            if let encoded = try? encoder.encode(ETHUSDDefault) {
                defaults.set(encoded, forKey: TradingPair.ETHUSD.rawValue)
            }
        } else {
            Settings.shared.showFees = UserDefaults.standard.bool(forKey: "showFees")
            Settings.shared.showLastPrice = UserDefaults.standard.bool(forKey: "showLastPrice")
            Settings.shared.selectedTradingPair = TradingPair(rawValue: UserDefaults.standard.string(forKey: "tradingPair") ?? "") ?? .XBTUSD
        }
    }
}
