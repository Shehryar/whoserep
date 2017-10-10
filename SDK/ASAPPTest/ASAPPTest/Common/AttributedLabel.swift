//
//  AttributedLabel.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 11/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class AttributedLabel: UILabel {

    override var text: String? {
        didSet {
            updateAttributedString()
        }
    }
    
    override var textColor: UIColor! {
        didSet {
            updateAttributedString()
        }
    }
    
    override var font: UIFont! {
        didSet {
            updateAttributedString()
        }
    }
    
    var kerning: CGFloat = 0 {
        didSet {
            updateAttributedString()
        }
    }
    
    // MARK: Init
    
    func commonInit() {
        numberOfLines = 0
        lineBreakMode = .byTruncatingTail
        isUserInteractionEnabled = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: Updates
    
    fileprivate var updatingMultipleProperties = false
    
    func update(text: String?, textColor: UIColor? = nil, font: UIFont? = nil, kerning: CGFloat? = nil) {
        updatingMultipleProperties = true
        self.text = text
        if let textColor = textColor { self.textColor = textColor }
        if let font = font { self.font = font }
        if let kerning = kerning { self.kerning = kerning }
        updatingMultipleProperties = false
        
        updateAttributedString()
    }
    
    fileprivate func updateAttributedString() {
        guard !updatingMultipleProperties else {
            return
        }
        
        if let text = text {
            let attributes: [String: Any] = [
                NSFontAttributeName: font ?? DemoFonts.asapp.regular,
                NSForegroundColorAttributeName: textColor ?? UIColor.darkText,
                NSKernAttributeName: kerning,
            ]
            attributedText = NSAttributedString(string: text, attributes: attributes)
        } else {
            attributedText = nil
        }
    }
}
