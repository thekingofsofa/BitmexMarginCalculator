//
//  UITextFieldDoneButton.swift
//  BitMEXMarginCalculator
//
//  Created by Иван Барабанщиков on 9/20/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

class UITextFieldWithDoneButton: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tintColor = .black
        self.addDoneButtonOnKeyboard()
    }
    
    fileprivate func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc fileprivate func doneButtonAction() {
        self.resignFirstResponder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
