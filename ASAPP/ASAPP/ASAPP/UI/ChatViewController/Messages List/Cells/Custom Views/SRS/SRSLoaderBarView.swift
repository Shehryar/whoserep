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
            
            if let loaderItem = loaderItem {
                timer = NSTimer.scheduledTimerWithTimeInterval(1,
                                                               target: self,
                                                               selector: #selector(SRSLoaderBarView.updateCurrentView),
                                                               userInfo: nil,
                                                               repeats: true)
                
                updateCurrentView()
            }
        }
    }
    
    private var timer: NSTimer?
    
    private let dateFormatter = NSDateFormatter()
    
    private let loaderView = UIImageView()
    
    private let finishedLabel = UILabel()
    
    private let loaderHeight: CGFloat = 20.0
    
    private let contentInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    
    // MARK: Initialization
    
    func commonInit() {
        loaderView.backgroundColor = UIColor.redColor()
        loaderView.image = Images.gifLoaderBar()
        loaderView.contentMode = .ScaleToFill
        addSubview(loaderView)
        
        finishedLabel.textAlignment = .Center
        finishedLabel.alpha = 0.0
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
    
    private(set) var styles = ASAPPStyles()
    
    func applyStyles(styles: ASAPPStyles) {
        self.styles = styles
        
        finishedLabel.textColor = styles.foregroundColor2
        finishedLabel.font = styles.detailFont
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let top = floor((CGRectGetHeight(bounds) - loaderHeight) / 2.0)
        let left = contentInset.left
        let width = CGRectGetWidth(bounds) - contentInset.left - contentInset.right
        loaderView.frame = CGRect(x: left, y: top, width: width, height: loaderHeight)
        
        finishedLabel.frame = CGRect(x: left, y: 0, width: width, height: CGRectGetHeight(bounds))
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: loaderHeight + contentInset.top + contentInset.bottom)
    }
    
    // MARK: Instance Methods
    
    func clearTimer() {
        if let timer = timer {
            if timer.valid {
                timer.invalidate()
            }
        }
        timer = nil
    }
    
    func updateCurrentView() {
        guard let loaderItem = loaderItem,
            let finishedDate = loaderItem.loadingFinishedTime else {
            loaderView.alpha = 1
            finishedLabel.alpha = 0
            clearTimer()
            return
        }
        
        if finishedDate.hasPassed() {
            dateFormatter.dateFormat = finishedDate.dateFormatForMostRecent()
            let formatString = ASAPPLocalizedString("Restart completed: %@")
            finishedLabel.text = String(format: formatString, dateFormatter.stringFromDate(finishedDate))
            loaderView.alpha = 0
            finishedLabel.alpha = 1
            
            clearTimer()
        } else {
            finishedLabel.text = nil
            loaderView.alpha = 1
            finishedLabel.alpha = 0
        }
    }
}
