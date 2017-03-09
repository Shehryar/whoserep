//
//  ChatTypingIndicatorCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/29/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatTypingIndicatorCell: UITableViewCell {

    // MARK: Properties - UI
    
    let bubbleView = BubbleView()
    
    let loadingView = BouncingBallsLoadingView()
    
    // MARK: Properties Layout
    
    let contentInset = UIEdgeInsets(top: 3, left: 16, bottom: 3, right: 16)
    
    
    // MARK: Init
    
    func commonInit() {
        selectionStyle = .none
        
        bubbleView.fillColor = ASAPP.styles.replyMessageFillColor
        bubbleView.strokeColor = ASAPP.styles.replyMessageStrokeColor
        bubbleView.roundedCorners = [.topLeft, .topRight, .bottomRight]
        bubbleView.clipsToBounds = true
        contentView.addSubview(bubbleView)
        
        loadingView.tintColor = ASAPP.styles.replyMessageTextColor.withAlphaComponent(0.6)
        bubbleView.addSubview(loadingView)
        
        layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
        
    // MARK: Layout
    
    override func layoutSubviews() {
        let loadingSize = loadingView.sizeThatFits(CGSize.zero)
        var bubbleLeft = contentInset.left
      
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
