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
    
    let loadingView = GlowingBallsLoadingView()
    
    // MARK: Properties Layout
    
    let contentInset = UIEdgeInsets(top: 3, left: 16, bottom: 3, right: 16)
    
    // MARK: Init
    
    func commonInit() {
        selectionStyle = .none
        accessibilityLabel = ASAPPLocalizedString("Agent is typing")
        
        backgroundColor = UIColor.clear
        
        bubbleView.fillColor = ASAPP.styles.colors.replyMessageBackground
        bubbleView.strokeColor = ASAPP.styles.colors.replyMessageBorder
        bubbleView.strokeLineWidth = 1
        bubbleView.roundedCorners = [.topLeft, .topRight, .bottomRight]
        bubbleView.clipsToBounds = true
        contentView.addSubview(bubbleView)
        
        loadingView.tintColor = ASAPP.styles.colors.replyMessageText
        bubbleView.addSubview(loadingView)
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
        super.layoutSubviews()
        
        let loadingSize = loadingView.sizeThatFits(CGSize.zero)
        let bubbleLeft = contentInset.left
        
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
        
        loadingView.stopAnimating()
    }
    
    // MARK: Instance Methods
    
    func startAnimating() {
        loadingView.startAnimating()
    }
    
    func stopAnimating() {
        loadingView.stopAnimating()
    }
}
