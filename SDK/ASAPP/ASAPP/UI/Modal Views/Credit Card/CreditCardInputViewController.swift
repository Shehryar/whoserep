//
//  CreditCardInputViewController.swift
//  AnimationTestingGround
//
//  Created by Mitchell Morgan on 2/10/17.
//  Copyright © 2017 ASAPP, Inc. All rights reserved.
//

import UIKit

protocol CreditCardAPIDelegate: class {
    /// Returns true if the request was sent. False if the request was unable to be sent (most likely connection issues)
    func uploadCreditCard(creditCard: CreditCard, completion: @escaping ((CreditCardResponse) -> Void)) -> Bool
}

class CreditCardInputViewController: ModalCardViewController {
    
    weak var delegate: CreditCardAPIDelegate?

    fileprivate let creditCardView = CreditCardInputView()
    
    // MARK:- Initialization
    
    override func commonInit() {
        super.commonInit()
        
        contentView = creditCardView
        shouldHideContentWhenBackgrounded = true
        
        successView.text = ASAPP.strings.creditCardSuccessText
        
        // Controls
        controlsView.confirmText = ASAPP.strings.creditCardConfirmButton
        controlsView.onConfirmButtonTap = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            guard !strongSelf.isShowingSuccessView else {
                strongSelf.dismiss(animated: true, completion: nil)
                return
            }
            
            let creditCard = strongSelf.creditCardView.getCurrentCreditCard()
            
            if let invalidFields = creditCard.getInvalidFields() {
                strongSelf.creditCardView.highlightInvalidFields(invalidFields: invalidFields)
                strongSelf.showErrorMessage(ASAPP.strings.creditCardInvalidFieldsError)
                return
            }
            
            guard let delegate = strongSelf.delegate else {
                strongSelf.showErrorMessage(ASAPP.strings.creditCardNoConnectionError)
                return
            }
            
            self?.view.endEditing(true)
            self?.startLoading()
            self?.showErrorMessage(nil)
            
            let requestSent = delegate.uploadCreditCard(creditCard: creditCard, completion: { (response: CreditCardResponse) in
                if response.success {
                    self?.stopLoading(hideContentView: true)
                    self?.showSuccessView(buttonText: ASAPP.strings.creditCardFinishButton)
                } else {
                    self?.stopLoading()
                    self?.creditCardView.highlightInvalidFields(invalidFields: response.invalidFields)
                    self?.showErrorMessage(response.errorMessage ?? CreditCardResponse.DEFAULT_ERROR_MESSAGE)
                }
            })
            if !requestSent {
                self?.stopLoading()
                self?.showErrorMessage(ASAPP.strings.creditCardNoConnectionError)
            }
        }
    }
}
