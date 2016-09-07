//
//  PredictiveChatViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/7/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class PredictiveChatViewController: UIViewController {

    let predictiveResponse: SRSPredictiveResponse
    
    let styles: ASAPPStyles
    
    // MARK: UI Properties
    
    private let contentInset = UIEdgeInsets(top: 20, left: 30, bottom: 40, right: 30)
    private let blurredBgView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    private let blurredColorLayer = CALayer()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let buttonsView: PredictiveChatButtonsView
    private let messageInputView = PredictiveChatInputView()
    
    // MARK: Initialization
    
    required init(predictiveResponse: SRSPredictiveResponse?, styles: ASAPPStyles?) {
        self.predictiveResponse = predictiveResponse ?? SRSPredictiveResponse(greeting: nil)
        self.styles = styles ?? ASAPPStyles()
        self.buttonsView = PredictiveChatButtonsView(styles: styles)
        super.init(nibName: nil, bundle: nil)
        
        blurredBgView.tintColor = Colors.blueColor()
    
        blurredColorLayer.backgroundColor = Colors.steelLightColor().colorWithAlphaComponent(0.5).CGColor
        blurredBgView.contentView.layer.insertSublayer(blurredColorLayer, atIndex: 0)
        
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .ByTruncatingTail
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = Fonts.latoRegularFont(withSize: 24)
        titleLabel.text = self.predictiveResponse.greeting
        blurredBgView.contentView.addSubview(titleLabel)
        
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .ByTruncatingTail
        messageLabel.textColor = UIColor.whiteColor()
        messageLabel.font = Fonts.latoRegularFont(withSize: 15)
        messageLabel.text = self.predictiveResponse.customizedMessage
        messageLabel.alpha = 0.0
        blurredBgView.contentView.addSubview(messageLabel)
        
        buttonsView.setButtonTitles(self.predictiveResponse.actions, hideButtonsForAnimation: true)
        buttonsView.onButtonTap = { [weak self] (buttonTitle) in
            self?.finishWithMessage(buttonTitle)
        }
        blurredBgView.contentView.addSubview(buttonsView)
        
        blurredBgView.contentView.addSubview(messageInputView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation Bar
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barStyle = .BlackTranslucent
            navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
            navigationBar.shadowImage = UIImage()
            navigationBar.tintColor = UIColor.whiteColor()
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Images.iconX(fillColor: UIColor.whiteColor()),
                                                            style: .Plain,
                                                            target: self,
                                                            action: #selector(PredictiveChatViewController.dismissPredictiveViewController))
        
        // View
        
        view.backgroundColor = UIColor.clearColor()
        view.addSubview(blurredBgView)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PredictiveChatViewController.dismissKeyboard)))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Dispatcher.delay(200) {
            if self.messageLabel.alpha == 0 {
            UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.messageLabel.alpha = 1.0
                }, completion: nil)
            }
            Dispatcher.delay(500, closure: {
                self.buttonsView.animateButtonsIn()
            })
        }
    }
    
    // MARK: Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateFrames()
    }
    
    func updateFrames() {
        
        blurredBgView.frame = view.bounds
        blurredColorLayer.frame = blurredBgView.bounds
        
        let additionalTextInset: CGFloat = 5
        let contentWidth = CGRectGetWidth(view.bounds) - contentInset.left - contentInset.right
        let textWidth = floor(0.85 * contentWidth - 2 * additionalTextInset)
        let textLeft = contentInset.left + additionalTextInset
        
        var textTop = contentInset.top
        if let navigationBar = navigationController?.navigationBar {
            textTop = CGRectGetMaxY(navigationBar.frame) + contentInset.top
        }
        
        // Title
        let titleHeight = ceil(titleLabel.sizeThatFits(CGSize(width: textWidth, height: 0)).height)
        titleLabel.frame = CGRect(x: textLeft, y: textTop, width: textWidth, height: titleHeight)
        textTop = CGRectGetMaxY(titleLabel.frame)
        
        // Message
        let messageHeight = ceil(messageLabel.sizeThatFits(CGSize(width: textWidth, height: 0)).height)
        if titleHeight > 0 && messageHeight > 0 {
            textTop += 10
        }
        messageLabel.frame = CGRect(x: textLeft, y: textTop, width: textWidth, height: messageHeight)
        textTop = CGRectGetMaxY(messageLabel.frame) + 45
        
        // Buttons View
        let buttonsHeight = ceil(buttonsView.sizeThatFits(CGSize(width: textWidth, height: 0)).height)
        buttonsView.frame = CGRect(x: textLeft, y: textTop, width: textWidth, height: buttonsHeight)
        
        // Input View
        let inputHeight = messageInputView.sizeThatFits(CGSize(width: contentWidth, height: 0)).height
        let inputTop = CGRectGetHeight(view.bounds) - contentInset.bottom - inputHeight
        messageInputView.frame = CGRect(x: contentInset.left, y: inputTop, width: contentWidth, height: inputHeight)
        
        if CGRectIntersectsRect(messageInputView.frame, buttonsView.frame) {
            buttonsView.alpha = 0.0
        } else {
            buttonsView.alpha = 1.0
        }
    }
    
    // MARK: Actions
    
    func finishWithMessage(message: String) {
        
    }
    
    func dismissPredictiveViewController() {
        if let presentingViewController = presentingViewController {
            presentingViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
