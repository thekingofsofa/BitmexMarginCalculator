//
//  SettingsLauncher.swift
//  BitMEXMarginCalculator
//
//  Created by Иван Барабанщиков on 9/20/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

fileprivate let cellId = "cellId"
fileprivate let cellHeight: CGFloat = 56

class SettingsLauncher: NSObject {
    
    var homeController = MainViewController()
    
    private let blackView = UIView()
    private let tableView: UITableView = {
        let tb = UITableView()
        
        if let backgroundImage = UIImage(named: "background_light") {
            tb.backgroundColor = UIColor(patternImage: backgroundImage)
        }
        tb.separatorStyle = .none
        tb.tableFooterView = UIView()
        tb.bounces = false
        tb.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        
        return tb
    }()
    
    private var tableViewBottomConstraint: NSLayoutConstraint?
    
    private let cells : [(SettingsCellType, SettingsButtons)] = [(SettingsCellType.withSwither, .showHideLastPrice), (SettingsCellType.withSwither, .showHideFees), (SettingsCellType.separator, .separator), (SettingsCellType.onlyTitle, .aboutApp), (SettingsCellType.onlyTitle, .feesInfo), (SettingsCellType.onlyTitle, .aboutLiqudation), (SettingsCellType.onlyTitle, .cancel)]
    
    override init() {
        super.init()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    func showSettings() {
        if let window = UIApplication.shared.currentWindow {
            window.addSubview(blackView)
            window.addSubview(tableView)
            setupLayout()
            
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackView.alpha = 1.0
                self.tableViewBottomConstraint?.constant = 0
                window.layoutIfNeeded()
                
            }, completion: nil)
        }
    }
    
    func setupLayout() {
        let height = cellHeight * CGFloat(cells.count)
        if let window = UIApplication.shared.currentWindow {
            
            tableView.anchor(top: nil, leading: window.leadingAnchor, bottom: nil, trailing: window.trailingAnchor)
            tableView.heightAnchor.constraint(equalToConstant: height).isActive = true
            tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: height)
            tableViewBottomConstraint?.isActive = true
            
            blackView.anchor(top: window.topAnchor, leading: window.leadingAnchor, bottom: window.bottomAnchor, trailing: window.trailingAnchor)
            
            UIApplication.shared.currentWindow?.layoutIfNeeded()
        }
    }
    
    // MARK: - Actions
    @objc func handleDismiss() {
        
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 0.0
            self.tableViewBottomConstraint?.constant = cellHeight * CGFloat(self.cells.count)
            UIApplication.shared.currentWindow?.layoutIfNeeded()
        }
    }
    
    @objc func switchShowFees() {
        
        Settings.shared.showFees = !Settings.shared.showFees
        homeController.showHideFees()
        homeController.calculate()
        UserDefaults.standard.set(Settings.shared.showFees, forKey: "showFees")
    }
    
    @objc func switchShowLastPrice() {
        
        Settings.shared.showLastPrice = !Settings.shared.showLastPrice
        homeController.showHideLastPrice()
        UserDefaults.standard.set(Settings.shared.showLastPrice, forKey: "showLastPrice")
    }
}

// MARK: - UITableViewDataSource/Delegate methods
extension SettingsLauncher: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if cells[indexPath.row].1 == .separator {
            return 20
        } else {
            return cellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SettingsTableViewCell
        cell.configureCell(text: cells[indexPath.row].1.title, cellType: cells[indexPath.row].0)
        
        if indexPath.row == 0 {
            cell.switcher.addTarget(self, action: #selector(switchShowLastPrice), for: .valueChanged)
            cell.switcher.isOn = Settings.shared.showLastPrice ? true : false
        } else if indexPath.row == 1 {
            cell.switcher.addTarget(self, action: #selector(switchShowFees), for: .valueChanged)
            cell.switcher.isOn = Settings.shared.showFees ? true : false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? SettingsTableViewCell {
            
            switch cells[indexPath.row].1 {
            case .showHideLastPrice:
                switchShowLastPrice()
                cell.switcher.setOn(!cell.switcher.isOn, animated: true)
            case .showHideFees:
                switchShowFees()
                cell.switcher.setOn(!cell.switcher.isOn, animated: true)
            case .separator:
                print("separator")
            case .aboutApp:
                handleDismiss()
                let vc = InfoTextViewController()
                vc.pageType = .aboutAppPage
                homeController.navigationController?.pushViewController(vc, animated: true)
            case .aboutLiqudation:
                handleDismiss()
                let vc = InfoTextViewController()
                vc.pageType = .aboutLiquidationPage
                homeController.navigationController?.pushViewController(vc, animated: true)
            case .cancel:
                handleDismiss()
            case .feesInfo:
                handleDismiss()
                let vc = FeesViewController()
                homeController.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
