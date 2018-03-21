//
//  RestartButton.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 3/12/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

class RestartButton: Button {
    let defaultHeight: CGFloat = 54
    private var blurredBackground: UIVisualEffectView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        contentAlignment = .left
        contentView.backgroundColor = .clear
        
        let blur = UIBlurEffect(style: .light)
        blurredBackground = UIVisualEffectView(effect: blur)
        contentView.insertSubview(blurredBackground, at: 0)
        
        imageSize = CGSize(width: 18, height: 16.5)
        image = Images.getImage(.iconNewQuestion)
        
        title = ASAPP.strings.quickRepliesRestartButton
        accessibilityLabel = title
        
        font = ASAPP.styles.textStyles.body.font.withSize(14)
        setForegroundColor(ASAPP.styles.colors.textButtonPrimary.textNormal, forState: .normal)
        setForegroundColor(ASAPP.styles.colors.textButtonPrimary.textHighlighted, forState: .highlighted)
        
        imageTitleMargin = 8
        
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.layer.shadowColor = ASAPP.styles.colors.textButtonPrimary.textNormal.withAlphaComponent(0.05).cgColor
        label.layer.shadowOpacity = 1
        label.layer.shadowRadius = 3
        
        imageView.layer.shadowOffset = label.layer.shadowOffset
        imageView.layer.shadowColor = label.layer.shadowColor
        imageView.layer.shadowOpacity = label.layer.shadowOpacity
        imageView.layer.shadowRadius = label.layer.shadowRadius
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        blurredBackground.frame = contentView.bounds
    }
}
