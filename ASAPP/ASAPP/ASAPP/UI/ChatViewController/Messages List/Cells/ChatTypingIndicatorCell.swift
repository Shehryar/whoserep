//
//  ChatTypingIndicatorCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/29/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatTypingIndicatorCell: ChatBubbleCell {

    let loadingView = BouncingBallsLoadingView()
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        loadingView.tintColor = UIColor.white
        bubbleView.addSubview(loadingView)
        
        bubbleView.clipsToBounds = true
        
        layoutSubviews()
    }
    
    // MARK: Styles
    
    override func updateFontsAndColors() {
        super.updateFontsAndColors()
        
        loadingView.tintColor = styles.replyMessageTextColor.withAlphaComponent(0.6)
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        let loadingSize = loadingView.sizeThatFits(CGSize.zero)
        var bubbleLeft = contentInset.left
        if !isReply {
            bubbleLeft = bounds.width - loadingSize.width - contentInset.right
        }
        bubbleView.frame = CGRect(x: bubbleLeft, y: contentInset.top, width: loadingSize.width, height: loadingSize.height)
        loadingView.frame = bubbleView.bounds
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let loadingSize = loadingView.sizeThatFits(size)
        
        return CGSize(width: loadingSize.width + contentInset.left + contentInset.right,
                      height: loadingSize.height + contentInset.top + contentInset.bottom)
    }
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        loadingView.endAnimating()
    }
}
