//
//  SpeechToTextViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 5/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//


/**
 // Required Info.plist keys
 
 <key>NSMicrophoneUsageDescription</key>  <string>Your microphone will be used to record your speech when you press the &quot;Start Recording&quot; button.</string>
 
 <key>NSSpeechRecognitionUsageDescription</key>  <string>Speech recognition will be used to determine which words you speak into this device&apos;s microphone.</string>
 */


import UIKit
import Speech

@available(iOS 10.0, *)
class SpeechToTextViewController: BaseViewController {
    
    fileprivate let audioEngine = AVAudioEngine()
    
    fileprivate let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    fileprivate var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    fileprivate var recognitionTask: SFSpeechRecognitionTask?
    
    fileprivate let defaultListeningText = "Listening...."
    
    var currentSpeechText: String? {
        didSet {
            outputLabel.text = currentSpeechText
            updateFrames()
        }
    }
    
    // MARK: Styling
    
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
        
        /**
         UI
         */
        
        label.text = "Output:"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor.gray
        
        outputLabel.font = UIFont.systemFont(ofSize: 16)
        outputLabel.numberOfLines = 0
        outputLabel.lineBreakMode = .byWordWrapping
        outputLabel.textColor = UIColor.darkGray
        
        button.text = "Speak"
        button.bounds = CGRect(x: 0, y: 0, width: 60, height: 60)
        button.textAlignment = .center
        button.font = UIFont.boldSystemFont(ofSize: 12)
        button.textColor = UIColor.white
        button.backgroundColor = buttonColor
        button.isUserInteractionEnabled = true
        button.layer.shouldRasterize = true
        button.layer.allowsEdgeAntialiasing = true
        button.layer.rasterizationScale = UIScreen.main.scale
        
        let gesture = UILongPressGestureRecognizer(target: self,
                                                   action: #selector(SpeechToTextViewController.handleLongPress(_:)))
        gesture.minimumPressDuration = 0.01
        button.addGestureRecognizer(gesture)
        
        activityIndicator.hidesWhenStopped = true
        button.addSubview(activityIndicator)
        
        /**
         Speech
         */
        
        speechRecognizer?.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        speechRecognizer?.delegate = nil
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
    
    
    // MARK:- Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateFrames()
    }
    
    func updateFrames() {
        let inset = UIEdgeInsets(top: 32.0, left: 24.0, bottom: 32.0, right: 24.0)
        var top = inset.top
        if let navBar = navigationController?.navigationBar {
            top = navBar.frame.maxY + inset.top
        }
        
        let buttonSize: CGFloat = button.bounds.height
        let buttonCtrY = view.bounds.height - inset.bottom - buttonSize / 2.0
        let buttonCtrX = floor(view.bounds.width / 2.0)
        button.center = CGPoint(x: buttonCtrX, y: buttonCtrY)
        button.layer.cornerRadius = buttonSize / 2.0
        button.layer.masksToBounds = true
        activityIndicator.sizeToFit()
        activityIndicator.center = CGPoint(x: button.bounds.midX, y: button.bounds.midY)
        
        let contentWidth = view.bounds.width - inset.left - inset.right
        let labelHeight = ceil(label.sizeThatFits(CGSize(width: contentWidth, height: 0)).height)
        label.frame = CGRect(x: inset.left, y: top, width: contentWidth, height: labelHeight)
        
        let outputLabelTop = label.frame.maxY + 16.0
        let outputLabelHeight = ceil(outputLabel.sizeThatFits(CGSize(width: contentWidth, height: 0)).height)
        outputLabel.frame = CGRect(x: inset.left, y: outputLabelTop, width: contentWidth, height: outputLabelHeight)
    }
}

// MARK:- Gesture

@available(iOS 10.0, *)
extension SpeechToTextViewController {
    
    func handleLongPress(_ gesture: UILongPressGestureRecognizer?) {
        guard let gesture = gesture else {
            return
        }
        
        switch gesture.state {
        case .began:
            setIsSpeaking(true, animated: true)
            beginListening()
            break
            
        case .cancelled, .failed, .ended:
            setIsSpeaking(false, animated: true)
            stopListening()
            break
            
        case .changed, .possible:
            // No-op
            break
        }
    }
}

// MARK:- Speech

@available(iOS 10.0, *)
extension SpeechToTextViewController {
    
    func beginListening() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                DemoDispatcher.performOnMainThread {
                    self.outputLabel.text = result?.bestTranscription.formattedString
                }
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        outputLabel.text = defaultListeningText
    }
    
    func stopListening() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        }
        
        if outputLabel.text == defaultListeningText {
            outputLabel.text = nil
        }
    }
    
    func setIsSpeaking(_ isSpeaking: Bool, animated: Bool) {
        
        let transform = isSpeaking ? CGAffineTransform(scaleX: 2.0, y: 2.0) : CGAffineTransform.identity
        let bgColor = isSpeaking
            ? UIColor(red:0.153, green:0.259, blue:0.620, alpha:1.000)
            : UIColor(red:0.333, green:0.439, blue:0.890, alpha:1.000)
        
        button.layer.removeAllAnimations()
        
        if animated {
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0,
                           options: .beginFromCurrentState,
                           animations: { [weak self] in
                            self?.button.transform = transform
                            self?.button.backgroundColor = bgColor
            }) { (completed) in }
        } else {
            button.transform = transform
            button.backgroundColor = bgColor
        }
    }
}

// MARK:- SFSpeechRecognizerDelegate

@available(iOS 10.0, *)
extension SpeechToTextViewController: SFSpeechRecognizerDelegate {
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        print("Speech recognizer availability change: \(available ? "AVAILABLE" : "UNAVAILABLE")")
    }
    
}
