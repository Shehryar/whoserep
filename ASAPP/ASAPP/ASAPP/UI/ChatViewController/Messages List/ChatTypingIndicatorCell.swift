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
        
        loadingView.tintColor = UIColor.whiteColor()
        bubbleView.addSubview(loadingView)
    }
    
    // MARK: Layout
    
    override func updateConstraints() {
        super.updateConstraints()
        
        bubbleView.snp_updateConstraints { (make) in
            make.width.equalTo(loadingView.snp_width)
            make.height.equalTo(loadingView.snp_height)
            
//            make.width.equalTo(600)
//            make.height.equalTo(40)
        }
        
        loadingView.snp_updateConstraints { (make) in
            make.left.equalTo(bubbleView.snp_left)
            make.top.equalTo(bubbleView.snp_top)
        }
        
        
    }
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        loadingView.endAnimating()
    }
}
