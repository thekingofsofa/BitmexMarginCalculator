//
//  ViewController.swift
//  BitMEXMarginCalculator
//
//  Created by Иван Барабанщиков on 9/20/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITextFieldDelegate {
    
    var mainScrollView = UIScrollView()
    var mainStackView = UIStackView()
    
    var longShortSwitcher = UISegmentedControl()
    var quantityXBT = TextFieldView(textFieldName: "Quantity XBT($)")
    var entryPrice = TextFieldView(textFieldName: "Entry price")
    var exitPrice = TextFieldView(textFieldName: "Exit price")
    var leverageSize = TextFieldView(textFieldName: "Leverage")
    var enterOrder = LabelSegmentedView(titleText: "Enter order", segmentedOptions: ["Limit", "Market"])
    var closeOrder = LabelSegmentedView(titleText: "Close order", segmentedOptions: ["Limit", "Market"])
    var feeType = FeeType.twoMarkets
    
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
            marginCalc.longShortSwitcher = .long
            marginCalc.saveEnteredData()
            calculate()
        case 1:
            marginCalc.longShortSwitcher = .short
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
    }
    
    // MARK: Setup View
    func setupView() {
        setupNavigationBar()
        
        // Manage colors
        guard let backgroundImage = UIImage(named: "background_light") else { return }
        self.view.backgroundColor = UIColor(patternImage: backgroundImage)
        
        // Delegate textfields
        [quantityXBT, entryPrice, exitPrice, leverageSize].forEach { $0.textFieldInputView.delegate = self }
        
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
        longShortSwitcher.selectedSegmentIndex = UserDefaults.standard.bool(forKey: "longShortSwitcher") == true ? 0 : 1
        quantityXBT.textFieldInputView.text = String(UserDefaults.standard.double(forKey: "quantityXBT").removeZerosFromEnd())
        entryPrice.textFieldInputView.text = String(UserDefaults.standard.double(forKey: "entryPrice").removeZerosFromEnd())
        exitPrice.textFieldInputView.text = String(UserDefaults.standard.double(forKey: "exitPrice").removeZerosFromEnd())
        leverageSize.textFieldInputView.text = String(UserDefaults.standard.double(forKey: "leverageSize").removeZerosFromEnd())
        enterOrder.segmentedControl.selectedSegmentIndex = UserDefaults.standard.bool(forKey: "entryLimit") == true ? 0 : 1
        closeOrder.segmentedControl.selectedSegmentIndex = UserDefaults.standard.bool(forKey: "closeLimit") == true ? 0 : 1
        determineFeeType()
        
        // If keyboard appeard above textfield(iphone 5s,SE), setContentOffset
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    // MARK: Layout View
    func setupLayout() {
        let entryDataStackView = UIStackView(arrangedSubviews: [longShortSwitcher, quantityXBT, entryPrice, exitPrice, leverageSize, enterOrder, closeOrder])
        entryDataStackView.distribution = .fillEqually
        entryDataStackView.axis = .vertical
        entryDataStackView.spacing = 10
        
        [longShortSwitcher, quantityXBT, entryPrice, exitPrice, leverageSize, enterOrder, closeOrder].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        
        mainStackView = UIStackView(arrangedSubviews: [entryDataStackView, resultBorderView])
        mainStackView.spacing = 12
        view.addSubview(mainScrollView)
        mainScrollView.addSubview(mainStackView)
        
        mainScrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        
        mainStackView.anchor(top: mainScrollView.topAnchor, leading: mainScrollView.leadingAnchor, bottom: mainScrollView.bottomAnchor, trailing: mainScrollView.trailingAnchor, padding: .init(top: 12, left: 12, bottom: 12, right: 12))
        mainStackView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor, constant: -24).isActive = true
    }
    
    // MARK: Setup NavigationBar
    private func setupNavigationBar() {
        self.title = "USD / XBT"
        let configButton = UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: self, action: #selector(configButtonPressed))
        navigationItem.rightBarButtonItem = configButton
    }
    
    @objc private func configButtonPressed() {
        settingsLauncher.showSettings()
    }
    
    // MARK: Calculator
    func calculate() {
        marginCalc.longShortSwitcher = longShortSwitcher.selectedSegmentIndex == 0 ? .long : .short
        marginCalc.quantityXBT = Double(quantityXBT.textFieldInputView.text!) ?? 0
        marginCalc.enterPrice = Double(entryPrice.textFieldInputView.text!) ?? 0
        marginCalc.closePrice = Double(exitPrice.textFieldInputView.text!) ?? 0
        marginCalc.leverageSize = Double(leverageSize.textFieldInputView.text!) ?? 0
        marginCalc.feeType = feeType
        marginCalc.calculate()
        
        resultBorderView.quantityBTC.resultLabel.text = String(format: "%.4f", marginCalc.initialBTC)
        resultBorderView.btcPriceChange.resultLabel.text = String(format: "%.2f", marginCalc.btcPriceChangePercentage)  + "%"
        
        resultBorderView.profitLossBTC.resultLabel.text = String(format: "%.4f", marginCalc.profitLossBTC)
        resultBorderView.profitLossUSD.resultLabel.text = String(format: "%.2f", marginCalc.profitLossUSD) + "$"
        resultBorderView.roe.resultLabel.text = String(format: "%.2f", marginCalc.roe) + "%"
        resultBorderView.liqudationPrice.resultLabel.text = String(format: "%.2f", marginCalc.liqudationPrice)
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
    
    // MARK: UITextfield methods
    func textFieldDidEndEditing(_ textField: UITextField) {
        calculate()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
}
