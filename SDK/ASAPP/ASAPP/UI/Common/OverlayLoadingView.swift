//
//  OverlayLoadingView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/19/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class OverlayLoadingView: UIView {

    fileprivate let loader = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    // MARK: Initialization
    
    func commonInit() {
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        loader.hidesWhenStopped = true
        addSubview(loader)
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
        
        loader.sizeToFit()
        loader.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
}

// MARK:- Public Interface

extension OverlayLoadingView {
    
    func setLoaderVisible(_ visible: Bool) {
        if visible {
            loader.startAnimating()
        } else {
            loader.stopAnimating()
        }
    }
}
