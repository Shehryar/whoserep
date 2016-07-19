//
//  SRSContent.swift
//  XfinityMyAccount
//
//  Created by Vicky Sehrawat on 3/14/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSContent: UIScrollView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var parent: SRS!
    var holder: UIView!
    
    var contentStack: [NSData] = []
    var mData: NSData!
    
    var mGravity = "up"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        holder = UIView()
        self.addSubview(holder)
        
        holder.translatesAutoresizingMaskIntoConstraints = false
        let top = NSLayoutConstraint(item: holder, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        let centerX = NSLayoutConstraint(item: holder, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: holder, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: holder, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: holder, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: self, attribute: .Height, multiplier: 1, constant: 0)
        
        self.addConstraint(top)
        self.addConstraint(centerX)
        self.addConstraint(width)
        self.addConstraint(bottom)
        self.addConstraint(height)
        
        self.bounces = false
    }
    
    func resetData() {
        holder.subviews.forEach({ $0.removeFromSuperview() })
        holder.removeConstraints(holder.constraints)
        views.removeAll()
        holder.backgroundColor = UIColor.clearColor()
        self.backgroundColor = UIColor.clearColor()
    }
    
    func resetStack() {
        SRS.conn.dataRequest("SRS_reset")
        mData = nil
        contentStack.removeAll()
        mGravity = "up"
    }
    
    func updateData(data: NSData, isBackUpdate: Bool) {
        resetData()
        SRS.input.input.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        SRS.input.input.textColor = UIColor(red: 59/255, green: 59/255, blue: 59/255, alpha: 0.5)
        holder.backgroundColor = UIColor.whiteColor()
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
            if let data = json as? [String: AnyObject] {
                self.processItem(data, parentOrientation: "vertical")
            }
        } catch {
            print("Failed to parse data")
        }
        
        addBackButton()
        
        if !isBackUpdate {
            if mData != nil {
                contentStack.append(mData)
            }
        }
        mData = data
        
//        prevBotConstraint.active = false
        self.backgroundColor = UIColor.whiteColor()
        SRS.updateContentheight()
        self.setNeedsLayout()
        self.holder.layoutSubviews()
    }
    
    func addBackButton() {
        let back = UIButton()
        let framework = NSBundle(forClass: SRSContent.self)
        let iconImage = UIImage(named: "back.png", inBundle: framework, compatibleWithTraitCollection: nil)
        back.contentHorizontalAlignment = .Left
        back.setImage(iconImage, forState: .Normal)
        back.translatesAutoresizingMaskIntoConstraints = false
        holder.addSubview(back)
        
        let top = NSLayoutConstraint(item: back, attribute: .Top, relatedBy: .Equal, toItem: holder, attribute: .Top, multiplier: 1, constant: 20)
        let left = NSLayoutConstraint(item: back, attribute: .Leading, relatedBy: .Equal, toItem: holder, attribute: .Leading, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: back, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 37)
        let height = NSLayoutConstraint(item: back, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 37)
        
        holder.addConstraint(top)
        holder.addConstraint(left)
        holder.addConstraint(width)
        holder.addConstraint(height)
        
        back.addTarget(self, action: #selector(SRSContent.goBack(_:)), forControlEvents: .TouchUpInside)
    }
    
    func goBack(sender: UIButton) {
        SRS.conn.dataRequest("SRS_back")
        
        let prevData = contentStack.popLast()
        if prevData == nil {
            mData = nil
            SRS.input.resetInput()
        } else {
            updateData(prevData!, isBackUpdate: true)
        }
    }
    
    func processItem(item: AnyObject, parentOrientation: String) {
        if let type = item["type"] as? String {
            if type == "itemlist" {
                if let items = item["value"] as? [[String: AnyObject]] {
                    if let orientation = item["orientation"] as? String {
                        let tmpGravity = mGravity
                        if let gravity = item["gravity"] as? String {
                            mGravity = gravity
                        }
                        for subItem in items {
                            processItem(subItem, parentOrientation: orientation)
                        }
                        mGravity = tmpGravity
                    }
                }
            } else if type == "separator" {
                let orientation = parentOrientation == "vertical" ? "horizontal" : "vertical"
                addSeparator(orientation)
            } else if type == "filler" {
                addFiller()
            } else if type == "icon" {
                if let value = item["value"] as? String {
                    addIcon(value)
                }
            } else if type == "button" {
                if let value = item["value"] as? [String: AnyObject] {
                    if let key = item["label"] as? String {
                        var colorScheme = "normal"
                        if let scheme = item["colorScheme"] as? String {
                            colorScheme = scheme
                        }
                        var icon = ""
                        if let rawIcon = item["icon"] as? String {
                            icon = rawIcon
                        }
                        addButton(value, key: key, colorScheme: colorScheme, icon: icon)
                    }
                }
            } else if let key = item["label"] as? String {
                if let value = item["value"] as? String {
                    if type == "info" {
                        let icon = item["icon"] as! String
                        let orientation = parentOrientation == "vertical" ? "horizontal" : "vertical"
                        var valueColor = "normal"
                        if let rawValueColor = item["valueColor"] as? String {
                            valueColor = rawValueColor
                        }
                        addItem(key, value: value, valueColor: valueColor, orientation: orientation, icon: icon)
                    } else if type == "pin" {
                        addPin()
                    } else if type == "textfield" {
                        addTextField()
                    }
                } else if type == "label" {
                    addLabel(key)
                }
            }
        }
    }
    
    var views = [UIView]()
    var prevBotConstraint: NSLayoutConstraint!
    func addItem(key:String, value: String, valueColor: String, orientation: String, icon: String) {
        let view = UIView()
        
        if icon != "" {
            let iconView = UIImageView()
            let framework = NSBundle(forClass: SRSContent.self)
            let iconImage = UIImage(named: icon, inBundle: framework, compatibleWithTraitCollection: nil)
            iconView.image = iconImage
            view.addSubview(iconView)
            
            iconView.translatesAutoresizingMaskIntoConstraints = false
            let iconLeft = NSLayoutConstraint(item: iconView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
            let iconTop = NSLayoutConstraint(item: iconView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: -3)
            let iconWidth = NSLayoutConstraint(item: iconView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 20)
            let iconHeight = NSLayoutConstraint(item: iconView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 20)
            
            view.addConstraint(iconLeft)
            view.addConstraint(iconTop)
            view.addConstraint(iconWidth)
            view.addConstraint(iconHeight)
        }
        
        let keyLabel = UILabel()
        let attributedKey = NSMutableAttributedString(string: key.uppercaseString)
        attributedKey.addAttribute(NSKernAttributeName, value: 1, range: NSMakeRange(0, key.characters.count))
        keyLabel.attributedText = attributedKey
        keyLabel.textAlignment = NSTextAlignment.Left
        keyLabel.textColor = SRSColor.key
        keyLabel.font = UIFont(name: "XFINITYSans-Reg", size: 12)
        keyLabel.numberOfLines = 0
        view.addSubview(keyLabel)
        
        let valueLabel = UILabel()
        let attributedValue = NSMutableAttributedString(string: value)
        attributedValue.addAttribute(NSKernAttributeName, value: 1, range: NSMakeRange(0, value.characters.count))
        valueLabel.attributedText = attributedValue
        valueLabel.textAlignment = NSTextAlignment.Left
        if valueColor == "red" {
            valueLabel.textColor = SRSColor.valueRed
        } else if valueColor == "green" {
            valueLabel.textColor = SRSColor.valueGreen
        } else {
            valueLabel.textColor = SRSColor.value
        }
        valueLabel.font = UIFont(name: "XFINITYSans-BoldCond", size: 13)
        if orientation == "vertical" {
            valueLabel.font = UIFont(name: "XFINITYSans-BoldCond", size: 24)
            valueLabel.textAlignment = NSTextAlignment.Center
            keyLabel.font = UIFont(name: "XFINITYSans-Bold", size: 13)
            keyLabel.textAlignment = NSTextAlignment.Center
        }
        view.addSubview(valueLabel)
        
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        var keyLeft = NSLayoutConstraint(item: keyLabel, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
        let keyTop = NSLayoutConstraint(item: keyLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        let keyRight = NSLayoutConstraint(item: keyLabel, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
        let keyBottom = NSLayoutConstraint(item: keyLabel, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        var keyWidth = NSLayoutConstraint(item: keyLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Width, multiplier: 0.72, constant: 0)
        if icon != "" {
            keyLeft = NSLayoutConstraint(item: keyLabel, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 25)
            keyWidth = NSLayoutConstraint(item: keyLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Width, multiplier: 0.52, constant: -25)
        }
        
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        var valWidth = NSLayoutConstraint(item: valueLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Width, multiplier: 0.25, constant: 0)
        var valTop = NSLayoutConstraint(item: valueLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: keyLabel, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        var valRight = NSLayoutConstraint(item: valueLabel, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
        let valBottom = NSLayoutConstraint(item: valueLabel, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        if orientation == "vertical" {
            valWidth = NSLayoutConstraint(item: valueLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: keyLabel, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
            if key != "" {
                valTop = NSLayoutConstraint(item: valueLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: keyLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 5)
            } else {
                valTop = NSLayoutConstraint(item: valueLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: keyLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
            }
            valRight = NSLayoutConstraint(item: valueLabel, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: keyLabel, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
            keyWidth = NSLayoutConstraint(item: keyLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        }
        
        
        
        holder.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        var viewTop = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 20)
        let viewX = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let viewWidth = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Width, multiplier: 0.80, constant: 0)
        var viewBottom = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -20)
        
        if orientation == "vertical" {
//            let prevView = views[views.count-1]
//            viewWidth = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Width, multiplier: 0.37, constant: -10)
//            viewX = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: prevView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
            // HACK!!!!!
//            if key.uppercaseString == "DUE DATE" {
//                valLeft.active = false
//                valRight = NSLayoutConstraint(item: valueLabel, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
//                keyWidth.active = false
//                keyLeft = NSLayoutConstraint(item: keyLabel, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: valueLabel, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
//                viewTop = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: prevView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
//                viewX = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: prevView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
//            }
        }
        if views.count > 0 {
            let prevView = views[views.count-1]
            viewTop = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: prevView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 10)
            
            if orientation != "vertical" {
                if !(prevView is UILabel) {
                    viewTop = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: prevView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 5)
                } else {
                    viewTop = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: prevView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 30)
                }
            }
        }
        
        view.addConstraint(keyLeft)
        view.addConstraint(keyTop)
        if orientation != "vertical" {
            view.addConstraint(keyBottom)
        } else {
            //            view.addConstraint(keyRight)
        }
        view.addConstraint(keyWidth)
        
        view.addConstraint(valWidth)
        view.addConstraint(valTop)
        view.addConstraint(valRight)
        view.addConstraint(valBottom)
        
        holder.addConstraint(viewX)
        holder.addConstraint(viewWidth)
        holder.addConstraint(viewTop)
//        if mGravity == "down" {
//            if prevBotConstraint != nil {
//                prevBotConstraint.active = false
//            }
//            holder.addConstraint(viewBottom)
//            prevBotConstraint = viewBottom
//        }
        if prevBotConstraint != nil {
            prevBotConstraint.active = false
        }
        if mGravity == "down" {
            viewBottom = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -20)
        }
        holder.addConstraint(viewBottom)
        prevBotConstraint = viewBottom
        
        views.append(view)
        holder.updateConstraintsIfNeeded()
        holder.layoutIfNeeded()
    }
    
    func addTextField() {
//        let view = UITextField()
//        view.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).CGColor
//        view.layer.borderWidth = 1
//        view.layer.cornerRadius = 0
//        view.textAlignment = NSTextAlignment.Center
//        view.backgroundColor = UIColor.whiteColor()
//        view.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
////        view.contentInset = UIEdgeInsetsMake(10, 0, 10, 0)
//        view.font = UIFont(name: "XFINITYSans-BoldCond", size: 24)
//        view.secureTextEntry = true
//        
//        holder.addSubview(view)
//        
//        view.translatesAutoresizingMaskIntoConstraints = false
//        var viewTop = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 15)
//        let viewX = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
//        let viewWidth = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Width, multiplier: 0.70, constant: 0)
//        let viewHeight = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 50)
//        let viewBottom = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -50)
//        
//        if views.count > 0 {
//            let prevView = views[views.count-1]
//            viewTop = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: prevView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 15)
//            prevBotConstraint.active = false
//        }
//        
//        holder.addConstraint(viewTop)
//        holder.addConstraint(viewX)
//        holder.addConstraint(viewWidth)
//        holder.addConstraint(viewHeight)
//        holder.addConstraint(viewBottom)
//        prevBotConstraint = viewBottom
//        views.append(view)
    }
    
    func addButton(value: [String: AnyObject], key: String, colorScheme: String, icon: String) {
        var viewHeightConst: CGFloat = 50
        let view = SRSButton()
        view.colorScheme = colorScheme
        let attributedString = NSMutableAttributedString(string: key.uppercaseString)
        attributedString.addAttribute(NSKernAttributeName, value: 1, range: NSMakeRange(0, key.uppercaseString.characters.count))
        
        if colorScheme == "dark" {
            view.backgroundColor = SRSColor.buttonDarkBg
            attributedString.addAttribute(NSForegroundColorAttributeName, value: SRSColor.buttonDarkText, range: NSMakeRange(0, key.uppercaseString.characters.count))
        } else if colorScheme == "light" {
            view.backgroundColor = SRSColor.buttonLightBg
            attributedString.addAttribute(NSForegroundColorAttributeName, value: SRSColor.buttonLightText, range: NSMakeRange(0, key.uppercaseString.characters.count))
            view.layer.borderColor = SRSColor.buttonNormalBg.CGColor
            view.layer.borderWidth = 1
        } else {
            view.backgroundColor = SRSColor.buttonNormalBg
            attributedString.addAttribute(NSForegroundColorAttributeName, value: SRSColor.buttonNormalText, range: NSMakeRange(0, key.uppercaseString.characters.count))
        }
        
        if let type = value["type"] as? String {
            if type == "_N/A_" {
                view.layer.borderWidth = 0
                view.backgroundColor = SRSColor.buttonDisabledBg
                attributedString.addAttribute(NSForegroundColorAttributeName, value: SRSColor.buttonDisabledText, range: NSMakeRange(0, key.uppercaseString.characters.count))
            }
        }
        
        view.clipsToBounds = true
        view.setAttributedTitle(attributedString, forState: .Normal)
        
        view.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        view.titleLabel?.textAlignment = .Center
//        view.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        view.titleLabel?.font = UIFont(name: "XFINITYSans-BoldCond", size: 13)
        
        if icon != "" {
            let frameworkBundle = NSBundle(forClass: SRSContent.self)
            let buttonImage = UIImage(named: icon, inBundle: frameworkBundle, compatibleWithTraitCollection: nil)
            view.setImage(buttonImage, forState: .Normal)

            viewHeightConst = 80
        }
        
        view.addTarget(self, action: #selector(SRSContent.buttonHighlight(_:)), forControlEvents: UIControlEvents.TouchDown)
        view.addTarget(self, action: #selector(SRSContent.buttonPress(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.key = value
        view.label = key
        
        holder.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        var viewTop = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 20)
        let viewX = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let viewWidth = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Width, multiplier: 0.80, constant: 0)
        let viewHeight = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: viewHeightConst)
        var viewBottom = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: holder, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -50)
        
        if views.count > 0 {
            let prevView = views[views.count-1]
            
            if let prevButton = prevView as? SRSButton {
                viewTop = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: prevView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 2)
            } else {
                viewTop = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: prevView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 20)
            }
//            prevBotConstraint.active = false
        }
        
        print(viewHeightConst)
        holder.addConstraint(viewTop)
        holder.addConstraint(viewX)
        holder.addConstraint(viewWidth)
        holder.addConstraint(viewHeight)
        if prevBotConstraint != nil {
            prevBotConstraint.active = false
        }
        if mGravity == "down" {
            viewBottom = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -30)
        }
        holder.addConstraint(viewBottom)
        prevBotConstraint = viewBottom
        views.append(view)
    }
    
    override func layoutSubviews() {
        for view in views {
            if let button = view as? SRSButton {
                let index = views.indexOf(button)
                if (self.isFirstButton(index!) && self.isLastButton(index!)) || button.colorScheme != "normal" {
                    view.layer.cornerRadius = 4
                } else if self.isFirstButton(index!) {
                    let bPath = UIBezierPath(roundedRect: button.bounds, byRoundingCorners: [.TopLeft, .TopRight], cornerRadii: CGSizeMake(4, 4))
                    let rLayer = CAShapeLayer()
                    rLayer.path = bPath.CGPath
                    view.layer.mask = rLayer
                } else if self.isLastButton(index!) {
                    let bPath = UIBezierPath(roundedRect: button.bounds, byRoundingCorners: [.BottomLeft, .BottomRight], cornerRadii: CGSizeMake(4, 4))
                    let rLayer = CAShapeLayer()
                    rLayer.path = bPath.CGPath
                    view.layer.mask = rLayer
                }
            }
        }
        super.layoutSubviews()
    }
    
    func isFirstButton(index: Int) -> Bool {
        if index == 0 {
            return true
        } else if let prevButton = views[index-1] as? SRSButton {
            if prevButton.colorScheme == "normal" {
                return false
            }
        }
        
        return true
    }
    
    func isLastButton(index: Int) -> Bool {
        if index == views.count - 1 {
            return true
        } else if let nextButton = views[index + 1] as? SRSButton {
            if nextButton.colorScheme == "normal" {
                return false
            }
        }
        
        return true
    }
    
    func buttonHighlight(sender: SRSButton!) {
        if let type = sender.key["type"] as? String {
            if type != "_N/A_" {
                sender.backgroundColor = UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 0.2)
            }
        }
    }
    
    func buttonPress(sender: SRSButton!) {
        print("BUTTON OPRESS")
        
        if let type = sender.key["type"] as? String {
            if type == "AID" {
                if let classification = sender.key["content"] as? String {
                    print("AID:", classification)
                    SRS.conn.requestByClassification(classification)
                    
                    SRS.conn.dataRequest(classification)
                }
            } else if type == "LINK" {
                if self.parent == nil {
                    return
                }
                if let content = sender.key["content"] as? [String: AnyObject] {
                    parent.colapse()
                    NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(SRSContent.processDeepLink(_:)), userInfo: content, repeats: false)
                    
                    do {
                        let jsonData = try NSJSONSerialization.dataWithJSONObject(content, options: [])
                        SRS.conn.dataRequest(String(data: jsonData, encoding: NSUTF8StringEncoding)!)
                    } catch let error as NSError {
                        SRS.conn.handleRequestError(error)
                    }
                }
            } else if type == "_N/A_" {
                let disabledString = "COMING SOON"
                let disabledAttributedString = NSMutableAttributedString(string: disabledString.uppercaseString)
                disabledAttributedString.addAttribute(NSKernAttributeName, value: 1, range: NSMakeRange(0, disabledString.uppercaseString.characters.count))
                disabledAttributedString.addAttribute(NSForegroundColorAttributeName, value: SRSColor.valueRed, range: NSMakeRange(0, disabledString.uppercaseString.characters.count))
                sender.setAttributedTitle(disabledAttributedString, forState: .Normal)
                
                NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(SRSContent.resetDisabledButton(_:)), userInfo: sender, repeats: false)
            }
        }
    }
    
    func resetDisabledButton(sender: NSTimer) {
        if let button = sender.userInfo as? SRSButton {
            let title = button.label
            let attributedString = NSMutableAttributedString(string: title.uppercaseString)
            attributedString.addAttribute(NSKernAttributeName, value: 1, range: NSMakeRange(0, title.uppercaseString.characters.count))
            attributedString.addAttribute(NSForegroundColorAttributeName, value: SRSColor.buttonDisabledText, range: NSMakeRange(0, title.uppercaseString.characters.count))
            button.setAttributedTitle(attributedString, forState: .Normal)
        }
    }
    
    func processDeepLink(sender: NSTimer) {
        SRS.processDeepLink(sender.userInfo as! [String: AnyObject])
    }
    
    func addLabel(value: String) {
        let view = UILabel()
        let attributedKey = NSMutableAttributedString(string: value)
        attributedKey.addAttribute(NSKernAttributeName, value: 1, range: NSMakeRange(0, value.uppercaseString.characters.count))
        view.attributedText = attributedKey
        view.textAlignment = NSTextAlignment.Center
        view.textColor = SRSColor.label
        view.font = UIFont(name: "XFINITYSans-Reg", size: 13)
        view.numberOfLines = 0
        
        holder.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        var viewTop = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 20)
        let viewX = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let viewWidth = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Width, multiplier: 0.80, constant: 0)
        let viewHeight = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 50)
        var viewBottom = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -20)
        
        if views.count > 0 {
            let prevView = views[views.count-1]
            
            if let isImage = prevView as? UIImageView {
                viewTop = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: prevView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 10)
            } else {
                viewTop = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: prevView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 20)
            }
//            prevBotConstraint.active = false
        }
        
        holder.addConstraint(viewTop)
        holder.addConstraint(viewX)
        holder.addConstraint(viewWidth)
//        holder.addConstraint(viewHeight)
//        if mGravity == "down" {
//            if prevBotConstraint != nil {
//                prevBotConstraint.active = false
//            }
//            holder.addConstraint(viewBottom)
//            prevBotConstraint = viewBottom
//        }
        if prevBotConstraint != nil {
            prevBotConstraint.active = false
        }
        if mGravity == "down" {
            viewBottom = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -20)
        }
        holder.addConstraint(viewBottom)
        prevBotConstraint = viewBottom
        views.append(view)
    }
    
    func addIcon(value: String) {
        let view = UIImageView()
//        view.backgroundColor = UIColor.redColor()
        let frameworkBundle = NSBundle(forClass: SRSContent.self)
        view.image = UIImage(named: value, inBundle: frameworkBundle, compatibleWithTraitCollection: nil)
        
        holder.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        var viewTop = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 20)
        let viewX = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let viewWidth = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        let viewHeight = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 20)
        var viewBottom = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -20)
        
        if views.count > 0 {
            let prevView = views[views.count-1]
            viewTop = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: prevView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 20)
//            prevBotConstraint.active = false
        }
        
        holder.addConstraint(viewTop)
        holder.addConstraint(viewX)
//        holder.addConstraint(viewWidth)
//        holder.addConstraint(viewHeight)
//        if mGravity == "down" {
//            if prevBotConstraint != nil {
//                prevBotConstraint.active = false
//            }
//            holder.addConstraint(viewBottom)
//            prevBotConstraint = viewBottom
//        }
        if prevBotConstraint != nil {
            prevBotConstraint.active = false
        }
        if mGravity == "down" {
            viewBottom = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -20)
        }
        holder.addConstraint(viewBottom)
        prevBotConstraint = viewBottom
        views.append(view)
        print("addedICON")
    }
    
    func addFiller() {
        let view = UIView()
        holder.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        var viewTop = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        let viewX = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let viewWidth = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        let viewHeight = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 1)
        let viewBottom = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        
        if views.count > 0 {
            let prevView = views[views.count-1]
            viewTop = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: prevView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
//            prevBotConstraint.active = false
        }
        
        holder.addConstraint(viewTop)
        holder.addConstraint(viewX)
        holder.addConstraint(viewWidth)
        holder.addConstraint(viewHeight)
//        if mGravity == "down" {
//            if prevBotConstraint != nil {
//                prevBotConstraint.active = false
//            }
//            holder.addConstraint(viewBottom)
//            prevBotConstraint = viewBottom
//        }
        if prevBotConstraint != nil {
            prevBotConstraint.active = false
        }
        holder.addConstraint(viewBottom)
        prevBotConstraint = viewBottom
        views.append(view)
        print("addedFiller")
    }
    
    func addPin() {
//        let view = SRSPinView()
//        holder.addSubview(view)
//        
//        view.translatesAutoresizingMaskIntoConstraints = false
//        var viewTop = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 20)
//        let viewX = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
//        let viewWidth = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Width, multiplier: 0.70, constant: 0)
//        let viewHeight = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 50)
//        let viewBottom = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -20)
//        
//        if views.count > 0 {
//            let prevView = views[views.count-1]
//            viewTop = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: prevView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 20)
//            prevBotConstraint.active = false
//        }
//        
//        holder.addConstraint(viewTop)
//        holder.addConstraint(viewX)
//        holder.addConstraint(viewWidth)
//        //        holder.addConstraint(viewHeight)
//        holder.addConstraint(viewBottom)
//        prevBotConstraint = viewBottom
//        views.append(view)
    }
    
    func addSeparator(orientation: String) {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        
        holder.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        var viewTop = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 20)
        var viewX = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        var viewWidth = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Width, multiplier: 0.80, constant: 0)
        let viewHeight = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 1)
        var viewBottom = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: holder, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -20)
        
        if orientation != "vertical" && views.count > 0 {
            let prevView = views[views.count-1]
            viewTop = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: prevView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 20)
//            prevBotConstraint.active = false
        }
        
        if orientation == "vertical" {
            let prevView = views[views.count-1]
            viewTop = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: prevView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
            viewX = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: prevView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
            viewWidth = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 1)
//            viewHeight = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 1)
            viewBottom = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: prevView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
            
//            if views.count > 0 {
//                viewTop = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: prevView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 20)
//                prevBotConstraint.active = false
//            }
        }
        
        holder.addConstraint(viewTop)
        holder.addConstraint(viewX)
        holder.addConstraint(viewWidth)
        if orientation != "vertical" {
            holder.addConstraint(viewHeight)
        }
//        holder.addConstraint(viewBottom)

        if orientation != "vertical" {
//            if mGravity == "down" {
//                if prevBotConstraint != nil {
//                    prevBotConstraint.active = false
//                }
//                holder.addConstraint(viewBottom)
//                prevBotConstraint = viewBottom
//            }
//            prevBotConstraint = viewBottom
            if prevBotConstraint != nil {
                prevBotConstraint.active = false
            }
            holder.addConstraint(viewBottom)
            prevBotConstraint = viewBottom
        }
        views.append(view)
    }
}
