//
//  InfoTextViewController.swift
//  BitMEXMarginCalculator
//
//  Created by Иван Барабанщиков on 9/20/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

class InfoTextViewController: UIViewController {

    enum InfoTextViewType {
        case aboutAppPage
        case aboutLiquidationPage
    }
    
    var textView = UITextView()
    var dataFiller = InfoTextViewDataFiller()
    var pageType = InfoTextViewType.aboutAppPage
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.textView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    // MARK: - Setup UI
    func setupView() {
        
        // Setup text view
        self.view.addSubview(textView)
        textView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                        leading: view.safeAreaLayoutGuide.leadingAnchor,
                        bottom: view.safeAreaLayoutGuide.bottomAnchor,
                        trailing: view.safeAreaLayoutGuide.trailingAnchor)
        // Manage colors
        guard let backgroundImage = UIImage(named: "background_light") else { return }
        self.view.backgroundColor = UIColor(patternImage: backgroundImage)
        textView.backgroundColor = .clear
        
        // Manage content
        textView.isEditable = false
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        switch pageType {
        case .aboutAppPage:
            self.title = "About App"
            textView.attributedText = dataFiller.loadAboutAppPage()
        case .aboutLiquidationPage:
            self.title = "About Liquidation"
            textView.attributedText = dataFiller.loadAboutLiquidationPage()
        }
        textView.setScaledCustomFont(forFont: .robotoRegular, textStyle: .body)
    }
}
