//
//  CreditCardInputView.swift
//  AnimationTestingGround
//
//  Created by Mitchell Morgan on 2/11/17.
//  Copyright © 2017 ASAPP, Inc. All rights reserved.
//

import UIKit

class CreditCardInputView: UIView {

    let contentInset = UIEdgeInsets(top: 26, left: 28, bottom: 32, right: 28)
    let titleMarginBottom: CGFloat = 20.0
    let errorLabelMarginBottom: CGFloat = 10.0

    fileprivate let scrollView = UIScrollView()
    fileprivate let titleView = ModalCardTitleView()
    fileprivate let nameTextView = PlaceholderTextInputView()
    fileprivate let numberTextView = PlaceholderTextInputView()
    fileprivate let expiryTextView = PlaceholderTextInputView()
    fileprivate let cvvTextView = PlaceholderTextInputView()
    
    // MARK: Initialization
    
    func commonInit() {
        clipsToBounds = false
        
        scrollView.clipsToBounds = false
        scrollView.alwaysBounceVertical = false
        addSubview(scrollView)
        
        // Title View
        titleView.text = "Add a New Card"
        scrollView.addSubview(titleView)

        // Name
        
        nameTextView.placeholderText = "NAME ON CARD"
        nameTextView.autocapitalizationType = .words
        nameTextView.autocorrectionType = .no
        nameTextView.returnKeyType = .next
        nameTextView.onReturn = { [weak self] in
            _ = self?.numberTextView.becomeFirstResponder()
        }
        let nameToolbar = ActionButtonToolbar()
        nameToolbar.onHideKeyboardTap = { [weak self] in
            self?.endEditing(true)
        }
        nameToolbar.onNextButtonTap = { [weak self] in
            _ = self?.numberTextView.becomeFirstResponder()
        }
        nameTextView.inputToolbar = nameToolbar
        scrollView.addSubview(nameTextView)
        
        // Card Number
        
        numberTextView.placeholderText = "CARD NUMER"
        numberTextView.keyboardType = .numberPad
        numberTextView.characterLimit = 19
        let numberToolbar = ActionButtonToolbar()
        numberToolbar.onHideKeyboardTap = { [weak self] in
            self?.endEditing(true)
        }
        numberToolbar.onPreviousButtonTap = { [weak self] in
            _ = self?.nameTextView.becomeFirstResponder()
        }
        numberToolbar.onNextButtonTap = { [weak self] in
            _ = self?.expiryTextView.becomeFirstResponder()
        }
        numberTextView.inputToolbar = numberToolbar
        scrollView.addSubview(numberTextView)
        
        // Expiration
        
        expiryTextView.placeholderText = "EXP DATE (MM/YY)"
        expiryTextView.keyboardType = .numberPad
        expiryTextView.returnKeyType = .next
        expiryTextView.characterLimit = 5
        expiryTextView.allowedCharacterSet = NSCharacterSet(charactersIn: "0123456789/")
        var previousExpiryText = ""
        expiryTextView.onTextChange = { [weak self] (text) in
//            print("new=\(text), old=\(previousExpiryText)")
            let isDeleting = text.characters.count < previousExpiryText.characters.count
            var updateToText: String?
            switch text.characters.count {
            case 1:
                if text == "/" {
                    updateToText = previousExpiryText
                }else if !["0", "1"].contains(text) {
                    updateToText = "0\(text)/"
                }
                break
                
            case 2:
                if !isDeleting {
                    if let numValue = Int(text) {
                        if numValue < 1 || numValue > 12 {
                            updateToText = previousExpiryText
                        } else {
                            updateToText = "\(text)/"
                        }
                    }
                }
                break
                
            case 3:
                if text.characters.last == "/" {
                    if isDeleting {
                        updateToText = text.replacingOccurrences(of: "/", with: "")
                    }
                } else {
                    let lastCharIdx = text.index(text.endIndex, offsetBy: -1)
                    
                    updateToText = "\(text.substring(to: lastCharIdx))/\(text.substring(from: lastCharIdx))"
                }
                
                if text.characters.count > previousExpiryText.characters.count {
                    
                }
                if text.characters.last != "/" {
                    
                }
                break
                
            case 4:
                break
                
            default:
                // Do nothing
                break
            }
            
            if let updateToText = updateToText {
                self?.expiryTextView.text = updateToText
                previousExpiryText = updateToText
            } else {
                previousExpiryText = text
            }
        }
        let expiryToolbar = ActionButtonToolbar()
        expiryToolbar.onHideKeyboardTap = { [weak self] in
            self?.endEditing(true)
        }
        expiryToolbar.onPreviousButtonTap = { [weak self] in
            _ = self?.numberTextView.becomeFirstResponder()
        }
        expiryToolbar.onNextButtonTap = { [weak self] in
            _ = self?.cvvTextView.becomeFirstResponder()
        }
        expiryTextView.inputToolbar = expiryToolbar
        scrollView.addSubview(expiryTextView)
        
        // CVV
        
        cvvTextView.placeholderText = "SECURITY CODE"
        cvvTextView.keyboardType = .numberPad
        cvvTextView.returnKeyType = .done
        cvvTextView.characterLimit = 4
        let cvvToolbar = ActionButtonToolbar()
        cvvToolbar.onHideKeyboardTap = { [weak self] in
            self?.endEditing(true)
        }
        cvvToolbar.onPreviousButtonTap = { [weak self] in
            _ = self?.expiryTextView.becomeFirstResponder()
        }
        cvvToolbar.onNextButtonTap = { [weak self] in
            self?.endEditing(true)
        }
        cvvTextView.inputToolbar = cvvToolbar
        scrollView.addSubview(cvvTextView)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
}

// MARK:- Layout

extension CreditCardInputView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateFrames()
    }
    
    func updateFrames() {
        scrollView.frame = bounds
        
        let (titleFrame, nameFrame, numberFrame, expFrame, cvvFrame) = getFrames(for: bounds.size)
        
        titleView.frame = titleFrame
        nameTextView.frame = nameFrame
        numberTextView.frame = numberFrame
        expiryTextView.frame = expFrame
        cvvTextView.frame = cvvFrame
        
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: cvvFrame.maxY + contentInset.bottom)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (_, _, _, _, cvvFrame) = getFrames(for: size)
        
        return CGSize(width: size.width, height: cvvFrame.maxY + contentInset.bottom)
    }
    
    // Returns title, name, number, exp, cvv frames
    private func getFrames(for size: CGSize) -> (CGRect, CGRect, CGRect, CGRect, CGRect) {

        let marginY: CGFloat = 8.0
        
        let contentWidth = size.width - contentInset.left - contentInset.right
        let textInputHeight = ceil(nameTextView.sizeThatFits(CGSize(width: contentWidth, height: 0)).height)
        var contentTop = contentInset.top
        
        // Title
        let titleHeight = ceil(titleView.sizeThatFits(CGSize(width: contentWidth, height: 0)).height)
        let titleFrame = CGRect(x: contentInset.left, y: contentTop, width: contentWidth, height: titleHeight)
        contentTop = titleFrame.maxY + titleMarginBottom
    
        // Name
        let nameFrame = CGRect(x: contentInset.left, y: contentTop, width: contentWidth, height: textInputHeight)
        contentTop = nameFrame.maxY + marginY
        
        // Number
        let numberFrame = CGRect(x: contentInset.left, y: contentTop, width: contentWidth, height: textInputHeight)
        contentTop = numberFrame.maxY + marginY
        
        // Expiry + CVV
        let spacing: CGFloat = 18.0
        let halfWidth = floor((contentWidth - spacing) / 2.0)
        let expFrame = CGRect(x: contentInset.left, y: contentTop, width: halfWidth, height: textInputHeight)
        let cvvFrame = CGRect(x: expFrame.maxX + spacing, y: contentTop, width: halfWidth, height: textInputHeight)

        return (titleFrame, nameFrame, numberFrame, expFrame, cvvFrame)
    }
}

// MARK:- Current Credit Card Information

extension CreditCardInputView {
    
    func getCurrentCreditCard() -> CreditCard {
        return CreditCard(name: nameTextView.text,
                          number: numberTextView.text,
                          expiry: expiryTextView.text,
                          cvv: cvvTextView.text)
    }
    
    func highlightInvalidFields(invalidFields: [CreditCardField]) {
        for field in invalidFields {
            switch field {
            case .name:
                nameTextView.invalid = true
                break
                
            case .number:
                numberTextView.invalid = true
                break
                
            case .expiry:
                expiryTextView.invalid = true
                break
                
            case .cvv:
                cvvTextView.invalid = true
                break
            }
        }
    }
}
