//
//  ViewController.swift
//  BitMEXMarginCalculator
//
//  Created by Иван Барабанщиков on 9/20/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    let marginCalc = MarginCalculator()
    var feeType = FeeType.twoMarkets
    
    var navDropMenu = NavDropMenu(items: Settings.shared.listOfAllTradingPairs)
//    var lastPriceView = LastPriceView()
    var inputCalcView = InputView()
    var outputCalcView = ResultView()
    var bottomLabel = UILabel()
    
    lazy var settingsLauncher: SettingsLauncher = {
        let launcher = SettingsLauncher()
        launcher.homeController = self
        return launcher
    }()
    
    private var lastPriceVC = LastPriceViewController()
    private var mainScrollView = UIScrollView()
    private var mainStackView = UIStackView()
    private var mainStackViewTopConstraint = NSLayoutConstraint()
    private var lastPriceViewHeightConstraint = NSLayoutConstraint()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupLayout()
        setupNavigationBar()
        showHideFees()
        showHideBTCPriceForAltcoins()
        calculate()
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
            if !lastPriceVC.lastPriceView.isCollapsed {
                DispatchQueue.main.async {
                    self.lastPriceVC.lastPriceView.chart.redrawChart()
                    self.lastPriceVC.lastPriceView.layoutIfNeeded()
                }
            }
        }
    }
    
    // MARK: - Setup View
    private func setupView() {
        // Manage colors
        guard let backgroundImage = UIImage(named: "background_light") else { return }
        self.view.backgroundColor = UIColor(patternImage: backgroundImage)
        // Adding views
        [mainScrollView, navDropMenu].forEach {
            view.addSubview($0)
        }
        mainStackView = UIStackView(arrangedSubviews: [inputCalcView, outputCalcView])
        mainStackView.spacing = 12
        addChild(lastPriceVC)
        [lastPriceVC.view, mainStackView, bottomLabel].forEach {
            mainScrollView.addSubview($0)
        }
        lastPriceVC.didMove(toParent: self)
        // Last BTC price view
        setupLastPriceView()
        // Bottom label
        bottomLabel.text = "All currency units denominated in XBT"
        bottomLabel.setScaledCustomFont(forFont: .robotoLight, textStyle: .footnote)
        bottomLabel.textColor = .gray
        bottomLabel.textAlignment = .center
        // Info Buttons
        setupInfoButtons()
        // Delegate textfields
        [inputCalcView.quantity, inputCalcView.entryPrice, inputCalcView.exitPrice, inputCalcView.leverageSize, inputCalcView.btcPriceWhenEnter, inputCalcView.btcPriceWhenExit].forEach { $0.textFieldInputView.delegate = self }
        
        inputCalcView.longShortSwitcher.addTarget(self, action: #selector(positionSideChanged), for: .valueChanged)
        // Fees switchers
        inputCalcView.enterOrder.segmentedControl.addTarget(self, action: #selector(changeFeeType), for: .valueChanged)
        inputCalcView.closeOrder.segmentedControl.addTarget(self, action: #selector(changeFeeType), for: .valueChanged)
        // Load last entered data via UserDefaults
        loadUserDefaults()
        determineFeeType()
        // If keyboard appeard above textfield, setContentOffset
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: Setup navigation bar
    private func setupNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .orangeMain
        navigationController?.navigationBar.tintColor = .white
        let configButton = UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: self, action: #selector(configButtonPressed))
        navigationItem.rightBarButtonItem = configButton
        navigationItem.titleView?.tintColor = .white
        navigationItem.titleView = navDropMenu.navBarButton
        navDropMenu.delegate = self
    }
    
    // MARK: Setup lastPrice top view
    private func setupLastPriceView() {
        
        lastPriceVC.lastPriceView.collapseAction = collapseLastPriceView
    }
    
    // MARK: Setup info Button
    private func setupInfoButtons() {
        outputCalcView.liquidationPrice.resultLabel.addInfoButton()
        outputCalcView.liquidationPrice.resultLabel.infoButton.addTarget(self, action: #selector(liquidationInfoButtonPressed), for: .touchUpInside)
    }
    
    // MARK: Layout View
    private func setupLayout() {
        
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            setupConstraintForCompactEnviromnentIphone()
        } else if UIDevice.current.orientation == .portrait {
            setupConstraintForRegularEnviromnentIphone()
        }
        
        lastPriceVC.view.anchor(top: mainScrollView.topAnchor, leading: mainScrollView.leadingAnchor, bottom: nil, trailing: mainScrollView.trailingAnchor, padding: .init(top: 12, left: 12, bottom: 0, right: 12))
        lastPriceViewHeightConstraint = lastPriceVC.view.heightAnchor.constraint(equalToConstant: 54)
        lastPriceViewHeightConstraint.isActive = true
        
        mainScrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        mainStackView.anchor(top: nil, leading: mainScrollView.leadingAnchor, bottom: mainScrollView.bottomAnchor, trailing: mainScrollView.trailingAnchor, padding: .init(top: 12, left: 12, bottom: 28, right: 12))
        mainStackView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor, constant: -24).isActive = true
        showHideLastPrice()
        
        navDropMenu.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        bottomLabel.anchor(top: outputCalcView.bottomAnchor, leading: outputCalcView.leadingAnchor, bottom: nil, trailing: outputCalcView.trailingAnchor, padding: .init(top: 4, left: 12, bottom: 0, right: 12))
    }
    
    private func setupConstraintForCompactEnviromnentIphone() {
        self.mainStackView.axis = .horizontal
        self.mainStackView.alignment = .top
        self.mainStackView.distribution = .fillEqually
    }
    
    private func setupConstraintForRegularEnviromnentIphone() {
        self.mainStackView.axis = .vertical
        self.mainStackView.alignment = .fill
        self.mainStackView.distribution = .fill
    }
    
    // MARK: - Calculator
    func calculate() {
        // Check max leverage
        if let leverageSizeInt = Int(self.inputCalcView.leverageSize.textFieldInputView.text ?? "0") {
            if leverageSizeInt > Settings.shared.selectedTradingPair.maxLeverage {
                inputCalcView.leverageSize.textFieldInputView.backgroundColor = UIColor(red: 1.00, green: 0.80, blue: 0.80, alpha: 1.0)
            } else {
                inputCalcView.leverageSize.textFieldInputView.backgroundColor = UIColor.orangeLightAlpha
            }
        }
        
        let enterPrice = NumberFormatter().number(from: inputCalcView.entryPrice.textFieldInputView.text ?? "0")
        if let enterPrice = enterPrice {
            marginCalc.calcEntryData.enterPrice = Double(truncating: enterPrice)
        }
        let closePrice = NumberFormatter().number(from: inputCalcView.exitPrice.textFieldInputView.text ?? "0")
        if let closePrice = closePrice {
            marginCalc.calcEntryData.closePrice = Double(truncating: closePrice)
        }
        marginCalc.calcEntryData.longShortSwitcher = inputCalcView.longShortSwitcher.selectedSegmentIndex == 0 ? .long : .short
        marginCalc.calcEntryData.quantity = Double(inputCalcView.quantity.textFieldInputView.text!) ?? 0
        marginCalc.calcEntryData.leverageSize = Double(inputCalcView.leverageSize.textFieldInputView.text!) ?? 0
        marginCalc.calcEntryData.feeType = feeType
        marginCalc.calcEntryData.btcPriceWhenEnter = Double(inputCalcView.btcPriceWhenEnter.textFieldInputView.text!) ?? 0
        marginCalc.calcEntryData.btcPriceWhenExit = Double(inputCalcView.btcPriceWhenExit.textFieldInputView.text!) ?? 0
        marginCalc.calculate()
        
        let formatLiquidationStringStyle = Settings.shared.selectedTradingPair.formatStyle
        
        outputCalcView.quantityBTC.resultLabel.text = String(format: "%.4f", marginCalc.initialMarginBTC)
        outputCalcView.btcPriceChange.resultLabel.text = String(format: "%.2f", marginCalc.priceChangePercentage)  + "%"
        outputCalcView.profitLossBTC.resultLabel.text = String(format: "%.4f", marginCalc.profitLossBTC)
        outputCalcView.profitLossUSD.resultLabel.text = String(format: "%.2f", marginCalc.profitLossUSD) + "$"
        outputCalcView.roe.resultLabel.text = String(format: "%.2f", marginCalc.roe) + "%"
        outputCalcView.liquidationPrice.resultLabel.text = String(format: formatLiquidationStringStyle, marginCalc.liquidationPrice)
        outputCalcView.fees.resultLabel.text = String(format: "%.2f", marginCalc.feesInUSD) + "$"
    }
    
    // MARK: - Actions
    @objc func collapseLastPriceView() {
        if lastPriceVC.lastPriceView.isCollapsed {
            lastPriceViewHeightConstraint.constant = 54
        } else {
            lastPriceViewHeightConstraint.constant = 300
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func positionSideChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
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
    
    @objc private func configButtonPressed() {
        settingsLauncher.showSettings()
        view.endEditing(true)
    }
    
    @objc func liquidationInfoButtonPressed() {
        let infoVC = PopUpViewController()
        infoVC.modalPresentationStyle = .overCurrentContext
        infoVC.modalTransitionStyle = .crossDissolve
        present(infoVC, animated: true, completion: nil)
    }
    
    // MARK: Fees methods
    @objc func changeFeeType() {
        determineFeeType()
        calculate()
    }
    
    func determineFeeType() {
        if inputCalcView.enterOrder.segmentedControl.selectedSegmentIndex == 0 && inputCalcView.closeOrder.segmentedControl.selectedSegmentIndex == 0 {
            feeType = FeeType.twoLimits
        } else if inputCalcView.enterOrder.segmentedControl.selectedSegmentIndex == 0 && inputCalcView.closeOrder.segmentedControl.selectedSegmentIndex == 1 {
            feeType = FeeType.enteredLimitClosedMarket
        } else if inputCalcView.enterOrder.segmentedControl.selectedSegmentIndex == 1 && inputCalcView.closeOrder.segmentedControl.selectedSegmentIndex == 1 {
            feeType = FeeType.twoMarkets
        } else if inputCalcView.enterOrder.segmentedControl.selectedSegmentIndex == 1 && inputCalcView.closeOrder.segmentedControl.selectedSegmentIndex == 0 {
            feeType = FeeType.enteredMarketClosedLimit
        }
    }
    
    // MARK: Show/hide fee
    func showHideFees() {
        if Settings.shared.showFees {
            inputCalcView.enterOrder.isHidden = false
            inputCalcView.closeOrder.isHidden = false
            outputCalcView.fees.isHidden = false
        } else {
            inputCalcView.enterOrder.isHidden = true
            inputCalcView.closeOrder.isHidden = true
            outputCalcView.fees.isHidden = true
        }
    }
    
    // MARK: - Show/hide last BTC price
    func showHideLastPrice() {
        mainStackViewTopConstraint.isActive = false
        if Settings.shared.showLastPrice {
            mainStackViewTopConstraint = mainStackView.topAnchor.constraint(equalTo: lastPriceVC.view.bottomAnchor)
            lastPriceVC.view.isHidden = false
        } else {
            mainStackViewTopConstraint = mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
            lastPriceVC.view.isHidden = true
        }
        mainStackViewTopConstraint.constant = 12
        mainStackViewTopConstraint.isActive = true
    }
    
    // MARK: Show/hide btc price when enter and exit for altcoins
    func showHideBTCPriceForAltcoins() {
        let traidingPair = Settings.shared.selectedTradingPair
        switch traidingPair {
        case .XBTUSD, .XBTH21, .XBTM21:
            inputCalcView.btcPriceWhenEnter.isHidden = true
            inputCalcView.btcPriceWhenExit.isHidden = true
        case .ETHUSD:
            inputCalcView.btcPriceWhenEnter.isHidden = false
            inputCalcView.btcPriceWhenExit.isHidden = false
        }
    }
    
    // MARK: - Load UserDefaults method
    private func loadUserDefaults() {
        let defaults = UserDefaults.standard
        let selectedPair = Settings.shared.selectedTradingPair.rawValue
        if let savedData = defaults.object(forKey: selectedPair) as? Data {
            let decoder = JSONDecoder()
            if let loadedData = try? decoder.decode(CalculatorEntryData.self, from: savedData) {
                inputCalcView.longShortSwitcher.selectedSegmentIndex = loadedData.longShortSwitcher == .long ? 0 : 1
                inputCalcView.quantity.textFieldInputView.text = String(loadedData.quantity.removeZerosFromEnd())
                inputCalcView.entryPrice.textFieldInputView.text = String(loadedData.enterPrice.removeZerosFromEnd())
                inputCalcView.exitPrice.textFieldInputView.text = String(loadedData.closePrice.removeZerosFromEnd())
                inputCalcView.leverageSize.textFieldInputView.text = String(loadedData.leverageSize.removeZerosFromEnd())
                inputCalcView.btcPriceWhenEnter.textFieldInputView.text = String(loadedData.btcPriceWhenEnter.removeZerosFromEnd())
                inputCalcView.btcPriceWhenExit.textFieldInputView.text = String(loadedData.btcPriceWhenExit.removeZerosFromEnd())
                
                switch loadedData.feeType {
                case .enteredLimitClosedMarket:
                    inputCalcView.enterOrder.segmentedControl.selectedSegmentIndex = 0
                    inputCalcView.closeOrder.segmentedControl.selectedSegmentIndex = 1
                case .twoLimits:
                    inputCalcView.enterOrder.segmentedControl.selectedSegmentIndex = 0
                    inputCalcView.closeOrder.segmentedControl.selectedSegmentIndex = 0
                case .twoMarkets:
                    inputCalcView.enterOrder.segmentedControl.selectedSegmentIndex = 1
                    inputCalcView.closeOrder.segmentedControl.selectedSegmentIndex = 1
                case .enteredMarketClosedLimit:
                    inputCalcView.enterOrder.segmentedControl.selectedSegmentIndex = 1
                    inputCalcView.closeOrder.segmentedControl.selectedSegmentIndex = 0
                }
            }
        }
    }
}

// MARK: - UITextfield methods
extension MainViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        calculate()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Restricts textfields only to numbers
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let allowedCharacters = CharacterSet(charactersIn: ",.0123456789 ")//Here change this characters based on your requirement
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    // Method to set setContentOffset, if keyboard appeard above textfield
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            if (view.frame.height - keyboardSize.height) <= (inputCalcView.leverageSize.frame.origin.y + inputCalcView.leverageSize.frame.height) {
                self.view.frame.origin.y -= ((inputCalcView.leverageSize.frame.origin.y + inputCalcView.leverageSize.frame.height) - (view.frame.height - keyboardSize.height)) + inputCalcView.leverageSize.frame.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let frameY = (navigationController?.navigationBar.frame.height ?? 0) + (self.view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0)
        if self.view.frame.origin.y != frameY {
            self.view.frame.origin.y = frameY
        }
    }
}

// MARK: - NavDropMenuDelegate methods
extension MainViewController: NavDropMenuDelegate {
    
    func navDropMenuCellSelected(selectedRowInt: Int) {
        
        loadUserDefaults()
        showHideBTCPriceForAltcoins()
        
        switch Settings.shared.selectedTradingPair {
        case .XBTUSD, .XBTH21, .XBTM21:
            inputCalcView.quantity.textFieldNameLabel.text = "Quantity ($)"
        case .ETHUSD:
            let currency = String(Settings.shared.selectedTradingPair.rawValue.prefix(3))
            inputCalcView.quantity.textFieldNameLabel.text = "Quantity (\(currency))"
        }
//        lastPriceVC.changeSubscribeArgumentsForWebsocket()
        lastPriceVC.lastPriceView.checkIfCollapsed()
        lastPriceVC.restartFeeding()
        calculate()
    }
}
