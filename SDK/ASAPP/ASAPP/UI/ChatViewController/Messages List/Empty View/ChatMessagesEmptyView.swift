//
//  ChatMessagesEmptyView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/9/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatMessagesEmptyView: UIView {
    
    // MARK: Private Properties
    
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
    // MARK: Init
    
    func commonInit() {
        backgroundColor = .clear
        
        spinner.startAnimating()
        addSubview(spinner)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        spinner.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
    }
}
