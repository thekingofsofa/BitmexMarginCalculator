//
//  SettingsTableViewCell.swift
//  BitMEXMarginCalculator
//
//  Created by Иван Барабанщиков on 9/20/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

enum SettingsCellType {
    case onlyTitle
    case withSwither
    case separator
}

class SettingsTableViewCell: UITableViewCell {
    let titleLabel = UILabel()
    let switcher = UISwitch()
    let separatorLine = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        [titleLabel, switcher, separatorLine].forEach { addSubview($0) }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if separatorLine.isHidden {
            if highlighted {
                UIView.animate(withDuration: 0.2) {
                    self.backgroundColor = .lightGray
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.backgroundColor = .clear
                }
            }
        }
    }
    
    func configureCell(text: String, cellType: SettingsCellType) {
        titleLabel.text = text
        titleLabel.setScaledCustomFont(forFont: .RobotoRegular, textStyle: .body)
        titleLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil, padding: .init(top: 12, left: 24, bottom: 12, right: 0))
        
        switcher.anchor(top: topAnchor, leading: titleLabel.trailingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 12, left: 0, bottom: 12, right: 24))
        switcher.tintColor = .lightGray
        
        separatorLine.frame = CGRect(x: 24, y: 10, width: self.frame.width - 48, height: 1)
        separatorLine.backgroundColor = .black
        
        switch cellType {
        case .onlyTitle:
            switcher.isHidden = true
            separatorLine.isHidden = true
        case .withSwither:
            switcher.isHidden = false
            separatorLine.isHidden = true
        case .separator:
            switcher.isHidden = true
            separatorLine.isHidden = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
