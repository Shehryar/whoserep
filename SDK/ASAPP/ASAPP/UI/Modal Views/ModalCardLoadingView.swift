//
//  ModalCardLoadingView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/22/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ModalCardLoadingView: UIView {

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                spinner.startAnimating()
            } else {
                spinner.stopAnimating()
            }
        }
    }
    
    var isBlurred: Bool = false {
        didSet {
            guard isBlurred != oldValue else {
                return
            }
            
            if isBlurred {
                let blurEffect = UIBlurEffect(style: .light)
                blurView.effect = blurEffect
                vibrancyView.effect = UIVibrancyEffect(blurEffect: blurEffect)
            } else {
                blurView.effect = nil
                vibrancyView.effect = nil
            }
        }
    }
    
    let blurView = UIVisualEffectView(effect: nil)
    let vibrancyView = UIVisualEffectView(effect: nil)
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    // MARK: Initialization
    
    func commonInit() {
        addSubview(blurView)
        
        blurView.contentView.addSubview(vibrancyView)
        
        spinner.hidesWhenStopped = true
        vibrancyView.contentView.addSubview(spinner)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK:- Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        
        blurView.frame = bounds
        vibrancyView.frame = blurView.bounds
        spinner.center = CGPoint(x: vibrancyView.bounds.midX, y: vibrancyView.bounds.midY)
    }
}
