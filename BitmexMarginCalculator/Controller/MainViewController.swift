//
//  ViewController.swift
//  BitMEXMarginCalculator
//
//  Created by Иван Барабанщиков on 9/20/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var mainScrollView = UIScrollView()
    var mainScrollViewTopConstraint = NSLayoutConstraint()
    var mainStackView = UIStackView()
    var navDropMenu = NavDropMenu(items: Settings.shared.listOfAllTradingPairs)
    var lastPriceView = LastPriceView()
    var bottomLabel = UILabel()
    
    var longShortSwitcher = UISegmentedControl()
    var quantity = TextFieldView(textFieldName: "Quantity ($)")
    var entryPrice = TextFieldView(textFieldName: "Entry price")
    var exitPrice = TextFieldView(textFieldName: "Exit price")
    var leverageSize = TextFieldView(textFieldName: "Leverage")
    var enterOrder = LabelSegmentedView(titleText: "Enter order", segmentedOptions: ["Limit", "Market"])
    var closeOrder = LabelSegmentedView(titleText: "Close order", segmentedOptions: ["Limit", "Market"])
    var feeType = FeeType.twoMarkets
    // For altcoins
    var btcPriceWhenEnter = TextFieldView(textFieldName: "BTC price when entry")
    var btcPriceWhenExit = TextFieldView(textFieldName: "BTC price when exit")
    
    var resultBorderView = ResultView()
    var resultViewHeightConstraint = NSLayoutConstraint()
    
    let marginCalc = MarginCalculator()
    
    lazy var settingsLauncher: SettingsLauncher = {
        let launcher = SettingsLauncher()
        launcher.homeController = self
        return launcher
    }()
    
    @objc func positionSideChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            marginCalc.calcEntryData.longShortSwitcher = .long
            marginCalc.saveEnteredData()
            calculate()
        case 1:
            marginCalc.calcEntryData.longShortSwitcher = .short
            marginCalc.saveEnteredData()
            calculate()
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        showHideFees()
        showHideBTCPriceForAltcoins()
        setupNavigationBar()
        calculate()
        _ = Timer.scheduledTimer(timeInterval: 5.0,
                                 target: self,
                                 selector: #selector(execute),
                                 userInfo: nil,
                                 repeats: true)
    }
    // method
    
    @objc func execute() {
        
        let network = ServiceLayer()
        network.request(router: Router.getXBTUSD) { (result: Result<[LastPrice]>) in
            switch result {
            case .success(let data):
                self.lastPriceView.statusIcon.image = UIImage(named: "ic_trending_up.png")
                UIView.animate(withDuration: 0.3, animations: {
                    self.lastPriceView.priceLabel.alpha = 0.0
                }, completion: { (bool) in
                    self.lastPriceView.priceLabel.text = "Last BTC price: \(data[0].price)$"
                    UIView.animate(withDuration: 0.3, animations: {
                        self.lastPriceView.priceLabel.alpha = 1.0
                    })
                })
                
            case .failure:
                self.noInternet()
                print(result)
            }
        }
    }
    
    func noInternet() {
        // do here
        DispatchQueue.main.async {
            self.lastPriceView.priceLabel.text = "No internet connection"
            self.lastPriceView.statusIcon.image = UIImage(named: "no_connection.png")
        }
    }
    
    // MARK: Setup View
    func setupView() {
        // Manage colors
        guard let backgroundImage = UIImage(named: "background_light") else { return }
        self.view.backgroundColor = UIColor(patternImage: backgroundImage)
        
        // Delegate textfields
        [quantity, entryPrice, exitPrice, leverageSize, btcPriceWhenEnter, btcPriceWhenExit].forEach { $0.textFieldInputView.delegate = self }
        
        // Long Short Switcher
        longShortSwitcher = UISegmentedControl(items: ["Long", "Short"])
        longShortSwitcher.updateTintColor(firstSection: UIColor(red:0.21, green:0.75, blue:0.00, alpha:1.0), secondSection: UIColor.red)
        longShortSwitcher.addTarget(self, action: #selector(positionSideChanged), for: .valueChanged)
        
        // Info Buttons
        showInfoButtons()
        
        // Fees switchers
        enterOrder.segmentedControl.addTarget(self, action: #selector(changeFeeType), for: .valueChanged)
        closeOrder.segmentedControl.addTarget(self, action: #selector(changeFeeType), for: .valueChanged)
        
        // Load last entered data via UserDefaults
        loadUserDefaults()
        determineFeeType()
        
        // If keyboard appeard above textfield(iphone 5s,SE), setContentOffset
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Last BTC price view
        setupLastPriceView()
        
        // Bottom label
        bottomLabel.text = "All currency units denominated in XBT"
        bottomLabel.setScaledCustomFont(forFont: .RobotoLight, textStyle: .footnote)
        bottomLabel.textColor = .gray
        bottomLabel.textAlignment = .center
        mainScrollView.addSubview(bottomLabel)
    }
    
    // MARK: Layout View
    func setupLayout() {
        let entryDataStackView = UIStackView(arrangedSubviews: [longShortSwitcher, quantity, entryPrice, exitPrice, leverageSize, enterOrder, closeOrder, btcPriceWhenEnter, btcPriceWhenExit])
        entryDataStackView.distribution = .fillEqually
        entryDataStackView.axis = .vertical
        entryDataStackView.spacing = 10
        
        [longShortSwitcher, quantity, entryPrice, exitPrice, leverageSize, enterOrder, closeOrder, btcPriceWhenEnter, btcPriceWhenExit].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        
        lastPriceView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor)
        lastPriceView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        mainStackView = UIStackView(arrangedSubviews: [entryDataStackView, resultBorderView])
        mainStackView.spacing = 12
        view.addSubview(mainScrollView)
        mainScrollView.addSubview(mainStackView)
        
        mainScrollView.anchor(top: nil, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        showHideLastPrice()
        
        mainStackView.anchor(top: mainScrollView.topAnchor, leading: mainScrollView.leadingAnchor, bottom: mainScrollView.bottomAnchor, trailing: mainScrollView.trailingAnchor, padding: .init(top: 12, left: 12, bottom: 28, right: 12))
        mainStackView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor, constant: -24).isActive = true
        bottomLabel.anchor(top: resultBorderView.bottomAnchor, leading: mainScrollView.leadingAnchor, bottom: nil, trailing: mainScrollView.trailingAnchor, padding: .init(top: 4, left: 12, bottom: 0, right: 12))
    }
    
    // MARK: Setup NavigationBar
    private func setupNavigationBar() {
        let configButton = UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: self, action: #selector(configButtonPressed))
        navigationItem.rightBarButtonItem = configButton
        navigationItem.titleView = navDropMenu.navBarButton
        navDropMenu.delegate = self
        
        view.addSubview(navDropMenu)
        navDropMenu.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    @objc private func configButtonPressed() {
        settingsLauncher.showSettings()
    }
    
    func setupLastPriceView() {
        view.addSubview(lastPriceView)
        lastPriceView.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0)
        
        let network = ServiceLayer()
        network.request(router: Router.getXBTUSD) { (result: Result<[LastPrice]>) in
            switch result {
            case .success(let data):
                print(result)
                self.lastPriceView.priceLabel.text = "Last BTC price: \(data[0].price)$"
            case .failure:
                print(result)
            }
        }
    }
    
    // MARK: Calculator
    func calculate() {
        // Check max leverage
        if Int(leverageSize.textFieldInputView.text ?? "0")! > Settings.shared.selectedTradingPair.maxLeverage {
            leverageSize.textFieldInputView.backgroundColor = UIColor(red:1.00, green:0.80, blue:0.80, alpha:1.0)
        } else {
            leverageSize.textFieldInputView.backgroundColor = UIColor.white
        }
        
        marginCalc.calcEntryData.longShortSwitcher = longShortSwitcher.selectedSegmentIndex == 0 ? .long : .short
        marginCalc.calcEntryData.quantity = Double(quantity.textFieldInputView.text!) ?? 0
        marginCalc.calcEntryData.enterPrice = Double(entryPrice.textFieldInputView.text!) ?? 0
        marginCalc.calcEntryData.closePrice = Double(exitPrice.textFieldInputView.text!) ?? 0
        marginCalc.calcEntryData.leverageSize = Double(leverageSize.textFieldInputView.text!) ?? 0
        marginCalc.calcEntryData.feeType = feeType
        marginCalc.calcEntryData.btcPriceWhenEnter = Double(btcPriceWhenEnter.textFieldInputView.text!) ?? 0
        marginCalc.calcEntryData.btcPriceWhenExit = Double(btcPriceWhenExit.textFieldInputView.text!) ?? 0
        marginCalc.calculate()
        
        var numbersAfterPointForLiquidation = String()
        switch Settings.shared.selectedTradingPair {
        case .XBTUSD, .XBTH20, .XBTZ19:
            numbersAfterPointForLiquidation = "%.2f"
        case .ADAZ19:
            numbersAfterPointForLiquidation = "%.8f"
        case .BCHZ19:
            numbersAfterPointForLiquidation = "%.5f"
        case .EOSZ19:
            numbersAfterPointForLiquidation = "%.7f"
        case .ETHUSD:
            numbersAfterPointForLiquidation = "%.2f"
        case .ETHZ19:
            numbersAfterPointForLiquidation = "%.5f"
        case .LTCZ19:
            numbersAfterPointForLiquidation = "%.6f"
        case .TRXZ19:
            numbersAfterPointForLiquidation = "%.8f"
        case .XRPZ19:
            numbersAfterPointForLiquidation = "%.8f"
        }
        
        resultBorderView.quantityBTC.resultLabel.text = String(format: "%.4f", marginCalc.initialMarginBTC)
        resultBorderView.btcPriceChange.resultLabel.text = String(format: "%.2f", marginCalc.priceChangePercentage)  + "%"
        resultBorderView.profitLossBTC.resultLabel.text = String(format: "%.4f", marginCalc.profitLossBTC)
        resultBorderView.profitLossUSD.resultLabel.text = String(format: "%.2f", marginCalc.profitLossUSD) + "$"
        resultBorderView.roe.resultLabel.text = String(format: "%.2f", marginCalc.roe) + "%"
        resultBorderView.liqudationPrice.resultLabel.text = String(format: numbersAfterPointForLiquidation, marginCalc.liqudationPrice)
        resultBorderView.fees.resultLabel.text = String(format: "%.2f", marginCalc.feesInUSD) + "$"
    }
    
    @objc func changeFeeType() {
        determineFeeType()
        calculate()
    }
    
    func determineFeeType() {
        if enterOrder.segmentedControl.selectedSegmentIndex == 0 && closeOrder.segmentedControl.selectedSegmentIndex == 0 {
            feeType = FeeType.twoLimits
        } else if enterOrder.segmentedControl.selectedSegmentIndex == 0 && closeOrder.segmentedControl.selectedSegmentIndex == 1 {
            feeType = FeeType.enteredLimitClosedMarket
        }  else if enterOrder.segmentedControl.selectedSegmentIndex == 1 && closeOrder.segmentedControl.selectedSegmentIndex == 1 {
            feeType = FeeType.twoMarkets
        } else if enterOrder.segmentedControl.selectedSegmentIndex == 1 && closeOrder.segmentedControl.selectedSegmentIndex == 0 {
            feeType = FeeType.enteredMarketClosedLimit
        }
    }
    
    // MARK: Show/hide fee method
    func showHideFees() {
        if Settings.shared.showFees {
            enterOrder.isHidden = false
            closeOrder.isHidden = false
            resultBorderView.fees.isHidden = false
        } else {
            enterOrder.isHidden = true
            closeOrder.isHidden = true
            resultBorderView.fees.isHidden = true
        }
    }
    
    // MARK: Show/hide fee method
    func showHideLastPrice() {
        mainScrollViewTopConstraint.isActive = false
        if Settings.shared.showLastPrice {
            mainScrollViewTopConstraint = mainScrollView.topAnchor.constraint(equalTo: lastPriceView.bottomAnchor)
            lastPriceView.isHidden = false
        } else {
            mainScrollViewTopConstraint = mainScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
            lastPriceView.isHidden = true
        }
        mainScrollViewTopConstraint.isActive = true
    }
    
    // MARK: Show/hide btc price when enter and exit for altcoins
    func showHideBTCPriceForAltcoins() {
        
        let traidingPair = Settings.shared.selectedTradingPair
        switch traidingPair {
        case .XBTUSD, .XBTZ19, .XBTH20:
            btcPriceWhenEnter.isHidden = true
            btcPriceWhenExit.isHidden = true
        case .ADAZ19, .BCHZ19, .EOSZ19, .ETHZ19, .LTCZ19, .TRXZ19, .XRPZ19, .ETHUSD:
            btcPriceWhenEnter.isHidden = false
            btcPriceWhenExit.isHidden = false
        }
    }
    
    // MARK: Show info Button
    func showInfoButtons() {
        resultBorderView.liqudationPrice.resultLabel.addInfoButton()
        resultBorderView.liqudationPrice.resultLabel.infoButton.addTarget(self, action: #selector(liquidationInfoButtonPressed), for: .touchUpInside)
    }
    
    @objc func liquidationInfoButtonPressed() {
        let infoVC = PopUpViewController()
        infoVC.modalPresentationStyle = .overCurrentContext
        infoVC.modalTransitionStyle = .crossDissolve
        present(infoVC, animated: true, completion: nil)
    }
    
    // MARK: Define constraints based on device and orientation
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if previousTraitCollection?.verticalSizeClass != traitCollection.verticalSizeClass {
            if UIDevice.current.userInterfaceIdiom == .phone && traitCollection.verticalSizeClass == .compact {
                setupConstraintForCompactEnviromnentIphone()
            } else if UIDevice.current.userInterfaceIdiom == .phone && traitCollection.verticalSizeClass == .regular {
                setupConstraintForRegularEnviromnentIphone()
            }
        }
    }
    
    func setupConstraintForCompactEnviromnentIphone() {
        print("iphoneLandscape")
        self.mainStackView.axis = .horizontal
        self.mainStackView.alignment = .top
        self.mainStackView.distribution = .fillEqually
    }
    
    func setupConstraintForRegularEnviromnentIphone() {
        print("iphonePortrait")
        self.mainStackView.axis = .vertical
        self.mainStackView.alignment = .fill
        self.mainStackView.distribution = .fill
    }
    
    // Method to set setContentOffset, if keyboard appeard above textfield
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            if (view.frame.height - keyboardSize.height) <= (leverageSize.frame.origin.y + leverageSize.frame.height) {
                self.view.frame.origin.y -= ((leverageSize.frame.origin.y + leverageSize.frame.height) - (view.frame.height - keyboardSize.height)) + leverageSize.frame.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    // Load UserDefaults method
    func loadUserDefaults() {
        let defaults = UserDefaults.standard
        let selectedPair = Settings.shared.selectedTradingPair.rawValue
        if let savedData = defaults.object(forKey: selectedPair) as? Data {
            let decoder = JSONDecoder()
            if let loadedData = try? decoder.decode(CalculatorEntryData.self, from: savedData) {
                longShortSwitcher.selectedSegmentIndex = loadedData.longShortSwitcher == .long ? 0 : 1
                quantity.textFieldInputView.text = String(loadedData.quantity.removeZerosFromEnd())
                entryPrice.textFieldInputView.text = String(loadedData.enterPrice.removeZerosFromEnd())
                exitPrice.textFieldInputView.text = String(loadedData.closePrice.removeZerosFromEnd())
                leverageSize.textFieldInputView.text = String(loadedData.leverageSize.removeZerosFromEnd())
                btcPriceWhenEnter.textFieldInputView.text = String(loadedData.btcPriceWhenEnter.removeZerosFromEnd())
                btcPriceWhenExit.textFieldInputView.text = String(loadedData.btcPriceWhenExit.removeZerosFromEnd())
                
                switch loadedData.feeType {
                case .enteredLimitClosedMarket:
                    enterOrder.segmentedControl.selectedSegmentIndex = 0
                    closeOrder.segmentedControl.selectedSegmentIndex = 1
                case .twoLimits:
                    enterOrder.segmentedControl.selectedSegmentIndex = 0
                    closeOrder.segmentedControl.selectedSegmentIndex = 0
                case .twoMarkets:
                    enterOrder.segmentedControl.selectedSegmentIndex = 1
                    closeOrder.segmentedControl.selectedSegmentIndex = 1
                case .enteredMarketClosedLimit:
                    enterOrder.segmentedControl.selectedSegmentIndex = 1
                    closeOrder.segmentedControl.selectedSegmentIndex = 0
                }
            }
        }
    }
}

// MARK: UITextfield methods
extension MainViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        calculate()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: NavDropMenuDelegate methods
extension MainViewController: NavDropMenuDelegate {
    func navDropMenuCellSelected(selectedRowInt: Int) {
        loadUserDefaults()
        showHideBTCPriceForAltcoins()
        
        switch Settings.shared.selectedTradingPair {
        case .XBTUSD, .XBTH20, .XBTZ19:
            quantity.textFieldNameLabel.text = "Quantity ($)"
        case .ADAZ19, .BCHZ19, .EOSZ19, .ETHUSD, .ETHZ19, .LTCZ19, .TRXZ19, .XRPZ19:
            let currency = String(Settings.shared.selectedTradingPair.rawValue.prefix(3))
            quantity.textFieldNameLabel.text = "Quantity (\(currency))"
        }
        
        calculate()
    }
}
