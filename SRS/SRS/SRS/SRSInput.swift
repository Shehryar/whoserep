//
//  SRSInput.swift
//  XfinityMyAccount
//
//  Created by Vicky Sehrawat on 3/13/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSInput: UIView, UITextViewDelegate {

    var srsContent:SRSContent!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addInputView()
        self.addPlaceholderView()
        self.addMenuViews()
        self.backgroundColor = UIColor.clearColor()
        
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var heightConstraint: NSLayoutConstraint!
    var input: UITextView!
    var placeholder: UILabel!
    var menu: UIView!
    
    var selfInputBotConstraint: NSLayoutConstraint!
    func addInputView() {
        input = UITextView()
        input.delegate = self
        input.returnKeyType = UIReturnKeyType.Done
        input.textAlignment = NSTextAlignment.Left
        input.textColor = UIColor.darkTextColor()
        input.backgroundColor = UIColor.whiteColor()
        input.font = UIFont(name: "HelveticaNeue", size: 16)
        input.textContainerInset = UIEdgeInsetsMake(0, 16, 0, 16)
        input.contentInset = UIEdgeInsetsMake(16, 0, 16, 0)
        self.addSubview(input)
        
        input.translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = NSLayoutConstraint(item: input, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: input, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
        let topContraint = NSLayoutConstraint(item: input, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        let bottomContraint = NSLayoutConstraint(item: input, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        heightConstraint = NSLayoutConstraint(item: input, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: getHeight() + 32)
        
        self.addConstraint(leftConstraint)
        self.addConstraint(rightConstraint)
        self.addConstraint(topContraint)
        self.addConstraint(bottomContraint)
        self.addConstraint(heightConstraint)
        selfInputBotConstraint = bottomContraint
    }
    
    func addPlaceholderView() {
        placeholder = UILabel()
        placeholder.textColor = UIColor(red: 59/255, green: 59/255, blue: 59/255, alpha: 0.3)
        placeholder.text = "I want to ..."
        placeholder.font = UIFont(name: "HelveticaNeue", size: 16)
        self.addSubview(placeholder)
        
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        let xPosition = NSLayoutConstraint(item: placeholder, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: input, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let yPosition = NSLayoutConstraint(item: placeholder, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: input, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: placeholder, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: -42)
//        let topContraint = NSLayoutConstraint(item: placeholder, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
//        let bottomContraint = NSLayoutConstraint(item: placeholder, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        
        self.addConstraint(xPosition)
        self.addConstraint(widthConstraint)
        self.addConstraint(yPosition)
//        self.addConstraint(bottomContraint)
    }
    
    var selfMenuBotConstraint: NSLayoutConstraint!
    func addMenuViews() {
        menu = UIView()
        self.addSubview(menu)
        
        menu.translatesAutoresizingMaskIntoConstraints = false
        let xPosition = NSLayoutConstraint(item: menu, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: menu, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        let topContraint = NSLayoutConstraint(item: menu, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: input, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        let botConstraint = NSLayoutConstraint(item: menu, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        
        if selfInputBotConstraint != nil {
//            selfInputBotConstraint.active = false
        }
        
        self.addConstraint(xPosition)
        self.addConstraint(widthConstraint)
        self.addConstraint(topContraint)
        self.addConstraint(botConstraint)
        selfMenuBotConstraint = botConstraint
        menu.userInteractionEnabled = true
        
        menu.subviews.forEach({ $0.removeFromSuperview() })
        menu.removeConstraints(self.constraints)
        addMenuItemView("pay my bill", tag: 1)
        addMenuItemView("troubleshooting help", tag: 2)
//        addMenuItemView("password reset", tag: 3)
    }
    
    var prevMenuItemBotConstraint: NSLayoutConstraint!
    func addMenuItemView(value: String, tag:Int) {
        let holder = UIView()
        holder.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        
        let view = UILabel()
        view.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        view.text = value
        view.font = UIFont(name: "HelveticaNeue", size: 16)
        
        var prevView = menu
        if menu.subviews.count > 0 {
            prevView = menu.subviews[menu.subviews.count-1]
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        let viewLeftPos = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 20)
        let viewTopPos = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        let viewRightPos = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
        let viewBottom = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        
        holder.translatesAutoresizingMaskIntoConstraints = false
        let xPosition = NSLayoutConstraint(item: holder, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: prevView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: holder, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: prevView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        var topContraint = NSLayoutConstraint(item: holder, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: prevView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 5)
        let heightContraint = NSLayoutConstraint(item: holder, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 50)
        let botConstraint = NSLayoutConstraint(item: holder, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: menu, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        
        if menu.subviews.count > 0 {
            topContraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: prevView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 5)
        }
        
        
        menu.addSubview(holder)
        holder.addSubview(view)
        holder.addConstraint(viewLeftPos)
        holder.addConstraint(viewTopPos)
        holder.addConstraint(viewRightPos)
        holder.addConstraint(viewBottom)
        menu.addConstraint(xPosition)
        menu.addConstraint(widthConstraint)
        menu.addConstraint(topContraint)
        menu.addConstraint(heightContraint)
        
        // HACKY: Fix this when menu items are retreived from the server.
        if tag == 2 {
            menu.addConstraint(botConstraint)
        }
        
        holder.tag = tag
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "didSelectMenuItem:")
        holder.addGestureRecognizer(tapGesture)
    }
    
    func didSelectMenuItem(sender: UITapGestureRecognizer) {
        print("hello tap")
        
        var inputStr = "help"
        if sender.view?.tag == 1 {
            inputStr = "pay my bill"
        } else if sender.view?.tag == 2 {
            inputStr = "troubleshooting help"
        } else if sender.view?.tag == 3 {
            inputStr = "password reset"
        }
        
        input.text = inputStr
        showPlaceholderIfNeeded()
        SRS.conn.request(inputStr)
        input.resignFirstResponder()
    }
    
    func getHeight() -> CGFloat {
        return input.sizeThatFits(CGSize(width: UIScreen.mainScreen().bounds.size.width - 32, height: CGFloat.max)).height
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        print("GOT FOCUS")
        self.focusInput()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        self.blurInputIfNeeded()
    }
    
    func focusInput() {
        textViewDidChange(self.input)
        input.backgroundColor = UIColor.whiteColor()
    }
    
    func resetData() {
        SRS.content.resetData()
        SRS.content.resetStack()
        showMenuIfNeeded()
        blurInputIfNeeded()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            print("did finsh editing", textView.text)
            if textView.text != "" {
                resetData()
                SRS.conn.request(textView.text)
            }
            input.resignFirstResponder()
        }
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        heightConstraint.constant = getHeight() + 32
        showPlaceholderIfNeeded()
        showMenuIfNeeded()
//        SRS.prompt.addRipple()
    }
    
    func showPlaceholderIfNeeded() {
        if input.text.characters.count > 0 {
            placeholder.text = ""
        } else {
            placeholder.text = "I want to ..."
            SRS.prompt.prompt.text = "HOW CAN WE HELP?"
        }
    }
    
    func showMenuIfNeeded() {
        if SRS.content.hasData() {
            menu.alpha = 0.0
            if selfMenuBotConstraint != nil {
                selfMenuBotConstraint.active = false
            }
        } else {
            menu.alpha = 1.0
            if selfMenuBotConstraint != nil {
                selfMenuBotConstraint.active = true
            }
        }
    }
    
    func blurInputIfNeeded() {
        if SRS.content.hasData() {
            blurInput()
        } else {
            input.backgroundColor = UIColor.whiteColor()
        }
    }
    
    func blurInput() {
        input.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        input.textColor = UIColor(red: 59/255, green: 59/255, blue: 59/255, alpha: 0.5)
    }
    
    func setSRSContent(content: SRSContent) {
        self.srsContent = content
    }
    
    func getQueryText() -> String {
        return self.input.text
    }
}
