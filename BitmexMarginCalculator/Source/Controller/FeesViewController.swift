//
//  FeesViewController.swift
//  BitmexMarginCalculator
//
//  Created by Иван Барабанщиков on 10/7/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

fileprivate let cellIdentifier = "cell"
fileprivate let cellHeight: CGFloat = 50
fileprivate let numberOfSectionsConstant = Settings.shared.listOfAllTradingPairs.count + 1

class FeesViewController: UIViewController {
    
    var scrollView = UIScrollView()
    var topLabel = UILabel()
    var collectionView: UICollectionView!
    
    private let spacingBetweenCells: CGFloat = 1.0
    
    let rowData: ([String], [String], [String]) = {
        var array0 = [String]()
        var array1 = [String]()
        var array2 = [String]()
        TradingPair.allCases.forEach {
            array0.append("\($0.makerFee * -100)%")
            array1.append("\($0.takerFee * -100)%")
            array2.append("\($0.maxLeverage)x")
        }
        var rowData = (array0, array1, array2)
        return rowData
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (_) in
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            self.collectionView.collectionViewLayout.invalidateLayout() // layout update
        }, completion: nil)
    }
    
    // MARK: - Setup UI
    func setupView() {
        // Manage view
        self.title = "Fees"
        guard let backgroundImage = UIImage(named: "background_light") else { return }
        self.view.backgroundColor = UIColor(patternImage: backgroundImage)
        
        // Setup collection view
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.backgroundColor = .clear
        collectionView.layer.borderColor = UIColor.black.cgColor
        collectionView.layer.borderWidth = 1.0
        
        // Setup bottom view
        let dataFiller = InfoTextViewDataFiller()
        topLabel.setScaledCustomFont(forFont: .robotoRegular, textStyle: .body)
        topLabel.numberOfLines = 0
        topLabel.attributedText = dataFiller.feesNotice()
        
        // Setup scroll view and stack view
        view.addSubview(scrollView)
        let stackView = UIStackView(arrangedSubviews: [topLabel, collectionView])
        stackView.spacing = 12
        stackView.distribution = .fill
        stackView.axis = .vertical
        scrollView.addSubview(stackView)
        
        // Manage Layout
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        stackView.anchor(top: scrollView.topAnchor, leading: scrollView.leadingAnchor, bottom: scrollView.bottomAnchor, trailing: scrollView.trailingAnchor, padding: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.heightAnchor.constraint(equalToConstant: cellHeight * CGFloat(numberOfSectionsConstant)).isActive = true
        collectionView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -24).isActive = true
        
        topLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -24).isActive = true
    }
}

// MARK: - CollectionView DataSource/Delegate methods

extension FeesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = ((collectionView.frame.width - (3 * spacingBetweenCells)) / 4)
        
        return CGSize(width: width, height: cellHeight)
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacingBetweenCells
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSectionsConstant
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CustomCollectionViewCell
        
        switch indexPath.row {
        case 0:
            if indexPath.section == 0 {
                cell.titleLabel.text = ""
            } else {
                cell.titleLabel.text = "\(Settings.shared.listOfAllTradingPairs[indexPath.section - 1])"
            }
        case 1:
            if indexPath.section == 0 {
                cell.titleLabel.text = "Taker fee"
            } else {
                cell.titleLabel.text = "\(rowData.0[indexPath.section - 1])"
            }
        case 2:
            if indexPath.section == 0 {
                cell.titleLabel.text = "Maker fee"
            } else {
                cell.titleLabel.text = "\(rowData.1[indexPath.section - 1])"
            }
        case 3:
            if indexPath.section == 0 {
                cell.titleLabel.text = "Maximum Leverage"
            } else {
                cell.titleLabel.text = "\(rowData.2[indexPath.section - 1])"
            }
        default:
            break
        }
        
        if indexPath.section % 2 == 1 {
            cell.backgroundColor = UIColor(red: 0.88, green: 0.90, blue: 0.93, alpha: 1.0)
        } else {
            cell.backgroundColor = .white
        }
        return cell
    }
}
