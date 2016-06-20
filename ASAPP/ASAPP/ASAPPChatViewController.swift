//
//  ASAPPChatViewController.swift
//  ASAPP
//
//  Created by Vicky Sehrawat on 6/14/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ASAPPChatViewController: UIViewController, ASAPPKeyboardObserverDelegate {

    var chatView: ASAPPChatTableView!
    var input: ASAPPChatInputView!
    var keyboardObserver: ASAPPKeyboardObserver!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.whiteColor()
        renderInputView()
        renderChatView()
    }
    
    override func viewWillAppear(animated: Bool) {
        if keyboardObserver == nil {
            keyboardObserver = ASAPPKeyboardObserver()
            keyboardObserver.delegate = self
        }
        
        keyboardObserver.registerForNotifications()
        
        ASAPP.instance.state.on(.Event, observer: self) { (info) in
            ASAPPLog(info)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if keyboardObserver != nil {
            keyboardObserver.deregisterForNotification()
        }
        
        ASAPP.instance.state.off(.Event, observer: self)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        input.textView.resignFirstResponder()
    }
    
    // MARK: - ChatView
    
    func renderChatView() {
        chatView = ASAPPChatTableView()
        self.view.addSubview(chatView)
    }
    
    // MARK: - InputView
    
    func renderInputView() {
        input = ASAPPChatInputView()
        self.view.addSubview(input)
    }
    
    // MARK: - KeyboardObserver
    
    var KEYBOARD_OFFSET: CGFloat = 0
    
    func ASAPPKeyboardWillShow(size: CGRect, duration: NSTimeInterval) {
        KEYBOARD_OFFSET = size.height
        self.view.setNeedsUpdateConstraints()
        self.view.updateConstraintsIfNeeded()
        
        UIView.animateWithDuration(duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func ASAPPKeyboardWillHide(duration: NSTimeInterval) {
        KEYBOARD_OFFSET = 0
        self.view.setNeedsUpdateConstraints()
        self.view.updateConstraintsIfNeeded()
        
        UIView.animateWithDuration(duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func updateViewConstraints() {
        input.snp_updateConstraints { (make) in
            make.bottom.equalTo(self.view.snp_bottom).offset(-KEYBOARD_OFFSET)
            make.leading.equalTo(self.view.snp_leading)
            make.trailing.equalTo(self.view.snp_trailing)
        }
        
        chatView.snp_remakeConstraints { (make) in
            make.top.equalTo(self.view.snp_top)
            make.leading.equalTo(self.view.snp_leading)
            make.trailing.equalTo(self.view.snp_trailing)
            make.bottom.equalTo(input.snp_top)
        }
        
        super.updateViewConstraints()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
