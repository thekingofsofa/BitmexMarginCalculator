//
//  InfoTextViewDataFiller.swift
//  BTCMarginCalc
//
//  Created by Иван Барабанщиков on 9/26/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import UIKit

class InfoTextViewDataFiller {
    
    func loadAboutAppPage() -> NSMutableAttributedString {
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.firstLineHeadIndent = 18
        // create an NSMutableAttributedString that we'll append everything to
        let fullString = NSMutableAttributedString(string: ["BitMEX Margin Calculator is designed to conveniently ",
                                                   "calculate the position on smartphone. Beware, trading with a ",
                                                   "large leverage is very risky!\n\nThis app is under MIT license, ",
            "you are welcome to visit it’s Github page. Also there you can find Privacy Policy"].joined(),
                                                   attributes: [NSAttributedString.Key.paragraphStyle: paragraph])
        fullString.setAsLink(textToFind: "Github page", linkURL: "https://github.com/thekingofsofa/BitmexMarginCalculator")
        fullString.setAsLink(textToFind: "Privacy Policy", linkURL: "https://github.com/thekingofsofa/BitmexMarginCalculator/blob/master/BitmexMarginCalculator/PrivacyPolicy.md")
        return fullString
    }
    
    func loadAboutLiquidationPage() -> NSMutableAttributedString {
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.firstLineHeadIndent = 18
        // create an NSMutableAttributedString that we'll append everything to
        let fullString = NSMutableAttributedString(string: "Maybe you already noticed that Liquidation price is not equal to 100% lost of your margin, that’s because liquidation engine of BitMEX closing your position way before your Bankruptcy price, depending on how high your leverage is.\n\n", attributes: [NSAttributedString.Key.paragraphStyle: paragraph])
        
        // create our NSTextAttachment
        let imageAttachment = NSTextAttachment()
        imageAttachment.bounds.size = CGSize(width: UIScreen.main.bounds.width - 36, height: (UIScreen.main.bounds.width - 36) * 0.8)
        imageAttachment.image = UIImage(named: "liquidation_example")
        // wrap the attachment in its own attributed string so we can append it
        let imageString = NSAttributedString(attachment: imageAttachment)
        // add the NSTextAttachment wrapper to our full string, then add some more text.
        fullString.append(imageString)
        fullString.append(NSAttributedString(string: "\n\nThe higher your leverage, the more gap you will have between bankruptcy price and liquidation price. When the index price gets to your liquidation price, your position automatically will be closed at the markets price and margin that’s left goes to the Insurance Fund. So that’s why it’s very important to use stop-losses.\n\nRead through documentation on BitMEX for more detailed information!"))
        return fullString
    }
    
    func liquidationPriceNotice() -> String {
        return "  When price reach Liquidation price you lose assigned Deposit BTC for this trade.\n\n  Liquidation might be slightly different comparing to Bitmex, so double check it."
    }
    
    func feesNotice() -> NSMutableAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.firstLineHeadIndent = 18
        // create an NSMutableAttributedString that we'll append everything to
        let fullString = NSMutableAttributedString(string: "For more detail information read Bitmex documentation.", attributes: [NSAttributedString.Key.paragraphStyle: paragraph])
        return fullString
    }
}
