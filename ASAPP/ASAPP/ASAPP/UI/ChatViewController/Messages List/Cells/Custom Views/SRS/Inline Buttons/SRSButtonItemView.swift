//
//  SRSButtonItemView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SRSButtonItemView: UIButton {

    var buttonItem: SRSButtonItem? {
        didSet {
            updateDisplay()
        }
    }
    
    var onTap: (() -> Void)?

    private let borderTop = UIView()
    private let borderStrokeWidth: CGFloat = 1.0
    
    // MARK: Initialization
    
    func commonInit() {
        contentEdgeInsets = UIEdgeInsets(top: 20, left: 24, bottom: 20, right: 24)
        
        titleLabel?.numberOfLines = 0
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.textAlignment = .center
        
        addSubview(borderTop)
        
        addTarget(self, action: #selector(SRSButtonItemView.didTap), for: .touchUpInside)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: Display
    
    func updateDisplay() {
        borderTop.backgroundColor = ASAPP.styles.separatorColor1
        
        setBackgroundImage(UIImage.imageWithColor(UIColor.white), for: .normal)
        setBackgroundImage(UIImage.imageWithColor(UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)), for: .highlighted)
        
        setTitleColor(ASAPP.styles.foregroundColor1, for: .normal)
        setTitleColor(ASAPP.styles.foregroundColor1, for: .highlighted)
        
        setAttributedText(buttonItem?.title.uppercased(),
                          textStyle: .srsButton,
                          color: UIColor(red:0.310, green:0.357, blue:0.463, alpha:1.000),
                          styles: ASAPP.styles,
                          state: .normal)
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        borderTop.frame = CGRect(x: 0, y: 0, width: bounds.width, height: borderStrokeWidth)
    }
    
    // MARK: Actions
    
    func didTap() {
        onTap?()
    }
}
