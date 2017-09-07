//
//  YesNoView.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 9/7/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class YesNoView: UIView {
    fileprivate(set) var choice: Bool?
    
    fileprivate let yesView = UIView()
    fileprivate let noView = UIView()
    
    // MARK: Initialization
    
    func commonInit() {
        addSubview(yesView)
        addSubview(noView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // Mark: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateFrames()
    }
}
