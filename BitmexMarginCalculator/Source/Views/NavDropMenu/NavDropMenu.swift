//
//  NavDropMenu.swift
//  BitMEXMarginCalculator
//
//  Created by Иван Барабанщиков on 10/4/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

fileprivate let cellId = "cellId"
fileprivate let cellHeight: CGFloat = 42

class NavDropMenu: UIView {
    
    var navBarButton = UIButton()
    var navBarTitle = UILabel()
    var navBarArrow = UIImageView()
    var items = [String]()
    let blackView = UIView()
    var viewDropped = false
    
    var tableView = UITableView()
    var tableViewBottomConstraint = NSLayoutConstraint()
    
    var delegate: NavDropMenuDelegate?
    
    init(items: [String]) {
        super.init(frame: CGRect.zero)
        
        self.items = items
        self.isUserInteractionEnabled = false
        self.clipsToBounds = true
        [navBarButton, blackView, tableView].forEach {
            addSubview($0)
        }
        setupBlackView()
        setupTableView()
        setupNavBarButton()
    }
    
    private func setupNavBarButton() {
        navBarTitle.text = Settings.shared.selectedTradingPair.rawValue
        navBarTitle.font = UIFont(name: "Roboto-Medium", size: 17)
        navBarTitle.textColor = .white
        navBarArrow.image = UIImage(named: "arrow_white")
        navBarArrow.contentMode = .scaleAspectFit
        let navBarButtonStackView = UIStackView(arrangedSubviews: [navBarTitle, navBarArrow])
        navBarButtonStackView.distribution = .fill
        navBarButtonStackView.axis = .horizontal
        navBarButtonStackView.isUserInteractionEnabled = false
        navBarButton.addSubview(navBarButtonStackView)
        navBarButton.addTarget(self, action: #selector(showHideMenu), for: .touchUpInside)
        navBarButtonStackView.fillSuperview()
    }
    
    private func setupBlackView() {
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.alpha = 0
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        // Layout BlackView
        blackView.translatesAutoresizingMaskIntoConstraints = false
        blackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        blackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        blackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        blackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.bounces = false
        tableView.tableFooterView = UIView()
        tableView.separatorColor = .grayLight
        // Layout TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.heightAnchor.constraint(equalToConstant: cellHeight * CGFloat(items.count)).isActive = true
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: topAnchor)
        tableViewBottomConstraint.isActive = true
    }
    
    @objc func showHideMenu() {
        if !viewDropped {
            self.isUserInteractionEnabled = true
            viewDropped = true
            tableViewBottomConstraint.constant = cellHeight * CGFloat(items.count)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1.0
                self.navBarArrow.transform = self.navBarArrow.transform.rotated(by: 180 * CGFloat(Double.pi/180))

                self.layoutIfNeeded()
            }, completion: nil)
            
            // Dissmis keyboard if its on.
            if let parentView = self.superview {
                parentView.endEditing(true)
            }
        } else {
            handleDismiss()
        }
    }
    
    @objc func handleDismiss() {
        tableViewBottomConstraint.constant = 0
        viewDropped = false
        self.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.blackView.alpha = 0
            self.navBarArrow.transform = self.navBarArrow.transform.rotated(by: 180 * CGFloat(Double.pi/180))
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NavDropMenu: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = items[indexPath.row]
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.selectionStyle = .none
        cell.separatorInset = .zero
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Settings.shared.selectedTradingPair = TradingPair(rawValue: items[indexPath.row]) ?? .XBTUSD
        self.navBarTitle.text = Settings.shared.selectedTradingPair.rawValue
        delegate?.navDropMenuCellSelected(selectedRowInt: indexPath.row)
        handleDismiss()
    }
}

protocol NavDropMenuDelegate {
    func navDropMenuCellSelected(selectedRowInt: Int)
}
