//
//  SRSPinView.swift
//  XfinityMyAccount
//
//  Created by Vicky Sehrawat on 3/15/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSPinView: UIView, UIKeyInput, UITextInputTraits {
    var pin:String!
    var pinHolders = [UIView]()

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
        self.backgroundColor = UIColor.whiteColor()
        
    }
    
    deinit {
        self.resignFirstResponder()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func canResignFirstResponder() -> Bool {
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.becomeFirstResponder()
    }
    
    func deleteBackward() {
        if self.pin.characters.count == 0 {
            return
        }
        self.pin = self.pin.substringToIndex(self.pin.endIndex.advancedBy(-1))
        updatePins()
    }
    
    func insertText(text: String) {
        if self.pin.characters.count >= 4 {
            return
        }
        self.pin = self.pin + text
        updatePins()
    }
    
    func hasText() -> Bool {
        return self.pin.characters.count > 0
    }
    
    func setup() {
//        self.keyboardType = UIKeyboardType.DecimalPad
        self.pin = ""
        for var i = 0; i < 4; i++ {
            let view = createPinHolder(i)
            pinHolders.append(view)
        }
    }
    
    func updatePins() {
        if pinHolders.count != 4 {
            return
        }
        
        self.subviews.forEach({ $0.removeFromSuperview() })
        self.removeConstraints(self.constraints)
        pinHolders.removeAll()
        for var i = 0; i < 4; i++ {
            let view = createPinHolder(i)
            pinHolders.append(view)
        }
        
    }
    
    func createPinHolder(idx: Int) -> UIView {
        let holder = UIView()
        self.addSubview(holder)
        
        let view = UILabel()
        view.font = UIFont.systemFontOfSize(40)
        view.textColor = UIColor(red: 99/255, green: 99/255, blue: 99/255, alpha: 0.5)
        view.textAlignment = NSTextAlignment.Center
        
        if pin.characters.count-1 >= idx {
            let pinIdx = pin.startIndex.advancedBy(idx)
            let range = Range<String.Index>(start: pinIdx, end: pinIdx.advancedBy(1))
            let pinToken = pin.substringWithRange(range)
            print("ADD PIN:", pinToken)
            view.text = pinToken
        }
        holder.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        let labelTop = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        let labelRight = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
        let labelLeft = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
        let labelBottom = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        
        holder.addConstraint(labelTop)
        holder.addConstraint(labelRight)
        holder.addConstraint(labelLeft)
        holder.addConstraint(labelBottom)
        
        let border = UIView()
        border.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1)
        if pin.characters.count == idx {
            border.backgroundColor = UIColor(red: 105/255, green: 147/255, blue: 255/255, alpha: 1)
        }
        holder.addSubview(border)
        
        border.translatesAutoresizingMaskIntoConstraints = false
        let borderX = NSLayoutConstraint(item: border, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let borderBottom = NSLayoutConstraint(item: border, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        let borderWidth = NSLayoutConstraint(item: border, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        let borderHeight = NSLayoutConstraint(item: border, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 5)
        
        holder.addConstraint(borderX)
        holder.addConstraint(borderBottom)
        holder.addConstraint(borderWidth)
        holder.addConstraint(borderHeight)
        
        if pin == "2734" {
            let checkMark = UIImageView()
            let framework = NSBundle(forClass: SRSPinView.self)
            let checkImage = UIImage(named: "icon_check", inBundle: framework, compatibleWithTraitCollection: nil)
            checkMark.image = checkImage
            holder.addSubview(checkMark)
            
            checkMark.translatesAutoresizingMaskIntoConstraints = false
            let checkTop = NSLayoutConstraint(item: checkMark, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
            let checkRight = NSLayoutConstraint(item: checkMark, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
            let checkWidth = NSLayoutConstraint(item: checkMark, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 30)
            let checkHeight = NSLayoutConstraint(item: checkMark, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 30)
            
            holder.addConstraint(checkTop)
            holder.addConstraint(checkRight)
            holder.addConstraint(checkWidth)
            holder.addConstraint(checkHeight)
            view.textColor = UIColor(red: 176/255, green: 176/255, blue: 176/255, alpha: 0.4)
        }
        
        holder.translatesAutoresizingMaskIntoConstraints = false
        let topPos = NSLayoutConstraint(item: holder, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 10)
        var leftPos = NSLayoutConstraint(item: holder, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 10)
        let botPos = NSLayoutConstraint(item: holder, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -10)
        let width = NSLayoutConstraint(item: holder, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 50)
        let height = NSLayoutConstraint(item: holder, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 50)
        if pinHolders.count > 0 {
            leftPos = NSLayoutConstraint(item: holder, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: pinHolders[pinHolders.count-1], attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 25)
        }
        
        if pinHolders.count == 3 {
            let rightPos = NSLayoutConstraint(item: holder, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: -10)
            self.addConstraint(rightPos)
        }
        
        self.addConstraint(topPos)
        self.addConstraint(leftPos)
        self.addConstraint(botPos)
        self.addConstraint(width)
        self.addConstraint(height)
        
        return holder
    }
}
