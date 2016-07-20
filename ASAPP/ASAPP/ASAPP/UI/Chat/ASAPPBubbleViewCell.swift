//
//  ASAPPBubbleViewCell.swift
//  ASAPP
//
//  Created by Vicky Sehrawat on 6/17/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ASAPPBubbleViewCell: UITableViewCell {

    var stateDataSource: ASAPPStateDataSource!
    
    var holder: UIView!
    var bubble: ASAPPBubbleView!
    var textMessageLabel: UILabel!
    
    let BUBBLE_OFFSET: CGFloat = 2
    let BUBBLE_PADDING: CGFloat = 16
    let HOLDER_PADDING: CGFloat = 16
    let HOLDER_PADDING_VERTICAL: CGFloat = 8
    
    var bubbleWidth: CGFloat = 0
    var bubbleHeight: CGFloat = 0
    var holderHeight: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    convenience init(style: UITableViewCellStyle, reuseIdentifier: String?, stateDataSource: ASAPPStateDataSource) {
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.stateDataSource = stateDataSource
        
        textMessageLabel = UILabel()
        setupLabel(textMessageLabel)
        
        bubble = ASAPPBubbleView()
        if self.reuseIdentifier == ASAPPChatTableView.CELL_IDENT_MSG_SEND {
            bubble.isMyEvent = true
        } else {
            bubble.isMyEvent = false
        }
        bubble.render(reuseIdentifier!)
        
        holder = UIView()
        
        bubble.addSubview(textMessageLabel)
        holder.addSubview(bubble)
        self.contentView.addSubview(holder)
        
        bubbleWidth = BUBBLE_PADDING * 2
        bubbleHeight = BUBBLE_PADDING * 2
        holderHeight = bubbleHeight
        
        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupLabel(label: UILabel) {
        label.font = UIFont(name: "Lato-Regular", size: 16)
        label.textColor = UIColor(red: 57/255, green: 61/255, blue: 71/255, alpha: 0.6)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = false
    }
    
    func setEvent(event: Event, isNew: Bool) {
        if event.isMessageEvent {
            if event.eventType == .TextMessage {
                if let payload = event.payload() as? EventPayload.TextMessage {
                    textMessageLabel.text = payload.Text
                }
            }
            
            drawBubble(event)
        }
        
        holder.snp_updateConstraints { (make) in
            make.height.equalTo(holderHeight).priorityMedium()
        }
        
        bubble.snp_updateConstraints { (make) in
            make.width.equalTo(bubbleWidth)
            make.height.equalTo(bubbleHeight)
        }
    }
    
    func drawBubble(event: Event) {
        if !stateDataSource.isMyEvent(event) {
            if !stateDataSource.isCustomer() && event.isCustomerEvent {
                textMessageLabel.textColor = UIColor.whiteColor()
            }
        }
        
        // Calculate bounds based on screen size and not the contentView.
        // NOTE: Why 100?
        var borderRect = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width - 100, CGFloat.max)
        
        if event.eventType == .TextMessage {
            let tempLabel = UILabel()
            setupLabel(tempLabel)
            
            if let payload = event.payload() as? EventPayload.TextMessage {
                tempLabel.text = payload.Text
            }
            
            let size = tempLabel.sizeThatFits(CGSize(width: borderRect.size.width - ((BUBBLE_PADDING * 2) + (HOLDER_PADDING * 2)), height: borderRect.height))
            bubbleWidth = max(size.width + (HOLDER_PADDING * 2), BUBBLE_PADDING * 2)
            bubbleHeight = max(size.height + (HOLDER_PADDING_VERTICAL * 2), BUBBLE_PADDING * 2)
            holderHeight = bubbleHeight
            borderRect.size.width = bubbleWidth
            borderRect.size.height = bubbleHeight
        }
        
    }
    
    override func updateConstraints() {
        holder.snp_updateConstraints { (make) in
            make.top.equalTo(self.contentView.snp_top)
            make.bottom.equalTo(self.contentView.snp_bottom).offset(-BUBBLE_OFFSET)
            make.width.equalTo(self.contentView.snp_width)
        }
        
        bubble.snp_updateConstraints { (make) in
            make.bottom.equalTo(holder.snp_bottom)
            make.width.equalTo(bubbleWidth)
            make.height.equalTo(bubbleHeight)
            
            if self.reuseIdentifier != nil {
                if self.reuseIdentifier == ASAPPChatTableView.CELL_IDENT_MSG_SEND {
                    make.leading.greaterThanOrEqualTo(self.contentView.snp_leading).offset(BUBBLE_PADDING).priorityMedium()
                    make.trailing.equalTo(self.contentView.snp_trailing).offset(-BUBBLE_PADDING).priorityMedium()
                } else {
                    make.leading.equalTo(self.contentView.snp_leading).offset(BUBBLE_PADDING).priorityMedium()
                    make.trailing.lessThanOrEqualTo(self.contentView.snp_trailing).offset(-BUBBLE_PADDING).priorityMedium()
                }
            }
        }
        
        textMessageLabel.snp_updateConstraints { (make) in
            make.top.equalTo(bubble.snp_top).offset(HOLDER_PADDING_VERTICAL)
            make.leading.equalTo(bubble.snp_leading).offset(HOLDER_PADDING)
            make.trailing.equalTo(bubble.snp_trailing).offset(-HOLDER_PADDING)
            make.bottom.equalTo(bubble.snp_bottom).offset(-HOLDER_PADDING_VERTICAL)
        }
        
        super.updateConstraints()
    }
    
    func animate() {
        let origBubbleWidth = self.bubbleWidth
        let origBubbleHeight = self.bubbleHeight
        
        self.bubbleWidth = HOLDER_PADDING * 2
        self.bubbleHeight = HOLDER_PADDING_VERTICAL * 2
        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
        self.layoutIfNeeded()
        
        self.bubbleWidth = origBubbleWidth
        self.bubbleHeight = origBubbleHeight
        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
        
        UIView.animateWithDuration(0.5) {
            self.layoutIfNeeded()
        }
    }

}
