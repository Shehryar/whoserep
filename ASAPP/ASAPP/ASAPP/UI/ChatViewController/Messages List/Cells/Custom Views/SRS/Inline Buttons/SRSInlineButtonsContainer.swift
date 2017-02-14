//
//  SRSInlineButtonsContainer.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SRSInlineButtonsContainer: UIView, ASAPPStyleable {

    var buttonItems: [SRSButtonItem]? {
        didSet {
            
        }
    }
    
    // MARK: Initialization
    
    func commonInit() {
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK:- ASAPPStyleable
    
    fileprivate(set) var styles = ASAPPStyles()
    
    func applyStyles(_ styles: ASAPPStyles) {
        self.styles = styles
        
        setNeedsLayout()
    }

    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let height: CGFloat = 0
        return CGSize(width: size.width, height: height)
    }
}

extension SRSInlineButtonsContainer: StackableView {
    func prefersFullWidthDisplay() -> Bool {
        return true
    }
    
    func sticksToEdges() -> Bool {
        return true
    }
}
