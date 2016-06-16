//
//  ASAPPChatInputView.swift
//  ASAPP
//
//  Created by Vicky Sehrawat on 6/14/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ASAPPChatInputView: UIView, UITextViewDelegate {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var textView: UITextView!
    var mediaButton: UIButton!
    var sendButton: UIButton!
    
    let INPUT_MIN_HEIGHT = 32
    let INPUT_MAX_HEIGHT = 80
    var inputHeight: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        render()
        
        registerListeners()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
    
    func registerListeners() {
        ASAPP.instance.state.on(.Connect, observer: self) { [weak self] (info) in
            guard self != nil else {
                return
            }
            
            self!.updateSendButton()
        }
        
        ASAPP.instance.state.on(.Disconnect, observer: self) { [weak self] (info) in
            guard self != nil else {
                return
            }
            
            self!.updateSendButton()
        }
    }
    
    func render() {
        self.backgroundColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
        self.translatesAutoresizingMaskIntoConstraints = false
        renderMediaButton()
        renderTextView()
        renderSendButton()
    }
    
    // MARK: - TextView for input
    
    func renderTextView() {
        textView = UITextView()
        textView.layer.cornerRadius = 4
        textView.layer.borderColor = UIColor(red: 206/255, green: 206/255, blue: 211/255, alpha: 1).CGColor
        textView.layer.borderWidth = 1
        textView.backgroundColor = UIColor.clearColor()
        textView.font = UIFont(name: "Lato-Regular", size: 16)
        textView.textColor = UIColor(red: 57/255, green: 61/255, blue: 71/255, alpha: 0.6)
        textView.bounces = false
        textView.scrollEnabled = false
        
        textView.sizeToFit()
        inputHeight = textView.frame.size.height
        
        textView.delegate = self
        self.addSubview(textView)
        
        
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        textView.backgroundColor = UIColor.whiteColor()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.backgroundColor = UIColor.clearColor()
        } else {
            textView.backgroundColor = UIColor.whiteColor()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        resizeIfNeeded(textView)
        updateSendButton()
    }
    
    func resizeIfNeeded(textView: UITextView) {
        let temp = UITextView()
        temp.font = UIFont(name: "Lato-Regular", size: 16)
        temp.bounces = false
        temp.scrollEnabled = false
        temp.text = textView.text
        
        let origWidth: CGFloat = textView.frame.size.width
        var size = temp.sizeThatFits(CGSize(width: origWidth, height: CGFloat.max))
        inputHeight = size.height
        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
        
        UIView.animateWithDuration(0.3) {
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Media Button
    
    func renderMediaButton() {
        mediaButton = UIButton()
        
        let mediaIcon = UIImage(named: "icon_camera-dark", inBundle: framework, compatibleWithTraitCollection: nil)
        mediaButton.setImage(mediaIcon, forState: .Normal)
        
        self.addSubview(mediaButton)
    }
    
    // MARK: - Send Button
    
    func renderSendButton() {
        sendButton = UIButton()
        updateSendButton()
        
        sendButton.addTarget(self, action: #selector(ASAPPChatInputView.sendAction(_:)), forControlEvents: .TouchUpInside)
        
        self.addSubview(sendButton)
    }
    
    func updateSendButton() {
        let text = "SEND"
        var textColor = UIColor(red: 91/255, green: 101/255, blue: 126/255, alpha: 1)
        if !ASAPP.instance.state.isConnected() || textView.text == "" {
            textColor = UIColor(red: 91/255, green: 101/255, blue: 126/255, alpha: 0.3)
            sendButton.enabled = false
        } else {
            sendButton.enabled = true
        }
        let attributedString = NSMutableAttributedString(string: text.uppercaseString)
        attributedString.addAttribute(NSKernAttributeName, value: 1.5, range: NSMakeRange(0, text.characters.count))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: textColor, range: NSMakeRange(0, text.characters.count))
        
        sendButton.titleLabel?.font = UIFont(name: "Lato-Black", size: 13)
        sendButton.setAttributedTitle(attributedString, forState: .Normal)
    }
    
    func sendAction(sender: UIButton) {
        print("send")
        ASAPP.instance.state.sendMessage(textView.text)
        
        textView.text = ""
        resizeIfNeeded(textView)
        updateSendButton()
    }
    
    override func updateConstraints() {
        mediaButton.snp_remakeConstraints { (make) in
            make.leading.equalTo(self.snp_leading).offset(16)
            make.bottom.equalTo(self.snp_bottom).offset(-8)
            make.height.equalTo(INPUT_MIN_HEIGHT)
            make.width.equalTo(28)
        }
        
        sendButton.snp_remakeConstraints { (make) in
            make.bottom.equalTo(mediaButton.snp_bottom)
            make.trailing.equalTo(self.snp_trailing).offset(-16)
            make.height.equalTo(INPUT_MIN_HEIGHT)
            make.width.equalTo(40)
        }
        
        textView.snp_remakeConstraints { (make) in
            make.top.equalTo(self.snp_top).offset(8)
            make.leading.equalTo(mediaButton.snp_trailing).offset(16)
            make.bottom.equalTo(mediaButton.snp_bottom)
            make.trailing.equalTo(sendButton.snp_leading).offset(-16)
            make.width.greaterThanOrEqualTo(1)
            make.height.greaterThanOrEqualTo(INPUT_MIN_HEIGHT)
            make.height.equalTo(inputHeight)
        }
        
        super.updateConstraints()
    }

}
