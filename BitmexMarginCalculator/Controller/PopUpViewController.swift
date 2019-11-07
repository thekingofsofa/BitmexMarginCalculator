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
    fileprivate let upperDots = UILabel()
    fileprivate let downDots = UILabel()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.6)
        [backgroundView, textLabel, upperDots, downDots].forEach { view.addSubview($0) }
        setupLayout()
        setupView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc func viewTapped(_ recognizer: UIGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Setup UI
    private func setupView() {
        
        backgroundView.backgroundColor = .white
        backgroundView.layer.cornerRadius = 12
        
        textLabel.setScaledCustomFont(forFont: .RobotoRegular, textStyle: .body)
        let infoTextViewDataFiller = InfoTextViewDataFiller()
        textLabel.text = infoTextViewDataFiller.liquidationPriceNotice()
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
        
        // Adding dots
        upperDots.text = "•   •   •"
        upperDots.textAlignment = .center
        upperDots.font = upperDots.font.withSize(20)
        downDots.text = "•   •   •"
        downDots.textAlignment = .center
        downDots.font = downDots.font.withSize(20)
    }
    
    private func setupLayout() {
        textLabel.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 48, bottom: 0, right: 48))
        textLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        upperDots.anchor(top: textLabel.topAnchor, leading: textLabel.leadingAnchor, bottom: textLabel.topAnchor, trailing: textLabel.trailingAnchor, padding: .init(top: -30, left: 12, bottom: 0, right: 12))
        downDots.anchor(top: textLabel.bottomAnchor, leading: textLabel.leadingAnchor, bottom: textLabel.bottomAnchor, trailing: textLabel.trailingAnchor, padding: .init(top: 0, left: 12, bottom: -30, right: 12))
        backgroundView.anchor(top: upperDots.topAnchor, leading: textLabel.leadingAnchor, bottom: downDots.bottomAnchor, trailing: textLabel.trailingAnchor, padding: .init(top: -10, left: -24, bottom: -10, right: -24))
    }
}
