//
//  ASAPPNavBar.swift
//  ComcastTech
//
//  Created by Vicky Sehrawat on 5/23/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import SnapKit

class ASAPPNavBar: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    typealias ControllerHandler = ((oldController: UIViewController?, newController: UIViewController) -> Void)
    var controllerHandler: ControllerHandler!
    
    let imageButtonFixedWidth = 50
    
    var buttons: [ASAPPNavButton] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(controllerHandler: ControllerHandler) {
        self.init(frame: CGRectZero)
        self.controllerHandler = controllerHandler
        self.setup()
        print("done")
    }
    
    func setup() {
        self.backgroundColor = UIColor(red: 91/255, green: 101/255, blue: 126/255, alpha: 1)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRectMake(0, 20, 500, 50)
        
        let topColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0).CGColor
        let bottomColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3).CGColor
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.locations = [0.0, 1.0]
        self.layer.addSublayer(gradientLayer)
        
        self.addButton(.Image, value: "icon_chat-white.png", targetController: ChatViewController(), isDefault: false)
        self.addButton(.Text, value: "CHECK", targetController: ASAPPCheckController(), isDefault: true)
        self.addButton(.Text, value: "TIMELINE", targetController: ChatViewController(), isDefault: false)
        self.addButton(.Image, value: "icon_logout-white.png", targetController: ChatViewController(), isDefault: false)
    }
    
    func addButton(type: ASAPPNavButton.ASAPPButtonType, value: String, targetController: UIViewController, isDefault: Bool) {
        let button = ASAPPNavButton()
        self.buttons.append(button)
        button.type = type
        button.viewController = targetController
        if isDefault {
            button.selected = true
            self.onButtonEvent(button)
        }
        
        if button.type == .Text {
            button.setAttributedTitle(getAttributedString(value, forState: .Normal), forState: .Normal)
            button.setAttributedTitle(getAttributedString(value, forState: .Selected), forState: .Selected)
            button.titleLabel?.font = UIFont(name: "Lato-Black", size: 13.0)
        } else if button.type == .Image {
            let img = UIImage(named: value)
            let defaultImg = img?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            button.setImage(defaultImg, forState: .Normal)
            button.setImage(img, forState: .Selected)
            button.imageView?.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
            button.bringSubviewToFront(button.imageView!)
        }
        
        self.addSubview(button)
        self.setNeedsUpdateConstraints()
        
        button.addTarget(self, action: #selector(ASAPPNavBar.onButtonEvent(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func onButtonEvent(sender: ASAPPNavButton) {
        var prevSelectedButton: ASAPPNavButton!
        for button in buttons {
            if button.selected {
                prevSelectedButton = button
            }
            
            if sender === button {
                button.selected = true
            } else {
                button.selected = false
            }
            
            button.updateBackground()
        }
        
        var prevViewController: UIViewController? = nil
        if prevSelectedButton != nil {
            prevViewController = prevSelectedButton.viewController
        }
        self.controllerHandler(oldController: prevViewController, newController: sender.viewController)
    }
    
    func getAttributedString(text: String, forState: UIControlState) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSKernAttributeName, value: 1.5, range: NSMakeRange(0, text.characters.count))
        
        if forState == .Selected {
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, text.characters.count))
        } else {
            let unselectedColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
            attributedString.addAttribute(NSForegroundColorAttributeName, value: unselectedColor, range: NSMakeRange(0, text.characters.count))
        }
        
        return attributedString
    }
    
    override func updateConstraints() {
        var count = 0
        var prevTextButton: ASAPPNavButton = ASAPPNavButton()
        var foundTextButton = false
        
        for button in buttons {
            button.snp_remakeConstraints(closure: { (make) in
                make.top.equalTo(self.snp_top).offset(20)
                make.height.equalTo(50)
                
                if count == 0 {
                    make.leading.equalTo(self.snp_leading)
                } else {
                    make.leading.equalTo(buttons[count-1].snp_trailing).offset(1)
                }
                
                if button.type == .Image {
                    make.width.equalTo(imageButtonFixedWidth)
                } else {
//                    make.width.greaterThanOrEqualTo(imageButtonFixedWidth)
                    if foundTextButton {
                        make.width.equalTo(prevTextButton.snp_width).multipliedBy(1)
                    }
                }
                
                if count == buttons.count - 1 {
                    make.trailing.equalTo(self.snp_trailing)
                }
            })
            
            if button.type == .Text {
                prevTextButton = button
                foundTextButton = true
            }
            count += 1
            
            print("updated")
        }
        
        super.updateConstraints()
    }
    
//    func getChildViewControler() -> UIViewController {
//        
//    }

}
