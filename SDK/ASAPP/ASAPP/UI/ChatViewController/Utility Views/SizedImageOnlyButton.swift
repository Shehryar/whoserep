//
//  SizedImageOnlyButton.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/13/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SizedImageOnlyButton: UIButton {
    
    var imageSize: CGSize?
    
    init() {
        super.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(button: UIButton) {
        self.init(frame: button.frame)
        
        self.setBackgroundImage(button.backgroundImage(for: .normal), for: .normal)
        self.setBackgroundImage(button.backgroundImage(for: .highlighted), for: .highlighted)
        
        self.setAttributedTitle(button.attributedTitle(for: .normal), for: .normal)
        self.setAttributedTitle(button.attributedTitle(for: .highlighted), for: .highlighted)
        
        self.titleEdgeInsets = button.titleEdgeInsets
        
        for target in button.allTargets {
            let actions = button.actions(forTarget: target, forControlEvent: .touchUpInside)
            for action in actions ?? [] {
                self.addTarget(target, action: NSSelectorFromString(action), for: .touchUpInside)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let imageSize = imageSize {
            let top = contentEdgeInsets.top + imageEdgeInsets.top
            let left = contentEdgeInsets.left + imageEdgeInsets.left
            imageView?.frame = CGRect(x: left, y: top, width: imageSize.width, height: imageSize.height)
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let imageSize = imageSize else {
            return super.sizeThatFits(size)
        }
        
        let width = imageSize.width + imageEdgeInsets.left + imageEdgeInsets.right + contentEdgeInsets.left + contentEdgeInsets.right
        let height = imageSize.height + imageEdgeInsets.top + imageEdgeInsets.bottom + contentEdgeInsets.top + contentEdgeInsets.bottom
        return CGSize(width: width, height: height)
    }
    
}
