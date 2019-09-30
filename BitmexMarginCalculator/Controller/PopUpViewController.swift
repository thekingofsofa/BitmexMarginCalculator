//
//  PopUpViewController.swift
//  BitmexMarginCalculator
//
//  Created by Иван Барабанщиков on 9/30/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {
    
    fileprivate let backgroundView = UIView()
    fileprivate let textLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.6)
        [backgroundView, textLabel].forEach { view.addSubview($0) }
        setupLayout()
        setupView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func viewTapped(_ recognizer: UIGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupLayout() {
        textLabel.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 48, bottom: 0, right: 48))
        textLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        backgroundView.anchor(top: textLabel.topAnchor, leading: textLabel.leadingAnchor, bottom: textLabel.bottomAnchor, trailing: textLabel.trailingAnchor, padding: .init(top: -16, left: -16, bottom: -16, right: -16))
    }
    
    private func setupView() {
        
        backgroundView.backgroundColor = .white
        backgroundView.layer.cornerRadius = 12
        
        textLabel.setScaledCustomFont(forFont: .RobotoRegular, textStyle: .body)
        let infoTextViewDataFiller = InfoTextViewDataFiller()
        textLabel.text = infoTextViewDataFiller.noticeAboutLiquidationPrice()
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
    }
}
