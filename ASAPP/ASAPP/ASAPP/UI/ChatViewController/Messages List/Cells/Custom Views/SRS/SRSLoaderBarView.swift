//
//  SRSLoaderBarView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/12/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSLoaderBarView: UIView, ASAPPStyleable {
    
    var loaderItem: SRSLoaderBarItem? {
        didSet {
            clearTimer()
            
            if loaderItem != nil {
                timer = Timer.scheduledTimer(timeInterval: 1,
                                             target: self,
                                             selector: #selector(SRSLoaderBarView.updateCurrentView),
                                             userInfo: nil,
                                             repeats: true)
            }
            updateCurrentView()
        }
    }
    
    fileprivate var timer: Timer?
    
    fileprivate let dateFormatter = DateFormatter()
    
    fileprivate let loaderView = UIImageView()
    
    fileprivate let finishedLabel = UILabel()
    
    fileprivate let loaderHeight: CGFloat = 20.0
    
    fileprivate let contentInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    
    // MARK: Initialization
    
    func commonInit() {
        loaderView.contentMode = .scaleToFill
        addSubview(loaderView)
        
        finishedLabel.textAlignment = .center
        finishedLabel.alpha = 0.0
        finishedLabel.numberOfLines = 0
        finishedLabel.lineBreakMode = .byTruncatingTail
        addSubview(finishedLabel)
        
        applyStyles(styles)
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
        clearTimer()
    }
    
    // MARK: ASAPPStyleable
    
    fileprivate(set) var styles = ASAPPStyles()
    
    func applyStyles(_ styles: ASAPPStyles) {
        self.styles = styles
        
        finishedLabel.textColor = styles.foregroundColor2
        finishedLabel.font = styles.font(for: .srsLabel)
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let top = floor((bounds.height - loaderHeight) / 2.0)
        let left = contentInset.left
        let width = bounds.width - contentInset.left - contentInset.right
        loaderView.frame = CGRect(x: left, y: top, width: width, height: loaderHeight)
        
        finishedLabel.frame = UIEdgeInsetsInsetRect(bounds, contentInset)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let labelWidth = size.width - contentInset.left - contentInset.right
        let labelHeight = ceil(finishedLabel.sizeThatFits(CGSize(width: labelWidth, height: 0)).height)
        let contentHeight = max(loaderHeight, labelHeight)
        
        return CGSize(width: size.width, height: contentHeight + contentInset.top + contentInset.bottom)
    }
    
    // MARK: Instance Methods
    
    func clearTimer() {
        if let timer = timer {
            if timer.isValid {
                timer.invalidate()
            }
        }
        timer = nil
    }
    
    func updateCurrentView() {
        guard let loaderItem = loaderItem else {
            finishedLabel.text = nil
            loaderView.alpha = 1
            if loaderView.image == nil {
                loaderView.image = Images.gifLoaderBar()
            }
            finishedLabel.alpha = 0
            clearTimer()
            return
        }
        
        if let finishedText = loaderItem.finishedText {
            finishedLabel.text = finishedText
            loaderView.alpha = 0
            loaderView.image = nil
            finishedLabel.alpha = 1
            clearTimer()
        } else {
            finishedLabel.text = nil
            loaderView.alpha = 1
            if loaderView.image == nil {
                loaderView.image = Images.gifLoaderBar()
            }
            finishedLabel.alpha = 0
        }
    }
}
