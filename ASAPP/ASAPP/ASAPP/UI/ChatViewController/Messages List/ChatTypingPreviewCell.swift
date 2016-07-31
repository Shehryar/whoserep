//
//  ChatTypingPreviewCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/31/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatTypingPreviewCell: ChatBubbleCell {
    
    var previewText: String? {
        didSet {
            previewLabel.text = previewText
        }
    }
    
    private let textInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    
    private let previewLabel = UILabel()
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        ignoresReplyBubbleStyling = true
        isReply = true
        bubbleStyling = .Default
        
        bubbleView.bubbleFillColor = Colors.bluishGray()
        bubbleView.bubbleStrokeColor = nil
        
        previewLabel.numberOfLines = 0
        previewLabel.font = Fonts.latoRegularFont(withSize: 16)
        previewLabel.textColor = Colors.whiteColor()
        bubbleView.addSubview(previewLabel)
        
        setNeedsUpdateConstraints()
    }
    
    // MARK: Layout
    
    override func updateConstraints() {
        
        bubbleView.snp_updateConstraints { (make) in
            make.height.equalTo(previewLabel.snp_height).offset(textInset.top + textInset.bottom)
            make.width.equalTo(previewLabel.snp_width).offset(textInset.left + textInset.right)
        }
        
        previewLabel.snp_updateConstraints { (make) in
            make.left.equalTo(bubbleView.snp_left).offset(textInset.left)
            make.top.equalTo(bubbleView.snp_top).offset(textInset.top)
            make.width.lessThanOrEqualTo(bubbleView.snp_width).offset(-(textInset.left + textInset.right))
        }
        
        super.updateConstraints()
    }
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        previewLabel.text = nil
    }
}
