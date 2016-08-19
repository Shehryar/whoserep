//
//  FrameTrackingInputAccessoryView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/19/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class FrameTrackingInputAccessoryView: UIView {

    var onFrameChange: ((updatedFrame: CGRect) -> Void)?
    
    private var didAddObserver = false
    
    // MARK: Initialization
    
    func commonInit() {
        userInteractionEnabled = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    deinit {
        if didAddObserver {
            superview?.removeObserver(self, forKeyPath: "frame")
            superview?.removeObserver(self, forKeyPath: "center")
        }
    }
    
    // MARK: View
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        if didAddObserver {
            superview?.removeObserver(self, forKeyPath: "frame")
            superview?.removeObserver(self, forKeyPath: "center")
        }
        
        newSuperview?.addObserver(self, forKeyPath: "frame", options: .New, context: nil)
        newSuperview?.addObserver(self, forKeyPath: "center", options: .New, context: nil)
        didAddObserver = true
        
        super.willMoveToSuperview(newSuperview)
    }
    
    // MARK: KVO 
    
    override func observeValueForKeyPath(keyPath: String?,
                                         ofObject object: AnyObject?,
                                                  change: [String : AnyObject]?,
                                                  context: UnsafeMutablePointer<Void>) {
        if let superviewFrame = superview?.frame {
            onFrameChange?(updatedFrame: superviewFrame)
        }
    }

    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let superviewFrame = superview?.frame {
            onFrameChange?(updatedFrame: superviewFrame)
        }
    }
}
