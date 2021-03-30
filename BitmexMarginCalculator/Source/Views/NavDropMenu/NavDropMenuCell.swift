//
//  NavDropMenuCell.swift
//  BitMEXMarginCalculator
//
//  Created by Иван Барабанщиков on 10/4/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

class NavDropMenuCell: UITableViewCell {
    
    let titleLabel = UILabel()
    let checkmark = UIImageView()
    let checkmarkWidth: CGFloat = 40
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        [titleLabel, checkmark].forEach {
            addSubview($0)
        }
        setupLayout()
        setupCell()
    }
    
    func setupLayout() {
        titleLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
    }
    
    func setupCell() {
        titleLabel.textAlignment = .center
        titleLabel.setScaledCustomFont(forFont: .robotoRegular, textStyle: .body)
        titleLabel.numberOfLines = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
