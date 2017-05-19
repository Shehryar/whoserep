//
//  SpeechToTextViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 5/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit
import Speech

class SpeechToTextViewController: BaseViewController {

    let buttonColor = UIColor(red:0.333, green:0.439, blue:0.890, alpha:1.000)
    
    let buttonHighlightedColor = UIColor(red:0.253, green:0.359, blue:0.720, alpha:1.000)
    
    let buttonDisabledColor = UIColor(red:0.85, green:0.87, blue:0.890, alpha:1.000)
    
    // MARK: Subviews
    
    let label = UILabel()
    
    let outputLabel = UILabel()
    
    let button = UILabel()
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    // MARK:- Initialization
    
    required init(appSettings: AppSettings) {
        super.init(appSettings: appSettings)
        
        label.text = "Output:"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor.gray
        
        outputLabel.font = UIFont.systemFont(ofSize: 16)
        outputLabel.numberOfLines = 0
        outputLabel.lineBreakMode = .byWordWrapping
        outputLabel.textColor = UIColor.darkGray
        
        button.text = "Speak"
        button.textAlignment = .center
        button.font = UIFont.boldSystemFont(ofSize: 12)
        button.textColor = UIColor.white
        button.backgroundColor = buttonColor
        button.isUserInteractionEnabled = true
        
        let gesture = UILongPressGestureRecognizer(target: self,
                                                   action: #selector(SpeechToTextViewController.handleLongPress(_:)))
        gesture.minimumPressDuration = 0.01
        button.addGestureRecognizer(gesture)
        
        
        activityIndicator.hidesWhenStopped = true
        button.addSubview(activityIndicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- View
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(label)
        view.addSubview(outputLabel)
        view.addSubview(button)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Authorization
        
        if #available(iOS 10.0, *) {
            SFSpeechRecognizer.requestAuthorization { (status) in
                OperationQueue.main.addOperation {
                    switch status {
                    case .authorized:
                        print("Speech: Authorized")
                        break
                        
                    case .denied:
                        print("Speech: Denied")
                        break
                        
                    case .notDetermined:
                        print("Speech: Not Determined")
                        break
                        
                    case .restricted:
                        print("Speech: Restricted")
                        break
                    }
                }
            }
        }
    }
    
    
    // MARK:- Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let inset = UIEdgeInsets(top: 32.0, left: 24.0, bottom: 32.0, right: 24.0)
        var top = inset.top
        if let navBar = navigationController?.navigationBar {
            top = navBar.frame.maxY + inset.top
        }
        
        let buttonSize: CGFloat = 64
        let buttonTop = view.bounds.height - inset.bottom - buttonSize
        let buttonLeft = floor((view.bounds.width - buttonSize) / 2.0)
        button.frame = CGRect(x: buttonLeft, y: buttonTop, width: buttonSize, height: buttonSize)
        button.layer.cornerRadius = buttonSize / 2.0
        button.layer.masksToBounds = true
        activityIndicator.sizeToFit()
        activityIndicator.center = CGPoint(x: button.bounds.midX, y: button.bounds.midY)
        
        let contentWidth = view.bounds.width - inset.left - inset.right
        let labelHeight = ceil(label.sizeThatFits(CGSize(width: contentWidth, height: 0)).height)
        label.frame = CGRect(x: inset.left, y: top, width: contentWidth, height: labelHeight)
        
        let outputLabelTop = label.frame.maxY + 16.0
        let outputLabelHeight = button.frame.minY - 32.0 - outputLabelTop
        outputLabel.frame = CGRect(x: inset.left, y: outputLabelTop, width: contentWidth, height: outputLabelHeight)
    }
}

// MARK:- Gesture

extension SpeechToTextViewController {
    
    func handleLongPress(_ gesture: UILongPressGestureRecognizer?) {
        guard let gesture = gesture else {
            return
        }
        
        switch gesture.state {
        case .began:
            button.backgroundColor = buttonHighlightedColor
            break
            
        case .cancelled, .failed, .ended:
            button.backgroundColor = buttonColor
            break
            
        case .changed, .possible:
            // No-op
            break
        }
    }
}

// MARK:- Speech

extension SpeechToTextViewController {
    
    
    
}

// MARK:- SFSpeechRecognizerDelegate

extension SpeechToTextViewController: SFSpeechRecognizerDelegate {
    
    @available(iOS 10.0, *)
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        print("Speech recognizer availability change: \(available ? "AVAILABLE" : "UNAVAILABLE")")
    }
    
}
