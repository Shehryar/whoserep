//
//  SRS.swift
//  XfinityMyAccount
//
//  Created by Vicky Sehrawat on 3/13/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

public class SRS: UIView {
    static var tutorial: SRSTutorial!
    static var srsCircle: SRSCircle!
    static var prompt: SRSPrompt!
    static var input: SRSInput!
    static var content: SRSContent!
    static var conn: SRSConn!
    static var instance: SRS!
    var isExpanded: Bool!
    var isDragEnabled = false
    var didAddBubble = false
    
    var originalFrame: CGRect!
    
    var parentController: UIViewController!

    public typealias CallbackHandler = ((deepLink: String, data:[String: AnyObject]) -> Void)
    public typealias ContextProvider = (() -> [String: AnyObject])
    public typealias AuthProvider = (() -> [String: AnyObject])
    var callbackHandler: CallbackHandler!
    var contextProvider: ContextProvider!
    var authProvider: AuthProvider!
    var mContext: [String: AnyObject]!
    var mAuth: AuthMacaroon!
    
    public struct AuthMacaroon {
        let token: String
        let issuedTime: NSDate
        let expiresAfter: NSTimeInterval
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        originalFrame = frame
        self.mAuth = AuthMacaroon(token: "", issuedTime: NSDate(), expiresAfter: 0)
        SRS.instance = self
        loadFonts()
    }
    
    convenience init() {
        self.init(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width - 70,20,60,60))
    }
    
    convenience public init(origin: CGPoint, authProvider:AuthProvider, contextProvider:ContextProvider, callback: CallbackHandler) {
        self.init(frame: CGRectMake(origin.x,origin.y,60,60))
        self.registerAuthProvider(authProvider)
        self.registerContextProvider(contextProvider)
        self.registerCallback(callback)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func registerCallback(callback: CallbackHandler) {
        self.callbackHandler = callback
        self.callbackHandler(deepLink: "registered", data: [String: AnyObject]())
    }
    
    func registerContextProvider(contextProvider: ContextProvider) {
        self.contextProvider = contextProvider
    }
    
    func registerAuthProvider(authProvider: AuthProvider) {
        self.authProvider = authProvider
    }
    
    static func getAuth(maxTries: Int) -> String {
        if (SRS.instance == nil) {
            return ""
        }
        if (!SRS.isAuthValid(SRS.instance.mAuth)) {
            SRS.instance.requestAuth(maxTries, remainingTries: maxTries)
        }
        return SRS.instance.mAuth.token
    }
    
    static func isAuthValid(auth: AuthMacaroon) -> Bool {
//        if (SRS.instance.mAuth == nil) {
//            return false
//        }
        if (auth.token == "") {
            return false
        }
        if (NSDate().compare(NSDate(timeInterval: auth.expiresAfter, sinceDate: auth.issuedTime)) == NSComparisonResult.OrderedDescending) {
            return false
        }
        return true
    }
    
    func requestAuth(maxTries: Int, remainingTries: Int) {
        if (self.authProvider == nil) {
            self.mAuth = AuthMacaroon(token: "", issuedTime: NSDate(), expiresAfter: 0)
            return
        }
        
        let authDict = self.authProvider()
        if let token = authDict["access_token"] as? String {
            if let expiresAfter = authDict["expires_in"] as? NSTimeInterval {
                if let issuedTime = authDict["issued_time"] as? NSDate {
                    self.mAuth = AuthMacaroon(token: token, issuedTime: issuedTime, expiresAfter: expiresAfter)
                } else {
                    self.mAuth = AuthMacaroon(token: token, issuedTime: NSDate(), expiresAfter: expiresAfter)
                }
            } else {
                self.mAuth = AuthMacaroon(token: token, issuedTime: NSDate(), expiresAfter: 0)
            }
        } else {
            self.mAuth = AuthMacaroon(token: "", issuedTime: NSDate(), expiresAfter: 0)
        }
        
        if !SRS.isAuthValid(self.mAuth) {
            if remainingTries - 1 >= 0 {
                sleep(UInt32(pow(Double(2), Double(maxTries - remainingTries))))
                if !SRS.isAuthValid(self.mAuth) {
                    self.requestAuth(maxTries, remainingTries: remainingTries - 1)
                }
            }
        }
    }
    
    static func getContext() -> [String: AnyObject] {
        if (SRS.instance == nil) {
            return [String:AnyObject]()
        }
        return SRS.instance.mContext
    }
    func requestContext() {
        if (self.contextProvider == nil) {
            self.mContext = [String:AnyObject]()
            return
        }
        self.mContext = self.contextProvider()
    }
    
    static func processDeepLink(deepLink: [String: AnyObject]) {
        print("process deeplink")
        if self.instance == nil {
            return
        }
        
        if let deepLinkTag = deepLink["deepLink"] as? String {
            if let deepLinkData = deepLink["deepLinkData"] as? [String: AnyObject] {
                self.instance.callbackHandler(deepLink: deepLinkTag, data: deepLinkData)
            }
        }
    }
    
    public static func viewDidAppear(animated: Bool) {
        if SRS.instance == nil || SRS.instance.didAddBubble == true {
            return
        }
        SRS.instance.setup()
        SRS.instance.isExpanded = false
        SRS.instance.didAddBubble = true
    }
    
    public static func viewWillDisappear(animated: Bool) {
        if SRS.instance == nil || SRS.instance.didAddBubble == false {
            return
        }
        SRS.instance.removeFromSuperview()
        SRS.instance.didAddBubble = false
    }
    
    static func sendToHostForProcessing(deepLink: String, data: [String: AnyObject]) {
        if SRS.instance == nil {
            return
        }
        if SRS.instance.callbackHandler == nil {
            return
        }
        
        SRS.instance.callbackHandler(deepLink: deepLink, data:data)
    }
    
    func setup() {
        self.subviews.forEach({$0.removeFromSuperview()})
        SRS.conn = SRSConn()
        SRS.srsCircle = SRSCircle(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.addSubview(SRS.srsCircle)
        UIApplication.sharedApplication().keyWindow?.addSubview(self)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: "dragger:")
        self.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "expand:")
        self.addGestureRecognizer(tapGesture)
    }
    
    func expand(sender: UITapGestureRecognizer) {
        if (isExpanded == true) {
            return
        }
        self.isExpanded = true
//        if self.mAuth == nil || !SRS.isAuthValid(self.mAuth) {
//            self.requestAuth()
//        }
        self.requestContext()
        SRS.srsCircle.frame = self.frame
        self.frame = CGRect(x: UIScreen.mainScreen().bounds.origin.x, y: UIScreen.mainScreen().bounds.origin.y, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
        SRS.srsCircle.expandSRS { 
            self.setupPrompt("HOW CAN WE HELP?")
            self.setupInput()
            self.setupContent()
//            self.setupTutorialIfNeeded()
            SRS.conn.openRequest()
        }
    }
    
    func colapse() {
        if (isExpanded == false) {
            return
        }
        SRS.input.input.resignFirstResponder()
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            SRS.content.alpha = 0.0
            }, completion: nil)
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            SRS.content.resetData()
            SRS.input.alpha = 0.0
            }, completion: nil)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            SRS.prompt.alpha = 0.0
            }) { (isComplete) -> Void in
                self.frame = self.originalFrame
                SRS.srsCircle.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
                SRS.srsCircle.colapseSRS()
        }
//        setupPrompt("HOW CAN WE HELP?")
//        setupInput()
//        setupContent()
//        SRS.srsCircle.colapseSRS()
        isExpanded = false
        SRS.conn.dataRequest("SRS_close")
    }
    
    var previousLocation: CGPoint!
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.previousLocation = self.center
    }
    
    func dragger(panGesture: UIPanGestureRecognizer) {
        if (self.isExpanded == true || !self.isDragEnabled) {
            return
        }
        let translation = panGesture.translationInView(self.superview)
        self.center = CGPointMake(self.previousLocation.x + translation.x, self.previousLocation.y + translation.y)
        if (panGesture.state == UIGestureRecognizerState.Ended) {
            let left = self.center.x
            let right = (self.superview?.frame.size.width)! - self.center.x
            let top = self.center.y
            let bottom = (self.superview?.frame.size.height)! - self.center.y
            let offset = (self.frame.size.height / 2) + 10
            
            var newPosition = self.center
            if left < right && left < top && left < bottom {
                newPosition.x = offset
            } else if right < left && right < top && right < bottom {
                newPosition.x = (self.superview?.frame.size.width)! - offset
            } else if top < left && top < right && top < bottom {
                newPosition.y = offset
            } else {
                newPosition.y = (self.superview?.frame.size.height)! - offset
            }
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
                self.layoutIfNeeded()
                self.center = newPosition
                }, completion: nil)
            self.originalFrame = self.frame
        }
    }
    
    func setupTutorialIfNeeded() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let didCloseTutorial = defaults.boolForKey("ASAPP_SRS_didCloseTutorial") as? Bool {
            if didCloseTutorial == true {
                return
            }
        }
        SRS.tutorial = SRSTutorial()
        self.addSubview(SRS.tutorial)
        
        SRS.tutorial.translatesAutoresizingMaskIntoConstraints = false
        let tutorialTop = NSLayoutConstraint(item: SRS.tutorial, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        let tutorialRight = NSLayoutConstraint(item: SRS.tutorial, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
        let tutorialBottom = NSLayoutConstraint(item: SRS.tutorial, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        let tutorialLeft = NSLayoutConstraint(item: SRS.tutorial, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
        
        self.addConstraint(tutorialTop)
        self.addConstraint(tutorialRight)
        self.addConstraint(tutorialBottom)
        self.addConstraint(tutorialLeft)
        
        defaults.setValue(true, forKey: "ASAPP_SRS_didCloseTutorial")
        defaults.synchronize()
    }
    
    func setupPrompt(text: String) {
        SRS.prompt = SRSPrompt()
        SRS.prompt.setPromptText(text)
        self.addSubview(SRS.prompt)
        self.bringSubviewToFront(SRS.prompt)
        NSLog("ADDED PROMPT")
        
//        let tapRecognizer = UITapGestureRecognizer(target: self, action: "dismissSRS:")
//        SRS.prompt.addGestureRecognizer(tapRecognizer)
        
        SRS.prompt.translatesAutoresizingMaskIntoConstraints = false
        let verticalDistance = NSLayoutConstraint(item: SRS.prompt, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        let xPosition = NSLayoutConstraint(item: SRS.prompt, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let widthContraint = NSLayoutConstraint(item: SRS.prompt, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        let heightContraint = NSLayoutConstraint(item: SRS.prompt, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 80)

        self.addConstraint(verticalDistance)
        self.addConstraint(widthContraint)
        self.addConstraint(heightContraint)
        self.addConstraint(xPosition)
    }
    
//    func dismissSRS(sender: UITapGestureRecognizer) {
//        self.colapse()
//    }
    
    func setupInput() {
        SRS.input = SRSInput()
        self.addSubview(SRS.input)
        self.bringSubviewToFront(SRS.input)
        
        SRS.input.translatesAutoresizingMaskIntoConstraints = false
        let verticalDistance = NSLayoutConstraint(item: SRS.input, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: SRS.prompt, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        let xPosition = NSLayoutConstraint(item: SRS.input, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let widthContraint = NSLayoutConstraint(item: SRS.input, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        
        self.addConstraint(verticalDistance)
        self.addConstraint(widthContraint)
        self.addConstraint(xPosition)
    }
    
    static var cheightContraint: NSLayoutConstraint!
    func setupContent() {
        SRS.content = SRSContent()
        SRS.content.parent = self
        self.addSubview(SRS.content)
        self.bringSubviewToFront(SRS.content)
        
        SRS.content.translatesAutoresizingMaskIntoConstraints = false
        let cverticalDistance = NSLayoutConstraint(item: SRS.content, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: SRS.input, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        let cxPosition = NSLayoutConstraint(item: SRS.content, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        let cwidthContraint = NSLayoutConstraint(item: SRS.content, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        SRS.cheightContraint = NSLayoutConstraint(item: SRS.content, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: UIScreen.mainScreen().bounds.size.height - (80 + SRS.input.getHeight() + 32))
        
        self.addConstraint(cverticalDistance)
        self.addConstraint(cwidthContraint)
        self.addConstraint(SRS.cheightContraint)
        self.addConstraint(cxPosition)
    }
    
    // HACK: Temporary fix to update content height
    static func updateContentheight() {
        if cheightContraint == nil {
            return
        }
        cheightContraint.constant = UIScreen.mainScreen().bounds.size.height - (80 + SRS.input.getHeight() + 32)
    }

}
